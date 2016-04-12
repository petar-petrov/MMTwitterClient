//
//  MMLinkLabel.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 30/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMLinkLabel.h"
#import "NSMutableAttributedString+TwitterLinks.h"

@interface MMLinkLabel () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSLayoutManager *layoutManager;
@property (strong, nonatomic) NSTextContainer *textContainer;
@property (strong, nonatomic) NSTextStorage *textStorage;

@property (strong, nonatomic) NSArray *linksRanges;
@property (strong, nonatomic) NSArray *hashtagsRanges;

@end

@implementation MMLinkLabel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.userInteractionEnabled = YES;
        
        [self configureLabel];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.userInteractionEnabled = YES;
        
        [self configureLabel];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.textContainer.size = frame.size;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    
    NSMutableAttributedString *mutableAttributedString = [attributedText mutableCopy];
    
    self.linksRanges = [mutableAttributedString highlightLinksWithAttributtes:@{NSForegroundColorAttributeName : [UIColor redColor]}];
    self.hashtagsRanges = [mutableAttributedString highlightHashtagsWithAttributtes:@{NSForegroundColorAttributeName : [UIColor blueColor]}];
    
    [super setAttributedText:[mutableAttributedString copy]];
    
    self.textStorage = [[NSTextStorage alloc] initWithAttributedString:self.attributedText];
    [self.textStorage addLayoutManager:self.layoutManager];
}

#pragma mark - Private

- (void)configureLabel {
    
    UITapGestureRecognizer *tapGestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//    tapGestureRecongnizer.delegate = self;
    
    [self addGestureRecognizer:tapGestureRecongnizer];
    
    
    // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
    self.layoutManager = [[NSLayoutManager alloc] init];
    self.textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
    
    // Configure layoutManager and textStorage
    [self.layoutManager addTextContainer:self.textContainer];
    
    // Configure textContainer
    self.textContainer.lineFragmentPadding = 0.0;
    self.textContainer.lineBreakMode = self.lineBreakMode;
    self.textContainer.maximumNumberOfLines = self.numberOfLines;
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    
    CGPoint locationOfTouchInLabel = [gesture locationInView:gesture.view];
    CGSize labelSize = gesture.view.bounds.size;
    CGRect textBoundingBox = [self.layoutManager usedRectForTextContainer:self.textContainer];
    CGPoint textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                              (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
    CGPoint locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
                                                         locationOfTouchInLabel.y - textContainerOffset.y);
    NSInteger indexOfCharacter = [self.layoutManager characterIndexForPoint:locationOfTouchInTextContainer
                                                            inTextContainer:self.textContainer
                                   fractionOfDistanceBetweenInsertionPoints:nil];
    
    for (NSValue *rangeValue in self.linksRanges) {
        if (NSLocationInRange(indexOfCharacter, rangeValue.rangeValue)) {
            // Open an URL, or handle the tap on the link in any other way
            NSString *urlString = [self.attributedText.string substringWithRange:rangeValue.rangeValue];
            
            if ([self.delegate respondsToSelector:@selector(linkLabel:didTapOnLink:)]) {
                [self.delegate linkLabel:self didTapOnLink:urlString];
            }
            
            NSLog(@"link tapped");
        }
    }
    
    
}

#pragma mark - UIGestureRecognizerDelegate

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    if ([touch.view isDescendantOfView:autocompleteTableView]) {
//        
//        // Don't let selections of auto-complete entries fire the
//        // gesture recognizer
//        return NO;
//    }
//    
//    return YES;
//}

@end
