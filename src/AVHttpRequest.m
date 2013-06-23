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
@property (nonatomic, assign, readwrite) AVHttpRequestState state;
@property (nonatomic, strong, readwrite) NSMutableDictionary *arguments;
@property (nonatomic, strong, readwrite) NSMutableDictionary *headers;
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
		self.response = [[AVHttpResponse alloc] init];

		self.arguments = [[NSMutableDictionary alloc] init];
		self.headers = [[NSMutableDictionary alloc] init];

		self.method = AVHttpRequestMethodPost;
		self.state = AVHttpRequestStateUnknown;
		self.type = AVHttpRequestTypeAsync;

		self.connection = nil;
	}

	return self;
}

- (id) initWithURL:(NSURL*)url
{
	self = [self init];

	if(self)
	{
		self.url = url;
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
	if(self.url == nil)
		return;

	if(self.state != AVHttpRequestStateDownloading)
	{
		self.state = AVHttpRequestStateDownloading;

		if([self.delegate respondsToSelector:@selector(didStartRequest:)])
		{
			[self.delegate didStartRequest:self];
		}
		
		switch (self.type) {
			case AVHttpRequestTypeSync:
				[self downloadSynchronous];
				break;

			case AVHttpRequestTypeAsync:
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
		self.response.statusCode = ((NSHTTPURLResponse*)response).statusCode;
		self.response.data = data;

		if([self.delegate respondsToSelector:@selector(didFinishRequest:withResponse:)])
		{
            [self.delegate didFinishRequest:self withResponse:self.response];
		}
	}
}

- (void) pause
{
	if(self.state != AVHttpRequestStatePaused)
	{
		[self.connection cancel];
		self.state = AVHttpRequestStatePaused;
		self.downloadedBytes = 0;

		if([self.delegate respondsToSelector:@selector(didPauseRequest:)])
		{
			[self.delegate didPauseRequest:self];
		}
	}
}

- (void) cancel
{
	if(self.state != AVHttpRequestStateCancelled)
	{
		[self.connection cancel];
		self.state = AVHttpRequestStateCancelled;
		self.downloadedBytes = 0;
		self.expectedRemainingBytes = 0;
		self.expectedTotalBytes = 0;
        self.response.data = nil;
        self.response.statusCode = -1;

		if([self.delegate respondsToSelector:@selector(didStopRequest:)])
		{
			[self.delegate didStopRequest:self];
		}
	}
}

#pragma mark - URL Request

- (NSURLRequest *) buildURLRequest
{
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:self.url];

	[urlRequest setValue:@"Objc-Networking /1.0" forHTTPHeaderField:@"User-Agent"];

	switch (self.method) {
		case AVHttpRequestMethodGet:
			[urlRequest setHTTPMethod:@"GET"];
			break;
		case AVHttpRequestMethodPut:
			[urlRequest setHTTPMethod:@"PUT"];
			break;
		case AVHttpRequestMethodDelete:
			[urlRequest setHTTPMethod:@"DELETE"];
			break;
			
		default:
		case AVHttpRequestMethodPost:
		{
			NSData *args = [[self buildArgs] dataUsingEncoding:NSUTF8StringEncoding];

			[urlRequest setValue:[NSString stringWithFormat:@"%li", (unsigned long)args.length] forHTTPHeaderField:@"Content-Length"];
			[urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
			[urlRequest setHTTPMethod:@"POST"];
			[urlRequest setHTTPBody:args];
			break;
		}
	}

	if(self.response.data.length > 0)
	{
		[urlRequest setValue:[NSString stringWithFormat:@"bytes=%lu-", (unsigned long)self.response.data.length] forHTTPHeaderField:@"Range"];
	}

	[self.headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [urlRequest setValue:key forHTTPHeaderField:value];
    }];

	return urlRequest;
}

- (NSString *) buildArgs
{
	NSMutableString *args = [[NSMutableString alloc] init];

	[self.arguments enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [args appendFormat:@"%@=%@&", [self escapeString:key], [self escapeString:value]];
    }];

	return args;
}

#pragma mark - NSURLConnection delegates

- (void) connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0)
    {
        [[challenge sender] useCredential:self.credentials forAuthenticationChallenge:challenge];
    }
    else
    {
        if([self.delegate respondsToSelector:@selector(didFailRequest:withError:)])
        {
            [self.delegate didFailRequest:self withError:challenge.error];
        }
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if(self.expectedTotalBytes == 0)
	{
		self.expectedTotalBytes = response.expectedContentLength;
	}
	
	self.expectedRemainingBytes = response.expectedContentLength;
	self.response.statusCode = ((NSHTTPURLResponse*)response).statusCode;
	self.startedTime = [[NSDate date] timeIntervalSince1970];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if(self.state == AVHttpRequestStateDownloading)
	{
		[self.response.data appendData:data];

		self.downloadedBytes += data.length;

		if([self.delegate respondsToSelector:@selector(estimatedTimeLeft:forRequest:)])
		{
			[self.delegate estimatedTimeLeft:[self expectedRemainingTime] forRequest:self];
		}
	}
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	self.state = AVHttpRequestStateFailed;

	if([self.delegate respondsToSelector:@selector(didFailRequest:withError:)])
	{
		[self.delegate didFailRequest:self withError:error];
	}
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	self.state = AVHttpRequestStateCompleted;
	
	if([self.delegate respondsToSelector:@selector(didFinishRequest:withResponse:)])
	{
        [self.delegate didFinishRequest:self withResponse:self.response];
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
