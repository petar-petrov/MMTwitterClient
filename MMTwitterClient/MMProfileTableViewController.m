//
//  MMProfileTableViewController.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 12/04/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMProfileTableViewController.h"

#import "MMTwitterManager.h"
#import "MMTwitterDataManager.h"
#import "MMTwitterDataStore.h"
#import "MMTwitterDataManager.h"
#import "UIImageView+Networking.h"

#import "MMTweetTableViewCell.h"
#import "MMTweetWithImageTableViewCell.h"

#import "MMLinkLabel.h"
#import "NSDate+TwitterDate.h"

@import QuartzCore;
@import CoreData;
@import SafariServices;

@interface MMProfileTableViewController () <NSFetchedResultsControllerDelegate, MMLinkLabelDelegate, MMTweetTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *profileImageBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation MMProfileTableViewController

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (!_fetchedResultsController) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        request.entity = [NSEntityDescription entityForName:kDataStoreTweetEntityName inManagedObjectContext:[MMTwitterDataStore defaultStore].mainContext];
        
        request.predicate = [NSPredicate predicateWithFormat:@"hasUser.userID == %@", self.user.userID];
        
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
        
        request.fetchBatchSize = 20;
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:[MMTwitterDataStore defaultStore].mainContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
        
        _fetchedResultsController.delegate = self;
        
    }
    
    return _fetchedResultsController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
//                             forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [UIImage new];
//    self.navigationController.navigationBar.translucent = YES;
//    
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = self.user.name;
    
    self.profileImageBackgroundView.layer.cornerRadius = 5.0f;
    
    self.profileImageView.layer.cornerRadius = 5.0f;
    self.profileImageView.layer.masksToBounds = YES;
    
    [self.profileImageView psetImageWithURLString:self.user.profileImageURL placeholder:nil];
    
    [self.profileBackgroundImageView psetImageWithURLString:self.user.profileBackgroundImageURL placeholder:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MMTweetTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"Cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MMTweetWithImageTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"ImageCell"];
    
    [[MMTwitterManager sharedManager] getTimelineForUser:self.user completion:^(NSError *error){
        
    }];
    
    __autoreleasing NSError *fetchedResultsError = nil;
    
    if (![self.fetchedResultsController performFetch:&fetchedResultsError]) {
        NSLog(@"Unresolved error %@ : %@", fetchedResultsError, [fetchedResultsError userInfo]);
        abort();
    }
    
    
}

- (IBAction)done:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *tweet = (Tweet *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([tweet.mediaType isEqualToString:@"photo"]) {
        return 387.0f;
    } else {
        return 136.0f;
    }
}

#pragma mark - UITableViewDataSource

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
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
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
    cell.delegate = self;
    
    [cell.profileImageView psetImageWithURLString:user.profileImageURL placeholder:nil];
    
    if ([tweet.hasUser.userID.stringValue isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"TwitterUserID"]]) {
        cell.retweetButton.enabled = NO;
    } else {
        cell.retweetButton.enabled = YES;
    }
    
    if (tweet.retweeted.boolValue) {
        cell.retweetButton.enabled = YES;
        [cell.retweetButton setTitle:@"Unretweet" forState:UIControlStateNormal];
    } else {
        [cell.retweetButton setTitle:@"Retweet" forState:UIControlStateNormal];
    }
    
    if (tweet.favorited.boolValue) {
        [cell.likeButton setTitle:@"Unlike" forState:UIControlStateNormal];
    } else {
        [cell.likeButton setTitle:@"Like" forState:UIControlStateNormal];
    }
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
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    NSString *title = [((NSDate *)[[NSUserDefaults standardUserDefaults] valueForKey:kTwitterHomeTimelineKey]) dateAsStringFormattedForRefreshControllTitle];
    
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:title];
    
    [self.tableView endUpdates];
}

@end
