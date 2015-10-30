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

@class DBShippingAddressCell;

@protocol DBShippingAddressCellDelegate <NSObject>
@optional
- (void)db_addressCellStartEditing:(DBShippingAddressCell *)cell;
- (void)db_addressCellEndEditing:(DBShippingAddressCell *)cell;
- (void)db_addressCell:(DBShippingAddressCell *)cell textChanged:(NSString *)text;
- (void)db_addressCellClickedAtImage:(DBShippingAddressCell *)cell;
@end

@interface DBShippingAddressCell : UITableViewCell

@property (nonatomic, readonly) DBShippingAddressCellType type;
@property (weak, nonatomic) id<DBShippingAddressCellDelegate> delegate;
@property (nonatomic) BOOL imageViewVisisble;

- (void)configureWithType:(DBShippingAddressCellType)type;

@end
