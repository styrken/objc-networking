//
//  HttpRequestQueue.h
//  objc-networking
//
//  Created by Rasmus Styrk on 20/06/13.
//  Copyright (c) 2013 Appværk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HttpRequest;

@interface HttpRequestQueue : NSObject

@property (nonatomic, retain) NSMutableArray *queue;

- (void) enqueue:(HttpRequest*)request;
- (void) dequeue:(HttpRequest*)request;

- (void) start;
- (void) pause;
- (void) cancel;

@end
