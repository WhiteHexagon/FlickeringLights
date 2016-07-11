// Copyright 2014 SunshineApps LLC. All rights reserved.

#import <QuartzCore/QuartzCore.h>
#import "SAButton.h"

@implementation SAButton

- (id) initWithFrame:(CGRect)frame {
    if ((self=[super initWithFrame:frame])) {
        [[self titleLabel] setFont:[UIFont systemFontOfSize:12.0]];
        CALayer* selfLayer = [self layer];
        [selfLayer setMasksToBounds:YES];
        [selfLayer setBorderWidth:1.0];
        [selfLayer setBorderColor:[[UIColor whiteColor] CGColor]];
        [selfLayer setCornerRadius:4.0];
    }
    return self;
}

@end
