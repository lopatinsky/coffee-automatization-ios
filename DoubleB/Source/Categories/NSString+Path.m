//
// Created by Sergey Pronin on 5/28/14.
// Copyright (c) 2014 Sergey Pronin. All rights reserved.
//

#import "NSString+Path.h"


@implementation NSString (Path)

+ (NSString *)documentsDirectory {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];

}

@end