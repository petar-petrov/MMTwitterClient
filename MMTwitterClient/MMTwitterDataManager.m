//
//  MMTwitterDataManager.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 22/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMTwitterDataManager.h"

#import "MMTwitterDataStore.h"

@interface MMTwitterDataManager ()

@property (strong, nonatomic) MMTwitterDataStore *dataStore;

@property (strong, nonatomic) NSNumber *greatestTweetIDNumber;



@end

@implementation MMTwitterDataManager

#pragma mark - Custom Accessors

- (NSNumber *)greatestTweetIDNumber {
    if (!_greatestTweetIDNumber) {
        _greatestTweetIDNumber = [NSNumber numberWithUnsignedInteger:0];
    }
    
    return _greatestTweetIDNumber;
}

#pragma mark - Class Initilizers

+ (instancetype)sharedManager {
    static MMTwitterDataManager *dataManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        dataManager = [[MMTwitterDataManager alloc] init];
    });
    
    return dataManager;
}

#pragma mark - Instance Initilizers

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.dataStore = [MMTwitterDataStore defaultStore];
    }
    
    return self;
}

#pragma mark - Add/Delete Tweet/s

-(void)addTweets:(NSArray *)tweets {
    
    [self.dataStore.defaultPrivateContext performBlock:^{
        if (tweets) {
            @autoreleasepool {
                for (NSInteger index = 0; index < tweets.count; index++) {
                    
                    // set the flag to YES when last tweet is reached
                    BOOL flag = (index == (tweets.count - 1)) ? YES : NO;
                    
                    [self addTweet:tweets[index]
                         inContext:self.dataStore.defaultPrivateContext
                              save:flag];
                }
            }
        }
    }];
}

- (NSArray <Tweet *>*)getUserTimeline {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:kDataStoreTweetEntityName inManagedObjectContext:self.dataStore.mainContext];
    
    request.predicate = [NSPredicate predicateWithFormat:@"isUserTimeline == YES"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    
    NSArray *fetchedTweets = [self.dataStore.mainContext executeFetchRequest:request error:nil]; // no error handling
    
    return fetchedTweets;
}

-(NSArray <User*>*)mutedUsers {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:kDataStoreUserEntityName inManagedObjectContext:self.dataStore.mainContext];
    
    request.predicate = [NSPredicate predicateWithFormat:@"muted == YES"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    
    NSArray *fetchedTweets = [self.dataStore.mainContext executeFetchRequest:request error:nil]; // no error handling
    
    return fetchedTweets;
}

- (NSArray <Tweet *>*)getHomeTimeline {
    
    return nil;
}

- (NSUInteger)sinceIDForUserTimeline {
    
    return self.greatestTweetIDNumber.unsignedIntegerValue;
}

- (NSUInteger)sinceIDForHomeTimeline {
    
    return 0;
}

#pragma mark - 

- (User *)getUserForID:(NSNumber *)userID {
    return [self getUserForID:userID inContext:self.dataStore.mainContext];
}

- (BOOL)deleteTweet:(Tweet *)tweet error:(NSError **)error {
    Tweet *tweetToDelete = [self.dataStore.mainContext existingObjectWithID:tweet.objectID error:error];
    
    if (error) {
        return NO;
    }
    
    [self.dataStore.mainContext deleteObject:tweetToDelete];
    
    if ([self.dataStore.mainContext save:error]) {
        return YES;
    }
    
    return NO;
}

/* no error handling what so ever */
- (void)tweetRetweeted:(Tweet *)tweet {
    Tweet *tweetToRetweet = [self.dataStore.mainContext existingObjectWithID:tweet.objectID error:nil];
    
    tweetToRetweet.retweeted = @(YES);
    tweetToRetweet.isUserTimeline = @(YES);
    
    if ([self.dataStore.mainContext save:nil]) {
        
    }
}

/* no error handling what so ever */
- (void)updateTweet:(Tweet *)tweet favoriedStatus:(BOOL)status{
    Tweet *tweetToRetweet = [self.dataStore.mainContext existingObjectWithID:tweet.objectID error:nil];
    
    tweetToRetweet.favorited = @(status);
    
    
    if ([self.dataStore.mainContext save:nil]) {
        
    }
}

