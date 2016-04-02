//
//  MMComposeTweetButtonTableViewController.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 31/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMComposeTweetButtonTableViewController.h"
#import <TwitterKit/TwitterKit.h>

@implementation MMComposeTweetButtonTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *compose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeTweet:)];
    
    self.navigationItem.rightBarButtonItem = compose;
}

#pragma mark - Private

- (void)composeTweet:(id)sender {
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    
    [composer setText:@"just setting up my Fabric!"];
    
    [composer showFromViewController:self completion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            NSLog(@"Tweet compositoin cancelled");
        } else {
            NSLog(@"Sending Tweet!");
        }
    }];
}

@end
