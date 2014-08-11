

  

 //                                         _____   _____   _____
 //                                        |     | |     | |     |
 //                                        |_____| |_____| |_____|
 //                                           |       |       |
 //                                           |       |       |
 //                                           |       |       |
 //                                           |       |       |
 //                                           V       V       V
 //                                         ---------------------
 //                                                   |
 //                                                   |
 //                                                   |
 //                                                   V




// -------------------------------------------------------------------------------------------------------------------------

  dispatch_queue_t queue = dispatch_get_global_qeueue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_group_t dispatchGroup = dispatch_group_create();
  
  for (NSUInteger i = 0; i < [contentGroup.subGroups count]; ++i) {
  
    dispatch_group_async(dispatchGroup, queue, ^{

      [self.client getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        // do sth..

      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        // do sth..

      }];

    });

  }

  // do sth..
  
  dispatch_group_notify(dispatchGroup, queue, ^{

    // all blocks completed, but not requests

  });

// -------------------------------------------------------------------------------------------------------------------------

  dispatch_group_t dispatchGroup = dispatch_group_create();
  
  for (NSUInteger i = 0; i < [contentGroup.subGroups count]; ++i) {
  
    dispatch_group_enter(dispatchGroup);
    
    [self.client getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
  
      // do sth..

      dispatch_group_leave(dispatchGroup);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

      // do sth..

      dispatch_group_leave(dispatchGroup);

    }];
  }

  // do sth..
  
  // dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); // blocking ui
  // // blocks completed

  dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{

    // all blocks completed

  });

// -------------------------------------------------------------------------------------------------------------------------

https://developer.apple.com/library/ios/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html

https://developer.apple.com/library/mac/documentation/Performance/Reference/GCD_libdispatch_Ref/Reference/reference.html



