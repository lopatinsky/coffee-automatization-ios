//
//  DBCompaniesViewController.h
//  
//
//  Created by Balaban Alexander on 24/08/15.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DBCompaniesViewControllerMode) {
    DBCompaniesViewControllerModeChooseCompany = 0,
    DBCompaniesViewControllerModeChangeCompany
};

@interface DBCompaniesViewController : UIViewController
@property (nonatomic) DBCompaniesViewControllerMode mode;

@property (nonatomic, copy) void (^finalBlock)();
@end
