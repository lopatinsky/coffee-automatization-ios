//
//  DBMenuModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 25/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBModuleView.h"


@class DBMenuModuleView;
@protocol DBMenuModuleViewDelegate <NSObject>

- (void)db_menuModuleViewDidReloadContent:(DBMenuModuleView *)module;
- (void)db_menuModuleViewNeedsToMoveForward:(DBMenuModuleView *)module object:(id)object;
- (void)db_menuModuleViewNeedsToAddPosition:(DBMenuModuleView *)module position:(DBMenuPosition *)position;

@end

@interface DBMenuModuleView : DBModuleView
@property (nonatomic) BOOL updateEnabled;
@property (weak, nonatomic) id<DBMenuModuleViewDelegate> menuModuleDelegate;

// Only for initial module in menu sequence
- (void)reloadContent;

@end
