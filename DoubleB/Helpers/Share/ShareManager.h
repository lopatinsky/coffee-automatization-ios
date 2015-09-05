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

@property (nonatomic) BOOL shareSuggestionIsAvailable;

- (void)showShareSuggestion:(BOOL)animated;
- (BOOL)shareSuggestionIsAvailable;

@end
