//
//  MMTweetTableViewCell.h
//  MMTwitterClient
//
//  Created by Petar Petrov on 25/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMLinkLabel;

@protocol MMTweetTableViewCellDelegate;

@interface MMTweetTableViewCell : UITableViewCell

@property (weak, nonatomic, readonly) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic, readonly) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic, readonly) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic, readonly) IBOutlet MMLinkLabel *message;
@property (weak, nonatomic, readonly) IBOutlet UILabel *relativeDateLabel;

@property (weak, nonatomic, readonly) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic, readonly) IBOutlet UIButton *likeButton;

@property (weak, nonatomic, readonly) IBOutlet UIView *containerView;


@property (weak, nonatomic) id <MMTweetTableViewCellDelegate> delegate;

@end

@protocol MMTweetTableViewCellDelegate <NSObject>

@optional
- (void)replyButtonTappedForCell:(MMTweetTableViewCell *)cell;
- (void)retweetButtonTappedForCell:(MMTweetTableViewCell *)cell;
- (void)likeButtonTappedForCell:(MMTweetTableViewCell *)cell;
- (void)moreButtonTappedForCell:(MMTweetTableViewCell *)cell;

- (void)didTapProfileImageForCell:(MMTweetTableViewCell *)cell;

@end
