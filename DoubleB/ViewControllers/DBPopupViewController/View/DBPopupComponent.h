//
//  DBPopupViewComponent.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 09/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DBPopupAppearance) {
    DBPopupAppearancePush = 0,
    DBPopupAppearanceModal
};

typedef NS_ENUM(NSInteger, DBPopupTransition) {
    DBPopupTransitionBottom = 0,
    DBPopupTransitionTop,
    DBPopupTransitionCenter
};

@protocol DBPopupComponentDelegate;

@interface DBPopupComponent : UIView
@property (weak, nonatomic) id<DBPopupComponentDelegate> delegate;
@property (weak, nonatomic) UIView *parentView;
@property (strong, nonatomic) UIImageView *overlayView;

@property (nonatomic, readonly) BOOL presented;

- (void)configOverlay;

- (void)showOnView:(UIView *)parentView appearance:(DBPopupAppearance)appearance;
- (void)showOnView:(UIView *)parentView appearance:(DBPopupAppearance)appearance transition:(DBPopupTransition)transition;
- (void)showOnView:(UIView *)parentView appearance:(DBPopupAppearance)appearance transition:(DBPopupTransition)transition offset:(CGFloat)offset;

- (void)hide;

@end

@protocol DBPopupComponentDelegate <NSObject>
@optional
- (void)db_componentWillDismiss:(DBPopupComponent *)component;
@end
