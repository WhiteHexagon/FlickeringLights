//
//  ServerProxy.h
//  FlickeringLights
//
//  Created by peter on 10/07/2016.
//  Copyright © 2016 SunshineApps LLC. All rights reserved.
//

@interface ServerProxy : NSObject
+ (ServerProxy*) sharedInstance;
- (void) searchPhotosByTags:(NSString*)tags thenDo:(void (^)())completion;
- (void) nextPageThenDo:(void (^)())completion;
- (NSArray*) searchResult;
@end
