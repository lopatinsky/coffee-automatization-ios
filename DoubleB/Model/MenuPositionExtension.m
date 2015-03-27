//
//  Grain.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 09.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "MenuPositionExtension.h"

@interface MenuPositionExtension ()

@end

@implementation MenuPositionExtension

+ (instancetype)extensionWithName:(NSString *)name id:(NSString *)extensionId price:(NSNumber *)extensionPrice {
    MenuPositionExtension *extension = [[MenuPositionExtension alloc] init];
    
    extension.extName = name;
    extension.extId = extensionId;
    extension.extPrice = extensionPrice;
    
    return extension;
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[MenuPositionExtension alloc] init];
    if(self != nil){
        self.extName = [aDecoder decodeObjectForKey:@"extName"];
        self.extId = [aDecoder decodeObjectForKey:@"extId"];
        self.extPrice = [aDecoder decodeObjectForKey:@"extPrice"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.extName forKey:@"extName"];
    [aCoder encodeObject:self.extId forKey:@"extId"];
    [aCoder encodeObject:self.extPrice forKey:@"extPrice"];
}

@end
