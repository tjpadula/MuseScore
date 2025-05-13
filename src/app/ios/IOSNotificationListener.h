//
//  IOSNotificationListener.h
//  MuseScoreStudio
//
//  Created by Tom Padula on 5/13/25.
//

void iOSNotificationListenerConnect(void);

#if __OBJC__

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IOSNotificationListener : NSObject

- (void) connect;

@end

NS_ASSUME_NONNULL_END
#endif
