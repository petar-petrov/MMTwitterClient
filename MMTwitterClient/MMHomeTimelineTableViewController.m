//
//  MMHomeTimelineTableViewController.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 25/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMHomeTimelineTableViewController.h"
#import "MMConstants.h"
#import "MMTwitterDataStore.h"
#import "Tweet.h"
#import "User.h"

#import "MMImageDetailsViewController.h"
#import "MMProfileTableViewController.h"
#import "MMTwitterManager.h"
#import "MMTweetTableViewCell.h"
#import "MMImageTweetTableViewCell.h"
#import "MMTweetWithImageTableViewCell.h"
#import "MMComposerViewController.h"

#import "UIImageView+Networking.h"
#import "NSDate+TwitterDate.h"

#import "MMLinkLabel.h"

#import <TwitterKit/TwitterKit.h>

@import CoreData;
@import SafariServices;

@interface MMHomeTimelineTableViewController () <NSFetchedResultsControllerDelegate, MMLinkLabelDelegate, MMTweetTableViewCellDelegate>

//@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation MMHomeTimelineTableViewController

#pragma mark - Custom Accessors

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (![super fetchedResultsController]) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        request.entity = [NSEntityDescription entityForName:kDataStoreTweetEntityName inManagedObjectContext:[MMTwitterDataStore defaultStore].mainContext];
        
        request.predicate = [NSPredicate predicateWithFormat:@"retweeted == NO"];
        
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
        
        request.fetchBatchSize = 20;
        
        super.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:[MMTwitterDataStore defaultStore].mainContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
        
        super.fetchedResultsController.delegate = self;
        
    }
    
    return super.fetchedResultsController;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.title = NSLocalizedString(@"Home", nil);
    UIImage *twitterImage = [UIImage imageNamed:@"twitter.png"];
    
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:twitterImage];
    
    self.navigationItem.titleView = titleImageView;
    
    __autoreleasing NSError *error = nil;

    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@ : %@", error, [error userInfo]);
        abort();
    }
    
    self.tableView.backgroundColor =  [[UIColor alloc]initWithRed: 0.949020 green: 0.964706 blue: 0.976471 alpha: 1 ];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(didRefreshHomeTimeline:) forControlEvents:UIControlEventValueChanged];
    
    NSString *title = [((NSDate *)[[NSUserDefaults standardUserDefaults] valueForKey:kTwitterHomeTimelineKey]) dateAsStringFormattedForRefreshControllTitle];
    
    if (title) {
        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:title];
    }
    
    self.refreshControl = refreshControl;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)didRefreshHomeTimeline:(id)sender {
    if ([MMTwitterManager sharedManager].isLoggedIn) {
        [self updateHomeTimeline];
    } else {
        [self.refreshControl endRefreshing];
    }
    
}

- (void)updateHomeTimeline {
    [[MMTwitterManager sharedManager] getHomeTimelineWithCompletion:^(NSError *error) {
        NSString *title = [((NSDate *)[[NSUserDefaults standardUserDefaults] valueForKey:kTwitterHomeTimelineKey]) dateAsStringFormattedForRefreshControllTitle];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:title];
        
        if (self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
        }
        
    }];
}

@end
