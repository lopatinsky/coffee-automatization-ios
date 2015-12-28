//
//  NewsHistoryTableViewCell.h
//  DoubleB
//
//  Created by Balaban Alexander on 27/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HistoryCellTextViewDelegate <NSObject>

- (void)tapOnCell:(NSInteger)index;

@end

@interface NewsHistoryTableViewCell : UITableViewCell

@property (weak, nonatomic) id<HistoryCellTextViewDelegate> delegate;
@property (nonatomic) NSInteger index;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *newsTextLabel;

@end
