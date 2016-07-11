//
//  ResultsTVC.m
//  FlickeringLights
//
//  Created by peter on 10/07/2016.
//  Copyright © 2016 SunshineApps LLC. All rights reserved.
//

#import "ResultsTVC.h"
#import "ServerProxy.h"
#import "ResponsePhoto.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DetailVC.h"
#import "UIImage+MDContentColor.h"

@interface ResultsTVC () {
    NSArray *data;
}
@end

@implementation ResultsTVC

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Results";
    self.clearsSelectionOnViewWillAppear = NO;

    data = [[ServerProxy sharedInstance] searchResult];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[ServerProxy sharedInstance] searchResult] count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //need to load next page?
    if (indexPath.row > [data count] - 60) {
        [[ServerProxy sharedInstance] nextPageThenDo:^() {
            dispatch_async(dispatch_get_main_queue(),^{
                [self.tableView reloadData];
            });
        }];
    }
    
    [cell.imageView setShowActivityIndicatorView:YES];
    [cell.imageView setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    ResponsePhoto *photo = [data objectAtIndex:indexPath.row];
    //cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    cell.textLabel.text = photo.title;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:photo.urlSmall] placeholderImage:[UIImage imageNamed:@"loading.png"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
    return cell;
}

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    ResponsePhoto *photo = [data objectAtIndex:indexPath.row];

    //calc avergage color of image - TODO this would probably work better by pixelating the image and counting the main colors? or using the pixelated blurred image as a background to the actual picture?
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    photo.averageColor = [cell.imageView.image md_averageColor];
    
    [self.navigationController pushViewController:[[DetailVC alloc] initWithPhoto:photo] animated:YES];
}

@end
