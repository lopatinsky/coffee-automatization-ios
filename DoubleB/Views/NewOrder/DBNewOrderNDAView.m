//
//  DBNewOrderNDAView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 20.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBNewOrderNDAView.h"

#import <BlocksKit/UIControl+BlocksKit.h>
#import <BlocksKit/UIGestureRecognizer+BlocksKit.h>

@interface DBNewOrderNDAView ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *labelNda;
@property (weak, nonatomic) IBOutlet UISwitch *ndaAcceptSwitch;
@end

@implementation DBNewOrderNDAView

- (void)awakeFromNib{
    self.labelNda.text = NSLocalizedString(@"Согласен с условиями политики конфиденциальности", nil);
    [self reload];
    self.ndaAcceptSwitch.onTintColor = [UIColor db_blueColor];
    
    @weakify(self)
    [self.ndaAcceptSwitch bk_addEventHandler:^(id sender) {
        @strongify(self)
        
        BOOL ndaSigned = self.ndaAcceptSwitch.isOn;
        
        [[NSUserDefaults standardUserDefaults] setBool:ndaSigned forKey:kDBDefaultsNDASigned];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if(ndaSigned){
            [GANHelper analyzeEvent:@"accept_policy" category:@"Order_screen"];
        } else {
            [GANHelper analyzeEvent:@"decline_policy" category:@"Order_screen"];
        }
        
        [self reload];
        
        if([self.delegate respondsToSelector:@selector(db_newOrderNDAView:didSelectSwitchState:)])
            [self.delegate db_newOrderNDAView:self didSelectSwitchState:ndaSigned];
    } forControlEvents:UIControlEventValueChanged];
    
    self.labelNda.userInteractionEnabled = YES;
    [self.labelNda addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        
        [GANHelper analyzeEvent:@"policy_click" category:@"Order_screen"];
        
        if([self.delegate respondsToSelector:@selector(db_newOrderNDAViewDidTapNDALabel:)])
            [self.delegate db_newOrderNDAViewDidTapNDALabel:self];
    }]];
}

- (void)reload{
    BOOL ndaSigned = [[NSUserDefaults standardUserDefaults] boolForKey:kDBDefaultsNDASigned];
    
    self.ndaAcceptSwitch.on = ndaSigned;
    if(ndaSigned){
        self.labelNda.textColor = [UIColor blackColor];
        [self.labelNda db_stopObservingAnimationNotification];
    } else {
        self.labelNda.textColor = [UIColor orangeColor];
        [self.labelNda db_startObservingAnimationNotification];
    }
}

- (void)show{
    self.heightConstraint.constant = 50;
    self.hidden = NO;
    
    [self layoutIfNeeded];
}

- (void)hide{
    self.heightConstraint.constant = 0;
    self.hidden = YES;
    
    [self layoutIfNeeded];
}

@end
