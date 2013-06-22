//
//  ImageViewController.h
//  LoremPixel
//
//  Created by Rasmus Styrk on 22/06/13.
//  Copyright (c) 2013 Appværk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController

@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, assign) IBOutlet UIImageView *imageView;

- (IBAction)reload:(id)sender;

@end
