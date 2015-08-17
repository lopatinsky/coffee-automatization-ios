//
//  DBProfileModuleViewDelegate.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 17.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBProfileModuleViewProtocol;

@protocol DBProfileModuleViewDelegate <NSObject>
- (void)db_profileModuleDidChange:(id<DBProfileModuleViewProtocol>)module;
@end

@protocol DBProfileModuleViewProtocol <NSObject>
@property(strong, nonatomic) NSString *analyticsCategory;
@property(weak, nonatomic) id<DBProfileModuleViewDelegate> delegate;
@end
