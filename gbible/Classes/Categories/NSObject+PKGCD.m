//
//  NSObject+PKGCD.m
//  gbible
//
//  Created by Kerri Shotts on 8/13/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

// inspired partly by http://stackoverflow.com/questions/4139219/how-do-you-trigger-a-block-after-a-delay-like-performselectorwithobjectafter
// especially http://stackoverflow.com/a/14830103

#import "NSObject+PKGCD.h"

@implementation NSObject (PKGCD)

- (dispatch_queue_t) onBackgroundThread
{
  return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
}

- (dispatch_queue_t) onMainThread
{
  return dispatch_get_main_queue();
}

- (void) performBlockAsynchronously:(void (^)())block afterDelay:(NSTimeInterval)delay onThread: (dispatch_queue_t)thread
{
  void (^block_)() = [block copy];
  dispatch_async ( thread, ^{
    dispatch_after( dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC ),
      thread, block_);
  });
}
- (void) performBlockAsynchronously:(void (^)())block onThread: (dispatch_queue_t) thread
{
  void (^block_)() = [block copy];
  dispatch_async( thread, block_ );
}

- (void) performBlockAsynchronouslyInBackground:(void (^)())block afterDelay:(NSTimeInterval)delay
{
  [self performBlockAsynchronously:block afterDelay:delay onThread:[self onBackgroundThread]];
}

- (void) performBlockAsynchronouslyInForeground:(void (^)())block afterDelay:(NSTimeInterval)delay
{
  [self performBlockAsynchronously:block afterDelay:delay onThread:[self onMainThread]];
}

- (void) performBlockAsynchronouslyInBackground:(void (^)())block
{
  [self performBlockAsynchronously:block onThread:[self onBackgroundThread]];
}

- (void) performBlockAsynchronouslyInForeground:(void (^)())block
{
  [self performBlockAsynchronously:block onThread:[self onMainThread]];
}


@end
