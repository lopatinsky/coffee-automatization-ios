//
//  UIViewController+DBPeoplePickerController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "UIViewController+DBPeoplePickerController.h"

#import <objc/runtime.h>

static char DB_PEOPLEPICKERCONTROLLER_CALLBACK_KEY;

@implementation UIViewController (DBPeoplePickerController)

+ (id)getCallback {
    return objc_getAssociatedObject(self, &DB_PEOPLEPICKERCONTROLLER_CALLBACK_KEY);
}

+ (void)setCallback:(id)callback {
    objc_setAssociatedObject(self, &DB_PEOPLEPICKERCONTROLLER_CALLBACK_KEY, callback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)db_presentPeoplePickerController:(void(^)(DBProcessState state, NSString *name, NSString *phone))callback {
    [UIViewController setCallback:callback];
    
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.peoplePickerDelegate = self;
    
    peoplePicker.displayedProperties = @[@(kABPersonPhoneProperty)];
    
    if([Compatibility systemVersionGreaterOrEqualThan:@"8.0"]){
        peoplePicker.predicateForEnablingPerson = [NSPredicate predicateWithFormat:@"phoneNumbers.@count > 0"];
    }
    
    [self presentViewController:peoplePicker animated:YES completion:nil];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty) ?: @"";
    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty) ?: @"";
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", lastName, firstName];
    
    NSString *number;
    if(property == kABPersonPhoneProperty){
        @try {
            CFTypeRef multivalue = ABRecordCopyValue(person, property);
            CFIndex index = ABMultiValueGetIndexForIdentifier(multivalue, identifier);
            number = (__bridge NSString *)ABMultiValueCopyValueAtIndex(multivalue, index);
            
            void(^callback)(DBProcessState state, NSString *name, NSString *phone) = [UIViewController getCallback];
            if(callback) {
                callback(DBProcessStateDone, fullName, number);
            }
        }
        @catch (NSException *exception) {}
    }
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty) ?: @"";
    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty) ?: @"";
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", lastName, firstName];
    
    NSString *number;
    if(property == kABPersonPhoneProperty){
        @try {
            CFTypeRef multivalue = ABRecordCopyValue(person, property);
            CFIndex index = ABMultiValueGetIndexForIdentifier(multivalue, identifier);
            number = (__bridge NSString *)ABMultiValueCopyValueAtIndex(multivalue, index);
            
            void(^callback)(DBProcessState state, NSString *name, NSString *phone) = [UIViewController getCallback];
            if(callback) {
                callback(DBProcessStateDone, fullName, number);
            }
        }
        @catch (NSException *exception) {}
        @finally {
            [peoplePicker dismissViewControllerAnimated:YES completion:nil];
            
            return NO;
        }
    } else {
        return YES;
    }
    
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    void(^callback)(DBProcessState state, NSString *name, NSString *phone) = [UIViewController getCallback];
    if(callback) {
        callback(DBProcessStateCancelled, nil, nil);
    }
}

@end
