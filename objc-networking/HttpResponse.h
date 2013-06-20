//
//  HttpResponse.h
//  objc-networking
//
//  Created by Rasmus Styrk on 20/06/13.
//  Copyright (c) 2013 Appværk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpResponse : NSObject

@property (nonatomic, assign) NSUInteger responseCode;
@property (nonatomic, strong) NSString *contentType;
@property (nonatomic, strong) NSString *charset;
@property (nonatomic, strong) NSData *data;

@end
