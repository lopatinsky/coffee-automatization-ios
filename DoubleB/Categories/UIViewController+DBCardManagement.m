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
#import "DBClientInfo.h"

#import <BlocksKit/UIAlertView+BlocksKit.h>

@implementation UIViewController (DBCardManagement)

static void (^completionBlock)(BOOL success);
static NSString *screenIdentifier;

- (void)db_cardManagementBindNewCardOnScreen:(NSString *)screen
                                    callback:(void(^)(BOOL success))completionHandler{
    screenIdentifier = screen;
    
    if([[DBClientInfo sharedInstance] validClientName] && [[DBClientInfo sharedInstance] validClientPhone]){
        [self bindNewCard:completionHandler];
    } else {
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
                                                  
                                                  /***** analytics *****/
                                                  
                                                  NSUInteger cardsCount = [IHSecureStore sharedInstance].cardCount;
                                                  NSArray *cards = [IHSecureStore sharedInstance].cards;
                                                  NSString *cardType = [cards[cardsCount - 1][@"cardPan"] db_cardIssuer];
                                                  
                                                  NSString *eventLabel = [NSString stringWithFormat:@"%@;%ld", cardType, (long)(cardsCount - 1)];
                                                  
                                                  [GANHelper analyzeEvent:@"add_card_success" label:eventLabel category:PAYMENT_SCREEN];
                                                  
                                                  /*********************/
                                                  
                                                  if(completionHandler){
                                                      completionHandler(YES);
                                                  }
                                                  
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
                                                  
                                                  [GANHelper analyzeEvent:@"add_card_failed" label:error category:PAYMENT_SCREEN];
                                                  
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
