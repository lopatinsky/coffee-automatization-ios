//
//  DBPopupViewComponent.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 09/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DBPopupViewComponentAppearance) {
    DBPopupViewComponentAppearancePush = 0,
    DBPopupViewComponentAppearanceModal
};

typedef NS_ENUM(NSInteger, DBPopupViewComponentTransition) {
    DBPopupViewComponentTransitionBottom = 0,
    DBPopupViewComponentTransitionCenter
};

@interface DBPopupViewComponent : UIView

@property (weak, nonatomic) UIView *parentView;
@property (strong, nonatomic) UIImageView *overlayView;

- (void)configOverlay;

- (void)showOnView:(UIView *)parentView withAppearance:(DBPopupViewComponentAppearance)appearance;
- (void)showOnView:(UIView *)parentView withAppearance:(DBPopupViewComponentAppearance)appearance transition:(DBPopupViewComponentTransition)transition;

- (void)hide;

@end
