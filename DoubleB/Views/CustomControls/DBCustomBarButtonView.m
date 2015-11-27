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

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    self.customText = text;
    return self;
}

- (void)awakeFromNib {
    self.customTextLabel.text = self.customText;
//    self.customTextLabel.textColor = [UIColor db_defaultColor];
}

@end
