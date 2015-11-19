//
//  DBActivityItemProvider.h
//  DoubleB
//
//  Created by Ощепков Иван on 05.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const DBActivityTypePostToVK;
extern NSString *const DBActivityTypePostToWhatsApp;

@interface DBActivityItemProvider : UIActivityItemProvider
- (instancetype)initWithTextFormat:(NSString *)textFormat links:(NSDictionary *)links;
@end
