//
//  MMTweetWithImageTableViewCell.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 01/04/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMTweetWithImageTableViewCell.h"

@interface MMTweetWithImageTableViewCell()

@property (strong, nonatomic, readwrite) UIImageView *tweetImageView;

//@property (assign, nonatomic, getter=isConstraintsSet) BOOL constraintsSet;

@end

@implementation MMTweetWithImageTableViewCell

//- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    
//    if (self) {
//        _tweetImageView = [[UIImageView alloc] init];
//        _tweetImageView.backgroundColor = [UIColor lightGrayColor];
//        _tweetImageView.contentMode = UIViewContentModeScaleAspectFill;
//        
//        _tweetImageView.translatesAutoresizingMaskIntoConstraints = NO;
//        
//        [self.containerView addSubview:_tweetImageView];
//        
//        self.constraintsSet = YES;
//        
//        [self setNeedsUpdateConstraints];
//        
//        for (NSLayoutConstraint *constraint in self.profileImageView.constraints) {
//            if ([constraint.identifier isEqualToString:@"topConstraint_ProfileImageView"])
//                constraint.active = NO;
//        }
//        
//        self.constraintsSet = NO;
//        
//        [self setNeedsUpdateConstraints];
//    }
//    
//    return self;
//}
//
//- (void)updateConstraints {
//    
//    if (!self.isConstraintsSet) {
//        // Tweet Image Veiw constraints
//        [self.tweetImageView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:0.0f].active = YES;
//        [self.tweetImageView.topAnchor constraintEqualToAnchor:self.containerView.topAnchor constant:0.0f].active = YES;
//        [self.tweetImageView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:0.0f].active = YES;
//        [self.tweetImageView.heightAnchor constraintEqualToConstant:250.0f].active = YES;
//        
//        // Profile Image View contraints
//        [self.profileImageView.topAnchor constraintEqualToAnchor:self.tweetImageView.bottomAnchor constant:8.0f].active = YES;
//    }
//    
//    [super updateConstraints];
//}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.containerView.layer.masksToBounds = YES;
    
    [super layoutSubviews];
}

@end
