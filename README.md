objc-networking
===============

Simple and lightweight objective-c http-networking library.

**Basic usage:**

1. Drag objc-networking.xcodeproj to your project
2. Add objc-networking as a target dependency under "Build Phases"
3. Add objc-networking.a as a library under "Link Binary With Libraries"
4. Thats it 

**Example:**

Take a look at the LoremPixel example code.

```objective-c

- (void)viewDidLoad
{
	[super viewDidLoad];

	AVHttpRequest *request = [HttpRequest requestWithURLString:@"http://lorempixel.com/1920/1920/"];
	request.delegate = self;
	[request start];
}
```

### Start, pause, cancel requests ###

```objective-c
/** Start
  Start the request according to type. When using AVHttpRequestTypeSync this method blocks untill it is done.
  */
- (void) start;

/** Pause
  Stops the request untill you call start again. When a request have been paused it will remember it current position in the download.
  Only async requests can be paused.
  */
- (void) pause;

/** Cancel
  Cancels the request throwing away all downloaded data.     
  Only async requests can be cancelled.
  */
- (void) cancel;
```


### Using the HttpRequestQueue ###

Need documentation

### Uploading files ###

Need documentation


### AVHttpRequestProtocol ###

```objective-c
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
```
