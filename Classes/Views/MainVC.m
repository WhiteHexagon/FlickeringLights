//
//  ViewController.m
//  FlickeringLights
//
//  Created by peter on 10/07/2016.
//  Copyright © 2016 SunshineApps LLC. All rights reserved.
//

#import "MainVC.h"
#import "SAButton.h"
#import "ServerProxy.h"
#import "ResultsTVC.h"
#import "BLEManager.h"
#import "BLESearchVC.h"
#import "BLESearchListener.h"

@interface MainVC () <UITextFieldDelegate, BLESearchListener> {
    UITextField *searchTF;
    UISegmentedControl *bleSC;
}
@end

@implementation MainVC

//SEL
- (void) searchPressed {
    DLog(@"searchPressed");
    [searchTF resignFirstResponder];
    NSString *tags = searchTF.text;

    //start loading in background before displaying screen for smoother experience
    UIActivityIndicatorView *busy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    busy.center = self.view.center;
    [busy startAnimating];
    [self.view addSubview:busy];
    [[ServerProxy sharedInstance] searchPhotosByTags:tags thenDo:^{
        dispatch_async(dispatch_get_main_queue(),^{
            [busy removeFromSuperview];
            [self.navigationController pushViewController:[ResultsTVC new] animated:YES];
        });
    }];
}

//SEL
- (void) pairPressed {
    UIViewController *viewController = [[BLESearchVC alloc] initWithCallback:self forOptions:[[BLEManager sharedInstance] discoveredDevices]];
    [[self navigationController] pushViewController:viewController animated:YES];
}

//SEL
- (void) bleSwitched {
    [[NSUserDefaults standardUserDefaults] setInteger:[bleSC selectedSegmentIndex] forKey:@"bleStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//SEL
- (void) scanPressed {
    UIViewController *viewController = [[BLESearchVC alloc] initWithCallback:self forOptions:[[BLEManager sharedInstance] discoveredDevices]];
    [[self navigationController] pushViewController:viewController animated:YES];
}

//protocol - BLESearchListener
- (void) searchResult:(NSString*)uuid {
    [[NSUserDefaults standardUserDefaults] setValue:uuid forKey:@"bleUUID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[BLEManager sharedInstance] connectToUUID:uuid];
    
    //turn on BLE option
    [bleSC setSelectedSegmentIndex:1];
    [self bleSwitched];
}

#pragma mark - UIViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Flickr Search";
    [self.view setBackgroundColor:[UIColor colorWithRed:(11.0f/255.0f) green:(94.0f/255.0f) blue:(215.0f/255.0f) alpha:1.0f]];
    
    float screenWidth = self.view.frame.size.width;
    float yPos = 120.0f;
    
    //text entry
    float widgetWidth = screenWidth * 0.8f;
    float xPos = (screenWidth - widgetWidth) / 2.0f;
    searchTF = [UITextField new];
    searchTF.frame = CGRectMake(xPos, yPos, widgetWidth, 44.0f);
    searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [searchTF setFont:[UIFont systemFontOfSize:18.0]];
    [searchTF setBorderStyle:UITextBorderStyleBezel];
    [searchTF setBackgroundColor:[UIColor whiteColor]];
    [searchTF setAutocorrectionType:UITextAutocorrectionTypeNo];
    [searchTF setDelegate:self];
    [self.view addSubview:searchTF];
    
    //search button
    yPos += 80.0f;
    widgetWidth = 200.0f;
    SAButton *searchB = [SAButton new];
    searchB.frame = CGRectMake((screenWidth - widgetWidth) / 2.0f, yPos, widgetWidth, 44.0f);
    [searchB.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [searchB setTitle:@"Search" forState:UIControlStateNormal];
    [searchB addTarget:self action:@selector(searchPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchB];

    //BLE 
    yPos += 80;
    UILabel *bleL = [[UILabel alloc] initWithFrame:CGRectMake((screenWidth - 95.0f) / 2.0f, yPos, 95.0, 28.0f)];
    bleL.textAlignment = UITextAlignmentCenter;
    [bleL setText:@"BLE LED"];
    [bleL setFont:[UIFont boldSystemFontOfSize:18.0]];
    [bleL setBackgroundColor:[UIColor clearColor]];
    [bleL setTextColor:[UIColor whiteColor]];
    [self.view addSubview:bleL];
    
    yPos += 40;
    bleSC = [[UISegmentedControl alloc] initWithItems:@[@"Off", @"Magic Blue"]];
    [bleSC setFrame:CGRectMake((screenWidth - 205.0f) / 2.0f, yPos, 205, 28.0f)];
    bleSC.tintColor = [UIColor whiteColor];
    NSInteger bleStatus = [[NSUserDefaults standardUserDefaults] integerForKey:@"bleStatus"];
    [bleSC setSelectedSegmentIndex:bleStatus];
    [bleSC addTarget:self action:@selector(bleSwitched) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:bleSC];
    
    yPos += 40;
    SAButton *scanB = [[SAButton alloc] initWithFrame:CGRectMake((screenWidth - 205.0f) / 2.0f, yPos, 205.0, 28.0f)];
    [scanB setTitle:@"Scan for BLE LED" forState:UIControlStateNormal];
    [scanB addTarget:self action:@selector(scanPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanB];
}

- (void) viewDidAppear:(BOOL)animated {
    [searchTF becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL) textFieldShouldReturn:(UITextField*)aTextField {
    [aTextField resignFirstResponder];
    return YES;
}

@end
