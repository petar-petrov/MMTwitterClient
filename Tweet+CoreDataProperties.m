//
//  Tweet+CoreDataProperties.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 12/04/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Tweet+CoreDataProperties.h"

@implementation Tweet (CoreDataProperties)

@dynamic createdAt;
@dynamic favorited;
@dynamic isUserTimeline;
@dynamic mediaType;
@dynamic mediaURL;
@dynamic retweeted;
@dynamic text;
@dynamic tweetID;
@dynamic isHomeTimeline;
@dynamic hasUser;

@end
