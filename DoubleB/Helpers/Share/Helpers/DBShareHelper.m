//
//  DBShareHelper.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19.01.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBShareHelper.h"
#import "DBAPIClient.h"
#import "IHSecureStore.h"

typedef NS_ENUM(NSUInteger, ShareType) {
    ShareTypeVK = 0,
    ShareTypeFacebook,
    ShareTypeSMS,
    ShareTypeEmail,
    ShareTypeWhatsApp,
    ShareTypeSkype,
    ShareTypeTwitter,
    ShareTypeInstagram,
    ShareTypeOther
};

NSString *const kDBShareHelperDefaultsInfo = @"kDBShareHelperDefaultsInfo";

@interface DBShareHelper ()

@end

@implementation DBShareHelper

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static DBShareHelper *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)fetchShareSupportInfo{
    [[DBAPIClient sharedClient] GET:@"shared/invitation/info"
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                [DBShareHelper saveValue:[responseObject getValueForKey:@"description"] ?: @"" forKey:@"textShareScreen"];
                                [DBShareHelper saveValue:[responseObject getValueForKey:@"title"] ?: @"" forKey:@"titleShareScreen"];
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                            }];
}

- (void)fetchShareInfo:(void(^)(BOOL success))callback{
    [[DBAPIClient sharedClient] GET:@"shared/invitation/get_url"
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                //NSLog(@"%@", responseObject);
                                
                                NSString *imageUrl = [responseObject getValueForKey:@"image"];
                                
                                if(imageUrl){
                                    dispatch_async(dispatch_queue_create("image_load_queue", NULL), ^{
                                        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [DBShareHelper saveValue:imageData forKey:@"shareImageData"];
                                        });
                                    });
                                }
                                
                                [DBShareHelper saveValue:[responseObject getValueForKey:@"text"] ?: @"" forKey:@"shareText"];
                                [DBShareHelper saveValue:imageUrl forKey:@"imageURL"];
                                [DBShareHelper saveValue:[responseObject getValueForKey:@"promo_code"] ?: @"" forKey:@"promoCode"];
                                _appUrls = [self processShareLinks:responseObject[@"urls"]];
                                
                                if(callback)
                                    callback(YES);
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                if(callback)
                                    callback(NO);
                            }];
}

- (NSString *)promoCode {
    return [DBShareHelper valueForKey:@"promoCode"];
}

- (NSString *)imageURL {
    return [DBShareHelper valueForKey:@"imageURL"];
}

- (UIImage *)imageForShare{
    NSData *imageData = [DBShareHelper valueForKey:@"shareImageData"];
    return [UIImage imageWithData:imageData];
}

- (NSString *)textShare {
    return [DBShareHelper valueForKey:@"shareText"];
}

- (NSString *)titleShareScreen {
    NSString *titleShareScreen = [DBShareHelper valueForKey:@"titleShareScreen"];
    
    if(titleShareScreen && ![titleShareScreen isEqualToString:@""]){
        return titleShareScreen;
    } else {
        return @"Расскажи друзьям о нашем приложении";
    }
}

- (NSString *)textShareScreen {
    NSString *textShareScreen = [DBShareHelper valueForKey:@"textShareScreen"];
    
    if(textShareScreen && ![textShareScreen isEqualToString:@""]){
        return textShareScreen;
    } else {
        return @"Нажми на кнопку Поделиться и предложи друзьям присоединиться к тебе";
    }
}

- (NSDictionary *)processShareLinks:(NSArray *)responseLinks{
    NSMutableDictionary *appLinks = [[NSMutableDictionary alloc] init];
    for(NSDictionary *link in responseLinks){
        int channel = [link[@"channel"] intValue];
        
        switch (channel) {
            case ShareTypeFacebook:
                appLinks[@"facebook"] = link[@"url"];
                break;
            case ShareTypeVK:
                appLinks[@"vk"] = link[@"url"];
                break;
            case ShareTypeSMS:
                appLinks[@"sms"] = link[@"url"];
                break;
            case ShareTypeEmail:
                appLinks[@"email"] = link[@"url"];
                break;
            case ShareTypeWhatsApp:
                appLinks[@"whatsApp"] = link[@"url"];
                break;
            case ShareTypeSkype:
                appLinks[@"skype"] = link[@"url"];
                break;
            case ShareTypeTwitter:
                appLinks[@"twitter"] = link[@"url"];
                break;
            case ShareTypeInstagram:
                appLinks[@"instagram"] = link[@"url"];
                break;
            case ShareTypeOther:
                appLinks[@"other"] = link[@"url"];
                break;
                
            default:
                break;
        }
    }
    
    return appLinks;
}

#pragma mark - Helper methods

+ (id)valueForKey:(NSString *)key{
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:kDBShareHelperDefaultsInfo];
    return info[key];
}

+ (void)saveValue:(id)value forKey:(NSString *)key {
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:kDBShareHelperDefaultsInfo];
    NSMutableDictionary *mutableInfo = [NSMutableDictionary dictionaryWithDictionary:info];
    
    if(value){
        mutableInfo[key] = value;
    } else {
        [mutableInfo removeObjectForKey:key];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:mutableInfo forKey:kDBShareHelperDefaultsInfo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
