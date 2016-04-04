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

- (void)awakeFromNib {
    [super awakeFromNib];
    
//    [self.tweetImageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
    
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
////    NSLog(@"image bounds %@", NSStringFromCGSize(self.tweetImageView.image.size) );
//    
//    [self layoutIfNeeded];
//    if (self.tweetImageView.image.size.height > 0) {
//        CGFloat containerWidth = self.containerView.bounds.size.width;
////        CGFloat containerHeight = self.containerView.bounds.size.height;
//        
//        CGFloat ratio = self.tweetImageView.image.size.height / self.tweetImageView.image.size.width;
//        
////        NSLog(@"retion %.2f", ratio);
//        
//        
//        self.heightConstraint_TweetImageView.constant = ratio * containerWidth;
//    }
//    
//    [self layoutIfNeeded];
//}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.containerView.layer.masksToBounds = YES;
    
    [super layoutSubviews];
}

@end
