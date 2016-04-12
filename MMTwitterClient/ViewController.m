//
//  ViewController.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 22/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "ViewController.h"
#import <TwitterKit/TwitterKit.h>

#import "MMTwitterTimeLineTableViewController.h"

#import "MMTwitterManager.h"


@interface ViewController ()

@property (strong, nonatomic) NSMutableArray *timeLine;
@property (weak, nonatomic) IBOutlet UIButton *showTimelineButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (assign, nonatomic, getter=isLoggedIn) BOOL loggedIn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Me!", nil);
    
    self.showTimelineButton.enabled = NO;
}

- (IBAction)showTimeline:(id)sender {
    [self performSegueWithIdentifier:@"showTimeline" sender:self];
}

- (IBAction)login:(id)sender {
    if (self.loggedIn) {
        
        self.showTimelineButton.enabled = NO;
        [self.loginButton setTitle:NSLocalizedString(@"Log In", nil) forState:UIControlStateNormal];
        self.loggedIn = NO;
    } else {
        [[MMTwitterManager sharedManager] loginWithCompletionHandler:^(NSError *error) {
            self.showTimelineButton.enabled = YES;
            [self.loginButton setTitle:NSLocalizedString(@"Log Out", nil) forState:UIControlStateNormal];
            self.loggedIn = YES;
        }];
    }
}

@end
