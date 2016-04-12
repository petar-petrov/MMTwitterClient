//
//  User+CoreDataProperties.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 11/04/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User+CoreDataProperties.h"

@implementation User (CoreDataProperties)

@dynamic createdAt;
@dynamic name;
@dynamic profileImageURL;
@dynamic screenName;
@dynamic userID;
@dynamic muted;
@dynamic tweets;

@end
