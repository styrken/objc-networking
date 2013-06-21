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
- (void) didFinishRequest:(HttpRequest*)request withResponse:(HttpResponse*)response;
- (void) didFailRequest:(HttpRequest*)request withError:(NSError*)error;
@optional
- (void) didStartRequest:(HttpRequest*)request;
- (void) didStopRequest:(HttpRequest*)request;
- (void) didPauseRequest:(HttpRequest*)request;
- (void) estimatedTimeLeft:(NSTimeInterval)seconds forRequest:(HttpRequest*)request;
@end

/** Http Request Method
 What kind of method is your request
*/
enum {
	HttpRequestMethodPost,
	HttpRequestMethodGet,
	HttpRequestMethodPut,
	HttpRequestMethodDelete
};
typedef NSUInteger HttpRequestMethod;

/** Http Request State
 The current state of your request
*/
enum {
	HttpRequestStateUnknown,
	HttpRequestStateDownloading,
	HttpRequestStatePaused,
	HttpRequestStateCancelled,
	HttpRequestStateCompleted,
	HttpRequestStateFailed
};
typedef NSUInteger HttpRequestState;

/** Http Request Type
 How the reqest downloads data. Sync is blocking and can't be cancelled.
*/
enum {
	HttpRequestTypeAsync,
	HttpRequestTypeSync // BLOCKING AND CAN'T BE CANCELLED
};
typedef NSUInteger HttpRequestType;

/** Http Request
 An http request is a simple object that makes it easy to download or send data over the internet. It supports both async and sync loading of data.
 When using async you are able to pause or cancel the request while its ongoing. Synchronous downlods cannot be paused or cancelled - they have
 to complete fully.

 The HttpRequest object supports sending arguments over POST and changing HTTP headers.
 
 The HttpRequest object is also capable of estimating time left of he current download.
*/
@interface HttpRequest : NSObject

+ (HttpRequest*) requestWithURL:(NSURL*)url;
+ (HttpRequest*) requestWithURLString:(NSString*)string;

- (id) initWithURLString:(NSString*)string;
- (id) initWithURL:(NSURL*)url;

@property (nonatomic, strong) NSMutableDictionary *requestArguments;
@property (nonatomic, strong) NSMutableDictionary *requestHeaders;

@property (nonatomic, weak) id<HttpRequestProtocol> delegate;

@property (nonatomic, assign) HttpRequestType requestType;
@property (nonatomic, assign) HttpRequestMethod requestMethod;
@property (nonatomic, assign, readonly) HttpRequestState requestState;

@property (nonatomic, strong) HttpResponse *requestResponse;

@property (nonatomic, strong) NSURL *requestUrl;

- (void) start;
- (void) pause;
- (void) cancel;

@end
