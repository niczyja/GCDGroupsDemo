//
//  AppDelegate.m
//  GCDGroupsDemo
//
//  Created by Maciej Sienkiewicz on 27.02.2014.
//  Copyright (c) 2014 Maciej Sienkiewicz. All rights reserved.
//

#import "AppDelegate.h"

#define SLEEP_TIME 1000
#define TASKS_COUNT 10000

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//  [self dispatchGroupAsyncMethod];
  
  [self serialQueueOrCustomCounterMethod];
  
//  [self dispatchGroupEnterLeaveMethod];

  return YES;
}


// Method to simulate background task that we need to perform multiple times. It can be some delegate method with callback
// or AFNetworking request operation with success and failure blocks or just NSURLConnection completion handler. Most likely
// something beyond our control.
- (void)taskWithNumber:(NSUInteger)number andCompletionBlock:(void (^)(void))completionBlock
{
  NSLog(@"Task number %lu", (unsigned long)number);
  usleep(arc4random_uniform(SLEEP_TIME));
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    usleep(arc4random_uniform(SLEEP_TIME));
    completionBlock();
  });
}


// Insufficient approach using dispatch_group_async from Apple Concurrency Programming Guide (Waiting on Groups of Queued Tasks)
- (void)dispatchGroupAsyncMethod
{
  dispatch_group_t group = dispatch_group_create();
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  __weak AppDelegate *weakSelf = self;
  
  for (NSUInteger i = 0; i < TASKS_COUNT; ++i) {
    dispatch_group_async(group, queue, ^{
      [weakSelf taskWithNumber:i andCompletionBlock:^{
        NSLog(@"End of task %lu", (unsigned long)i);
      }];
    });
  }
  
  dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
  NSLog(@"All tasks done");
}


// Working but not clean solution using custom counter which needs to be synchronized (or serial queue must be used)
- (void)serialQueueOrCustomCounterMethod
{
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  __block NSUInteger inProgress = TASKS_COUNT;
  __weak AppDelegate *weakSelf = self;
  
  for (NSUInteger i = 0; i < TASKS_COUNT; ++i) {
    dispatch_async(queue, ^{
      [weakSelf taskWithNumber:i andCompletionBlock:^{
        NSLog(@"End of task %lu", (unsigned long)i);
        NSUInteger localInProgress;
        
        @synchronized(weakSelf) {
          localInProgress = --inProgress;
        }
        
        if (localInProgress == 0) {
          NSLog(@"All tasks done");
        }
      }];
    });
  }
}


// Nice and clean solution using dispatch_group_enter and dispatch_group_leave
- (void)dispatchGroupEnterLeaveMethod
{
  dispatch_group_t group = dispatch_group_create();
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  __weak AppDelegate *weakSelf = self;
  
  for (NSUInteger i = 0; i < TASKS_COUNT; ++i) {
    dispatch_async(queue, ^{
      dispatch_group_enter(group);
      [weakSelf taskWithNumber:i andCompletionBlock:^{
        NSLog(@"End of task %lu", (unsigned long)i);
        dispatch_group_leave(group);
      }];
    });
  }
  
  dispatch_group_notify(group, queue, ^{
    NSLog(@"All tasks done");
  });
  
}


@end
