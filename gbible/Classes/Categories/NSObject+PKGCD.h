//
//  NSObject+PKGCD.h
//  gbible
//
//  Created by Kerri Shotts on 8/13/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PKGCD)

- (dispatch_queue_t) onBackgroundThread;
- (dispatch_queue_t) onMainThread;
- (void) performBlockAsynchronously:(void (^)())block afterDelay:(NSTimeInterval)delay onThread: (dispatch_queue_t)thread;
- (void) performBlockAsynchronously:(void (^)())block onThread: (dispatch_queue_t) thread;
- (void) performBlockAsynchronouslyInBackground:(void (^)())block afterDelay:(NSTimeInterval)delay;
- (void) performBlockAsynchronouslyInForeground:(void (^)())block afterDelay:(NSTimeInterval)delay;
- (void) performBlockAsynchronouslyInBackground:(void (^)())block;
- (void) performBlockAsynchronouslyInForeground:(void (^)())block;

@end
