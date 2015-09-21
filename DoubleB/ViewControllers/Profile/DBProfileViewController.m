//
//  DBProfileViewController1.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 14.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBProfileViewController.h"
#import "DBProfileNameModuleView.h"
#import "DBProfilePhoneModuleView.h"
#import "DBProfileMailModuleView.h"

#import "DBClientInfo.h"
#import "DBServerAPI.h"

#import "UIBarButtonItem+BlocksKit.h"

@interface DBProfileViewController ()
@end

@implementation DBProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Профиль", nil);
    self.view.backgroundColor = [UIColor db_backgroundColor];
    
    // Name module
    DBProfileNameModuleView *nameModule = [DBProfileNameModuleView new];
    nameModule.ownerViewController = self;
    nameModule.analyticsCategory = self.analyticsScreen;
    [self.modules addObject:nameModule];
    
    // Phone module
    DBProfilePhoneModuleView *phoneModule = [DBProfilePhoneModuleView new];
    phoneModule.ownerViewController = self;
    phoneModule.analyticsCategory = self.analyticsScreen;
    [self.modules addObject:phoneModule];
    
    // Mail module
    DBProfileMailModuleView *mailModule = [DBProfileMailModuleView new];
    mailModule.ownerViewController = self;
    mailModule.analyticsCategory = self.analyticsScreen;
    [self.modules addObject:mailModule];
    
    [self layoutModules];
    
    [[DBClientInfo sharedInstance] addObserver:self withKeyPaths:@[DBClientInfoNotificationClientName, DBClientInfoNotificationClientPhone] selector:@selector(reloadDoneButton)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [GANHelper analyzeScreen:self.analyticsScreen];
    
    if (self.fillingMode == ProfileFillingModeFillToContinue) {
        @weakify(self)
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemCancel handler:^(id sender) {
            @strongify(self)
            [self sendProfileInfo];
            [self.view endEditing:YES];
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    
    [self reloadDoneButton];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self sendProfileInfo];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
        [GANHelper analyzeEvent:@"back_arrow_pressed" category:self.analyticsScreen];
    }
}

- (void)dealloc {
    [[DBClientInfo sharedInstance] removeObserver:self];
}

- (BOOL)dataIsValid {
    BOOL result = [DBClientInfo sharedInstance].clientName.valid;
    result = result && [DBClientInfo sharedInstance].clientPhone.valid;
    
    return result;
}

- (void)reloadDoneButton {
    if ([self dataIsValid] && self.fillingMode == ProfileFillingModeFillToContinue) {
        [self showRightBarButtonItem];
    } else {
        [self hideRightBarButtonItem];
    }
}

- (void)showRightBarButtonItem{
    if(!self.navigationItem.rightBarButtonItem && self.fillingMode == ProfileFillingModeFillToContinue){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemDone handler:^(id sender) {
            if (![self dataIsValid])
                return;
            [self sendProfileInfo];
            [self.view endEditing:YES];
            if ([self.delegate respondsToSelector:@selector(profileViewControllerDidFillAllFields:)])
                [self.delegate profileViewControllerDidFillAllFields:self];
        }];
    }
}

- (void)hideRightBarButtonItem{
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)sendProfileInfo{
    [GANHelper trackClientInfo];
    
    [DBServerAPI sendUserInfo:nil];
}

@end
