//
//  FlickrDetailedViewController.m
//  FlickrDemo
//
//  Created by Julio Reyes on 7/13/14.
//  Copyright (c) 2014 Julio Reyes. All rights reserved.
//

#import "FlickrDetailedViewController.h"
#import "UIImageView+WebCache.h"

@interface FlickrDetailedViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *fullImageView;
@property (strong, nonatomic) IBOutlet UIView *detailView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@end

@implementation FlickrDetailedViewController
@synthesize fullImageView;
@synthesize detailView;
@synthesize selectedPhoto;
@synthesize titleLabel, authorLabel, descriptionLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - Interface Orientation setup
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
// Check to see if the phone is in landscape. If so, change the content mode of the image so that it compliments the image itself
-(void) viewWillAppear:(BOOL)animated{
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        // Set to Aspect Fill and hide the nav bar so the image can be seen in fullscreen
        self.fullImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.navigationController.navigationBarHidden = YES;
    }
    else
    {
        self.fullImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.navigationController.navigationBarHidden = NO;
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if (fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        self.fullImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.navigationController.navigationBarHidden = NO;
    }
    else
    {
        // Set to Aspect Fill and hide the nav bar so the image can be seen in fullscreen
        self.fullImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.navigationController.navigationBarHidden = YES;
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailView.alpha = 0.0;
    // Do any additional setup after loading the view.
    NSString *urlConcatenatedString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.people.getInfo&api_key=%@&user_id=%@&format=json&nojsoncallback=1", FLICKR_API_KEY,selectedPhoto.filckrphotoAuthor];
        NSLog(@"urlConcatenatedString: %@",urlConcatenatedString);
    NSURL* url  = [NSURL URLWithString:urlConcatenatedString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSDictionary *returnedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
         
         
         NSDictionary *authorDict = [returnedData objectForKey:@"person"];
         NSLog(@"returnedResults:  %@",authorDict);
         
         NSString *authorname = [authorDict valueForKeyPath:@"realname._content"];
         NSString *hometown = [authorDict valueForKeyPath:@"timezone.label"];
         NSString *desc = [authorDict valueForKeyPath:@"description._content"];
         NSLog(@"The author is %@ from %@", authorname, hometown);
         
         titleLabel.text = selectedPhoto.filckrphotoTitle;
         authorLabel.text = [NSString stringWithFormat:@"%@ from %@", authorname, hometown];
         descriptionLabel.text = [NSString stringWithFormat:@"%@",desc];
     }];

     [self.fullImageView sd_setImageWithURL:selectedPhoto.filckrphotoImageURL placeholderImage:[UIImage imageNamed:@"white-large-chiclet.png"] completed:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Pre-load action
- (void)loadFromPhoto:(FlickrPhoto *)photo{
    selectedPhoto = photo;
    
   
}

#pragma mark IBActions
-(IBAction)TapImage:(id)sender{
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        [UIView animateWithDuration:0.7 animations:^{
            self.navigationController.navigationBarHidden = NO;
            self.detailView.alpha = 0.7;
            self.detailView.center = CGPointMake(self.detailView.center.x, 260.0);
        }];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
