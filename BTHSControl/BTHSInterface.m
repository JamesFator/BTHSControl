//
//  BTHSInterface.m
//  BTHSControl
//
//  Created by James Fator on 8/21/14.
//  Copyright (c) 2014 JamesFator. All rights reserved.
//

#import "BTHSInterface.h"

#pragma mark Media key emulation

// Aquire access to the event driver required to post IOHID events
static io_connect_t get_event_driver(void)
{
    static mach_port_t sEventDrvrRef = 0;
    mach_port_t masterPort, service, iter;
    kern_return_t kr;
    
    if (!sEventDrvrRef) {
        // Get master device port
        kr = IOMasterPort(bootstrap_port, &masterPort);
        assert(KERN_SUCCESS == kr);
        
        kr = IOServiceGetMatchingServices(masterPort, IOServiceMatching(kIOHIDSystemClass), &iter);
        assert(KERN_SUCCESS == kr);
        
        service = IOIteratorNext(iter);
        assert(service);
        
        kr = IOServiceOpen(service, mach_task_self(), kIOHIDParamConnectType, &sEventDrvrRef);
        assert(KERN_SUCCESS == kr);
        
        IOObjectRelease( service );
        IOObjectRelease( iter );
    }
    return sEventDrvrRef;
}

// Simulate the input of a keystroke based on an associated keycode
static void HIDPostAuxKey(const UInt8 auxKeyCode)
{
    NXEventData event;
    kern_return_t kr;
    IOGPoint loc = {0, 0};
    
    // Key press event
    UInt32 evtInfo = auxKeyCode << 16 | NX_KEYDOWN << 8;
    bzero(&event, sizeof(NXEventData));
    event.compound.subType = NX_SUBTYPE_AUX_CONTROL_BUTTONS;
    event.compound.misc.L[0] = evtInfo;
    kr = IOHIDPostEvent(get_event_driver(), NX_SYSDEFINED, loc, &event, kNXEventDataVersion, 0, FALSE);
    assert(KERN_SUCCESS == kr);
    
    // Key release event
    evtInfo = auxKeyCode << 16 | NX_KEYUP << 8;
    bzero(&event, sizeof(NXEventData));
    event.compound.subType = NX_SUBTYPE_AUX_CONTROL_BUTTONS;
    event.compound.misc.L[0] = evtInfo;
    kr = IOHIDPostEvent(get_event_driver(), NX_SYSDEFINED, loc, &event, kNXEventDataVersion, 0, FALSE);
    assert(KERN_SUCCESS == kr);
}

#pragma mark - Bluetooth Headset interface

@implementation BTHSInterface

/**
 * Invokes the input of the PLAY media keytype.
 */
+ (void)play
{
    HIDPostAuxKey(NX_KEYTYPE_PLAY);
}

/**
 * Invokes the input of the FAST media keytype.
 */
+ (void)forward
{
    HIDPostAuxKey(NX_KEYTYPE_FAST);
}

/**
 * Invokes the input of the REWIND media keytype.
 */
+ (void)back
{
    HIDPostAuxKey(NX_KEYTYPE_REWIND);
}


#pragma mark - NotificationCenter interface

/**
 * Posts a user notification to the notification center to alert
 * the user of connecting and disconnecting.
 * @param message - text to be relayed to the user
 */
+ (void)postNotification:(NSString*)message
{
    // Create a static reference to the interface once.
    static BTHSInterface *interface;
    if (!interface) {
        interface = [[BTHSInterface alloc] init];
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:interface];
    }
    
    // Construct the notification and deliver
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    [notification setTitle:@"BTHSControl"];
    [notification setInformativeText:message];
    [notification setSoundName:NSUserNotificationDefaultSoundName];
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

/**
 * Static method dedicated to delivering a notification of the headset
 * connecting. We're doing this because there may be some devices out there
 * that submit Status commands more than I've seen.
 */
+ (void)notifyConnection
{
    static BOOL alreadyAlerted;
    if (!alreadyAlerted) {
        // If we haven't sent this message out yet, do so
        [BTHSInterface postNotification:@"Bluetooth headset connected"];
        alreadyAlerted = YES;
    }
}

/**
 * NotificationCenterDelegate method to ensure we display the notification.
 * Notifications can be turned off by setting this return to NO.
 * Later on, there may be some sort of preferences to dynamically set this.
 */
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

@end
