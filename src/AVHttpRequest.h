//
//  HttpRequest.h
//  objc-networking
//
//  Created by Rasmus Styrk on 20/06/13.
//  Copyright (c) 2013 Appværk. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AVHttpResponse;
@class AVHttpRequest;

/** Http Request Protocol
 A protocol you can implement to get notifications about a request
*/
@protocol AVHttpRequestProtocol <NSObject>
- (void) didFinishRequest:(AVHttpRequest*)request withResponse:(AVHttpResponse*)response;
- (void) didFailRequest:(AVHttpRequest*)request withError:(NSError*)error;
@optional
- (void) didStartRequest:(AVHttpRequest*)request;
- (void) didStopRequest:(AVHttpRequest*)request;
- (void) didPauseRequest:(AVHttpRequest*)request;
- (void) estimatedTimeLeft:(NSTimeInterval)seconds forRequest:(AVHttpRequest*)request;
@end

/** Http Request Method
 What kind of method is your request
*/
enum {
    AVHttpRequestMethodPost,
    AVHttpRequestMethodGet,
    AVHttpRequestMethodPut,
    AVHttpRequestMethodDelete
};
typedef NSUInteger AVHttpRequestMethod;

/** Http Request State
 The current state of your request
*/
enum {
    AVHttpRequestStateUnknown,
    AVHttpRequestStateDownloading,
    AVHttpRequestStatePaused,
    AVHttpRequestStateCancelled,
    AVHttpRequestStateCompleted,
    AVHttpRequestStateFailed
};
typedef NSUInteger AVHttpRequestState;

/** Http Request Type
 How the reqest downloads data. Sync is blocking and can't be cancelled.
*/
enum {
    AVHttpRequestTypeAsync,
    AVHttpRequestTypeSync // BLOCKING AND CAN'T BE CANCELLED
};
typedef NSUInteger AVHttpRequestType;

/** Http Request
 An http request is a simple object that makes it easy to download or send data over the internet. It supports both async and sync loading of data.
 When using async you are able to pause or cancel the request while its ongoing. Synchronous downlods cannot be paused or cancelled - they have
 to complete fully.

 The HttpRequest object supports sending arguments over POST and changing HTTP headers.
 
 The HttpRequest object is also capable of estimating time left of he current download.
*/
@interface AVHttpRequest : NSObject

+ (AVHttpRequest*) requestWithURL:(NSURL*)url;
+ (AVHttpRequest*) requestWithURLString:(NSString*)string;

- (id) initWithURLString:(NSString*)string;
- (id) initWithURL:(NSURL*)url;

@property (nonatomic, strong) NSMutableDictionary *arguments;
@property (nonatomic, strong) NSMutableDictionary *headers;

@property (nonatomic, weak) id<AVHttpRequestProtocol> delegate;

@property (nonatomic, assign) AVHttpRequestType type;
@property (nonatomic, assign) AVHttpRequestMethod method;
@property (nonatomic, assign, readonly) AVHttpRequestState state;

@property (nonatomic, strong) AVHttpResponse *response;

@property (nonatomic, strong) NSURL *url;

- (void) start;
- (void) pause;
- (void) cancel;

@end
