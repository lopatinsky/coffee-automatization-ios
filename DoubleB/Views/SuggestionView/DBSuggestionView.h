//
//  ShareSuggestionView.h
//  
//
//  Created by Balaban Alexander on 03/09/15.
//
//

#import <UIKit/UIKit.h>

@class DBSuggestionView;
@protocol DBSuggestionViewDelegate <NSObject>

- (void)db_clickSuggestionView:(DBSuggestionView *)view;
- (void)db_closeSuggestionView:(DBSuggestionView *)view;

@end

@interface DBSuggestionView : UIView
@property (strong, nonatomic) NSString *title;

@property (nonatomic, strong) id<DBSuggestionViewDelegate> delegate;

- (void)showOnView:(UIView *)view animated:(BOOL)animated;
- (void)hide:(BOOL)animated completion:(void(^)())completion;

@end
