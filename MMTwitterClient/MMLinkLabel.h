//
//  MMLinkLabel.h
//  MMTwitterClient
//
//  Created by Petar Petrov on 30/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMLinkLabelDelegate;

@interface MMLinkLabel : UILabel

@property (weak, nonatomic) id <MMLinkLabelDelegate> delegate;

@end

@protocol MMLinkLabelDelegate <NSObject>

@optional
- (void)linkLabel:(MMLinkLabel *)label didTapOnLink:(NSString *)link;

@end