//
//  MMProfileTableViewController.h
//  MMTwitterClient
//
//  Created by Petar Petrov on 12/04/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface MMProfileTableViewController : UITableViewController

@property (strong, nonatomic) User *user;

@end
