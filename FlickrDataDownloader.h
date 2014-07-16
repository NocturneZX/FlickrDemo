//
//  FlickrDataDownloader.h
//  FlickrDemo
//
//  Created by Julio Reyes on 7/12/14.
//  Copyright (c) 2014 Julio Reyes. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol FlickrDataDownloaderDelegate
    - (void) FlickrDataDownloaderDidComplete: (NSArray *)resultingdata;
@end

@interface FlickrDataDownloader : NSObject{
    NSUInteger currentpage;
}
@property NSUInteger currentpage;
@property id<FlickrDataDownloaderDelegate>delegate;
    - (void) getArrayOfPhotoObjectsforTheSearchTerm: (NSString *)searchTerm;
@end
