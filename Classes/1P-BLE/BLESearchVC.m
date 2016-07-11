//  Copyright 2010, 2011, 2012 SunshineApps LLC. All rights reserved.

#import "BLESearchVC.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEManager.h"

@implementation BLESearchVC

//SEL
- (void) updateResults {
    dispatch_async(dispatch_get_main_queue(),^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [[self tableView] reloadData];
    });
}

//SEL
- (void) search {
    [[BLEManager sharedInstance] scan];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self performSelector:@selector(updateResults) withObject:nil afterDelay:3.0];
}

- (void) viewDidLoad {
    self.title = @"BLE Devices";
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStyleDone target:self action:@selector(search)];
    [self.navigationItem setRightBarButtonItem:rightButton];
    
    [self search];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [data count];
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"";
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *uuid = [[data allKeys] objectAtIndex:indexPath.row];
    CBPeripheral *device = [data objectForKey:uuid];
    [[cell textLabel] setText:[device name]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [callback searchResult:[[data allKeys] objectAtIndex:indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (id) initWithCallback:(id <BLESearchListener>)aCallback forOptions:(NSDictionary*)options {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        callback = aCallback;
        data = options;
	}
	return self;
}
@end
