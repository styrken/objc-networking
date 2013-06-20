//
//  HttpRequest.h
//  objc-networking
//
//  Created by Rasmus Styrk on 20/06/13.
//  Copyright (c) 2013 Appværk. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HttpResponse;
@class HttpRequest;

@protocol HttpRequestProtocol <NSObject>
- (void) didStartRequest:(HttpRequest*)request;
- (void) didStopRequest:(HttpRequest*)request;
- (void) didPauseRequest:(HttpRequest*)request;
- (void) estimatedTimeLeft:(long long int)seconds forRequest:(HttpRequest*)request;
@end

enum {
	HttpRequestTypePost,
	HttpRequestTypeGet,
	HttpRequestTypePut,
	HttpRequestTypeDelete
};
typedef NSUInteger HttpRequestType;

enum {
	HttpRequestStateUnknown,
	HttpRequestStateDownloading,
	HttpRequestStatePaused,
	HttpRequestStateCancelled,
	HttpRequestStateCompleted
};
typedef NSUInteger HttpRequestState;

@interface HttpRequest : NSObject

@property (nonatomic, strong) NSMutableDictionary *requestParameters;
@property (nonatomic, strong) NSMutableDictionary *requestHeaders;

@property (nonatomic, weak) id<HttpRequestProtocol> delegate;

@property (nonatomic, assign) HttpRequestType requestType;
@property (nonatomic, assign, readonly) HttpRequestState requestState;

@property (nonatomic, strong) HttpResponse *requestResponse;

- (void) start;
- (void) pause;
- (void) cancel;

@end
