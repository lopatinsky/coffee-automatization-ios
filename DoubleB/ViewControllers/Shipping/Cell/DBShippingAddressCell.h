//
//  DBShippingAddressCell.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 22/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DBShippingAddressCellType) {
    DBShippingAddressCellTypeCity = 0,
    DBShippingAddressCellTypeStreet,
    DBShippingAddressCellTypeHome,
    DBShippingAddressCellTypeApartment,
    DBShippingAddressCellTypeComment
    
};

@interface DBShippingAddressCell : UITableViewCell

@property (nonatomic, readonly) DBShippingAddressCellType type;

- (void)configureWithType:(DBShippingAddressCellType)type;

@end
