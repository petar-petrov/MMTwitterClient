//
//  MMTweetWithImageTableViewCell.h
//  MMTwitterClient
//
//  Created by Petar Petrov on 01/04/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMTweetTableViewCell.h"

@interface MMTweetWithImageTableViewCell : MMTweetTableViewCell

@property (weak, nonatomic, readonly) IBOutlet UIImageView *tweetImageView;

@end
