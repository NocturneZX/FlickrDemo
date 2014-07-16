//
//  FlickrDetailedViewController.h
//  FlickrDemo
//
//  Created by Julio Reyes on 7/13/14.
//  Copyright (c) 2014 Julio Reyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrPhoto.h"

@interface FlickrDetailedViewController : UIViewController
@property FlickrPhoto *selectedPhoto;

- (void)loadFromPhoto:(FlickrPhoto *)photo;

@end
