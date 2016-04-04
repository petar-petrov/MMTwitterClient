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
#import "MMTweetTableViewCell.h"
#import "MMTweetWithImageTableViewCell.h"
#import "MMImageTweetTableViewCell.h"
#import "UIImageView+Networking.h"
#import "MMTwitterManager.h"
#import "MMLinkLabel.h"

#import "NSDate+TwitterDate.h"

@import CoreData;
@import SafariServices;

@interface MMUserTimelineTableViewController () <NSFetchedResultsControllerDelegate, MMLinkLabelDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) MMTwitterDataStore *dataStore;

@property (strong, nonatomic) MMTweetWithImageTableViewCell *dummyImageCell;


@end

@implementation MMUserTimelineTableViewController

#pragma mark - Constants

static NSString *const kTableViewCellIdentifier = @"UserTimelineCell";

#pragma mark - Custom Accessors

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController == nil) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:kDataStoreTweetEntityName inManagedObjectContext:self.dataStore.mainContext];
        
        request.predicate = [NSPredicate predicateWithFormat:@"isUserTimeline == YES"];
        
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
        
        request.fetchBatchSize = 20;
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.dataStore.mainContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
        
        _fetchedResultsController.delegate = self;
        
    }
    
    return _fetchedResultsController;
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

    [self.tableView registerNib:[UINib nibWithNibName:@"MMTweetTableViewCell" bundle:nil]
         forCellReuseIdentifier:kTableViewCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"MMTweetWithImageTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"ImageCell"];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(didRefreshUserTimeline:) forControlEvents:UIControlEventValueChanged];
    
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showUserTimelineImage"]) {

    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MMTweetTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isMemberOfClass:[MMTweetWithImageTableViewCell class]]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        MMImageDetailsViewController *dvc = [storyboard instantiateViewControllerWithIdentifier:@"ImageViewController"];
        dvc.tweetInfo = (Tweet *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        [self presentViewController:dvc animated:YES completion:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *tweet = (Tweet *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    MMTweetTableViewCell *cell = nil;
    
    if ([tweet.mediaType isEqualToString:@"photo"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Private

- (void)configureCell:(MMTweetTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Tweet *tweet = (Tweet *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    User *user = tweet.hasUser;
    
    NSAttributedString *attributedMessage = [[NSAttributedString alloc] initWithString:tweet.text];
    NSString *screenName = [@"@" stringByAppendingString:user.screenName];
    NSString *relativeDate = [tweet.createdAt relativeDateAsStringSinceNow];
    
    if ([cell isMemberOfClass:[MMTweetWithImageTableViewCell class]]) {
        [((MMTweetWithImageTableViewCell *)cell).tweetImageView psetImageWithURLString:tweet.mediaURL placeholder:nil];
    }
    
    cell.nameLabel.text = user.name;
    cell.screenNameLabel.text = screenName;
    cell.relativeDateLabel.text = relativeDate;
    cell.message.attributedText = attributedMessage;
    cell.message.delegate = self;
    
    [cell.profileImageView psetImageWithURLString:user.profileImageURL placeholder:nil];
}

- (void)didRefreshUserTimeline:(id)sender {
    [[MMTwitterManager sharedManager] getUserTimelineWithCompletion:^(NSArray *tweets, NSUInteger sinceID, NSError *error) {
//        NSLog(@"%@", tweets);
        NSString *title = [((NSDate *)[[NSUserDefaults standardUserDefaults] valueForKey:kTwitterHomeTimelineKey]) dateAsStringFormattedForRefreshControllTitle];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:title];
        
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - NSFetchedResultControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

#pragma mark - MMLinkLabelDelegate

- (void)linkLabel:(MMLinkLabel *)label didTapOnLink:(NSString *)link {
    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:link]];
    safariViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    safariViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    
    [self presentViewController:safariViewController animated:YES completion:nil];
}


@end
