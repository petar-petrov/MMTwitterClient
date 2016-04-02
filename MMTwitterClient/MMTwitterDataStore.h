//
//  MMTwitterDataStore.h
//  MMTwitterClient
//
//  Created by Petar Petrov on 22/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreData;

@interface MMTwitterDataStore : NSObject

+ (instancetype)defaultStore;

@property (nonatomic, readonly) NSManagedObjectContext *mainContext;
@property (nonatomic, readonly) NSManagedObjectContext *defaultPrivateContext;

- (void)saveContext;

- (NSManagedObjectContext *)privateContext;

@end
