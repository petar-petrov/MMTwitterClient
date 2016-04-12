//
//  MMTweetTableViewCell.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 25/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMTweetTableViewCell.h"
#import "MMLinkLabel.h"

@import QuartzCore;

@interface MMTweetTableViewCell ()

@property (weak, nonatomic, readwrite) UIImageView *profileImageView;
@property (weak, nonatomic, readwrite) UILabel *nameLabel;
@property (weak, nonatomic, readwrite) UILabel *screenNameLabel;
@property (weak, nonatomic, readwrite) MMLinkLabel *message;
@property (weak, nonatomic, readwrite) UILabel *relativeDateLabel;

@property (weak, nonatomic, readwrite)  UIButton *retweetButton;
@property (weak, nonatomic, readwrite)  UIButton *likeButton;

@property (weak, nonatomic, readwrite) UIView *containerView;

@property (assign, nonatomic, getter=isContraintsSet) BOOL constraintsSet;

@end

@implementation MMTweetTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.contentView.backgroundColor = [[UIColor alloc]initWithRed: 0.835294 green: 0.835294 blue: 0.835294 alpha: 1 ];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnProfileImage:)];
    
    [self.profileImageView addGestureRecognizer:tapGestureRecognizer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.profileImageView.layer.cornerRadius = 5.0f;
    self.profileImageView.layer.masksToBounds = YES;
    self.containerView.layer.cornerRadius = 3.0f;
    
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Buttons Actions

- (IBAction)replyButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(replyButtonTappedForCell:)]) {
        [self.delegate replyButtonTappedForCell:self];
    }
}

- (IBAction)retweetButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(retweetButtonTappedForCell:)]) {
        [self.delegate retweetButtonTappedForCell:self];
    }
}

- (IBAction)likeButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(likeButtonTappedForCell:)]) {
        [self.delegate likeButtonTappedForCell:self];
    }
}


- (IBAction)moreButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(moreButtonTappedForCell:)]) {
        [self.delegate moreButtonTappedForCell:self];
    }
}

#pragma mark - Gesture Action

- (void)handleTapOnProfileImage:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(didTapProfileImageForCell:)]) {
            [self.delegate didTapProfileImageForCell:self];
        }
    }
}

@end
