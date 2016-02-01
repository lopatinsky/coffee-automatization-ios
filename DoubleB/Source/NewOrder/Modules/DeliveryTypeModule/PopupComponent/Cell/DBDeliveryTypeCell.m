//
//  DBDeliveryTypeCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 20/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBDeliveryTypeCell.h"
#import "DBDeliveryType.h"
#import "OrderCoordinator.h"

@interface DBDeliveryTypeCell ()
@property (weak, nonatomic) IBOutlet UIImageView *tickImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation DBDeliveryTypeCell

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBDeliveryTypeCell" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [self.tickImageView templateImageWithName:@"tick.png"];
}

- (void)configureWithDeliveryType:(DBDeliveryType *)type {
    _deliveryType = type;
    
    self.tickImageView.hidden = _deliveryType.typeId != [OrderCoordinator sharedInstance].deliverySettings.deliveryType.typeId;
    
    switch (_deliveryType.typeId) {
        case DeliveryTypeIdShipping:
            self.titleLabel.text = NSLocalizedString(@"Доставка", nil);
            break;
        case DeliveryTypeIdTakeaway:
            self.titleLabel.text = NSLocalizedString(@"Возьму с собой", nil);
            break;
        case DeliveryTypeIdInRestaurant:
            self.titleLabel.text = NSLocalizedString(@"На месте", nil);
            break;
            
        default:
            break;
    }
}

@end
