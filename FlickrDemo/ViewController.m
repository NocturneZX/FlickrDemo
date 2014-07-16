//
//  ViewController.m
//  FlickrDemo
//
//  Created by Julio Reyes on 7/12/14.
//  Copyright (c) 2014 Julio Reyes. All rights reserved.
//

#import "ViewController.h"
#import "FlickrIbXTableViewCell.h"
#import "FlickrDetailedViewController.h"
#import "FlickrDataDownloader.h"

@interface ViewController () <FlickrDataDownloaderDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) NSMutableArray  *photosets;
@property FlickrDataDownloader *downloader;
@property (strong, nonatomic) IBOutlet UITableView *PhotoTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation ViewController
@synthesize photosets = _photosets;
@synthesize PhotoTableView = _PhotoTableView;
@synthesize activityIndicator = _activityIndicator;

//static NSString * const FlickrPublicFeedURL = @"http://api.flickr.com/services/feeds/photos_public.gne";

static NSString * const TVCIdentifier = @"PhotoCell";
static NSString * const EXIdentifier = @"LoadMoreCell";

// Set BOOL toggle for loading more photos
BOOL isOperating = NO;

#define searchQuery @"Gundam"

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = [NSString stringWithFormat:@"Result of %@",searchQuery];
    self.photosets = [[NSMutableArray alloc]init];
    self.downloader = [[FlickrDataDownloader alloc]init];
    self.downloader.delegate = self;
    [self.downloader getArrayOfPhotoObjectsforTheSearchTerm:searchQuery];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Delegates and Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.photosets.count > 0) {
        return self.photosets.count + 1;

    }else{
        return 0;
    }
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // CREATE CUSTOM CELL AND SET DELEGATE
    FlickrIbXTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TVCIdentifier];
    if (cell == nil) {
        cell = [[FlickrIbXTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TVCIdentifier];
    }

    
    // Setup pagination
    if (self.photosets.count != indexPath.row ) {
        //cell.photoIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.photoIndicator.center = cell.photoImage.center;// it will display in center of image view
        
        FlickrPhoto *currentPhoto = self.photosets[indexPath.row];
        
        // Ste up the title
        cell.photoName.text = currentPhoto.filckrphotoTitle;
        [cell.photoName setFont:[UIFont fontWithName:@"OpenSans" size:16]];
        
        //Set up images
        NSString *imageName = [NSString stringWithContentsOfURL:currentPhoto.filckrphotoThumbnailImageURL encoding:NSStringEncodingConversionExternalRepresentation error:nil];
        
        //UIImage *savedImage = [_imageCache objectForKey:imageName];
        // Asynchronously load image. Personally, I like to use the third-party library called SDWebImage.

            cell.photoImage.image = [[UIImage alloc]initWithCIImage:nil];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSData *imgData = [NSData dataWithContentsOfURL:currentPhoto.filckrphotoThumbnailImageURL];
                if (imgData) {
                    UIImage *image = [UIImage imageWithData:imgData];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            FlickrIbXTableViewCell *updateCell = (FlickrIbXTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell){
                                cell.photoImage.image = [self maskImage:image withMask:[UIImage imageNamed:@"circlemask.png"]];
                                [cell setNeedsLayout];
                                
                                // Remove activity Indicator for image
                                [cell.photoIndicator stopAnimating];
                                [cell.photoIndicator removeFromSuperview];
                            }
                        });// end dispatch_async(dispatch_get_main_queue())
                    }
                }
            });// end dispatch_async(dispatch_get_global_queue())
        
    }else{
        UITableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:EXIdentifier];
        // Load more cell is made
        if (cell2 == nil){
            cell2 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EXIdentifier];
        }

        UIActivityIndicatorView* photoIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        photoIndicator.frame = CGRectMake(37, 27, photoIndicator.frame.size.width, photoIndicator.frame.size.height);// it will display in center of image view
        [cell2 addSubview:photoIndicator];
        [photoIndicator startAnimating];
        
        UILabel *loadMoreLabel =[[UILabel alloc]initWithFrame: CGRectMake(0,0,362,73)];
        loadMoreLabel.textColor = [UIColor blackColor];
        loadMoreLabel.highlightedTextColor = [UIColor darkGrayColor];
        loadMoreLabel.backgroundColor = [UIColor clearColor];
        loadMoreLabel.font=[UIFont fontWithName:@"OpenSans-ExtraBold" size:18];
        loadMoreLabel.textAlignment = NSTextAlignmentCenter;
        loadMoreLabel.text=@"Fetching More Photos..";
        [cell2 addSubview:loadMoreLabel];
        return cell2;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Not the extra cell but the photo cell
    if(indexPath.row != [self.photosets count] ){
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        
        FlickrDetailedViewController *detail =[storyboard instantiateViewControllerWithIdentifier:@"FlickrDetailedViewController"];
        
        [self.navigationController pushViewController:detail animated:YES];
        
        [detail loadFromPhoto:self.photosets[indexPath.row]];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Lazy load action
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reload_distance = 20;
    if(y > h + reload_distance)
    {
        //Execute the next set of operation here...
        [self.activityIndicator startAnimating];
        if (!isOperating) {
            NSLog(@"Executing new operation...");
            isOperating = YES;
            [self getMorePhotos];
    }
        
        
        //[self getPhotos];
        /* Operation Queue init (autorelease) */
       
    }
}
#pragma mark - View Actions
-(void) getMorePhotos{
    
    //self.downloader = [FlickrDataDownloader new];
    [self.downloader getArrayOfPhotoObjectsforTheSearchTerm:searchQuery];
    
}

- (void) FlickrDataDownloaderDidComplete: (NSArray *)resultingdata{
    if (self.photosets.count == 0) {
        for (FlickrPhoto *photo in resultingdata) {
            [self.photosets addObject:photo];
        }
        
        NSLog(@"Photosets: %lu", (unsigned long)self.photosets.count);
        [self.PhotoTableView reloadData];
        [self.activityIndicator stopAnimating];
    }else{
        
        
    
        int64_t delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            
            // build the index paths for insertion
            // since you're adding to the end of datasource, the new rows will start at count
            NSMutableArray *indexPaths = [NSMutableArray array];
            NSInteger currentCount = self.photosets.count;
            for (int i = 0; i < resultingdata.count; i++) {
                // do the insertion
                [self.photosets addObject:resultingdata[i]];
                [indexPaths addObject:[NSIndexPath indexPathForRow:currentCount+i inSection:0]];
            }
            
            // Second operation and onward operations handling
            NSLog(@"Photosets: %lu", (unsigned long)self.photosets.count);

            // tell the table view to update (at all of the inserted index paths)
            [self.PhotoTableView beginUpdates];
            [self.PhotoTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            [self.PhotoTableView endUpdates];
            
        });
    }
    
    // Set the operation toggle back on
    isOperating = NO;
}

#pragma mark - Image Mask
- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage{
    CGImageRef maskReference = maskImage.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskReference),
                                        CGImageGetHeight(maskReference),
                                        CGImageGetBitsPerComponent(maskReference),
                                        CGImageGetBitsPerPixel(maskReference),
                                        CGImageGetBytesPerRow(maskReference),
                                        CGImageGetDataProvider(maskReference), NULL, false);
    
    CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
    
    CGImageRelease(mask);
    CGImageRelease(maskedImageRef);
    
    // returns new image with mask applied
    return maskedImage;
}

#pragma mark - Interface setups
-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;;
}

@end
