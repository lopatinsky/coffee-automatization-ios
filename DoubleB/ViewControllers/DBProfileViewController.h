//
//  DBProfileViewController.h
//  DoubleB
//
//  Created by Balaban Alexander on 01/08/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ProfileFillingMode) {
    ProfileFillingModeNoRestrictions = 0,
    ProfileFillingModeFillToContinue
};

@class DBProfileViewController;
@protocol DBProfileViewControllerDelegate <NSObject>
- (void)profileViewControllerDidFillAllFields:(DBProfileViewController *)profileViewController;
@end

@interface DBProfileViewController : UITableViewController

@property (nonatomic) ProfileFillingMode fillingMode;
@property (nonatomic, weak) id<DBProfileViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *screen;

@end
