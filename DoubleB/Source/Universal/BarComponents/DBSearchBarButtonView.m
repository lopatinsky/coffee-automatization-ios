//
//  DBSearchBarButtonView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 10/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBSearchBarButtonView.h"

@interface DBSearchBarButtonView ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end

@implementation DBSearchBarButtonView

+ (DBSearchBarButtonView *)create {
    DBSearchBarButtonView *view = [[[NSBundle mainBundle] loadNibNamed:@"DBSearchBarButtonView" owner:self options:nil] firstObject];
    
    return view;
}

- (void)awakeFromNib {
    [self.iconImageView templateImageWithName:@"search_icon.png" tintColor:[UIColor whiteColor]];
}

@end
