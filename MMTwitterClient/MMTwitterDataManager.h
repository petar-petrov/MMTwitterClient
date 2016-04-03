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


- (User *)getUserForID:(NSNumber *)userID;

@end
