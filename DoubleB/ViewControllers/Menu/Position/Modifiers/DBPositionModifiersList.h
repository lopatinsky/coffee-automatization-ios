//
//  DBPositionModifiersList.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 09/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBPositionModifiersList;
@class DBMenuPosition;
@class DBMenuPositionModifier;

@protocol DBPositionModifiersListDelegate <NSObject>

- (void)db_positionModifiersList:(DBPositionModifiersList *)list didSelectGroupModifier:(DBMenuPositionModifier *)modifier;
- (void)db_positionModifiersListDidSelectSingleModifiers:(DBPositionModifiersList *)list;

@end

@interface DBPositionModifiersList : UIView

@property (weak, nonatomic) id<DBPositionModifiersListDelegate> delegate;
@property (nonatomic, readonly) NSInteger contentHeight;

- (void)configureWithPosition:(DBMenuPosition *)position;
- (void)reload;

@end
