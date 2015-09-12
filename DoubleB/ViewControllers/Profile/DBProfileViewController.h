//
//  DBProfileViewController1.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 14.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBModulesViewController.h"

typedef NS_ENUM(NSUInteger, ProfileFillingMode) {
    ProfileFillingModeNoRestrictions = 0,
    ProfileFillingModeFillToContinue
};

@class DBProfileViewController;
@protocol DBProfileViewControllerDelegate <NSObject>
- (void)profileViewControllerDidFillAllFields:(DBProfileViewController *)profileViewController;
@end

@interface DBProfileViewController : DBModulesViewController

@property (nonatomic) ProfileFillingMode fillingMode;
@property (nonatomic, strong) NSString *analyticsScreen;

@property (weak, nonatomic) id<DBProfileViewControllerDelegate> delegate;

@end
