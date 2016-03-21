//
//  DBCosmothecaNewOrderVC.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 28/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBCosmothecaNewOrderVC.h"

#import "DBNOOrderItemsModuleView.h"
#import "DBNOGiftItemsModuleView.h"
#import "DBNOBonusItemsModuleView.h"
#import "DBNOBonusItemAdditionModuleView.h"
#import "DBNOWalletModuleView.h"
#import "DBNOTotalModuleView.h"
#import "DBNOPromosModuleView.h"
#import "DBNODeliveryTypeModuleView.h"
#import "DBNOVenueModuleView.h"
#import "DBNOTimeModuleView.h"
#import "DBNOProfileModuleView.h"
#import "DBNOPaymentModuleView.h"
#import "DBNOCommentModuleView.h"
#import "DBNOOddModuleView.h"
#import "DBNOPersonsModuleView.h"
#import "DBNOndaModuleView.h"
#import "DBNOOrderModuleView.h"
#import "DBModuleSeparatorView.h"

#import "DBClientInfo.h"
#import "DBUniversalModulesManager.h"
#import "DBUniversalModule.h"

@interface DBCosmothecaNewOrderVC ()

@end

@implementation DBCosmothecaNewOrderVC

- (void)setupModules {
    [self addModule:[DBNOOrderItemsModuleView create]];
    [self addModule:[DBNOGiftItemsModuleView create] topOffset:1];
    [self addModule:[DBNOBonusItemsModuleView create] topOffset:1];
    [self addModule:[DBNOBonusItemAdditionModuleView create]];
    
    [self addModule:[[DBModuleSeparatorView alloc] initWithHeight:10]];
    
    if (![DBClientInfo sharedInstance].clientPhone.valid || ![DBClientInfo sharedInstance].clientName.valid){
        [self addModule:[DBNOProfileModuleView create] topOffset:0 bottomOffset:5];
    }
    
//    if ([DBCompanyInfo sharedInstance].deliveryTypes.count > 1) {
//        [self addModule:[DBNODeliveryTypeModuleView create] topOffset:0];
//    }
    
    [self addModule:[DBNOVenueModuleView create] topOffset:1];
    
    [self addModule:[DBNOTimeModuleView create] topOffset:1];
    
    [self addModule:[DBNOPaymentModuleView create]topOffset:5];
    
    [self addModule:[DBNOCommentModuleView create]topOffset:5];
    
//    if ([[DBModulesManager sharedInstance] moduleEnabled:DBModuleTypeOddSum]) {
//        [self addModule:[DBNOOddModuleView create]topOffset:1];
//    }
//    if ([[DBModulesManager sharedInstance] moduleEnabled:DBModuleTypePersonsCount]) {
//        [self addModule:[DBNOPersonsModuleView create]topOffset:1];
//    }
    
    // Universal modules
    for (DBUniversalModule *module in [DBUniversalOrderModulesManager sharedInstance].modules) {
        [self addModule:[module getModuleView] topOffset:0];
    }
    
    [self addModule:[DBNOndaModuleView create]topOffset:5];
    
    [self addModule:[[DBModuleSeparatorView alloc] initWithHeight:5]];
    
    [self addModule:[DBNOWalletModuleView create] topOffset:0 bottomOffset:1];
    [self addModule:[DBNOTotalModuleView create] topOffset:0];
    
    [self layoutModules];
}

@end
