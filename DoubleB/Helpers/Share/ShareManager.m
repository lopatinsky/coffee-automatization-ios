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

typedef enum : NSUInteger {
    ShareManagerShareIsAvailable,
    ShareManagerShareIsNotAvailable
} ShareManagerStatus;

@interface ShareManager() <ShareSuggestionViewDelegate>

@property (nonatomic) NSUInteger successOrderCreationIndex;
@property (nonatomic) ShareManagerStatus status;

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeStatusOfShareManager) name:kDBNewOrderCreatedNotification object:nil];
        self.successOrderCreationIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ShareManagerOrderCreationIndex"] integerValue];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)changeStatusOfShareManager {
    self.successOrderCreationIndex += 1;
    [[NSUserDefaults standardUserDefaults] setObject:@(self.successOrderCreationIndex) forKey:@"ShareManagerOrderCreationIndex"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (self.successOrderCreationIndex % 5 == 0) {
        self.status = ShareManagerShareIsAvailable;
    }
}

- (void)showOnViewController:(UIViewController *)viewController {
    CGRect frame = viewController.view.frame;
    self.shareView = [[ShareSuggestionView alloc] initWithNibNamed:@"ShareSuggestionView"];
    [self.shareView setFrame:CGRectMake(0.0, frame.size.height - 40, frame.size.width, 40)];
    [self.shareView layoutIfNeeded];
    self.shareView.delegate = self;
    [UIView animateWithDuration:0.1 animations:^{
        [viewController.view addSubview:self.shareView];
    }];
    self.status = ShareManagerShareIsNotAvailable;
}

- (BOOL)shareSuggestionIsAvailable {
    return self.status == ShareManagerShareIsAvailable;
}

#pragma mark - ShareSuggestionViewDelegate
- (void)showShareViewController {
    [UIView animateWithDuration:0.1 animations:^{
        [self.shareView removeFromSuperview];
    }];
    [[UIViewController currentViewController] presentViewController:[ViewControllerManager shareFriendInvitationViewController] animated:YES completion:^{
    }];
}

- (void)hideShareSuggestionView {
    [UIView animateWithDuration:0.1 animations:^{
        [self.shareView removeFromSuperview];
    }];
}

@end
