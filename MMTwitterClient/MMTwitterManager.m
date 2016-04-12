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
#import "MMConstants.h"


@interface MMTwitterManager()

@property (strong, nonatomic) TWTRSession *session;
@property (strong, nonatomic) TWTRAPIClient *client;

@property (nonatomic, readonly) MMTwitterDataManager *dataManager;

@property (assign, nonatomic, readwrite, getter=isLoggedIn) BOOL loggedIn;

@end

@implementation MMTwitterManager

@synthesize dataManager = _dataManager;

static NSString *const kTimelineRequestCount = @"30";

static NSString *const kGetMethod   = @"GET";
static NSString *const kPostMethod  = @"POST";

static NSString *const kTwitterAPIUserTimelineURL       = @"https://api.twitter.com/1.1/statuses/user_timeline.json";
static NSString *const kTwitterAPIHomeTimelineURL       = @"https://api.twitter.com/1.1/statuses/home_timeline.json";
static NSString *const kTwitterAPIDestroyTweetURL       = @"https://api.twitter.com/1.1/statuses/destroy/";

static NSString *const kTwitterAPIRetweetURL            = @"https://api.twitter.com/1.1/statuses/retweet/";
static NSString *const kTwitterAPIUnretweetURL          = @"https://api.twitter.com/1.1/statuses/unretweet/";

static NSString *const kTwitterAPIFavoritesCreateURL    = @"https://api.twitter.com/1.1/favorites/create.json";
static NSString *const kTwitterAPIFavoritesDestroyURL   = @"https://api.twitter.com/1.1/favorites/destroy.json";

static NSString *const kTwitterAPIBlockCreateURL        = @"https://api.twitter.com/1.1/blocks/create.json";
static NSString *const kTwitterAPIBlockDestroyURL       = @"https://api.twitter.com/1.1/blocks/destroy.json";

static NSString *const kTwitterAPIUpdateStatusURL       = @"https://api.twitter.com/1.1/statuses/update.json";

static NSString *const kTwitterAPIMuteCreateURL         = @"https://api.twitter.com/1.1/mutes/users/create.json";
static NSString *const kTwitterAPIMuteDistroyURL        = @"https://api.twitter.com/1.1/mutes/users/destroy.json";

typedef void (^MMTwitterRequestSuccessBlock)(NSData *data, NSError *error);

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
            [self setupClientForSession:session];
            
            self.loggedIn = YES;
        } else {
            NSLog(@"Login error: %@", [error localizedDescription]);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler != nil) {
                handler(error);
            }
        });
        
    }];
    
    
}

- (void)loginWithViewConroller:(UIViewController *)viewController completionHandler:(void (^)(NSError *))handler {
    [[Twitter sharedInstance] logInWithViewController:viewController completion:^(TWTRSession *session, NSError *error) {
        if (session) {
            [self setupClientForSession:session];
            
            self.loggedIn = YES;
        } else {
            NSLog(@"Login error: %@", [error localizedDescription]);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler != nil) {
                handler(nil);
            }
        });
        
    }];
}

#pragma mark - User's Timeline

- (void)getUserTimelineWithCompletion:(void (^)(NSError *error))handler {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"count":kTimelineRequestCount}];
    
    [self sendTwitterRequestWithURL:kTwitterHomeTimelineKey
                         parameters:parameters
                             method:kGetMethod
                          completed:^(NSData *data, NSError *error) {
                              id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
              
                              [self.dataManager addTweets:json];
                              [self updateLastUpdatedDateForTimelineKey:kTwitterUserTimelineKey];
                          }
                             failed:handler];
}

- (void)getHomeTimelineWithCompletion:(void (^)(NSError *error))handler {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"count":kTimelineRequestCount}];
    
    [self sendTwitterRequestWithURL:kTwitterAPIHomeTimelineURL
                         parameters:parameters
                             method:kGetMethod
                          completed:^(NSData *data, NSError *error){
                              id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
              
                              [self.dataManager addTweets:json];
                              [self updateLastUpdatedDateForTimelineKey:kTwitterHomeTimelineKey];
                          }
                             failed:handler];
}

#pragma mark - Mute/Block Mehtods

- (User *)blockUserWithID:(NSString *)userID {
    
    return nil;
}

- (NSArray <User *> *)mutedUsers {
    
    return [self.dataManager mutedUsers];
}

- (void)changeUser:(User *)user mutedStatus:(BOOL)status; {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"user_id":user.userID.stringValue}];
    
    NSString *url = status ? kTwitterAPIMuteCreateURL : kTwitterAPIMuteDistroyURL;
    
    [self sendTwitterRequestWithURL:url
                         parameters:parameters
                             method:kPostMethod
                          completed:^(NSData *data, NSError *error) {
//                              id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                              
                              [self.dataManager updateUser:user mutedStatus:status];
                          }
                             failed:nil];
}

