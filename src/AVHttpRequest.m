//
//  HttpRequest.m
//  objc-networking
//
//  Created by Rasmus Styrk on 20/06/13.
//  Copyright (c) 2013 Appværk. All rights reserved.
//

#import "AVHttpRequest.h"
#import "AVHttpResponse.h"

@interface AVHttpRequest () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property (nonatomic, assign, readwrite) HttpRequestState requestState;
@property (nonatomic, assign) NSURLConnection *connection;
@property (nonatomic, assign) NSTimeInterval startedTime;

@property (nonatomic, assign) long long int expectedTotalBytes;
@property (nonatomic, assign) long long int expectedRemainingBytes;
@property (nonatomic, assign) unsigned long long int downloadedBytes;

@end

@implementation AVHttpRequest

#pragma mark - Static factories

+ (AVHttpRequest*) requestWithURL:(NSURL *)url
{
	return [[self alloc] initWithURL:url];
}

+ (AVHttpRequest*) requestWithURLString:(NSString *)string
{
	return [[self alloc] initWithURLString:string];
}

#pragma mark - Initializes

- (id) init
{
	self = [super init];

	if(self)
	{
		self.requestResponse = [[AVHttpResponse alloc] init];

		self.requestArguments = [[NSMutableDictionary alloc] init];
		self.requestHeaders = [[NSMutableDictionary alloc] init];

		self.requestMethod = HttpRequestMethodPost;
		self.requestState = HttpRequestStateUnknown;
		self.requestType = HttpRequestTypeAsync;

		self.connection = nil;
	}

	return self;
}

- (id) initWithURL:(NSURL*)url
{
	self = [self init];

	if(self)
	{
		self.requestUrl = url;
	}

	return self;
}

- (id) initWithURLString:(NSString*)string
{
	return [self initWithURL:[NSURL URLWithString:string]];
}

#pragma mark - Start, pause and cancel

- (void) start
{
	if(self.requestUrl == nil)
		return;

	if(self.requestState != HttpRequestStateDownloading)
	{
		self.requestState = HttpRequestStateDownloading;

		if([self.delegate respondsToSelector:@selector(didStartRequest:)])
		{
			[self.delegate didStartRequest:self];
		}
		
		switch (self.requestType) {
			case HttpRequestTypeSync:
				[self downloadSynchronous];
				break;

			case HttpRequestTypeAsync:
			default:
				[self downloadAsynchronous];
				break;
		}
	}
}

- (void) downloadAsynchronous
{
	self.connection = [NSURLConnection connectionWithRequest:[self buildURLRequest] delegate:self];
}

- (void) downloadSynchronous
{
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:[self buildURLRequest] returningResponse:&response error:&error];

	if(error != nil)
	{
		if([self.delegate respondsToSelector:@selector(didFailRequest:withError:)])
		{
			[self.delegate didFailRequest:self withError:error];
		}
	}
	else
	{
		self.requestResponse.responseCode = ((NSHTTPURLResponse*)response).statusCode;
		self.requestResponse.data = data;

		if([self.delegate respondsToSelector:@selector(didFinishRequest:withResponse:)])
		{
			[self.delegate didFinishRequest:self withResponse:self.requestResponse];
		}
	}
}

- (void) pause
{
	if(self.requestState != HttpRequestStatePaused)
	{
		[self.connection cancel];
		self.requestState = HttpRequestStatePaused;
		self.downloadedBytes = 0;

		if([self.delegate respondsToSelector:@selector(didPauseRequest:)])
		{
			[self.delegate didPauseRequest:self];
		}
	}
}

- (void) cancel
{
	if(self.requestState != HttpRequestStateCancelled)
	{
		[self.connection cancel];
		self.requestState = HttpRequestStateCancelled;
		self.downloadedBytes = 0;
		self.expectedRemainingBytes = 0;
		self.expectedTotalBytes = 0;

		if([self.delegate respondsToSelector:@selector(didStopRequest:)])
		{
			[self.delegate didStopRequest:self];
		}
	}
}

#pragma mark - URL Request

- (NSURLRequest *) buildURLRequest
{
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:self.requestUrl];

	[urlRequest setValue:@"Objc-Networking /1.0" forHTTPHeaderField:@"User-Agent"];

	switch (self.requestMethod) {
		case HttpRequestMethodGet:
			[urlRequest setHTTPMethod:@"GET"];
			break;
		case HttpRequestMethodPut:
			[urlRequest setHTTPMethod:@"PUT"];
			break;
		case HttpRequestMethodDelete:
			[urlRequest setHTTPMethod:@"DELETE"];
			break;
			
		default:
		case HttpRequestMethodPost:
		{
			NSData *args = [[self buildArgs] dataUsingEncoding:NSUTF8StringEncoding];

			[urlRequest setValue:[NSString stringWithFormat:@"%i", args.length] forHTTPHeaderField:@"Content-Length"];
			[urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
			[urlRequest setHTTPMethod:@"POST"];
			[urlRequest setHTTPBody:args];
			break;
		}
	}

	if(self.requestResponse.data.length > 0)
	{
		[urlRequest setValue:[NSString stringWithFormat:@"bytes=%llu-", self.requestResponse.data.length] forHTTPHeaderField:@"Range"];
	}

	[self.requestHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
		[urlRequest setValue:key forHTTPHeaderField:value];
	}];

	return urlRequest;
}

- (NSString *) buildArgs
{
	NSMutableString *args = [[NSMutableString alloc] init];

	[self.requestArguments enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
		[args appendFormat:@"%@=%@&", [self escapeString:key], [self escapeString:value]];
	}];

	return args;
}

#pragma mark - NSURLConnection delegates

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if(self.expectedTotalBytes == 0)
	{
		self.expectedTotalBytes = response.expectedContentLength;
	}
	
	self.expectedRemainingBytes = response.expectedContentLength;
	self.requestResponse.responseCode = ((NSHTTPURLResponse*)response).statusCode;
	self.startedTime = [[NSDate date] timeIntervalSince1970];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if(self.requestState == HttpRequestStateDownloading)
	{
		[self.requestResponse.data appendData:data];

		self.downloadedBytes += data.length;

		if([self.delegate respondsToSelector:@selector(estimatedTimeLeft:forRequest:)])
		{
			[self.delegate estimatedTimeLeft:[self expectedRemainingTime] forRequest:self];
		}
	}
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	self.requestState = HttpRequestStateFailed;

	if([self.delegate respondsToSelector:@selector(didFailRequest:withError:)])
	{
		[self.delegate didFailRequest:self withError:error];
	}
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	self.requestState = HttpRequestStateCompleted;
	
	if([self.delegate respondsToSelector:@selector(didFinishRequest:withResponse:)])
	{
		[self.delegate didFinishRequest:self withResponse:self.requestResponse];
	}
}

#pragma mark - Other helpers

- (NSString *) escapeString:(NSString*)string
{
	CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(NULL,
																	(CFStringRef)string,
																	NULL,
																	(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
																	kCFStringEncodingUTF8 );
    return (__bridge NSString *)urlString;
}

- (NSTimeInterval) expectedRemainingTime
{
	NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
	NSTimeInterval elapsedTime = currentTime - self.startedTime;

	double remainingBytes = self.expectedRemainingBytes - self.downloadedBytes;

	if(self.downloadedBytes > 0)
	{
		double currentDownloadSpeed = (double)elapsedTime/self.downloadedBytes;
		return remainingBytes*currentDownloadSpeed;
	}

	return 0;
}

@end
