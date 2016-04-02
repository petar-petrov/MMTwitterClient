//
//  MMTwitterManager.h
//  MMTwitterClient
//
//  Created by Petar Petrov on 22/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

@interface MMTwitterManager : NSObject

+ (instancetype)sharedManager;

- (void)loginWithCompletionHandler:(void (^)(NSError *error))handler;
- (void)loginWithViewConroller:(UIViewController *)viewController completionHandler:(void (^)(NSError *))handler;
- (void)logout;

- (void)getUserTimelineWithCompletion:(void (^)(NSArray *tweets, NSUInteger sinceID, NSError *error))handler;
- (void)getHomeTimelineWithCompletion:(void (^)(NSArray *tweets, NSUInteger sinceID, NSError *error))handler;

- (void)postTweetWithText:(NSString *)text image:(UIImage *)image url:(NSURL *)url;



@end
