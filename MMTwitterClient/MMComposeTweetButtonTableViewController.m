//
//  MMComposeTweetButtonTableViewController.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 31/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMComposeTweetButtonTableViewController.h"
#import <TwitterKit/TwitterKit.h>

#import "MMComposerViewController.h"

@implementation MMComposeTweetButtonTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *compose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeTweet:)];
    
    self.navigationItem.rightBarButtonItem = compose;
}

#pragma mark - Private

- (void)composeTweet:(id)sender {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"Composer"];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
    
}

@end
