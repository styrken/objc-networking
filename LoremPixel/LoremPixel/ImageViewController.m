//
//  ImageViewController.m
//  LoremPixel
//
//  Created by Rasmus Styrk on 22/06/13.
//  Copyright (c) 2013 Appværk. All rights reserved.
//

#import "ImageViewController.h"
#import <objc-networking-ios/HttpRequest.h>
#import <objc-networking-ios/HttpResponse.h>


@interface ImageViewController () <HttpRequestProtocol>

@end

@implementation ImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reload:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)reload:(id)sender
{
	HttpRequest *request = [HttpRequest requestWithURLString:@"http://lorempixel.com/1920/1920/"];
    request.delegate = self;
    [request start];
}

#pragma mark - HttpRequest Protocol

- (void) didStartRequest:(HttpRequest *)request
{
    self.imageView.image = nil;
    [self.spinner startAnimating];
}

- (void) didFailRequest:(HttpRequest *)request withError:(NSError *)error
{
    [self.spinner stopAnimating];
}

- (void) didFinishRequest:(HttpRequest *)request withResponse:(HttpResponse *)response
{
    [self.spinner stopAnimating];
    self.imageView.image = [UIImage imageWithData:response.data];
}

@end
