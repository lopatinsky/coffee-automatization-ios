//
//  DBDiscountAdvertView.m
//  DoubleB
//
//  Created by Ощепков Иван on 02.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBDiscountAdvertView.h"

@implementation DBDiscountAdvertView

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBDiscountAdvertView" owner:self options:nil] firstObject];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
    separatorView.backgroundColor = [UIColor db_separatorColor];
    separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:separatorView];
    
    return self;
}

@end
