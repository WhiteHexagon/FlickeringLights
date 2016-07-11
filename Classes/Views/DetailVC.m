//
//  DetailVC.m
//  FlickeringLights
//
//  Created by peter on 10/07/2016.
//  Copyright © 2016 SunshineApps LLC. All rights reserved.
//

#import "DetailVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "BLEManager.h"

@interface DetailVC (){
    UIImageView *photoIV;
    ResponsePhoto *photo;
}
@end

@implementation DetailVC

- (id) initWithPhoto:(ResponsePhoto*)aPhoto {
    if (self = [super init]) {
        photo = aPhoto;
        return self;
    }
    return nil;
}

#pragma mark - UIViewController
- (void) viewDidLoad {
    [super viewDidLoad];
    self.title = @"Photo";
   // [self.view setBackgroundColor:[UIColor colorWithRed:(11.0f/255.0f) green:(94.0f/255.0f) blue:(215.0f/255.0f) alpha:1.0f]];
    [self.view setBackgroundColor:photo.averageColor];
    
    //BLE color
    NSInteger bleStatus = [[NSUserDefaults standardUserDefaults] integerForKey:@"bleStatus"];
    if (bleStatus == 1) {
        [[BLEManager sharedInstance] pokeColor:photo.averageColor];
    }
    
    float screenWidth = self.view.frame.size.width;
    float yPos = 80.0f;
    
    //photo
    float widgetWidth = screenWidth * 0.95f;
    float widgetHeight = widgetWidth * 0.6f;
    float xPos = (screenWidth - widgetWidth) / 2.0f;
    photoIV = [UIImageView new];
    photoIV.frame = CGRectMake(xPos, yPos, widgetWidth, widgetHeight);
//TODO    photoIV tap listener for fullscreen?
    [photoIV.layer setMasksToBounds:YES];
    [photoIV.layer setBorderWidth:6.0];
    [photoIV.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [photoIV.layer setCornerRadius:6.0];
    [self.view addSubview:photoIV];
    
    //load the image in the background and cache it.
    __block UIActivityIndicatorView *activityIndicator;
    __weak UIImageView *weakImageView = photoIV;
    [photoIV sd_setImageWithURL:[NSURL URLWithString:photo.urlLarge]
                      placeholderImage:nil
                               options:SDWebImageProgressiveDownload
                              progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                  if (!activityIndicator) {
                                      [weakImageView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
                                      activityIndicator.center = weakImageView.center;
                                      [activityIndicator startAnimating];
                                  }
                              }
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 [activityIndicator removeFromSuperview];
                                 activityIndicator = nil;
                             }];
    
    //title
    yPos += widgetHeight + 30.0f;
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(xPos, yPos, widgetWidth, 20.0f)];
    titleL.textAlignment = UITextAlignmentCenter;
    titleL.text = photo.title;
    [titleL setFont:[UIFont boldSystemFontOfSize:16.0]];
    [titleL setBackgroundColor:[UIColor clearColor]];
    [titleL setTextColor:[UIColor whiteColor]];
    [self.view addSubview:titleL];

    //title
    yPos += 20.0f + 10.0f;
    UILabel *dateL = [[UILabel alloc] initWithFrame:CGRectMake(xPos, yPos, widgetWidth, 20.0f)];
    dateL.textAlignment = UITextAlignmentCenter;
    dateL.text = photo.datetaken;
    [dateL setFont:[UIFont boldSystemFontOfSize:16.0]];
    [dateL setBackgroundColor:[UIColor clearColor]];
    [dateL setTextColor:[UIColor whiteColor]];
    [self.view addSubview:dateL];
}

@end
