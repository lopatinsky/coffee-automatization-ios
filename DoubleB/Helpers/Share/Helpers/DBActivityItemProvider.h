//
//  DBActivityItemProvider.h
//  DoubleB
//
//  Created by Ощепков Иван on 05.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBActivityItemProvider : UIActivityItemProvider
- (instancetype)initWithTextFormat:(NSString *)textFormat links:(NSDictionary *)links image:(UIImage *)image;
@end
