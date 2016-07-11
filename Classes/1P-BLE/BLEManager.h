//  Copyright 2010, 2011, 2012 SunshineApps LLC. All rights reserved.

#import "BLEManagerListener.h"


@interface BLEManager : NSObject {

}
+ (id) sharedInstance;
- (void) scan;
- (NSDictionary*) discoveredDevices;
- (void) connectToUUID:(NSString*)uuid;
- (void) disconnectFromUUID:(NSString*)uuid;
- (NSString*) getNameForUUID:(NSString*)uuid;

- (void) pokeColor:(UIColor*)color;

@end
