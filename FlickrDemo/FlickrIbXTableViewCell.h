//
//  FlickrIbXTableViewCell.h
//  FlickrDemo
//
//  Created by Julio Reyes on 7/12/14.
//  Copyright (c) 2014 Julio Reyes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrIbXTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *photoIndicator;
@property (weak, nonatomic) IBOutlet UILabel *photoName;
@property (strong, nonatomic) IBOutlet UIImageView *photoImage;

@end
