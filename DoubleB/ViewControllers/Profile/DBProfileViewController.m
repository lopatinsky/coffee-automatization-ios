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

#import "DBModuleHeaderView.h"

#import "DBClientInfo.h"
#import "DBServerAPI.h"

#import "DBUniversalModulesManager.h"
#import "DBUniversalModule.h"

#import "UIBarButtonItem+BlocksKit.h"

@interface DBProfileViewController ()
@end

@implementation DBProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self db_setTitle:NSLocalizedString(@"Профиль", nil)];
    self.view.backgroundColor = [UIColor db_backgroundColor];
    
    // Name module
    [self addModule:[DBProfileNameModuleView new] bottomOffset:1];
    
    // Phone module
    [self addModule:[DBProfilePhoneModuleView new] bottomOffset:1];
    
    // Mail module
    [self addModule:[DBProfileMailModuleView new]];
    
    // Universal modules
    for (DBUniversalModule *module in [DBUniversalModulesManager sharedInstance].modules) {
        [self addModule:[module getModuleView]];
    }
    
    [self layoutModules];
    
    [[DBClientInfo sharedInstance] addObserver:self withKeyPaths:@[DBClientInfoNotificationClientName, DBClientInfoNotificationClientPhone] selector:@selector(reloadDoneButton)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [GANHelper analyzeScreen:self.analyticsCategory];
    
    if (self.fillingMode == ProfileFillingModeFillToContinue) {
        @weakify(self)
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemCancel handler:^(id sender) {
            @strongify(self)
            [self sendProfileInfo];
            [self.view endEditing:YES];
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    
    [self reloadModules:NO];
    [self reloadDoneButton];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self sendProfileInfo];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
        [GANHelper analyzeEvent:@"back_arrow_pressed" category:self.analyticsCategory];
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
            if ([self.profileDelegate respondsToSelector:@selector(profileViewControllerDidFillAllFields:)])
                [self.profileDelegate profileViewControllerDidFillAllFields:self];
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
