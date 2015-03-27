//
//  NSString+DoubleB.h
//  DoubleB
//
//  Created by Sergey Pronin on 8/1/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kDBCardTypeMasterCard;
extern NSString *const kDBCardTypeVisa;
extern NSString *const kDBCardTypeMaestro;
extern NSString *const kDBCardTypeDinersClub;

@interface NSString (DoubleB)

- (NSString *)db_cardIssuer;

- (NSAttributedString *)attributedStringWithBoldKeyWordsWithFontSize:(CGFloat)size;

@end
