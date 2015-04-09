//
//  DBOrderItemInactivityView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 09.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBOrderItemInactivityView.h"

@interface DBOrderItemInactivityView ()
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;

@end

@implementation DBOrderItemInactivityView

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBOrderItemInactivityView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib{
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.errorMessageLabel.textColor = [UIColor orangeColor];
}

- (void)setErrors:(NSArray *)errors{
    NSString *error = [errors firstObject];
    
    if(error){
        self.errorMessageLabel.text = error;
    }
}

@end
