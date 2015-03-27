//
//  UIViewController+DBCardManagement.m
//  DoubleB
//
//  Created by Ощепков Иван on 13.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "UIViewController+DBCardManagement.h"
#import "IHPaymentManager.h"
#import "IHSecureStore.h"
#import "DBMastercardPromo.h"
#import "DBClientInfo.h"

#import <BlocksKit/UIAlertView+BlocksKit.h>

@implementation UIViewController (DBCardManagement)

static void (^completionBlock)(BOOL success);
static NSString *screenIdentifier;

- (void)db_cardManagementBindNewCardOnScreen:(NSString *)screen
                                    callback:(void(^)(BOOL success))completionHandler{
    if([[DBClientInfo sharedInstance] validName] && [[DBClientInfo sharedInstance] validPhone]){
        [self bindNewCard:completionHandler];
    } else {
        screenIdentifier = screen;
        completionBlock = completionHandler;
        
        DBProfileViewController *profileViewController = [DBProfileViewController new];
        profileViewController.fillingMode = ProfileFillingModeFillToContinue;
        profileViewController.delegate = self;
        profileViewController.screen = @"Profile_screen";
        [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:profileViewController]
                                                animated:YES
                                              completion:nil];
    }
}

- (void)bindNewCard:(void(^)(BOOL success))completionHandler{
    [[IHPaymentManager sharedInstance] setNavigationController:self.navigationController];
    [[IHPaymentManager sharedInstance] bindNewCardForClient:[IHSecureStore sharedInstance].clientId
                                          completionHandler:^(BOOL success, NSString *message, NSDictionary *items) {
                                              if (success) {
                                                  [[DBMastercardPromo sharedInstance] synchronisePromoInfoForClient:[IHSecureStore sharedInstance].clientId];
                                                  
                                                  if(completionHandler){
                                                      completionHandler(YES);
                                                  }
                                                  
                                                  [GANHelper analyzeEvent:@"card_add_success" category:screenIdentifier];
                                              } else {
                                                  NSString *error;
                                                  
                                                  if([message isEqualToString:kDBPaymentErrorDefault]){
                                                      error = NSLocalizedString(@"DefaultErrorMessage", nil);
                                                  }
                                                  if([message isEqualToString:kDBPaymentErrorWrongCardData]){
                                                      error = NSLocalizedString(@"WrongCardDataErrorMessage", nil);
                                                  }
                                                  if([message isEqualToString:kDBPaymentErrorCardLimitExceeded]){
                                                      error = NSLocalizedString(@"CardLimitExceededErrorMessage", nil);
                                                  }
                                                  if([message isEqualToString:kDBPaymentErrorCardNotUnique]){
                                                      error = NSLocalizedString(@"CardNotUniqueErrorMessage", nil);
                                                  }
                                                  if([message isEqualToString:kDBPaymentErrorNoInternetConnection]){
                                                      error = NSLocalizedString(@"NoInternetConnectionErrorMessage", nil);
                                                  }
                                                  if(!error){
                                                      error = message;
                                                  }
                                                  
                                                  
                                                  [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil)
                                                                                 message:error
                                                                       cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                       otherButtonTitles:nil
                                                                                 handler:nil];
                                                  
                                                  NSMutableString *eventLabel = [[NSMutableString alloc] init];
                                                  [eventLabel appendFormat:@"%@;", [DBClientInfo sharedInstance].clientName];
                                                  [eventLabel appendFormat:@"%@;", [DBClientInfo sharedInstance].clientPhone];
                                                  
                                                  if(items){
                                                      [eventLabel appendString:items[@"alfaResponse"]];
                                                  }
                                                  
                                                  [GANHelper analyzeEvent:@"card_add_failure" label:eventLabel category:screenIdentifier];
                                                  
                                                  if(completionHandler){
                                                      completionHandler(NO);
                                                  }
                                              }
                                          }];
}

#pragma mark - DBProfileViewControllerDelegate

- (void)profileViewControllerDidFillAllFields:(DBProfileViewController *)profileViewController {
    [self bindNewCard:completionBlock];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
