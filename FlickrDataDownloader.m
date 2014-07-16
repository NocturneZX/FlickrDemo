//
//  FlickrDataDownloader.m
//  FlickrDemo
//
//  Created by Julio Reyes on 7/12/14.
//  Copyright (c) 2014 Julio Reyes. All rights reserved.
//

#import "FlickrDataDownloader.h"
#import "FlickrPhoto.h"

#define PHOTO_COUNT 20


@implementation FlickrDataDownloader

// Current Page
@synthesize currentpage;
-(id)init{
    if (self) {
        currentpage = 0;
    }
    return self;
}
- (void) getArrayOfPhotoObjectsforTheSearchTerm:(NSString *)searchTerm
{
    // Setup the current page number to increase every time the operation executes
    ++currentpage;
    
    NSLog(@"%lu", (unsigned long)currentpage);
    
    NSMutableArray *arrayOfFlickrPhotoObjects = [[NSMutableArray alloc] init];
    
    NSString *urlConcatenatedString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&text=%@&sort=interestingness-desc&page=%lu&per_page=%d&format=json&nojsoncallback=1",FLICKR_API_KEY, searchTerm, (unsigned long) currentpage,PHOTO_COUNT];
    
    NSURL * url  = [NSURL URLWithString:urlConcatenatedString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSOperationQueue *flickrRequestQueue = [[NSOperationQueue alloc]init];
    flickrRequestQueue.maxConcurrentOperationCount = 1;
    
    NSURLSession *flickrsession = [NSURLSession sharedSession];
    NSURLSessionDataTask *flickrtask = [flickrsession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
        NSDictionary *flickrphotosDict = [results objectForKey:@"photos"];
        NSArray *flickrphotoArray = [flickrphotosDict objectForKey:@"photo"];
        
        for (NSDictionary* eachPhoto in flickrphotoArray) {
            
            //Grab each piece of data needed for the Photo class
            FlickrPhoto *PhotoObject = [[FlickrPhoto alloc]init];
            
            NSString *farm = [eachPhoto objectForKey:@"farm"];
            NSString *server = [eachPhoto objectForKey:@"server"];
            NSString *photoID = [eachPhoto objectForKey:@"id"];
            NSString *secret = [eachPhoto objectForKey:@"secret"];
            
            NSString *owner = [eachPhoto objectForKey:@"owner"];
            NSString *title = [eachPhoto objectForKey:@"title"];
            
            // Image URL setups save unto a class
            NSString *httpThumbnailString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_t.jpg", farm,server,photoID,secret];
            NSURL *photoThumbnailURL = [NSURL URLWithString:httpThumbnailString];
            NSString *httpImageString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_m.jpg", farm,server,photoID,secret];
            NSURL *photoURL = [NSURL URLWithString:httpImageString];
            
            // Setup the FlickrPhoto class
            PhotoObject.filckrphotoID = photoID;
            PhotoObject.filckrphotoTitle = title;
            PhotoObject.filckrphotoImageURL  = photoThumbnailURL;
            PhotoObject.filckrphotoThumbnailImageURL = photoURL;
            PhotoObject.filckrphotoAuthor = owner;
            
            //Add PhotoObject into the array
            [arrayOfFlickrPhotoObjects addObject:PhotoObject];
            
        }
        
        // Send data to the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            // do work here
            [self.delegate FlickrDataDownloaderDidComplete:arrayOfFlickrPhotoObjects];
        });
        
        
    }];
    
    // Execute the task
    [flickrtask resume];
}
@end
