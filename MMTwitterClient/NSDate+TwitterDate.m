//
//  NSDate+TwitterDate.m
//  MMTwitterClient
//
//  Created by Petar Petrov on 31/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "NSDate+TwitterDate.h"

@implementation NSDate (TwitterDate)

- (NSString *)relativeDateAsStringSinceNow {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *currentDate = [NSDate date];
    
    NSDateComponents *components = [calendar components:(NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear)
                                               fromDate:self
                                                 toDate:currentDate options:0];
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    
    if (components.year > 0) {
        dateFormater.dateFormat = @"MMM dd YYYY";
        return [dateFormater stringFromDate:self];
    } else if (components.month > 0 || components.weekOfYear > 0 || components.day > 1) {
        dateFormater.dateFormat = @"MMM dd";
        return [dateFormater stringFromDate:self];
    } else if (components.day == 1) {
        return @"Yesterday";
    } else if (components.hour > 0) {
        return [NSString stringWithFormat:@"%ldh", (long)components.hour];
    } else if (components.minute > 5) {
        return [NSString stringWithFormat:@"%ldm", (long)components.minute];
    } else {
        return @"Just Now";
    }
  
    return nil;
}

@end
