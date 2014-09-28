//
//  BTHSInterface.m
//  BTHSControl
//
//  Created by James Fator on 8/21/14.
//  Copyright (c) 2014 JamesFator. All rights reserved.
//

#import "BTHSInterface.h"

#pragma mark Media key emulation

static io_connect_t get_event_driver(void)
{
    static  mach_port_t sEventDrvrRef = 0;
    mach_port_t masterPort, service, iter;
    kern_return_t    kr;
    
    if (!sEventDrvrRef)
    {
        // Get master device port
        kr = IOMasterPort(bootstrap_port, &masterPort);
        assert(KERN_SUCCESS == kr);
        
        kr = IOServiceGetMatchingServices(masterPort, IOServiceMatching(kIOHIDSystemClass), &iter);
        assert(KERN_SUCCESS == kr);
        
        service = IOIteratorNext(iter);
        assert(service);
        
        kr = IOServiceOpen(service, mach_task_self(),
                           kIOHIDParamConnectType, &sEventDrvrRef);
        assert(KERN_SUCCESS == kr);
        
        IOObjectRelease( service );
        IOObjectRelease( iter );
    }
    return sEventDrvrRef;
}

static void HIDPostAuxKey( const UInt8 auxKeyCode )
{
    NXEventData   event;
    kern_return_t kr;
    IOGPoint      loc = { 0, 0 };
    
    // Key press event
    UInt32      evtInfo = auxKeyCode << 16 | NX_KEYDOWN << 8;
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

+ (void)play
{
    HIDPostAuxKey(NX_KEYTYPE_PLAY);
}

+ (void)forward
{
    HIDPostAuxKey(NX_KEYTYPE_FAST);
}

+ (void)back
{
    HIDPostAuxKey(NX_KEYTYPE_REWIND);
}

@end
