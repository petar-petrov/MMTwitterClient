//
//  MMTweetWithImageTableViewCell.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 01/04/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMTweetWithImageTableViewCell.h"

@interface MMTweetWithImageTableViewCell()

@property (weak, nonatomic, readwrite) UIImageView *tweetImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint_TweetImageView;

@end

@implementation MMTweetWithImageTableViewCell

@dynamic delegate;

#pragma mark - Custom Accessors

- (void)setDelegate:(id<MMTweetWithImageTableViewCellDelegate>)delegate {
    [super setDelegate:delegate];
}

- (id <MMTweetWithImageTableViewCellDelegate> )delegate {
    return [super delegate];
}

#pragma mark -

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    
    [self.tweetImageView addGestureRecognizer:tapGesture];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.containerView.layer.masksToBounds = YES;
    
    [super layoutSubviews];
}

#pragma mark - Private

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(didTapOnTweetImageView:)]) {
            [self.delegate didTapOnTweetImageView:self];
        }
    }
}

@end
