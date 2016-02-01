//
//  DBCommentViewController.h
//  DoubleB
//
//  Created by Balaban Alexander on 31/07/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBCommentViewController;

@protocol DBCommentViewControllerDelegate <NSObject>
- (void)commentViewController:(DBCommentViewController *)controller didFinishWithText:(NSString *)text;
@end

@interface DBCommentViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, weak) id<DBCommentViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *comment;

@end
