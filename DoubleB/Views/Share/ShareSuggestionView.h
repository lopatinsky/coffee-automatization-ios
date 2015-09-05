//
//  ShareSuggestionView.h
//  
//
//  Created by Balaban Alexander on 03/09/15.
//
//

#import <UIKit/UIKit.h>

@protocol ShareSuggestionViewDelegate <NSObject>

- (void)showShareViewController;
- (void)hideShareSuggestionView;

@end

@interface ShareSuggestionView : UIView

@property (nonatomic, strong) id<ShareSuggestionViewDelegate> delegate;

- (void)showOnView:(UIView *)view animated:(BOOL)animated;
- (void)hide:(BOOL)animated;

@end
