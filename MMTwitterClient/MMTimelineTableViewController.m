//
//  MMTimelineTableViewController.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 13/04/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMTimelineTableViewController.h"

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

@import SafariServices;

@interface MMTimelineTableViewController () <MMTweetTableViewCellDelegate, MMLinkLabelDelegate>

@end

@implementation MMTimelineTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MMTweetTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"Cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MMTweetWithImageTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"ImageCell"];
}

#pragma mark - UITableViewDelegate

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

//- (void)didRefreshHomeTimeline:(id)sender {
//    if ([MMTwitterManager sharedManager].isLoggedIn) {
//        [self updateHomeTimeline];
//    } else {
//        [self.refreshControl endRefreshing];
//    }
//    
//}
//
//- (void)updateHomeTimeline {
//    [[MMTwitterManager sharedManager] getHomeTimelineWithCompletion:^(NSError *error) {
//        NSString *title = [((NSDate *)[[NSUserDefaults standardUserDefaults] valueForKey:kTwitterHomeTimelineKey]) dateAsStringFormattedForRefreshControllTitle];
//        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:title];
//        
//        if (self.refreshControl.isRefreshing) {
//            [self.refreshControl endRefreshing];
//        }
//        
//    }];
//}

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
    NSString *title = [((NSDate *)[[NSUserDefaults standardUserDefaults] valueForKey:kTwitterHomeTimelineKey]) dateAsStringFormattedForRefreshControllTitle];
    
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:title];
    
    [self.tableView endUpdates];
}

#pragma mark - MMLinkLabelDelegate

- (void)linkLabel:(MMLinkLabel *)label didTapOnLink:(NSString *)link {
    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:link]];
    safariViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    safariViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:safariViewController animated:YES completion:nil];
}

#pragma mark - MMTweetTableViewCellDelegate

- (void)replyButtonTappedForCell:(MMTweetTableViewCell *)cell {
    Tweet *tweet = (Tweet *)[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"Composer"];
    
    MMComposerViewController *composerViewController = (MMComposerViewController *)navigationController.topViewController;
    [composerViewController setInReplyToStatusID:tweet.tweetID.stringValue username:tweet.hasUser.screenName];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)retweetButtonTappedForCell:(MMTweetTableViewCell *)cell {
    Tweet *tweet = (Tweet *)[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    
    [[MMTwitterManager sharedManager] changeRetweetStatusOfTweet:tweet];
}

- (void)likeButtonTappedForCell:(MMTweetTableViewCell *)cell {
    Tweet *tweet = (Tweet *)[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    
    [[MMTwitterManager sharedManager] changeFavoriteStatusOfTweet:tweet compeleted:nil];
}

- (void)moreButtonTappedForCell:(MMTweetTableViewCell *)cell {
    Tweet *tweet = (Tweet *)[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Share via Direct Message", nil) style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:shareAction];
    
    if ([tweet.hasUser.userID.stringValue isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"TwitterUserID"]] && !tweet.retweeted.boolValue) {
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [[MMTwitterManager sharedManager] deleteTweet:tweet competed:nil];
        }];
        [alert addAction:deleteAction];
    } else {
        UIAlertAction *muteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Mute", nil)  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [[MMTwitterManager sharedManager] changeUser:tweet.hasUser mutedStatus:YES];
        }];
        
        [alert addAction:muteAction];
        
        UIAlertAction *blockAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Block", nil) style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:blockAction];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didTapProfileImageForCell:(MMTweetTableViewCell *)cell {
    Tweet *tweet = (Tweet *)[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UINavigationController *navigationControlle = [storyboard instantiateViewControllerWithIdentifier:@"Profile"];
    
    MMProfileTableViewController *profileTableViewController = (MMProfileTableViewController *)[navigationControlle topViewController];
    profileTableViewController.user = tweet.hasUser;
    
    [self presentViewController:navigationControlle animated:YES completion:nil];
    
    
}

#pragma mark - MMTweetWithImageTableViewCellDelegate

- (void)didTapOnTweetImageView:(MMTweetWithImageTableViewCell *)cell {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    MMImageDetailsViewController *destinationViewController = [storyboard instantiateViewControllerWithIdentifier:@"ImageViewController"];
    destinationViewController.tweetInfo = (Tweet *)[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    
    [self presentViewController:destinationViewController animated:YES completion:nil];
}


@end
