//
//  MMComposerViewController.h
//  MMTwitterClient
//
//  Created by Petar Petrov on 07/04/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface MMComposerViewController : UIViewController

- (void)setInReplyToStatusID:(NSString * _Nonnull)statusID username:(NSString * _Nonnull)username;

@end
