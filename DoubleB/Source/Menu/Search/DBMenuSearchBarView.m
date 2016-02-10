//
//  DBMenuSearchBarView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 10/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBMenuSearchBarView.h"

@interface DBMenuSearchBarView ()

@end

@implementation DBMenuSearchBarView

+ (DBMenuSearchBarView *)create {
    DBMenuSearchBarView *view = [[[NSBundle mainBundle] loadNibNamed:@"DBMenuSearchBarView" owner:self options:nil] firstObject];
    
    return view;
}

- (void)awakeFromNib {
    self.backgroundColor = [UIColor colorWithRed:248./255 green:248./255 blue:248./255 alpha:1.0];
    [self.cancelButton setTitle:NSLocalizedString(@"Отмена", nil) forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor db_defaultColor] forState:UIControlStateNormal];
}

@end
