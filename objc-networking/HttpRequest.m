//
//  HttpRequest.m
//  objc-networking
//
//  Created by Rasmus Styrk on 20/06/13.
//  Copyright (c) 2013 Appværk. All rights reserved.
//

#import "HttpRequest.h"
#import "HttpResponse.h"

@interface HttpRequest ()
@property (nonatomic, assign, readwrite) HttpRequestState requestState;
@end

@implementation HttpRequest

- (id) init
{
	self = [super init];

	if(self)
	{
		self.requestResponse = [[HttpResponse alloc] init];

		self.requestParameters = [[NSMutableDictionary alloc] init];
		self.requestHeaders = [[NSMutableDictionary alloc] init];

		self.requestType = HttpRequestTypePost;
		self.requestState = HttpRequestStateUnknown;
	}

	return self;
}

@end
