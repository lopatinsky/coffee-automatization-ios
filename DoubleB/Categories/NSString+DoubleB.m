//
//  NSString+DoubleB.m
//  DoubleB
//
//  Created by Sergey Pronin on 8/1/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "NSString+DoubleB.h"

@implementation NSString (DoubleB)

- (NSAttributedString *)attributedStringWithBoldKeyWordsWithFontSize:(CGFloat)size{
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:self];
    
    NSArray *searchStrings = @[@"Даблби", @"Doubleb", @"Mastercard"];
    for(NSString *substring in searchStrings){
        NSRange searchRange = NSMakeRange(0, self.length);
        while (searchRange.location < self.length) {
            searchRange.length = self.length-searchRange.location;
            NSRange range = [self rangeOfString:substring options:NSCaseInsensitiveSearch range:searchRange];
            if (range.location != NSNotFound) {
                searchRange.location = range.location + range.length;
                
                [result addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:size] range:range];
            } else {
                break;
            }
        }
    }
    
    return result;
}

@end
