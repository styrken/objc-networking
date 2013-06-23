//
//  HttpResponse.h
//  objc-networking
//
//  Created by Rasmus Styrk on 20/06/13.
//  Copyright (c) 2013 Appværk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AVHttpResponse : NSObject

@property (nonatomic, assign) NSUInteger statusCode;
@property (nonatomic, strong) NSMutableData *data;
@end
