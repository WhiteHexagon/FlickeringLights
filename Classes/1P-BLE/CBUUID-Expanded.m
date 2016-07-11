//  Copyright 2010, 2011, 2012 SunshineApps LLC. All rights reserved.

#import "CBUUID-Expanded.h"

@implementation CBUUID (CBUUID_Expanded)

//see http://stackoverflow.com/questions/13275859/how-to-turn-cbuuid-into-string
- (NSString*) representativeString {
    NSData *data = [self data];
    
    NSUInteger bytesToConvert = [data length];
    const unsigned char *uuidBytes = [data bytes];
    NSMutableString *outputString = [NSMutableString stringWithCapacity:16];
    
    for (NSUInteger currentByteIndex = 0; currentByteIndex < bytesToConvert; currentByteIndex++) {
        switch (currentByteIndex) {
            case 3:
            case 5:
            case 7:
            case 9:
                [outputString appendFormat:@"%02x-", uuidBytes[currentByteIndex]];
                break;
            default:
                [outputString appendFormat:@"%02x", uuidBytes[currentByteIndex]];
        }
        
    }
    
    return outputString;
}

@end
