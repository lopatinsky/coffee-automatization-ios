//
//  DBCustomBarButtonView.m
//  DoubleB
//
//  Created by Balaban Alexander on 26/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBCustomBarButtonView.h"

@implementation DBCustomBarButtonView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBCustomBarButtonView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    self.customTextLabel.textColor = [UIColor whiteColor];
    self.customTextLabel.textAlignment = NSTextAlignmentRight;
}

@end
