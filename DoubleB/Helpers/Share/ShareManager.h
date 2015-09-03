//
//  ShareManager.h
//  
//
//  Created by Balaban Alexander on 03/09/15.
//
//

#import <Foundation/Foundation.h>

@interface ShareManager : NSObject

+ (nonnull instancetype)sharedManager;

- (void)showOnViewController:(nonnull UIViewController *)viewController;
- (BOOL)shareSuggestionIsAvailable;

@end
