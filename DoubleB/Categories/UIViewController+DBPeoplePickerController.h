//
//  UIViewController+DBPeoplePickerController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 19/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@import AddressBookUI;

@interface UIViewController (DBPeoplePickerController)<ABPeoplePickerNavigationControllerDelegate>

- (void)db_presentPeoplePickerController:(void(^)(DBProcessState state, NSString *name, NSString *phone))callback;

@end
