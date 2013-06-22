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
#import <objc-networking-ios/HttpRequest.h>
#import <objc-networking-ios/HttpResponse.h>

@interface YourClass : UIViewController <HttpRequestProtocol>

@end
```

YourClass.m
```objective-c
- (void) didStartRequest:(HttpRequest *)request
{
}

- (void) didFailRequest:(HttpRequest *)request withError:(NSError *)error
{
}

- (void) didFinishRequest:(HttpRequest *)request withResponse:(HttpResponse *)response
{
}
```

Then start a request

```objective-c

- (void)viewDidLoad
{
	[super viewDidLoad];

	HttpRequest *request = [HttpRequest requestWithURLString:@"http://lorempixel.com/1920/1920/"];
	request.delegate = self;
	[request start];
}
```

### Start, pasue, cancel request ###

Need documentation

### Using the HttpRequestQueue ###

Need documentation

### Uploading files ###

Need documentation
