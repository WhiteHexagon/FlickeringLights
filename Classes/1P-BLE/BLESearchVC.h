//  Copyright 2010, 2011, 2012 SunshineApps LLC. All rights reserved.

#import "BLESearchListener.h"

@interface BLESearchVC : UITableViewController {
    id <BLESearchListener> callback;
    NSDictionary *data;
}
- (id) initWithCallback:(id <BLESearchListener>)aCallback forOptions:(NSDictionary*)options;
@end
