//
//  DBShippingAutocompleteCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 30/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBShippingAutocompleteCell.h"
#import "OrderCoordinator.h"

@interface DBShippingAutocompleteCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DBShippingAutocompleteCell

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBShippingAutocompleteCell" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
}

- (void)configureWithAddress:(DBShippingAddress *)address {
    self.titleLabel.text = address.street;
}

@end
