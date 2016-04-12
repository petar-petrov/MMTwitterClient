//
//  MMTwitterManager.h
//  MMTwitterClient
//
//  Created by Petar Petrov on 22/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

@class Tweet, User;

typedef void (^MMTwitterManagerCompletionBlock)(NSError *error);
typedef void (^MMTwitterManagerImageUploadCompletedBlock)(NSString *mediaID, NSError *error);

@interface MMTwitterManager : NSObject

@property (assign, nonatomic, readonly, getter=isLoggedIn) BOOL loggedIn;

+ (instancetype)sharedManager;

- (void)loginWithCompletionHandler:(MMTwitterManagerCompletionBlock)handler;
- (void)loginWithViewConroller:(UIViewController *)viewController completionHandler:(MMTwitterManagerCompletionBlock)handler;

- (void)getUserTimelineWithCompletion:(MMTwitterManagerCompletionBlock)handler;
- (void)getHomeTimelineWithCompletion:(MMTwitterManagerCompletionBlock)handler;

- (User *)blockUserWithID:(NSString *)userID;
- (NSArray <User *> *)mutedUsers;
- (void)changeUser:(User *)user mutedStatus:(BOOL)status;

- (void)postTweetWithText:(NSDictionary *)parameters image:(UIImage *)image url:(NSURL *)url complete:(MMTwitterManagerCompletionBlock)handler;
- (void)changeRetweetStatusOfTweet:(Tweet *)tweet;
- (void)changeFavoriteStatusOfTweet:(Tweet *)tweet compeleted:(MMTwitterManagerCompletionBlock)handler;
- (void)deleteTweet:(Tweet *)tweet competed:(MMTwitterManagerCompletionBlock)completed;

- (void)uploadMedia:(UIImage *)image completed:(MMTwitterManagerImageUploadCompletedBlock)handler;

@end
