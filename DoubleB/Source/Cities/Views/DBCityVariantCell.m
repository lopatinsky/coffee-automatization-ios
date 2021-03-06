//
//  DBCityVariantCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBCityVariantCell.h"
#import "DBCitiesManager.h"

@interface DBCityVariantCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DBCityVariantCell

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
}

- (void)setCity:(DBUnifiedCity *)city {
    _city = city;
    
    self.titleLabel.text = city.cityName;
}

@end
