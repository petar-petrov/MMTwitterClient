 //
//  MMUserTimelineTableViewController.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 25/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMUserTimelineTableViewController.h"

#import "MMTwitterDataStore.h"
#import "MMConstants.h"
#import "Tweet.h"
#import "User.h"

#import "MMImageDetailsViewController.h"
#import "MMComposerViewController.h"
#import "MMTweetTableViewCell.h"
#import "MMTweetWithImageTableViewCell.h"
#import "MMImageTweetTableViewCell.h"
#import "UIImageView+Networking.h"
#import "MMTwitterManager.h"
#import "MMLinkLabel.h"

#import "NSDate+TwitterDate.h"

@import CoreData;
@import SafariServices;

@interface MMUserTimelineTableViewController () <NSFetchedResultsControllerDelegate, MMLinkLabelDelegate, MMTweetTableViewCellDelegate>

//@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) MMTwitterDataStore *dataStore;

@property (strong, nonatomic) MMTweetWithImageTableViewCell *dummyImageCell;


@end

@implementation MMUserTimelineTableViewController

#pragma mark - Constants

static NSString *const kTableViewCellIdentifier = @"UserTimelineCell";

#pragma mark - Custom Accessors

- (NSFetchedResultsController *)fetchedResultsController {
    if (super.fetchedResultsController == nil) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:kDataStoreTweetEntityName inManagedObjectContext:self.dataStore.mainContext];
        
        request.predicate = [NSPredicate predicateWithFormat:@"isUserTimeline == YES"];
        
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
        
        request.fetchBatchSize = 20;
        
        super.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.dataStore.mainContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
        
        super.fetchedResultsController.delegate = self;
        
    }
    
    return super.fetchedResultsController;
}

- (MMTwitterDataStore *)dataStore {
    if (!_dataStore) {
        _dataStore = [MMTwitterDataStore defaultStore];
    }
    
    return _dataStore;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Timeline", nil);
    
    __autoreleasing NSError *error = nil;
    
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@ : %@", error, [error userInfo]);
        abort();
    }

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(didRefreshUserTimeline:) forControlEvents:UIControlEventValueChanged];
    
    NSString *title = [((NSDate *)[[NSUserDefaults standardUserDefaults] valueForKey:kTwitterUserTimelineKey]) dateAsStringFormattedForRefreshControllTitle];
    
    if (title) {
        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:title];
    }
    
    self.refreshControl = refreshControl;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)updateHomeTimeline {
    [[MMTwitterManager sharedManager] getUserTimelineWithCompletion:^(NSError *error) {
        NSString *title = [((NSDate *)[[NSUserDefaults standardUserDefaults] valueForKey:kTwitterUserTimelineKey]) dateAsStringFormattedForRefreshControllTitle];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:title];
        
        if (self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
        }
        
    }];
}

- (void)didRefreshUserTimeline:(id)sender {
    if ([MMTwitterManager sharedManager].isLoggedIn) {
        [self updateHomeTimeline];
    } else {
        [self.refreshControl endRefreshing];
    }
}

@end
