//
//  BTHSControlPlugin.m
//  BTHSControl
//
//  Created by James Fator on 8/21/14.
//  Copyright (c) 2014 JamesFator. All rights reserved.
//

#import "BTHSControlPlugin.h"

#pragma mark - Methods to inject

@implementation NSObject (BTHSControlInterceptor)

/**
 * Method we are injecting into the AVRCPAgent. This will allow us
 * to receive the AVR commands directly and handle them as we please.
 * @param command - _NSInlineData of the AVR command
 */
- (int)handleInterceptedAVRCommand:(id)command
{
    const unsigned *tokenBytes = [command bytes];
    NSString *hexToken = [[NSString stringWithFormat:@"%08x",
                           ntohl(tokenBytes[1])]
                          substringWithRange:NSMakeRange(4, 2)];
    
    if ([hexToken isEqualToString:@"44"] ||
            [hexToken isEqualToString:@"64"] ||
            [hexToken isEqualToString:@"46"]) {
        [BTHSInterface play];
    } else if ([hexToken isEqualToString:@"4c"]) {
        [BTHSInterface forward];
    } else if ([hexToken isEqualToString:@"4b"]) {
        [BTHSInterface back];
    }
    return 1;
}

@end

#pragma mark - Bluetooth Headset Control Plugin

@implementation BTHSControlPlugin

/**
 * AVRCPAgent requires us to have this method even though we
 * don't do anything with it.
 */
- (void)setDelegate:(id)delegate
{
    NSLog(@"Setting Delegate: %@", delegate);
}

/**
 * Swaps out a classes' instance method for a custom override.
 * This allows us to redirect the AVR commands.
 * @param cls - Class to inject override method into
 * @param old - selector to the old method to replace
 * @param new - selector to the new method to use
 */
+ (void)swizzleInstanceMethod:(Class)cls original:(SEL)old override:(SEL)new
{
	Method original = class_getInstanceMethod(cls, old);
	Method override = class_getInstanceMethod(cls, new);
	if (!original || !override) {
        return;
    }
    if (class_addMethod(cls, old, method_getImplementation(original),
                        method_getTypeEncoding(original))) {
        original = class_getInstanceMethod(cls, old);
    }
    if (class_addMethod(cls, new, method_getImplementation(override),
                        method_getTypeEncoding(override))) {
        override = class_getInstanceMethod(cls, new);
    }
    method_exchangeImplementations(original, override);
}

/**
 * Method called by SIMBL once the application has started and all classes are
 * initialized. We're simply intercepting the AVR command that comes in from
 * the bluetooth headset and handling it ourself.
 */
+ (void)load
{
    Class cls;
    SEL old, new;
    cls = NSClassFromString(@"BluetoothAVRCPAgent");
    if (!cls) {
        NSLog(@"Failed to install BTMonitorPlugin");
        return;
    }
    old = NSSelectorFromString(@"handleIncomingAVRCommand:");
    new = @selector(handleInterceptedAVRCommand:);
    [BTHSControlPlugin swizzleInstanceMethod:cls original:old override:new];
    NSLog(@"BTHSControlPlugin installed");
}

@end
