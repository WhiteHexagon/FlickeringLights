//
//  ResponsePhotos.h
//  FlickeringLights
//
//  Created by peter on 10/07/2016.
//  Copyright © 2016 SunshineApps LLC. All rights reserved.
//

#import "JSONModel.h"
#import "ResponsePhoto.h"

@protocol ResponsePhoto
@end

@interface ResponsePhotos : JSONModel
@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) NSString *pages;
@property (nonatomic, strong) NSString *perpage;
@property (nonatomic, strong) NSString *total;
@property (nonatomic, strong) NSArray<ResponsePhoto> *photo;
@end
