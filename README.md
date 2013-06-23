objc-networking
===============

Simple and lightweight objective-c http-networking library.

**Basic usage:**

1. Drag objc-networking.xcodeproj to your project
2. Add objc-networking as a target dependency under "Build Phases"
3. Add objc-networking.a as a library under "Link Binary With Libraries"
4. Thats it 

**Example:**

Import headers and implement the procotol

YourClass.h
```objective-c
#import <UIKit/UIKit.h>
#import <objc-networking-ios/AVHttpRequest.h>
#import <objc-networking-ios/AVHttpResponse.h>

@interface YourClass : UIViewController <AVHttpRequestProtocol>

@end
```

YourClass.m
```objective-c
- (void) didStartRequest:(AVHttpRequest *)request
{
}

- (void) didFailRequest:(AVHttpRequest *)request withError:(NSError *)error
{
}

- (void) didFinishRequest:(AVHttpRequest *)request withResponse:(AVHttpResponse *)response
{
}
```

Then start a request

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
  Only async requests can be cancelled.
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
