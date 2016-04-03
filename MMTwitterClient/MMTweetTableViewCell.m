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

@property (weak, nonatomic, readwrite) UIView *containerView;

@property (assign, nonatomic, getter=isContraintsSet) BOOL constraintsSet;

@end

@implementation MMTweetTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.contentView.backgroundColor = [[UIColor alloc]initWithRed: 0.835294 green: 0.835294 blue: 0.835294 alpha: 1 ];
}

//- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    
//    if (self) {
//        self.contentView.backgroundColor = [[UIColor alloc]initWithRed: 0.835294 green: 0.835294 blue: 0.835294 alpha: 1 ];

//        _containerView = [[UIView alloc] init];
//        _containerView.backgroundColor = [UIColor whiteColor];
//        _containerView.layer.cornerRadius = 3.0f;
//        _containerView.layer.masksToBounds = YES;
//        _containerView.translatesAutoresizingMaskIntoConstraints = NO;
//        
//        [self.contentView addSubview:_containerView];
//        
//        _profileImageView = [[UIImageView alloc] init];
//        _profileImageView.backgroundColor = [UIColor lightGrayColor];
//        _profileImageView.layer.cornerRadius = 5.0f;
//        _profileImageView.layer.masksToBounds = YES;
//        _profileImageView.translatesAutoresizingMaskIntoConstraints = NO;
//        
//        [_containerView addSubview:_profileImageView];
//        
//        _nameLabel = [[UILabel alloc] init];
//        _nameLabel.font = [UIFont boldSystemFontOfSize:17.0f];
//        _nameLabel.textColor = [[UIColor alloc]initWithRed: 0.011765 green: 0.082353 blue: 0.156863 alpha: 1 ];
//        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
//        
//        [_containerView addSubview:_nameLabel];
//        
//        _screenNameLabel = [[UILabel alloc] init];
//        _screenNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
//        
//        [_containerView addSubview:_screenNameLabel];
//        
//        _relativeDateLabel = [[UILabel alloc] init];
//        _relativeDateLabel.textColor = [[UIColor alloc]initWithRed: 0.787411 green: 0.787411 blue: 0.787411 alpha: 1 ];
//        _relativeDateLabel.translatesAutoresizingMaskIntoConstraints = NO;
//        
//        [_containerView addSubview:_relativeDateLabel];
//        
//        _message = [[MMLinkLabel alloc] init];
//        _message.numberOfLines = 0;
//        _message.translatesAutoresizingMaskIntoConstraints = NO;
//        
//        [_containerView addSubview:_message];
//        
//        [self.contentView setNeedsUpdateConstraints];
//    }
//    
//    return self;
//}

//- (void)updateConstraints {
//    if (!self.isContraintsSet) {
//        
//        // Container View constraints
//        [self.containerView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:10.0f].active = YES;
//        [self.containerView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:5.0f].active = YES;
//        [self.containerView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-10.0f].active = YES;
//        [self.containerView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-5.0f].active = YES;
//        
//        // Profile Image View contraints
//        NSLayoutConstraint * topConstraint_ProfileImageView = [self.profileImageView.topAnchor constraintEqualToAnchor:self.containerView.topAnchor constant:8.0f];
//        topConstraint_ProfileImageView.identifier = @"topConstraint_ProfileImageView";
//        topConstraint_ProfileImageView.active = YES;
//        
//        
//        [self.profileImageView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:8.0f].active = YES;
//        [self.profileImageView.widthAnchor constraintEqualToConstant:40.0f].active = YES;
//        [self.profileImageView.heightAnchor constraintEqualToConstant:40.0f].active = YES;
//        
//        // Name Label contraints
//        [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.profileImageView.trailingAnchor constant:8.0f].active = YES;
//        [self.nameLabel.topAnchor constraintEqualToAnchor:self.profileImageView.topAnchor].active = YES;
//        
//        // Screen Name Label constraints
//        [self.screenNameLabel.leadingAnchor constraintEqualToAnchor:self.nameLabel.trailingAnchor constant:8.0f].active = YES;
//        [self.screenNameLabel.topAnchor constraintEqualToAnchor:self.nameLabel.topAnchor].active = YES;
//        
//        // Relative Date Label Contraints
//        [self.relativeDateLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.screenNameLabel.trailingAnchor constant:8.0f].active = YES;
//        [self.relativeDateLabel.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-8.0f].active = YES;
//        [self.relativeDateLabel.topAnchor constraintEqualToAnchor:self.nameLabel.topAnchor].active = YES;
//        
//        // Text Label constraints
//        [self.message.leadingAnchor constraintEqualToAnchor:self.nameLabel.leadingAnchor].active = YES;
//        [self.message.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:8.0f].active = YES;
//        [self.message.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-8.0f].active = YES;
//        [self.message.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor constant:-8.0f].active = YES;
//    }
//    
//    [super updateConstraints];
//}

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

@end
