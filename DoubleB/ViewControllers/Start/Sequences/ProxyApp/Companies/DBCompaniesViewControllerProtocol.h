//
//  DBCompaniesViewControllerProtocol.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DBCompaniesViewControllerMode) {
    DBCompaniesViewControllerModeChooseCompany = 0,
    DBCompaniesViewControllerModeChangeCompany
};

@protocol DBCompaniesViewControllerProtocol <NSObject>
@optional
- (void)setVCMode:(DBCompaniesViewControllerMode)mode;

@required
- (void)setFinalBlock:(void (^)())finalBlock;
@end
