//
//  MMProfileTableViewController.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 12/04/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMProfileTableViewController.h"

#import "MMImageDetailsViewController.h"
#import "MMComposerViewController.h"

#import "MMTwitterManager.h"
#import "MMTwitterDataManager.h"
#import "MMTwitterDataStore.h"
#import "MMTwitterDataManager.h"
#import "UIImageView+Networking.h"

#import "MMTweetTableViewCell.h"
#import "MMTweetWithImageTableViewCell.h"

#import "NSDate+TwitterDate.h"

@import QuartzCore;
@import CoreData;

@interface MMProfileTableViewController () <NSFetchedResultsControllerDelegate, MMTweetTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *profileImageBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;

@end

@implementation MMProfileTableViewController

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (!super.fetchedResultsController) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        request.entity = [NSEntityDescription entityForName:kDataStoreTweetEntityName inManagedObjectContext:[MMTwitterDataStore defaultStore].mainContext];
        
        request.predicate = [NSPredicate predicateWithFormat:@"hasUser.userID == %@", self.user.userID];
        
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
    
    self.screenNameLabel.text = [@"@" stringByAppendingString:self.user.screenName];
    
    __autoreleasing NSError *fetchedResultsError = nil;
    
    if (![self.fetchedResultsController performFetch:&fetchedResultsError]) {
        NSLog(@"Unresolved error %@ : %@", fetchedResultsError, [fetchedResultsError userInfo]);
        abort();
    }
    
    
}

- (IBAction)done:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MMTweetTableViewCell

- (void)didTapProfileImageForCell:(MMTweetTableViewCell *)cell {
    
}



@end
