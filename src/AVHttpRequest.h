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

#pragma mark - AVHttpRequest initializers

/** Request With URL
Shorthand for alloc/init procedure
*/
+ (AVHttpRequest*) requestWithURL:(NSURL*)url;

/** Request With URL
Shorthand for alloc/init procedure
*/
+ (AVHttpRequest*) requestWithURLString:(NSString*)string;

/** Init with Url String
Creates an httprequest object with default values using a specific url
*/
- (id) initWithURLString:(NSString*)string;

/** Init with Url
Creates an httprequest object with default values using a specific url
*/
- (id) initWithURL:(NSURL*)url;

#pragma mark - AVHttpRequest Properties

/** Delegate
A delegate class that implements AVVHttpRequestProtocol to get notifications when events happens. See AVHttpRequestProtocol for a list of events.
*/
@property (nonatomic, weak) id<AVHttpRequestProtocol> delegate;

/** Arguments
A key/value store of arguments to pass along as body for the request
*/
@property (nonatomic, strong, readonly) NSMutableDictionary *arguments;

/** Headers
A key/value store of optional headers to send with he request
*/
@property (nonatomic, strong, readonly) NSMutableDictionary *headers;

/** Type
Specifies if the request should be sync or async

ASYNC
    The request is loaded in a background thread, everytime something happens the delegate is called. Async requests can be cancelled or paused

SYNC
    The request is loaded on the current thread block all other activities. As soon as you call [request start] the thread blocks untill the request is done.
    When the request starts it calls its delegate didStartRequest:(AVHttpRequest*)request, and when it finishes it either calls didFailRequest:(AVHttpRequest *)request or didFinishHttpRequest:(AVHttpRequest*)request withResponse:(AVHttpResponse*)response;

    If you don't add a delegate you can always get the repsonse throigh request.response property
*/
@property (nonatomic, assign) AVHttpRequestType type;

/** Method
The method to use when sending the request. This can be GET, POST, PUT, DELETE, UPDATE. Your server might not be able to understand anything else than GET and POST.
*/
@property (nonatomic, assign) AVHttpRequestMethod method;

/** State
Describes the current state of the request.
*/
@property (nonatomic, assign, readonly) AVHttpRequestState state;

/** Response
Holds an response object with a statusCode and the delivered data
*/
@property (nonatomic, strong) AVHttpResponse *response;

/** URL
What URL the request should talk with
*/
@property (nonatomic, strong) NSURL *url;

#pragma mark - Public methods

/** Start
Start the request according to type. When using AVHttpRequestTypeSync this method blocks untill it is done.
*/
- (void) start;

/** Pause
Stops the request untill you call start again. When a request have been paused it will remember it current position in the download.
Only async requests can be cancelled.
*/
- (void) pause;

/** Cancel
Cancels the request throwing away all downloaded data.
Only async requests can be cancelled.
*/
- (void) cancel;

@end
