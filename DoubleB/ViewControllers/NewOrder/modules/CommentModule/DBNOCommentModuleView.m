//
//  DBNOCommentModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOCommentModuleView.h"
#import "OrderCoordinator.h"

#import "DBCommentViewController.h"

@interface DBNOCommentModuleView ()
@property (weak, nonatomic) IBOutlet UIImageView *commentImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) OrderCoordinator *orderCoordinator;
@end

@implementation DBNOCommentModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBNOCommentModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [self commomInit];
}

- (void)commomInit {
    [self.commentImageView templateImageWithName:@"comment"];
    
    _orderCoordinator = [OrderCoordinator sharedInstance];
    
    [self reload];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    if (_orderCoordinator.orderManager.comment.length > 0) {
        if (_orderCoordinator.orderManager.comment.length > 10) {
            self.titleLabel.text = [NSString stringWithFormat:@"%@...", [_orderCoordinator.orderManager.comment substringToIndex:10]];
        } else {
            self.titleLabel.text = _orderCoordinator.orderManager.comment;
        }
    } else {
        self.titleLabel.text = NSLocalizedString(@"Комментарий", nil);
    }
}

- (void)touchAtLocation:(CGPoint)location {
    [GANHelper analyzeEvent:@"comment_screen" category:self.analyticsCategory];
    DBCommentViewController *commentController = [DBCommentViewController new];
    [self.ownerViewController.navigationController pushViewController:commentController animated:YES];
}

@end
