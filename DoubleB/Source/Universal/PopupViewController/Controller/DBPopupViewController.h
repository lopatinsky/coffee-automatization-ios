//
//  DBPopupViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DBPopupVCAppearanceMode) {
    DBPopupVCAppearanceModeHeader = 0,
    DBPopupVCAppearanceModeFooter
};

@protocol DBPopupViewControllerContent <NSObject>

@optional
- (CGFloat)db_popupContentContentHeight;
- (CGSize)db_popupContentContentSize;

- (UIView *)db_popupContentRightNavigationItem;

@end

@interface DBPopupViewController : UIViewController<UIViewControllerAnimatedTransitioning>

@property (strong, nonatomic) UIViewController<DBPopupViewControllerContent> *displayController;
@property (strong, nonatomic) UIView<DBPopupViewControllerContent> *displayView;

@property (nonatomic) DBPopupVCAppearanceMode appearanceMode;

+ (DBPopupViewController *)presentController:(UIViewController<DBPopupViewControllerContent> *)controller
              inContainer:(UIViewController *)container
                     mode:(DBPopupVCAppearanceMode)mode;

+ (DBPopupViewController *)presentView:(UIView<DBPopupViewControllerContent> *)view
        inContainer:(UIViewController *)container
               mode:(DBPopupVCAppearanceMode)mode;

@end

@interface UIViewController (DBPopupViewControllerContent)
@property (weak, nonatomic) DBPopupViewController *popupViewController;
@end

@interface UIView (DBPopupViewControllerContent)
@property (weak, nonatomic) DBPopupViewController *popupViewController;
@end
