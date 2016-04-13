//
//  MMTwitterDataManager.h
//  MMTwitterClient
//
//  Created by Petar Petrov on 22/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Tweet.h"
#import "User.h"
#import "MMConstants.h"

@interface MMTwitterDataManager : NSObject

+ (instancetype)sharedManager;

- (void)addTweets:(NSArray *)tweets;

- (NSArray <Tweet *>*)getUserTimeline;
- (NSArray <Tweet *>*)getHomeTimeline;

- (NSUInteger)sinceIDForUserTimeline;
- (NSUInteger)sinceIDForHomeTimeline;

-(NSArray <User*>*)mutedUsers;
- (void)updateUser:(User *)user mutedStatus:(BOOL)status;


- (User *)getUserForID:(NSNumber *)userID;

- (BOOL)deleteTweet:(Tweet *)tweet error:(NSError **)error;
- (void)tweetRetweeted:(Tweet *)tweet;
- (void)updateTweet:(Tweet *)tweet favoriedStatus:(BOOL)status;
@end
