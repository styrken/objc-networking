//
//  HttpResponse.m
//  objc-networking
//
//  Created by Rasmus Styrk on 20/06/13.
//  Copyright (c) 2013 Appværk. All rights reserved.
//

#import "AVHttpResponse.h"

@implementation AVHttpResponse

- (id) init
{
	self = [super init];
	if(self)
	{
		self.data = [[NSMutableData alloc] init];
		self.statusCode = 0;
	}

	return self;
}

@end
