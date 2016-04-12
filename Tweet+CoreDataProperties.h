//
//  Tweet+CoreDataProperties.h
//  MMTwitterClient
//
//  Created by Petar Petrov on 12/04/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Tweet.h"

NS_ASSUME_NONNULL_BEGIN

@interface Tweet (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSNumber *favorited;
@property (nullable, nonatomic, retain) NSNumber *isUserTimeline;
@property (nullable, nonatomic, retain) NSString *mediaType;
@property (nullable, nonatomic, retain) NSString *mediaURL;
@property (nullable, nonatomic, retain) NSNumber *retweeted;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSNumber *tweetID;
@property (nullable, nonatomic, retain) NSNumber *isHomeTimeline;
@property (nullable, nonatomic, retain) User *hasUser;

@end

NS_ASSUME_NONNULL_END
