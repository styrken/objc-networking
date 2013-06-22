objc-networking
===============

Simple and lightweight objective-c http-networking library.

**Basic usage:**

1. Drag objc-networking.xcodeproj to your project
2. Add objc-networking as a target dependency under "Build Phases"
3. Add objc-networking.a as a library under "Link Binary With Libraries"
4. Thats it 

**Example:**

First import some headers

```objective-c
#import <objc-networking-ios/HttpRequest.h>
#import <objc-networking-ios/HttpResponse.h>

```

Then implement the procotol

YourClass.h
```objective-c
@interface YourClass : UIViewControlelr <HttpRequestProtocol>

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
HttpRequest *request = [HttpRequest requestWithURLString:@"http://lorempixel.com/1920/1920/"];
request.delegate = self;
[request start];
```
