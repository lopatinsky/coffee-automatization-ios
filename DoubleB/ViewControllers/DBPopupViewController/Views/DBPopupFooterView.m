//
//  DBPopupFooterView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 16/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBPopupFooterView.h"

@interface DBPopupFooterView ()
@property (weak, nonatomic) IBOutlet UILabel *donelabel;

@end

@implementation DBPopupFooterView

+ (DBPopupFooterView *)create {
    DBPopupFooterView *view = [[[NSBundle mainBundle] loadNibNamed:@"DBPopupFooterView" owner:self options:nil] firstObject];
    
    return view;
}

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    
    self.donelabel.text = NSLocalizedString(@"ok", nil);
    self.donelabel.backgroundColor = [UIColor db_defaultColor];
    self.donelabel.layer.cornerRadius = 6.f;
    self.donelabel.layer.masksToBounds = YES;
    
    @weakify(self)
    [self addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        if (self.doneBlock) {
            self.doneBlock();
        }
    }]];
}

@end
