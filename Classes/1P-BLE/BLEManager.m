//  Copyright 2010, 2011, 2012 SunshineApps LLC. All rights reserved.

//http://processors.wiki.ti.com/index.php/CC2650_SensorTag_User%27s_Guide
//http://processors.wiki.ti.com/index.php/SensorTag_User_Guide    - temp conversions

#import "BLEManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "CBUUID-Expanded.h"


@interface BLEManager() <CBCentralManagerDelegate, CBPeripheralDelegate> {
    id <BLEManagerListener> listener;
    CBCentralManager *centralManager;
    NSMutableDictionary *foundPeripherals;
    NSMutableArray *connectedServices;
    BOOL btReady;
    BOOL shouldBeConnected;
    
    CBPeripheral *controlPeripheral;
    CBCharacteristic *controlCharacteristic;
}
@end

@implementation BLEManager


- (void) pokeColor:(UIColor*)color {
    if (controlPeripheral == nil || controlCharacteristic == nil || color == nil) {
        DLog(@"not ready or not found");
        return;
    }
    Byte byteArray[] = { 0x56, 0xFF, 0xFF, 0xFF, 0x00, 0xf0, 0xaa};     //white (bytes 1,2,3 represent RGB
    
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];       //only works for RGB color space - monochrome will fail
    byteArray[1] = red * 255;
    byteArray[2] = green * 255;
    byteArray[3] = blue * 255;
    
    [controlPeripheral writeValue:[NSData dataWithBytes:byteArray length:7] forCharacteristic:controlCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

//protocol
- (void) centralManagerDidUpdateState:(CBCentralManager*)central {
    btReady = NO;
	switch ([centralManager state]) {
        case CBCentralManagerStateUnsupported: {
            DLog(@"  unsupported");
            dispatch_async(dispatch_get_main_queue(),^{
                [[[UIAlertView alloc] initWithTitle:@"BLE" message:@"It doesn't look like this device supports Bluetooth 4 (BLE)." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            });
            break;
        }
		case CBCentralManagerStatePoweredOff: {
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"temperatureChangedMessage" object:@"BT off"];
            DLog(@" BT off");
			break;
		}
		case CBCentralManagerStateUnauthorized: {
            DLog(@" unauth");
			break;
		}
		case CBCentralManagerStateUnknown: {
            DLog(@" unknown");
			break;
		}
		case CBCentralManagerStatePoweredOn: {
            DLog(@" BT on");
            btReady = YES;
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"temperatureChangedMessage" object:@"BT on"];
            [self scan];
			break;
		}
		case CBCentralManagerStateResetting: {
            DLog(@" resetting");
			break;
		}
	}
}

//protocol
- (void) centralManager:(CBCentralManager*)central didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber*)RSSI {
    NSString *uuid = peripheral.identifier.UUIDString;
    DLog(@"Found somthing %@  connected: %d  UUID: %@", [peripheral name], (peripheral.state == CBPeripheralStateConnected), uuid);
    CBPeripheral *found = [foundPeripherals objectForKey:uuid];
    if (found == nil) {
        [foundPeripherals setObject:peripheral forKey:uuid];
        DLog(@"Store %@", uuid);
    }
}

//protocol - scanForPeripheralsWithServices
- (void) centralManager:(CBCentralManager*)central didRetrieveConnectedPeripherals:(NSArray*)peripherals {
    DLog(@"didRetrieveConnectedPeripherals count:%lu", (unsigned long)[peripherals count]);
	for (CBPeripheral *peripheral in peripherals) {
        DLog(@"got %@", peripheral.identifier.UUIDString);

	}
}

//API
- (void) scan {
    if (btReady) {
        DLog(@"start scan");
        //disable button, once only synch, and busy rotating thing for scan
        [centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
        
        int64_t delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            DLog(@"STOP");
            [centralManager stopScan];
        });
        
    }
}

//API
- (NSDictionary*) discoveredDevices {
    return foundPeripherals;
}

