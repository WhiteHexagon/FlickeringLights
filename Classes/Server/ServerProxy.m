//
//  ServerProxy.m
//  FlickeringLights
//
//  Created by peter on 10/07/2016.
//  Copyright © 2016 SunshineApps LLC. All rights reserved.
//

#import "ServerProxy.h"
#import "ResponseHeader.h"
#import "ResponsePhoto.h"

@interface ServerProxy () {
    NSString *currentSearchTags;
    NSInteger pageNo;
    NSInteger maxPages;
    NSMutableArray *data;
}
@end

@implementation ServerProxy


#pragma mark - API
+ (ServerProxy*) sharedInstance {
    static ServerProxy *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [ServerProxy new];
    });
    return sharedInstance;
}

- (void) searchPhotosByTags:(NSString*)tags thenDo:(void (^)())completion {
    currentSearchTags = tags;
    pageNo = 1;
    data = [NSMutableArray new];        //New search so replace existing array
    
    //run web request on background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self searchPhotos];
        if (completion) {
            completion();
        }
    });
}

- (void) nextPageThenDo:(void (^)())completion {
    if (pageNo < maxPages) {
        pageNo++;
        //run web request on background thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self searchPhotos];
            if (completion) {
                completion();
            }
        });
    }
}

- (NSArray*) searchResult {
    return data;
}

#pragma mark - private
- (void) searchPhotos {
    //ensure proper URL encoding of tags
    NSString *urlString = @"https://api.flickr.com/services/rest/";
    NSURLComponents *components = [NSURLComponents componentsWithString:urlString];
    components.queryItems = @[[NSURLQueryItem queryItemWithName:@"method" value:@"flickr.photos.search"],
                              [NSURLQueryItem queryItemWithName:@"api_key" value:@"d7bae6cb8e42d0ec85b3cb444cb24605"],
                              [NSURLQueryItem queryItemWithName:@"format" value:@"json"],
                              [NSURLQueryItem queryItemWithName:@"sort" value:@"relevance"],
                              [NSURLQueryItem queryItemWithName:@"extras" value:@"date_taken"],
                              [NSURLQueryItem queryItemWithName:@"per_page" value:@"100"],
                              [NSURLQueryItem queryItemWithName:@"page" value:[NSString stringWithFormat:@"%ld", (long)pageNo]],
                              [NSURLQueryItem queryItemWithName:@"tags" value:currentSearchTags]
                              ];
    NSString *request = [components string];
    DLog(@"request\n%@", request);

    //fetch page of results
    NSString *response = [NSString stringWithContentsOfURL:[NSURL URLWithString:request] encoding:NSUTF8StringEncoding error:nil];
    //DLog(@"response:\n%@", response);
    
    if (response == nil || ![response hasPrefix:@"jsonFlickrApi("]) {
        return;
    }
    //JSON response from flickr is actually javascript, and thus we need to remove the wrapper function of jsonFlickrApi()
    response = [response substringWithRange:NSMakeRange(14, [response length] -15)];
    //DLog(@"response:\n%@", response);

    //parse the json
    ResponseHeader *header = [[ResponseHeader alloc] initWithString:response error:nil];
    
    DLog(@"stat=%@", header.stat);
    if ([header.stat isEqualToString:@"fail"]) {
        DLog(@"failed: %@", header.message);
        //TODO
        return;
    }
    
    maxPages = [header.photos.pages integerValue];

    //calculate URLs of actual images
    for (ResponsePhoto *photo in header.photos.photo) {
        photo.urlSmall = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_s.jpg", photo.farm, photo.server, photo.id, photo.secret];
        photo.urlLarge = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_h.jpg", photo.farm, photo.server, photo.id, photo.secret];
    }

    [data addObjectsFromArray:header.photos.photo];
}




@end
