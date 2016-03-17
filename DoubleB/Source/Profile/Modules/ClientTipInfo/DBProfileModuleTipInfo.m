//
//  DBPaymentModuleCardsInfo.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 16/03/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBProfileModuleTipInfo.h"

@implementation DBProfileModuleTipInfo

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    
    DBModule *module = [[DBModulesManager sharedInstance] module:DBModuleTypeProfilePaymentCardInfo];
    
    UILabel *label = [UILabel new];
    label.textColor = [UIColor db_textGrayColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f];
    label.numberOfLines = 0;
    label.text = [module.info getValueForKey:@"text"] ?: @"";
    
    [self addSubview:label];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [label alignTop:@"0" leading:@"8" bottom:@"0" trailing:@"-8" toView:self];
}

- (CGFloat)moduleViewContentHeight {
    return 60.f;
}

@end
