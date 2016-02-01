//
//  NSString+LanguageFeature.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 26.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "NSString+LanguageFeature.h"

@implementation NSString (LanguageFeature)

+ (NSString *)db_localizedFormOfWordBall:(int)count{
    NSString *result = @"";
    if(count >= 10 && count <= 20)
        result = @"баллов";

    if(count % 10 == 1){
        result = @"балл";
    }
    if(count % 10 >= 2 && count % 10 <= 4){
        result = @"балла";
    }
    if((count % 10 >= 5 && count % 10 <= 9) || (count % 10 == 0)){
        result = @"баллов";
    }
    
    return NSLocalizedString(result, nil);
}

@end
