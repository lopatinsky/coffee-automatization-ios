//
//  DBCompaniesViewControllerProtocol.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBCompaniesViewController;
@class DBCompany;

typedef NS_ENUM(NSInteger, DBCompaniesViewControllerMode) {
    DBCompaniesViewControllerModeChooseCompany = 0,
    DBCompaniesViewControllerModeChangeCompany
};

@protocol DBCompaniesViewControllerDelegate <NSObject>
- (void)db_companiesVC:(DBCompaniesViewController *)controller didSelectCompany:(DBCompany *)company;
@end

@protocol DBCompaniesViewControllerProtocol <NSObject>
@optional
- (void)setVCMode:(DBCompaniesViewControllerMode)mode;

@required
- (void)setVCDelegate:(id<DBCompaniesViewControllerDelegate>)delegate;
@end
