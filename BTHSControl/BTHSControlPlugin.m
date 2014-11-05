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
 * Replaces the handlePlayCommand method of the AVRCPAgent AppControl.
 * Makes a call to the BTHSInterface requesting play.
 * @param status - int value denoting whether this is a press or release
 */
- (void)playCommand:(int)status
{
    if (status == 68) {
        NSLog(@"BTHSCommand: Play Pressed");
        [BTHSInterface play];
    } else {
        NSLog(@"BTHSCommand: Play Released");
    }
}

/**
 * Replaces the handleForwardsCommand method of the AVRCPAgent AppControl.
 * Makes a call to the BTHSInterface requesting forward.
 * @param status - int value denoting whether this is a press or release
 */
- (void)forwardCommand:(int)status
{
    if (status == 75) {
        NSLog(@"BTHSCommand: Forward Pressed");
        [BTHSInterface forward];
    } else {
        NSLog(@"BTHSCommand: Forward Released");
    }
}

/**
 * Replaces the handleBackwardsCommand method of the AVRCPAgent AppControl.
 * Makes a call to the BTHSInterface requesting backward.
 * @param status - int value denoting whether this is a press or release
 */
- (void)backwardCommand:(int)status
{
    if (status == 76) {
        NSLog(@"BTHSCommand: Backward Pressed");
        [BTHSInterface back];
    } else {
        NSLog(@"BTHSCommand: Backward Released");
    }
}

/**
 * Replaces the executeScript method of the AVRCPAgent AppControl.
 * By doing nothing, we are preventing iTunes from opening when it is
 * not open and a button on the headset is pressed.
 * NOTE: This method could hypothetically make a similar AppleScript
 * call, but to any preferred media application other than iTunes.
 * @param arg - string of the AppleScript code to launch iTunes.
 */
- (void*)iTunesLaunch:(void*)arg
{
    return NULL;
}

@end


#pragma mark - Bluetooth Headset Control Plugin


@implementation BTHSControlPlugin

/**
 * AVRCPAgent requires us to have this method even though we
 * don't do anything with it.
 * @param delegate - reference to the delegate of this PlugIn
 */
- (void)setDelegate:(id)delegate
{
    NSLog(@"Setting Delegate: %@", delegate);
}

/**
 * Swaps out a class instance method for a custom override.
 * This allows us to redirect the AVR commands.
 * @param cls - Class to inject override method into
 * @param old - selector to the old method to replace
 * @param new - selector to the new method to use
 */
+ (void)replaceInstanceMethod:(Class)cls original:(SEL)old override:(SEL)new
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
 * Primary entry point for this plugin.
 * We use this method to feed custom code into an existing class.
 */
+ (void)load
{
    // Swap out methods from AppControl with our custom methods
    Class ac = NSClassFromString(@"AppControl");
    SEL old, new;
    
    old = NSSelectorFromString(@"handlePlayCommand:");
    new = @selector(playCommand:);
    [BTHSControlPlugin replaceInstanceMethod:ac original:old override:new];
    
    old = NSSelectorFromString(@"handleForwardsCommand:");
    new = @selector(forwardCommand:);
    [BTHSControlPlugin replaceInstanceMethod:ac original:old override:new];
    
    old = NSSelectorFromString(@"handleBackwardsCommand:");
    new = @selector(backwardCommand:);
    [BTHSControlPlugin replaceInstanceMethod:ac original:old override:new];
    
    old = NSSelectorFromString(@"executeScript:");
    new = @selector(iTunesLaunch:);
    [BTHSControlPlugin replaceInstanceMethod:ac original:old override:new];
    
    NSLog(@"BTHSControlPlugin installed");
}

@end
