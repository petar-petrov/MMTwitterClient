//
//  MMTwitterManager.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 22/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMTwitterManager.h"
#import <TwitterKit/TwitterKit.h>

#import "MMTwitterDataManager.h"


@interface MMTwitterManager()

@property (strong, nonatomic) TWTRSession *session;
@property (strong, nonatomic) TWTRAPIClient *client;

@property (assign, nonatomic) NSUInteger greatestTweetID;
@property (assign, nonatomic) NSUInteger greatestHomeTimelineTweetID;

@property (nonatomic, readonly) MMTwitterDataManager *dataManager;

@end

@implementation MMTwitterManager

@synthesize dataManager = _dataManager;

static NSString *const kTimelineRequestCount = @"30";

static NSString *const kGetMethod   = @"GET";
static NSString *const kPostMethod  = @"POST";

static NSString *const kTwitterAPIUserTimelineURL   = @"https://api.twitter.com/1.1/statuses/user_timeline.json";
static NSString *const kTwitterAPIHomeTimelineURL   = @"https://api.twitter.com/1.1/statuses/home_timeline.json";

#pragma mark - Custom Accessors

- (MMTwitterDataManager *)dataManager {
    if (!_dataManager) {
        _dataManager = [MMTwitterDataManager sharedManager];
    }
    
    return _dataManager;
}

#pragma mark - Initilizers

+ (instancetype)sharedManager {
    static MMTwitterManager *manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[MMTwitterManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

#pragma mark - Log In/Out

- (void)loginWithCompletionHandler:(void (^)(NSError *error))handler {
    
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {
            self.client = [[TWTRAPIClient alloc] initWithUserID:[session userID]];
        } else {
            NSLog(@"Login error: %@", [error localizedDescription]);
        }
        
        [self storeUserIDToUserDefaults:[session userID]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler != nil) {
                handler(nil);
            }
        });
        
    }];
    
    
}

- (void)loginWithViewConroller:(UIViewController *)viewController completionHandler:(void (^)(NSError *))handler {
    [[Twitter sharedInstance] logInWithViewController:viewController completion:^(TWTRSession *session, NSError *error) {
        if (session) {
            self.client = [[TWTRAPIClient alloc] initWithUserID:[session userID]];
        } else {
            NSLog(@"Login error: %@", [error localizedDescription]);
        }
        
        [self storeUserIDToUserDefaults:[session userID]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler != nil) {
                handler(nil);
            }
        });
        
    }];
}

- (void)logout {
//    [[Twitter sharedInstance] logOut];
}

#pragma mark - User's Timeline

- (void)getUserTimelineWithCompletion:(void (^)(NSArray *tweets, NSUInteger sinceID, NSError *error))handler {
    
    __block NSMutableArray *timeline = nil;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"count":kTimelineRequestCount}];
    
    if (self.greatestTweetID) {
        [parameters setObject:[NSString stringWithFormat:@"%lud",self.greatestTweetID] forKey:@"since_id"];
    }
    
    __block NSUInteger sinceIDInteger;
    
    if (self.client) {
        NSURLRequest *request = [self.client URLRequestWithMethod:kGetMethod URL:kTwitterAPIUserTimelineURL parameters:parameters error:nil];
        
        [self.client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError == nil ) {
                id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
//                NSLog(@"%@", json);
                
                timeline = [NSMutableArray array];
                
                [self.dataManager addTweets:json];
                
                for (NSDictionary *dic in json) {
                    [timeline addObject:[dic objectForKey:@"text"]];
                    
                    // set the greatestTweetID
                }
                
                sinceIDInteger = [self.dataManager sinceIDForUserTimeline];
                self.greatestTweetID = sinceIDInteger;
            }
            
            if (handler != nil) {
                handler([timeline copy], sinceIDInteger, connectionError);
            }
        }];
    }
}

- (void)getHomeTimelineWithCompletion:(void (^)(NSArray *tweets, NSUInteger sinceID, NSError *error))handler {
    __block NSMutableArray *timeline = nil;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"count":kTimelineRequestCount}];
    
    if (self.greatestHomeTimelineTweetID) {
        [parameters setObject:[NSString stringWithFormat:@"%lud",self.greatestHomeTimelineTweetID] forKey:@"since_id"];
    }
    
    __block NSUInteger sinceIDInteger;
    
    if (self.client) {
        NSURLRequest *request = [self.client URLRequestWithMethod:kGetMethod URL:kTwitterAPIHomeTimelineURL parameters:parameters error:nil];
        
        [self.client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError == nil ) {
                id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
//                NSLog(@"%@", json);
                
                timeline = [NSMutableArray array];
                
                [self.dataManager addTweets:json];
                
                for (NSDictionary *dic in json) {
                    [timeline addObject:[dic objectForKey:@"text"]];
                    
                    // set the greatestTweetID
                }
                
                sinceIDInteger = [self.dataManager sinceIDForUserTimeline];
                self.greatestHomeTimelineTweetID = sinceIDInteger;
            }
            
            if (handler != nil) {
                handler([timeline copy], sinceIDInteger, connectionError);
            }
        }];
    }
}

#pragma mark - Post Tweets

- (void)postTweetWithText:(NSString *)text image:(UIImage *)image url:(NSURL *)url {
    
}

#pragma mark - Private

- (void)storeUserIDToUserDefaults:(NSString *)userID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults valueForKey:@"TwitterUserID"] == nil || ![[userDefaults valueForKey:@"TwitterUserID"] isEqualToString:userID]) {
        
        [userDefaults setObject:userID forKey:@"TwitterUserID"];
    }
}

@end
