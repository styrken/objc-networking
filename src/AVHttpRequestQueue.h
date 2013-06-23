//
//  HttpRequestQueue.h
//  objc-networking
//
//  Created by Rasmus Styrk on 20/06/13.
//  Copyright (c) 2013 Appværk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVHttpRequest;

@interface AVHttpRequestQueue : NSObject

@property (nonatomic, retain) NSMutableArray *queue;

- (void) enqueue:(AVHttpRequest*)request;
- (void) dequeue:(AVHttpRequest*)request;

- (void) start;
- (void) pause;
- (void) cancel;

@end
