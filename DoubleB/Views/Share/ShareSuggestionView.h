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

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) IBOutlet UILabel *suggestTextLabel;

@property (nonatomic, strong) id<ShareSuggestionViewDelegate> delegate;

@end
