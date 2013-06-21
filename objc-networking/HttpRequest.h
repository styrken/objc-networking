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

/** Http Request Protocol
 A protocol you can implement to get notifications about a request
*/
@protocol HttpRequestProtocol <NSObject>
- (void) didStartRequest:(HttpRequest*)request;
- (void) didStopRequest:(HttpRequest*)request;
- (void) didPauseRequest:(HttpRequest*)request;
- (void) estimatedTimeLeft:(long long int)seconds forRequest:(HttpRequest*)request;
@end

/** Http Request Type
 What kind of type is your request
*/
enum {
	HttpRequestTypePost,
	HttpRequestTypeGet,
	HttpRequestTypePut,
	HttpRequestTypeDelete
};
typedef NSUInteger HttpRequestType;

/** Http Request State
 The current state of your request
*/
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
