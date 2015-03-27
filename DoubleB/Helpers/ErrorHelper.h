//
//  ErrorHelper.h
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 10.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorHelper : NSObject

+ (instancetype) sharedHelper;
- (void) setErrorsWithErrors:(NSArray *)errors;
@end