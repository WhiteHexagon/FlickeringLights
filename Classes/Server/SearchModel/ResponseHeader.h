//
//  ResponseHeader.h
//  FlickeringLights
//
//  Created by peter on 10/07/2016.
//  Copyright © 2016 SunshineApps LLC. All rights reserved.
//

#import "JSONModel.h"
#import "ResponsePhotos.h"

@interface ResponseHeader : JSONModel
@property (nonatomic, strong) NSString *stat;           //ok|fail
@property (nonatomic, strong) NSString<Optional> *code;
@property (nonatomic, strong) NSString<Optional> *message;
@property (nonatomic, strong) ResponsePhotos<Optional> *photos;
@end
