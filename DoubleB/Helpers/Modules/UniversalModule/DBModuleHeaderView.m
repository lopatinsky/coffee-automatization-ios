//
//  DBModuleHeaderView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 29/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBModuleHeaderView.h"

@interface DBModuleHeaderView ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DBModuleHeaderView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBModuleHeaderView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    self.titleLabel.textColor = [UIColor db_textGrayColor];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
}

@end