- (void)updateUser:(User *)user mutedStatus:(BOOL)status {
    User *userToUpdate = [self.dataStore.mainContext existingObjectWithID:user.objectID error:nil];
    
    userToUpdate.muted = @(status);
    
    if ([self.dataStore.mainContext save:nil]) {
        
    }
}


#pragma mark - Private

- (void)addTweet:(NSDictionary *)tweetInfo inContext:(NSManagedObjectContext *)context save:(BOOL)flag {
    Tweet *tweet = [self getTweetForID:tweetInfo[@"id"] inContext:context];
    
    if (tweet == nil || (!tweet.retweeted.boolValue && ((NSNumber *)tweetInfo[@"retweeted"]).boolValue)) {
        tweet = [NSEntityDescription insertNewObjectForEntityForName:kDataStoreTweetEntityName inManagedObjectContext:context];
        
        NSDate *date = [[self dateFormatter] dateFromString:[tweetInfo valueForKey:@"created_at"]];
        
        tweet.createdAt = date;
        tweet.text = [tweetInfo valueForKey:@"text"];
        tweet.retweeted = [tweetInfo valueForKey:@"retweeted"];
        tweet.favorited = [tweetInfo valueForKey:@"favorited"];
        tweet.tweetID = [tweetInfo valueForKey:@"id"];
        
        if (tweetInfo[@"entities"][@"media"]) {
            tweet.mediaURL = tweetInfo[@"entities"][@"media"][0][@"media_url_https"];
            tweet.mediaType = tweetInfo[@"entities"][@"media"][0][@"type"];
        }
        
        tweet.hasUser = [self addUser:[tweetInfo valueForKey:@"user"] inContext:context];
        
        NSString *storedUserID = [[NSUserDefaults standardUserDefaults] valueForKey:@"TwitterUserID"];
        NSString *userID = tweet.hasUser.userID.stringValue ;
        
        if ([userID isEqualToString:storedUserID]) {
            tweet.isUserTimeline = @(YES);

        } else {
            tweet.isUserTimeline = @(NO);
        }
        
        if ([self.greatestTweetIDNumber compare:(NSNumber *)tweetInfo[@"id"]] == NSOrderedAscending) {
            self.greatestTweetIDNumber = tweetInfo[@"id"];
        }
     
    }
    
    if (flag) {
        if (![context save:nil]) { // no error handling
            abort();
        }
    }
}

- (User *)addUser:(NSDictionary *)userInfo inContext:(NSManagedObjectContext *)context {
    User *user = [self getUserForID:[userInfo valueForKey:@"id"] inContext:context];
    
    // create new user if it does not exist already
    if (user == nil) {
        user = [NSEntityDescription insertNewObjectForEntityForName:kDataStoreUserEntityName inManagedObjectContext:context];
        
        user.name = [userInfo valueForKey:@"name"];
        user.userID = [userInfo valueForKey:@"id"];
        user.profileImageURL = [userInfo valueForKey:@"profile_image_url_https"];
        user.screenName = [userInfo valueForKey:@"screen_name"];
        user.muted = @(NO);
        user.profileBackgroundImageURL = [userInfo valueForKey:@"profile_background_image_url_https"];
        
        NSDate *date = [[self dateFormatter] dateFromString:[userInfo valueForKey:@"created_at"]];
        
        user.createdAt = date;
    }
    
    return user;
}

- (User *)getUserForID:(NSNumber *)userID inContext:(NSManagedObjectContext *)context{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:kDataStoreUserEntityName inManagedObjectContext:context];
    
    request.predicate = [NSPredicate predicateWithFormat:@"userID == %@", userID];
    
    NSArray *fetchedUsers = [context executeFetchRequest:request error:nil]; // error not handled
    
    return [fetchedUsers lastObject];
}

- (Tweet *)getTweetForID:(NSNumber *)tweetID inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:kDataStoreTweetEntityName inManagedObjectContext:context];
    
    request.predicate = [NSPredicate predicateWithFormat:@"tweetID == %@", tweetID];
    
    NSArray *fetchedTweets = [context executeFetchRequest:request error:nil]; // error not handled
    
    return [fetchedTweets lastObject];
}

- (NSDateFormatter *)dateFormatter {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss ZZZ yyyy";
    
    return dateFormatter;
}

@end
