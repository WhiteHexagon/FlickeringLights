//
//  ResponsePhoto.h
//  FlickeringLights
//
//  Created by peter on 10/07/2016.
//  Copyright © 2016 SunshineApps LLC. All rights reserved.
//

#import "JSONModel.h"

@interface ResponsePhoto : JSONModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSString *farm;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *ispublic;
@property (nonatomic, strong) NSString *isfriend;
@property (nonatomic, strong) NSString *isfamily;
@property (nonatomic, strong) NSString<Optional> *datetaken;
@property (nonatomic, strong) NSString<Optional> *urlSmall;      //not part of JSON - calculated once we have the above data
@property (nonatomic, strong) NSString<Optional> *urlLarge;      //not part of JSON - calculated once we have the above data
@property (nonatomic, strong) UIColor<Optional> *averageColor;   //not part of JSON - calculated once we have downloaded and selected the small image
@end
