//
//  HttpRequestTests.m
//  objc-networking
//
//  Created by Rasmus Styrk on 21/06/13.
//  Copyright (c) 2013 Appværk. All rights reserved.
//

#import "HttpRequestTests.h"
#import "AVHttpRequest.h"
#import "AVHttpResponse.h"

@interface HttpRequestTests ()
@end

@implementation HttpRequestTests

- (void) testRequestPauseStates
{
	AVHttpRequest *request = [[AVHttpRequest alloc] init];
	[request pause];
	STAssertTrue(request.state == AVHttpRequestStatePaused, @"RequestState did not change to paused");
}

- (void) TestRequestStateCancelled
{
	AVHttpRequest *request = [[AVHttpRequest alloc] init];
	[request cancel];
	STAssertTrue(request.state == AVHttpRequestStateCancelled, @"RequestState did not change to cancelled");
}

- (void) testDefaultRequest
{
	AVHttpRequest *request = [[AVHttpRequest alloc] init];

	STAssertTrue(request.state == AVHttpRequestStateUnknown, @"RequestState was not nil");
	STAssertTrue(request.method == AVHttpRequestMethodPost, @"RequestMethod was not POST");
}

- (void) testDownloadOfFileSynchronous
{
	// This is not a real unittest but i wan't to test whole flow so i wont be mocking anything in this
	// test, sorry :-)

	AVHttpRequest *request = [AVHttpRequest requestWithURLString:@"http://lorempixel.com/400/200/"];
	request.method = AVHttpRequestMethodGet;
	request.type = AVHttpRequestTypeSync;

	// Blocking
	[request start];

	STAssertTrue(request.response.data.length > 0, @"ResponseData lenght was not greater than zero");
}

@end