//API
- (NSString*) getNameForUUID:(NSString*)uuid {
    CBPeripheral *peripheral = [foundPeripherals objectForKey:uuid];
    return (peripheral == nil) ? @"discon." : [peripheral name];
}

#pragma mark - services


//protocol CBPeripheralDelegate
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    DLog(@"didDiscoverServices");
    for (CBService *service in peripheral.services) {
        NSLog(@"%@",service.UUID);
        
        NSString *uuidNSString = [[service UUID] representativeString];
        DLog(@"  found service uuid  %@ characteristics count %lu", uuidNSString, (unsigned long)[service.characteristics count]);
        
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

//protocol
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    //DLog(@"found %@", [service UUID]);
}

#pragma mark - connecting

//protocol
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    DLog(@"didConnectPeripheral %d - name %@", peripheral.state == CBPeripheralStateConnected, peripheral.name);
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

//protocol
- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    DLog(@"didFailToConnectPeripheral");
}

//protocol
//- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
//}

//API - this need to run if we are connecting to multiple devices!
- (void) connectToUUID:(NSString*)uuid {
    DLog(@"connect to %@", uuid);
    if (uuid == nil) {
        return;
    }
    shouldBeConnected = YES;
    if (btReady == NO) {
        DLog(@"  waiting for BT to init");
        [self performSelector:@selector(connectToUUID:) withObject:uuid afterDelay:5.0];
        return;
    }
    CBPeripheral *peripheral = [foundPeripherals objectForKey:uuid];
    if (peripheral == nil) {
        DLog(@"not found in foundPeripherals, uuid=%@", uuid);
        [self scan];
        [self performSelector:@selector(connectToUUID:) withObject:uuid afterDelay:5.0];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"temperatureChangedMessage" object:@"scan"];
        return;
    }
    DLog(@"connected =%d  state=%ld", (peripheral.state == CBPeripheralStateConnected), (long)peripheral.state);
    if (peripheral.state != CBPeripheralStateConnected) {
        DLog(@"connectPeripheral");
        //[centralManager cancelPeripheralConnection:peripheral];
		[centralManager connectPeripheral:peripheral options:nil];
        [self performSelector:@selector(connectToUUID:) withObject:uuid afterDelay:10.0];
        return;
	}
    DLog(@"it was already connected then...");
}

#pragma mark - disconnecting
//API
- (void) disconnectFromUUID:(NSString*)uuid {
    if (uuid == nil) {
        return;
    }
    shouldBeConnected = NO;
    CBPeripheral *peripheral = [foundPeripherals objectForKey:uuid];
    if (peripheral != nil && peripheral.state == CBPeripheralStateConnected) {
        [centralManager cancelPeripheralConnection:peripheral];
    }
}




#pragma mark - Peripherals

//todo
- (void) peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error {
    DLog(@"got something %@", [[characteristic UUID] representativeString]);
}

- (void) peripheral:(CBPeripheral *)periph didDiscoverCharacteristicsForService:(CBService *)serv error:(NSError *)error {
    CBCharacteristic* characteristic;
    //DLog(@"serv.characteristics.count=%lu", (unsigned long)serv.characteristics.count);
    for(int i = 0; i < serv.characteristics.count; i++) {
        characteristic = [serv.characteristics objectAtIndex:i];
        //DLog(@"char      %@   %@", [[characteristic UUID] representativeString], characteristic.description);
//        for (CBDescriptor *desc in characteristic.descriptors) {
//            DLog(@"desc        %@", desc);
//        }

        if ([[[characteristic UUID] representativeString] isEqualToString:@"ffe9"]) {
            controlPeripheral = periph;
            controlCharacteristic = characteristic;
            DLog(@"FOUND COLOR CHARACTERISTIC?");
        //    [self pokeColor];
        
        }
   
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        DLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    if (characteristic.isNotifying) {
        DLog(@"Notification began on %@", characteristic);
    }
}

- (id) init {
	if ((self = [super init])) {
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        foundPeripherals = [[NSMutableDictionary alloc] init];
		connectedServices = [[NSMutableArray alloc] init];
	}
	return self;
}

+ (id) sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

@end
