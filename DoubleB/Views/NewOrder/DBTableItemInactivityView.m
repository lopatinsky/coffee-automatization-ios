//
//  DBOrderItemInactivityView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 09.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBTableItemInactivityView.h"

@interface DBTableItemInactivityView ()
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;

@end

@implementation DBTableItemInactivityView

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBTableItemInactivityView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib{
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    self.errorMessageLabel.textColor = [UIColor orangeColor];
}

- (void)setErrors:(NSArray *)errors{
    NSString *error = [errors firstObject];
    
    if(error){
        self.errorMessageLabel.text = error;
    } else {
        self.errorMessageLabel.text = @"";
    }
}

@end
