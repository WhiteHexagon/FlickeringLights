//  Copyright 2010, 2011, 2012 SunshineApps LLC. All rights reserved.

@protocol BLESearchListener <NSObject>
- (void) searchResult:(NSString*)uuid;
@end
