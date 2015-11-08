//
//  DBCityVariantCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBCityVariantCell.h"
#import "DBUnifiedAppManager.h"

@interface DBCityVariantCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DBCityVariantCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setCity:(DBCity *)city {
    _city = city;
    
    self.titleLabel.text = city.cityName;
}

@end
