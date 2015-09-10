//
//  DBPositionPriceView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 09/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DBPositionPriceViewMode) {
    DBPositionPriceViewModeStatic = 0,
    DBPositionPriceViewModeInteracted
};

@interface DBPositionPriceView : UIView

@property (nonatomic) DBPositionPriceViewMode mode;

@property (nonatomic) NSString *title;

@property (nonatomic) CGSize size;
@property (nonatomic, copy) void(^touchAction)();

- (void)animatePositionAdditionWithCompletion:(void(^)())completion;

@end
