//
//  MMTweetWithImageTableViewCell.h
//  MMTwitterClient
//
//  Created by Petar Petrov on 01/04/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMTweetTableViewCell.h"

@protocol MMTweetWithImageTableViewCellDelegate;

@interface MMTweetWithImageTableViewCell : MMTweetTableViewCell

@property (weak, nonatomic, readonly) IBOutlet UIImageView *tweetImageView;

@property (weak, nonatomic) id <MMTweetWithImageTableViewCellDelegate> delegate;

@end

@protocol MMTweetWithImageTableViewCellDelegate <MMTweetTableViewCellDelegate>

@optional

- (void)didTapOnTweetImageView:(MMTweetWithImageTableViewCell *)cell;

@end