#pragma mark - Post/Retweet/Delete Tweets

- (void)postTweetWithText:(NSDictionary *)parameters image:(UIImage *)image url:(NSURL *)url complete:(void (^)(NSError *error))handler {
    [self sendTwitterRequestWithURL:kTwitterAPIUpdateStatusURL
                         parameters:parameters
                             method:kPostMethod
                          completed:^(NSData *data, NSError *error) {
                              id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                              NSLog(@"%@", json);
                              
                              if (handler != nil) {
                                  handler(error);
                              }
                          }
                             failed:handler];
}

- (void)deleteTweet:(Tweet *)tweet competed:(void (^)(NSError *error))completed {
    
    NSString *urlString = [kTwitterAPIDestroyTweetURL stringByAppendingString:[NSString stringWithFormat:@"%@.json", tweet.tweetID.stringValue]];
    
    [self sendTwitterRequestWithURL:urlString
                         parameters:nil
                             method:kPostMethod
                          completed:^(NSData *data, NSError *error) {
                              [self.dataManager deleteTweet:tweet error:nil];
                              
                              if (completed != nil) {
                                  completed(error);
                              }
                          }
                             failed:completed];
}

- (void)changeRetweetStatusOfTweet:(Tweet *)tweet {
    
    NSString *baseURL = tweet.retweeted.boolValue ? kTwitterAPIUnretweetURL : kTwitterAPIRetweetURL;
    
    NSString *urlString = [baseURL stringByAppendingString:[NSString stringWithFormat:@"%@.json", tweet.tweetID.stringValue]];
    
    [self sendTwitterRequestWithURL:urlString
                         parameters:nil
                             method:kPostMethod
                          completed:^(NSData *data, NSError *error){
                              if (tweet.retweeted.boolValue) {
                                  [self.dataManager deleteTweet:tweet error:nil];
                              }
                          }
                             failed:nil];
}

- (void)changeFavoriteStatusOfTweet:(Tweet *)tweet compeleted:(void(^)(NSError *error))handler{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"id":tweet.tweetID.stringValue}];
    
    NSString *urlString = tweet.favorited.boolValue ? kTwitterAPIFavoritesDestroyURL : kTwitterAPIFavoritesCreateURL;
    
    [self sendTwitterRequestWithURL:urlString
                         parameters:parameters
                             method:kPostMethod
                          completed:^(NSData *data, NSError *error){
                             [self.dataManager updateTweet:tweet favoriedStatus:!tweet.favorited.boolValue];
                              
                              if (handler != nil) {
                                  handler(error);
                              }
                          }
                             failed:handler];
}

#pragma mark - Upload Media

- (void)uploadMedia:(UIImage *)image completed:(void (^)(NSString *mediaID, NSError *error))handler {
    
    
    if (self.client) {
        if (image) {
            NSData *imageData = UIImageJPEGRepresentation(image, 0.7f);
            
            [self.client uploadMedia:imageData contentType:@"photo" completion:^(NSString *mediaID, NSError *error) {
                if (handler != nil) {
                    handler(mediaID, error);
                }
            }];
        }
        
    }
}

#pragma mark - Private

- (void)sendTwitterRequestWithURL:(NSString *)url
                       parameters:(NSDictionary *)parameters
                           method:(NSString *)method
                        completed:(MMTwitterRequestSuccessBlock)successBlock
                           failed:(MMTwitterManagerCompletionBlock)failedBlock {

    if (self.client) {
        
        NSURLRequest *request = [self.client URLRequestWithMethod:method URL:url parameters:parameters error:nil];
        
        [self.client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError == nil ) {
                if (successBlock !=nil) {
                    successBlock(data, connectionError);
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failedBlock != nil) {
                    failedBlock(connectionError);
                }
                
            });
            
        }];
    }
    
}
- (void)setupClientForSession:(TWTRSession *)session {
    self.client = [[TWTRAPIClient alloc] initWithUserID:[session userID]];
    
    [self storeUserIDToUserDefaults:[session userID]];
}

- (void)storeUserIDToUserDefaults:(NSString *)userID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults valueForKey:@"TwitterUserID"] == nil || ![[userDefaults valueForKey:@"TwitterUserID"] isEqualToString:userID]) {
        
        [userDefaults setObject:userID forKey:@"TwitterUserID"];
        [userDefaults synchronize];
    }
}

- (void)updateLastUpdatedDateForTimelineKey:(NSString *)type {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:[NSDate date] forKey:type];
    [userDefaults synchronize];
}

@end
