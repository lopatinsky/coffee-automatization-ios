//
//  ShareManager.m
//  
//
//  Created by Balaban Alexander on 03/09/15.
//
//

#import "ShareManager.h"
#import "ShareSuggestionView.h"

#import "UIView+NIBInit.h"
#import "DBConstants.h"

NSString *const kDBShareManagerDefaultsInfo = @"kDBShareManagerDefaultsInfo";

//typedef enum : NSUInteger {
//    ShareManagerShareIsAvailable,
//    ShareManagerShareIsNotAvailable
//} ShareManagerStatus;

@interface ShareManager() <ShareSuggestionViewDelegate>

@property (nonatomic) NSUInteger successOrderCreationIndex;
//@property (nonatomic) ShareManagerStatus status;

@property (nonatomic, strong) ShareSuggestionView *shareView;

@end

@implementation ShareManager

+ (instancetype)sharedManager {
    static dispatch_once_t token;
    static ShareManager *instance;
    dispatch_once(&token, ^{
        instance = [[ShareManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeStatusOfShareManager) name:kDBNewOrderCreatedNotification object:nil];
//        self.successOrderCreationIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ShareManagerOrderCreationIndex"] integerValue];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//- (void)changeStatusOfShareManager {
//    int successOrderCreationIndex = [[ShareManager valueForKey:@"successOrderCreationIndex"] intValue];
//    [ShareManager setValue:@(successOrderCreationIndex + 1) forKey:@"successOrderCreationIndex"];
//    
//    [[NSUserDefaults standardUserDefaults] setObject:@(self.successOrderCreationIndex) forKey:@"ShareManagerOrderCreationIndex"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    if (self.successOrderCreationIndex % 5 == 0) {
//        self.status = ShareManagerShareIsAvailable;
//    }
//}

- (void)showShareSuggestion:(BOOL)animated {
    if(!self.shareView) {
        self.shareView = [[ShareSuggestionView alloc] initWithNibNamed:@"ShareSuggestionView"];
        self.shareView.delegate = self;
    }
    
    [self.shareView showOnView:[UIViewController currentViewController].view animated:animated];
//    self.status = ShareManagerShareIsNotAvailable;
}

- (BOOL)shareSuggestionIsAvailable {
    return [[DBCompanyInfo sharedInstance] friendInvitationEnabled];
}

#pragma mark - ShareSuggestionViewDelegate
- (void)showShareViewController {
    [self.shareView hide:YES];
    [[UIViewController currentViewController] presentViewController:[ViewControllerManager shareFriendInvitationViewController] animated:YES completion:nil];
}

- (void)hideShareSuggestionView {
    [self.shareView hide:YES];
}

#pragma mark - Helper methods

+ (id)valueForKey:(NSString *)key{
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:kDBShareManagerDefaultsInfo];
    return info[key];
}

+ (void)setValue:(id)value forKey:(NSString *)key {
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:kDBShareManagerDefaultsInfo];
    NSMutableDictionary *mutableInfo = [NSMutableDictionary dictionaryWithDictionary:info];
    
    if(value){
        mutableInfo[key] = value;
    } else {
        [mutableInfo removeObjectForKey:key];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:mutableInfo forKey:kDBShareManagerDefaultsInfo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
