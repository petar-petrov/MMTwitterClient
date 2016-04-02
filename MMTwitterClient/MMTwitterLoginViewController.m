//
//  MMTwitterLoginViewController.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 29/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMTwitterLoginViewController.h"
#import "MMTwitterManager.h"

@interface MMTwitterLoginViewController ()

@end

@implementation MMTwitterLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    [[MMTwitterManager sharedManager] loginWithCompletionHandler:^(NSError *error){
        if (error == nil) {
            self.presentingViewController.view.hidden = NO;
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

@end
