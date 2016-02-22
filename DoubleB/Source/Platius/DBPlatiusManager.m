//
//  DBPlatiusManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBPlatiusManager.h"
#import "DBAPIClient.h"
#import "DBClientInfo.h"

@implementation DBPlatiusManager

- (void)enableModule:(BOOL)enabled withDict:(NSDictionary *)moduleDict {
    [DBPlatiusManager setValue:@(enabled) forKey:@"enabled"];
    
    NSString *description = [[[moduleDict getValueForKey:@"info"] getValueForKey:@"about"] getValueForKey:@"description"] ?: @"";
    [DBPlatiusManager setValue:description forKey:@"about_screen_description"];
}

- (BOOL)enabled {
    return [[DBPlatiusManager valueForKey:@"enabled"] boolValue];
}

- (BOOL)authorized {
    return [[DBPlatiusManager valueForKey:@"authorized"] boolValue];
}

- (DBUserPhone *)confirmedPhone {
    NSString *phone = [DBPlatiusManager valueForKey:@"confirmedPhone"];
    
    if (phone.length == 0) {
        phone = [DBClientInfo sharedInstance].clientPhone.value;
    }
    
    DBUserPhone *phoneObj = [DBUserPhone new];
    phoneObj.value = phone;
    return phoneObj;
}

- (void)setPhone:(NSString *)phone {
    [DBPlatiusManager setValue:phone forKey:@"confirmedPhone"];
}

- (NSString *)screenAboutDescription {
    return [DBPlatiusManager valueForKey:@"about_screen_description"];
}

- (void)checkStatus:(void(^)(BOOL result))callback {
    [[DBAPIClient sharedClient] GET:@"platius/status"
                         parameters:nil
                            success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                [self parseStatusResponse:responseObject];
                                
                                if (callback)
                                    callback (YES);
                            } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                NSLog(@"%@", error);
                                
                                if (callback)
                                    callback (NO);
                            }];
}

- (void)parseStatusResponse:(NSDictionary *)responseObject {
    [DBPlatiusManager setValue:@([[responseObject getValueForKey:@"authorized"] boolValue]) forKey:@"authorized"];
    
    if (self.authorized) {
        _barcode = [responseObject getValueForKey:@"payment_code"] ?: @"";
        _barcodeUrl = [[responseObject getValueForKey:@"barcode_info"] getValueForKey:@"image_url"] ?: @"";
    }
}

- (void)requestSms:(void(^)(BOOL success, NSString *description))callback {
    [[DBAPIClient sharedClient] POST:@"platius/send_sms"
                          parameters:@{@"client_phone": self.confirmedPhone.value}
                             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                 BOOL success = [[responseObject getValueForKey:@"success"] boolValue];
                                 NSString *description = [responseObject getValueForKey:@"description"] ?: @"";
                                 
                                 if (success) {
                                     [[DBClientInfo sharedInstance] setPhone:self.confirmedPhone.value];
                                 }
                                 
                                 if (callback)
                                     callback(success, description);
                             } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                 NSLog(@"%@", error);
                                 
                                 if (callback)
                                     callback(NO, nil);
                             }];
}

- (void)sendConfirmationCode:(NSString *)code callback:(void(^)(BOOL success))callback {
    [[DBAPIClient sharedClient] POST:@"platius/check_sms"
                          parameters:@{@"code": code ?: @""}
                             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                 BOOL authorized = [[responseObject getValueForKey:@"authorized"] boolValue];
                                 
                                 if (authorized) {
                                     [self parseStatusResponse:responseObject];
                                 }
                                 
                                 if (callback)
                                     callback (authorized);
                             } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                 NSLog(@"%@", error);
                                 
                                 if (callback)
                                     callback(NO);
                             }];
}

+ (NSString *)db_managerStorageKey {
    return @"kDBPlatiusManagerDefaults";
}

@end
