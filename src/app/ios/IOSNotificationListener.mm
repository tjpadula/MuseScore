//
//  IOSNotificationListener.m
//  MuseScoreStudio
//
//  Created by Tom Padula on 5/13/25.
//

#import "IOSNotificationListener.h"

#import <UIKit/UIKit.h>

#include <iostream>

IOSNotificationListener* sStaticListener = [IOSNotificationListener new];

void iOSNotificationListenerConnect(void)
{
    if (!sStaticListener) {
        sStaticListener = [IOSNotificationListener new];
    }
    
    [sStaticListener connect];
}

@interface IOSNotificationListener ()

- (void) _willResignActive:(NSNotification*) inNotification;
- (void) _didBecomeActive:(NSNotification*) inNotification;
- (void) _willTerminate:(NSNotification*) inNotification;

@end

@implementation IOSNotificationListener

- (void) connect
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_willTerminate:) name:UIApplicationWillTerminateNotification object:nil];
}

- (void) _willResignActive:(NSNotification*) inNotification
{
    std::cerr << __PRETTY_FUNCTION__ << std::endl;
}

- (void) _didBecomeActive:(NSNotification*) inNotification
{
    std::cerr << __PRETTY_FUNCTION__ << std::endl;
}

- (void) _willTerminate:(NSNotification*) inNotification
{
    std::cerr << __PRETTY_FUNCTION__ << std::endl;
}

@end
