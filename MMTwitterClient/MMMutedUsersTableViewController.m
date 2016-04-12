//
//  MMMutedUsersTableViewController.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 11/04/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//


#import "MMMutedUsersTableViewController.h"
#import "MMTwitterManager.h"
#import "MMTwitterDataManager.h"

@interface MMMutedUsersTableViewController ()

@property (strong, nonatomic) NSArray <User *> *mutedUsers;

@end

@implementation MMMutedUsersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Unmute", nil);
    
    self.mutedUsers = [[MMTwitterManager sharedManager] mutedUsers];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[MMTwitterManager sharedManager] changeUser:self.mutedUsers[indexPath.row] mutedStatus:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mutedUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    static NSString *cellIdentifier = @"Cell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = self.mutedUsers[indexPath.row].name;
    
    return cell;
}

@end
