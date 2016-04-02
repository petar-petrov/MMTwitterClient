//
//  Tweet+CoreDataProperties.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 25/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Tweet+CoreDataProperties.h"

@implementation Tweet (CoreDataProperties)

@dynamic createdAt;
@dynamic mediaURL;
@dynamic mediaType;
@dynamic tweetID;
@dynamic retweeted;
@dynamic text;
@dynamic isUserTimeline;
@dynamic hasUser;

@end
