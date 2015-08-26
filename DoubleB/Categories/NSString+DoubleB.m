//
//  NSString+DoubleB.m
//  DoubleB
//
//  Created by Sergey Pronin on 8/1/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "NSString+DoubleB.h"

NSString *const kDBCardTypeMasterCard = @"MasterCard";
NSString *const kDBCardTypeVisa = @"Visa";
NSString *const kDBCardTypeMaestro = @"Maestro";
NSString *const kDBCardTypeDinersClub = @"Diners Club";

@implementation NSString (DoubleB)

- (NSString *)db_cardIssuer {
    NSString *result = @"";
    NSString *check = [self substringWithRange:NSMakeRange(0, 2)];
    if(check.intValue == 34 || check.intValue == 37) result = @"American Express";
    if(check.intValue == 36) result = kDBCardTypeDinersClub;
    if(check.intValue == 38) result = @"Carte Blanche";
    if(check.intValue >= 51 && check.intValue <= 55) result = kDBCardTypeMasterCard;
    
    if([result isEqualToString:@""]){
        check = [self substringWithRange:NSMakeRange(0, 4)];
        NSSet *maestroPans = [NSSet setWithObjects:@"5018", @"5020", @"5038", @"5612", @"5893", @"6304", @"6759", @"6761", @"6762", @"6763", @"0604", @"6390", nil];
        if([maestroPans containsObject:check]) result = kDBCardTypeMaestro;
        if(check.intValue == 2014 || check.intValue == 2149) result = @"EnRoute";
        if(check.intValue == 2131 || check.intValue == 1800) result = @"JCB";
        if(check.intValue == 6011) result = @"Discover";
        
        if([result isEqualToString:@""]){
            check = [self substringWithRange:NSMakeRange(0, 3)];
            if(check.intValue >= 300 && check.intValue <= 305) result = kDBCardTypeDinersClub;
            
            if([result isEqualToString:@""]){
                check = [self substringWithRange:NSMakeRange(0, 1)];
                if(check.intValue == 3) result = @"JCB";
                if(check.intValue == 4) result = kDBCardTypeVisa;
            }
        }
    }
    
    if([result isEqualToString:@""]) result = @"Unknown";
    
    return result;
}

@end
