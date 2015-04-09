//
//  DBPositionCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 07.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBPositionCompactCell.h"
#import "DBMenuPosition.h"

@interface DBPositionCompactCell () 
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

@implementation DBPositionCompactCell

- (void)awakeFromNib {
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor whiteColor];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.priceLabel.backgroundColor = [UIColor db_defaultColor];
    self.priceLabel.layer.cornerRadius = self.priceLabel.frame.size.height / 2;
    self.priceLabel.layer.masksToBounds = YES;
    self.priceLabel.textColor = [UIColor whiteColor];
    
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
}

- (void)configureWithPosition:(DBMenuPosition *)position{
    self.position = position;
    
    self.titleLabel.text = position.name;
    
    self.priceLabel.text = [NSString stringWithFormat:@"%.0f р.", position.price];
}

- (IBAction)orderButtonPressed:(id)sender {
    [self animateAdditionWithCompletion:^{
        [self.delegate positionCellDidOrder:self];
        
        [GANHelper analyzeEvent:@"item_product_add_to_order"
                          label:self.position.positionId
                       category:@"Menu_screen"];
    }];
}

- (void)animateAdditionWithCompletion:(void(^)())completion{
    UIView *view = [[UIView alloc] initWithFrame:self.orderButton.frame];
    view.layer.cornerRadius = view.frame.size.height / 2.f;
    view.layer.masksToBounds = YES;
    view.backgroundColor = [UIColor db_defaultColor];
    
    [self.contentView addSubview:view];
    
    self.orderButton.alpha = 0;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         view.transform = CGAffineTransformMakeScale(1.5, 1.5);
                     }
                     completion:^(BOOL finished) {
                         [view removeFromSuperview];
                         
                         if(completion)
                             completion();
                     }];
    
    [UIView animateWithDuration:0.2
                          delay:0.1
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         view.alpha = 0;
                         self.orderButton.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         [view removeFromSuperview];
                     }];
}

@end
