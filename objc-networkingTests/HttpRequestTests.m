//
//  HttpRequestTests.m
//  objc-networking
//
//  Created by Rasmus Styrk on 21/06/13.
//  Copyright (c) 2013 Appværk. All rights reserved.
//

#import "HttpRequestTests.h"
#import "HttpRequest.h"
#import "HttpResponse.h"

@interface HttpRequestTests () <HttpRequestProtocol>
@end

@implementation HttpRequestTests

- (void) testRequestPauseStates
{
	HttpRequest *request = [[HttpRequest alloc] init];
	[request pause];
	STAssertTrue(request.requestState == HttpRequestStatePaused, @"RequestState did not change to paused");
}

- (void) TestRequestStateCancelled
{
	HttpRequest *request = [[HttpRequest alloc] init];
	[request cancel];
	STAssertTrue(request.requestState == HttpRequestStateCancelled, @"RequestState did not change to cancelled");
}

- (void) testDefaultRequest
{
	HttpRequest *request = [[HttpRequest alloc] init];

	STAssertTrue(request.requestState == HttpRequestStateUnknown, @"RequestState was not nil");
	STAssertTrue(request.requestMethod == HttpRequestMethodPost, @"RequestMethod was not POST");
}

- (void) testDownloadOfFileSynchronous
{
	// This is not a real unittest but i wan't to test whole flow so i wont be mocking anything in this
	// test, sorry :-)

	HttpRequest *request = [HttpRequest requestWithURLString:@"http://lorempixel.com/400/200/"];
	request.requestMethod = HttpRequestMethodGet;
	request.requestType = HttpRequestTypeSync;

	// Blocking
	[request start];

	STAssertTrue(request.requestResponse.data.length > 0, @"ResponseData lenght was not greater than zero");
}

@end

