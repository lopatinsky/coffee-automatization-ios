//
//  DBPreviewItemViewController.h
//  DoubleB
//
//  Created by Ощепков Иван on 18.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBPreviewItemViewController;
@protocol DBPreviewItemDelegate <NSObject>
- (void)db_previewItemDidChooseBindCard:(DBPreviewItemViewController *)previewItemViewController;
- (void)db_previewItemDidChooseSkipBinding:(DBPreviewItemViewController *)previewItemViewController;

@end

@interface DBPreviewItemViewController : UIViewController
@property (weak, nonatomic) id<DBPreviewItemDelegate> delegate;
- (instancetype)initWithImage:(UIImage *)image final:(BOOL)final;

@end
