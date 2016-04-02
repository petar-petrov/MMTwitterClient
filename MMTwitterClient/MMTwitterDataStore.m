//
//  MMTwitterDataStore.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 22/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMTwitterDataStore.h"

@interface MMTwitterDataStore ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation MMTwitterDataStore

@synthesize defaultPrivateContext = _defaultPrivateContext;

static NSString *const kModelResource = @"TwitterModel";

#pragma mark - Custom Accessors

- (NSManagedObjectContext *)mainContext {
    return self.managedObjectContext;
}

- (NSManagedObjectContext *)defaultPrivateContext {
    if (!_defaultPrivateContext) {
        _defaultPrivateContext = [self privateContext];
    }
    
    return _defaultPrivateContext;
}

#pragma mark - Initilizers

+ (instancetype)defaultStore {
    static MMTwitterDataStore *dataStore = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        dataStore = [[MMTwitterDataStore alloc] init];
    });
    
    return dataStore;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self setupSaveNotification];
    }
    
    return self;
}

#pragma mark - Public

- (void)saveContext {
    __autoreleasing NSError *error = nil;
    
    if (self.managedObjectContext != nil) {
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)privateContext {
    NSManagedObjectContext *privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    privateManagedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
    privateManagedObjectContext.undoManager = nil;
    privateManagedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    return privateManagedObjectContext;
}

#pragma mark - Private

- (void)setupSaveNotification {
    __weak MMTwitterDataStore *weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note){
                                                      MMTwitterDataStore *strongSelf = weakSelf;
                                                      
                                                      if (note.object != strongSelf.managedObjectContext) {
                                                          [strongSelf.managedObjectContext performBlock:^{
                                                              [strongSelf.managedObjectContext mergeChangesFromContextDidSaveNotification:note];
                                                          }];
                                                      }
                                                  }];
}

#pragma mark - Core Data

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    if (self.persistentStoreCoordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kModelResource withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TwitterDB.sqlite"];
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES};
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    __autoreleasing NSError *error = nil;
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:storeURL
                                                        options:options
                                                           error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Document Directory

// Return the URL to the application's Documents directory

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
