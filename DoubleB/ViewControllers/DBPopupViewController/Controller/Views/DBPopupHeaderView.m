//
//  DBPopupHeaderView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 16/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBPopupHeaderView.h"

#import "UIGestureRecognizer+BlocksKit.h"

@interface DBPopupHeaderView ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DBPopupHeaderView

+ (DBPopupHeaderView *)create {
    DBPopupHeaderView *view = [[[NSBundle mainBundle] loadNibNamed:@"DBPopupHeaderView" owner:self options:nil] firstObject];
    
    return view;
}

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    
    self.titleLabel.text = NSLocalizedString(@"Закрыть", nil);
    
    @weakify(self)
    [self addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        if (self.doneBlock) {
            self.doneBlock();
        }
    }]];
}

@end
