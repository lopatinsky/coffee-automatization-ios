//
//  DBProfileModuleViewDelegate.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 17.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBPaymentModuleViewProtocol;

@protocol DBPaymentModuleViewDelegate <NSObject>

@end

@protocol DBPaymentModuleViewProtocol <NSObject>
@property(strong, nonatomic) NSString *analyticsCategory;
@property(weak, nonatomic) id<DBPaymentModuleViewDelegate> delegate;
@end
