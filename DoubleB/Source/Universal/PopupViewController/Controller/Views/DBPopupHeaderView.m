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
@property (weak, nonatomic) IBOutlet UIImageView *closeImageView;
@property (weak, nonatomic) IBOutlet UIView *rightNavigationItemHolder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintNavItemHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintNavItemWidth;

@end

@implementation DBPopupHeaderView

+ (DBPopupHeaderView *)create {
    DBPopupHeaderView *view = [[[NSBundle mainBundle] loadNibNamed:@"DBPopupHeaderView" owner:self options:nil] firstObject];
    
    return view;
}

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    
    self.titleLabel.text = NSLocalizedString(@"Закрыть", nil);
    [self.closeImageView templateImageWithName:@"close_circle" tintColor:[UIColor whiteColor]];
    
    @weakify(self)
    [self addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        if (self.doneBlock) {
            self.doneBlock();
        }
    }]];
}

- (void)setRightNavigationItem:(UIView *)rightNavigationItem {
    _rightNavigationItem = rightNavigationItem;
    
    self.constraintNavItemHeight.constant = _rightNavigationItem.frame.size.height > 30 ? 30 : _rightNavigationItem.frame.size.height;
    self.constraintNavItemWidth.constant = _rightNavigationItem.frame.size.width > 100 ? 100 : _rightNavigationItem.frame.size.width;
    [_rightNavigationItemHolder addSubview:_rightNavigationItem];
}
@end
