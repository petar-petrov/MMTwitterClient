//
//  MMTimelineTableViewController.h
//  MMTwitterClient
//
//  Created by Petar Petrov on 13/04/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMComposeTweetButtonTableViewController.h"

@import CoreData;

@interface MMTimelineTableViewController : MMComposeTweetButtonTableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
