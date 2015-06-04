//
//  DBPromoCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 02.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPromoCell.h"

@implementation DBPromoCell

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPromoCell" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {

}


@end
