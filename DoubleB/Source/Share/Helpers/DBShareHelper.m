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

#import "ShareSuggestionView.h"
#import "DBPopupViewController.h"
#import "UIView+NIBInit.h"

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


@interface DBShareHelper ()<ShareSuggestionViewDelegate>
@property (nonatomic, strong) ShareSuggestionView *shareView;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableModule) name:kDBModulesManagerModulesLoaded object:nil];
    [self enableModule];
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)enabled {
    return [[DBShareHelper valueForKey:@"enabled"] boolValue];
}

- (BOOL)infoLoaded {
    return [[DBShareHelper valueForKey:@"infoLoaded"] boolValue];
}

- (void)enableModule {
    DBModule *module = [[DBModulesManager sharedInstance] module:DBModuleTypeFriendInvitation];
    [DBShareHelper setValue:@(module != nil) forKey:@"enabled"];
    
    if (self.enabled) {
        NSDictionary *info = [module.info getValueForKey:@"info"];
        [DBShareHelper setValue:[[info getValueForKey:@"about"] getValueForKey:@"title"] ?: @"" forKey:@"titleShareScreen"];
        [DBShareHelper setValue:[[info getValueForKey:@"about"] getValueForKey:@"description"] ?: @"" forKey:@"textShareScreen"];

        [self fetchShareInfo:nil];
    }
}

#pragma mark - Logic

- (void)fetchShareInfo:(void(^)(BOOL success))callback{
    if(![IHSecureStore sharedInstance].clientId){
        return;
    }
    
    [[DBAPIClient sharedClient] GET:@"shared/invitation/get_url"
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                //NSLog(@"%@", responseObject);
                                [DBShareHelper setValue:@(YES) forKey:@"infoLoaded"];
                                
                                NSString *imageUrl = [responseObject getValueForKey:@"image"];
                                
                                if(imageUrl){
                                    dispatch_async(dispatch_queue_create("image_load_queue", NULL), ^{
                                        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [DBShareHelper setValue:imageData forKey:@"shareImageData"];
                                        });
                                    });
                                }
                                
                                [DBShareHelper setValue:[responseObject getValueForKey:@"text"] ?: @"" forKey:@"shareText"];
                                [DBShareHelper setValue:imageUrl forKey:@"imageURL"];
                                [DBShareHelper setValue:[responseObject getValueForKey:@"promo_code"] ?: @"" forKey:@"promoCode"];
                                
                                NSDictionary *urls = [self processShareLinks:[responseObject getValueForKey:@"urls"]];
                                [DBShareHelper setValue:urls ?: @[] forKey:@"urls"];
                                
                                if(callback)
                                    callback(YES);
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                if(callback)
                                    callback(NO);
                            }];
}

#pragma mark - Storage

- (NSString *)promoCode {
    return [DBShareHelper valueForKey:@"promoCode"];
}

- (NSString *)imageURL {
    return [DBShareHelper valueForKey:@"imageURL"];
}

- (NSDictionary *)appUrls {
    return [DBShareHelper valueForKey:@"urls"];
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

#pragma mark - UI

- (BOOL)shareSuggestionIsAvailable {
    return [[DBCompanyInfo sharedInstance] friendInvitationEnabled];
}

- (void)showShareSuggestion:(BOOL)animated {
    if(!self.shareView) {
        self.shareView = [[ShareSuggestionView alloc] initWithNibNamed:@"ShareSuggestionView"];
        self.shareView.delegate = self;
    }
    
    [self.shareView showOnView:[UIViewController currentViewController].view animated:animated];
}

#pragma mark - ShareSuggestionViewDelegate
- (void)showShareViewController {
    [self.shareView hide:YES];
    
    [DBPopupViewController presentController:[ViewControllerManager shareFriendInvitationViewController] inContainer:[UIViewController currentViewController] mode:DBPopupVCAppearanceModeHeader];
}

- (void)hideShareSuggestionView {
    [self.shareView hide:YES];
}


+ (NSString *)db_managerStorageKey {
    return @"kDBShareHelperDefaultsInfo";
}

@end
