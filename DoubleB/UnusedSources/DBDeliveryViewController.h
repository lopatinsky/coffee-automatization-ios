//
//  DBDeliveryViewController.h
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 10.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Dirty way of solving the problem with segmented control, that responds on 
 *  taps.
 *
 *  TODO: fix it
 */
@protocol KeyboardAppearance <NSObject>

- (void)keyboardWillAppear;
- (void)keyboardWillDisappear;

@end

@interface DBDeliveryViewController : UIViewController

@property (nonatomic, weak) id<KeyboardAppearance> delegate;

@end
