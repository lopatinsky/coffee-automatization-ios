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

@interface DBShareHelper ()

@property(strong, nonatomic) NSUserDefaults *userDefaults;
@property(strong, nonatomic) NSData *imageData;
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
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        [self fetchAll];
        [self updateShareInfo];
    }
    return self;
}

- (void)updateShareInfo{
    NSString *locale =  [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    NSString *clientId = [IHSecureStore sharedInstance].clientId;
    
    if(clientId){
        [[DBAPIClient sharedClient] GET:@"shared/info"
                             parameters:@{@"locale": locale,
                                          @"client_id": clientId}
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    //NSLog(@"%@", responseObject);
                                    
                                    NSString *imageUrl = responseObject[@"image_url"];
                                    dispatch_async(dispatch_queue_create("image_load_queue", NULL), ^{
                                        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            self.imageData = imageData;
                                            [self synchronize];
                                        });
                                    });
                                    
                                    self.appUrl = responseObject[@"app_url"];
                                    self.appUrlForSettings = responseObject[@"about_url"];
                                    
                                    self.textShareNewOrder = responseObject[@"text_share_new_order"];
                                    self.textShareAboutApp = responseObject[@"text_share_about_app"];
                                    
                                    self.titleShareScreen = responseObject[@"screen_title"];
                                    self.textShareScreen = responseObject[@"screen_text"];
                                    
                                    [self synchronize];
                                }
                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    NSLog(@"%@", error);
                                
                                }];
    }
}

- (UIImage *)imageForShare{
    return [UIImage imageWithData:self.imageData];
}

- (void)setImageData:(NSData *)imageData{
    _imageData = imageData ?: [NSData new];
}

- (void)setAppUrl:(NSString *)appUrl{
    if(appUrl && ![appUrl isEqualToString:@""]){
        _appUrl = appUrl;
    } else {
        _appUrl = @"https://itunes.apple.com/app/id908237281";
    }
}

- (void)setAppUrlForSettings:(NSString *)appUrlForSettings{
    if(appUrlForSettings && ![appUrlForSettings isEqualToString:@""]){
        _appUrlForSettings = appUrlForSettings;
    } else {
        _appUrlForSettings = @"https://itunes.apple.com/app/id908237281";
    }
}

- (void)setTextShareNewOrder:(NSString *)textShareNewOrder{
    if(textShareNewOrder && ![textShareNewOrder isEqualToString:@""]){
        _textShareNewOrder = textShareNewOrder;
    } else {
        _textShareNewOrder = @"Советую попробовать это интересное приложение для заказа кофе в 3 клика:";
    }
}

- (void)setTextShareAboutApp:(NSString *)textShareAboutApp{
    if(textShareAboutApp && ![textShareAboutApp isEqualToString:@""]){
        _textShareAboutApp = textShareAboutApp;
    } else {
        _textShareAboutApp = @"Я эксперт кофе 80-го уровня!";
    }
}

- (void)setTitleShareScreen:(NSString *)titleShareScreen{
    if(titleShareScreen && ![titleShareScreen isEqualToString:@""]){
        _titleShareScreen = titleShareScreen;
    } else {
        _titleShareScreen = NSLocalizedString(@"Ого! Поздравляю!\nНапиток в подарок от Mastercard!", nil);
    }
}

- (void)setTextShareScreen:(NSString *)textShareScreen{
    if(textShareScreen && ![textShareScreen isEqualToString:@""]){
        _textShareScreen = textShareScreen;
    } else {
        _textShareScreen = NSLocalizedString(@"Расскажи друзьям, если тебе нравится приложение Даблби.\nЕсть, что улучшить? Тогда напиши нам!", nil);
    }
}

- (void)fetchAll{
    NSDictionary *shareInfo = [self.userDefaults valueForKey:kDBDefaultsSharingInfo];
    
    self.imageData = shareInfo[@"imageData"];
    self.appUrl = shareInfo[@"appUrl"];
    self.appUrlForSettings = shareInfo[@"appUrlForSettings"];
    self.textShareNewOrder = shareInfo[@"textShareNewOrder"];
    self.textShareAboutApp = shareInfo[@"textShareAboutApp"];
    self.titleShareScreen = shareInfo[@"titleShareScreen"];
    self.textShareScreen = shareInfo[@"textShareScreen"];
}

- (void)synchronize{
    NSDictionary *shareInfo = @{@"imageData": self.imageData,
                                @"appUrl": self.appUrl,
                                @"appUrlForSettings": self.appUrlForSettings,
                                @"textShareNewOrder": _textShareNewOrder,
                                @"textShareAboutApp": _textShareAboutApp,
                                @"titleShareScreen": _titleShareScreen,
                                @"textShareScreen": _textShareScreen};
    
    [self.userDefaults setObject:shareInfo forKey:kDBDefaultsSharingInfo];
    [self.userDefaults synchronize];
}

@end
