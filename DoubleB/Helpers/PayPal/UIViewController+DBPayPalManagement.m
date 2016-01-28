//
//  UIViewController+DBPayPalManagement.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 20.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "UIViewController+DBPayPalManagement.h"
#import "DBPayPalManager.h"

@implementation UIViewController (DBPayPalManagement)

- (void)bindPayPal:(void(^)(BOOL success))callback {
    [DBPayPalManager sharedInstance].delegate = self;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[DBPayPalManager sharedInstance] bindPayPal:^(DBPayPalBindingState state, NSString *message) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if(state == DBPayPalBindingStateFailure){
            if(!message)
                message = @"Произошла непредвиденная ошибка! Пожалуйста, попробуйте еще раз!";
            
            [self showError:message];
        }
        
        if(callback)
            callback(state == DBPayPalBindingStateDone);
    }];
}

- (void)unbindPayPal:(void(^)(BOOL success))callback {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[DBPayPalManager sharedInstance] unbindPayPal:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if(callback)
            callback(YES);
    }];
}

#pragma mark - DBPayPalManagerDelegate

- (void)payPalManager:(DBPayPalManager *)manager shouldPresentViewController:(UIViewController *)controller{
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)payPalManager:(DBPayPalManager *)manager shouldDismissViewController:(UIViewController *)controller{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
