//
//  DBNOProfileModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOProfileModuleView.h"

@interface DBNOProfileModuleView ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DBNOProfileModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBNOProfileModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [self.profileImageView templateImageWithName:@"profile"];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
}

@end
