//
//  DBNODeliveryTypeModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 20/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNODeliveryTypeModuleView.h"
#import "DBDeliveryTypesPopupView.h"

#import "OrderCoordinator.h"

@interface DBNODeliveryTypeModuleView ()
@property (weak, nonatomic) IBOutlet UIImageView *tickImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) DBDeliveryTypesPopupView *typesPopupView;
@end

@implementation DBNODeliveryTypeModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBNODeliveryTypeModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.typesPopupView = [DBDeliveryTypesPopupView new];
    
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationNewDeliveryType selector:@selector(reload)];
}

- (void)dealloc {
    [[OrderCoordinator sharedInstance] removeObserver:self];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    switch ([OrderCoordinator sharedInstance].deliverySettings.deliveryType.typeId) {
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

- (void)touchAtLocation:(CGPoint)location {
    if ([DBCompanyInfo sharedInstance].deliveryTypes.count > 1) {
        if ([self.delegate respondsToSelector:@selector(db_moduleViewModalComponentContainer:)]) {
            [self.typesPopupView showFrom:self onView:[self.delegate db_moduleViewModalComponentContainer:self]];
        }
    }
}

@end
