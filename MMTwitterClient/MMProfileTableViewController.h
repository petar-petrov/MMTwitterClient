//
//  MMProfileTableViewController.h
//  MMTwitterClient
//
//  Created by Petar Petrov on 12/04/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMTimelineTableViewController.h"

@class User;

@interface MMProfileTableViewController : MMTimelineTableViewController 

@property (strong, nonatomic) User *user;

@end
