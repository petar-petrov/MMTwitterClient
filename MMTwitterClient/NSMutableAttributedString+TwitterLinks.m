//
//  NSMutableAttributedString+TwitterLinks.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 30/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "NSMutableAttributedString+TwitterLinks.h"

@interface NSMutableAttributedString (TwitterLinksPrivate)

@end

@implementation NSMutableAttributedString (TwitterLinksPrivate)

- (NSArray *)parseMessageWithPattern:(NSString *)pattern attributes:(NSDictionary *)attributes {
    NSString *messageAsString = self.string;
    
    NSRange range = NSMakeRange(0, messageAsString.length);
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    
    NSArray *matches = [regex matchesInString:messageAsString options:0 range:range];
    
    NSMutableArray *ranges = [NSMutableArray array];
    
    for (NSTextCheckingResult *match in matches) {
        [self addAttributes:attributes range:match.range];
        [ranges addObject:[NSValue valueWithRange:match.range]];
    }
    
    return ranges;;
}

@end

@implementation NSMutableAttributedString (TwitterLinks)

- (NSArray *)highlightLinksWithAttributtes:(NSDictionary *)attributes {
    NSString *pattern = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    
    return [self parseMessageWithPattern:pattern attributes:attributes];
}

- (NSArray *)highlightHashtagsWithAttributtes:(NSDictionary *)attributes {
    NSString *pattern = @"[#@]\\S+\\b";
    
    return [self parseMessageWithPattern:pattern attributes:attributes];
}

@end
