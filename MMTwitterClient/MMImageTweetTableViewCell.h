//
//  MMImageTweetTableViewCell.h
//  MMTwitterClient
//
//  Created by Petar Petrov on 28/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMLinkLabel;

@interface MMImageTweetTableViewCell : UITableViewCell

@property (strong, nonatomic, readonly) UIImageView *profileImageView;
@property (strong, nonatomic, readonly) UILabel *nameLabel;
@property (strong, nonatomic, readonly) UILabel *screenNameLabel;
@property (strong, nonatomic, readonly) MMLinkLabel *message;
@property (strong, nonatomic, readonly) UIImageView *tweetImageView;
@property (strong, nonatomic, readonly) UILabel *relativeDateLabel;

@end
