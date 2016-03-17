//
//  DBPlatiusManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBPrimaryManager.h"
#import "DBUserProperty.h"

@interface DBPlatiusManager : DBPrimaryManager
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL authorized;
@property (strong, nonatomic,readonly) DBUserPhone *confirmedPhone;

@property (strong, nonatomic) NSString *barcode;
@property (strong, nonatomic) NSString *barcodeUrl;

@property (strong, nonatomic) NSString *screenAboutDescription;


- (void)setPhone:(NSString *)phone;

- (void)checkStatus:(void(^)(BOOL result))callback;
- (void)requestSms:(void(^)(BOOL success, NSString *description))callback;
- (void)sendConfirmationCode:(NSString *)code callback:(void(^)(BOOL success))callback;

@end
