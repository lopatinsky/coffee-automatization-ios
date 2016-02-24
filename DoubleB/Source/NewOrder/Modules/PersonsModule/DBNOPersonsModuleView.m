//
//  DBNOPersonsModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 05/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOPersonsModuleView.h"
#import "OrderCoordinator.h"
#import "DBPickerView.h"

@interface DBNOPersonsModuleView ()<DBPopupComponentDelegate, DBPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) DBPickerView *pickerView;

@property (strong, nonatomic) NSArray *titles;

@end

@implementation DBNOPersonsModuleView

+ (NSString *)xibName {
    return @"DBNOPersonsModuleView";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.titles = @[@"Буду один", @"На двоих", @"3 человека", @"4 человека", @"5 человек", @"6 человек", @"Нас много"];
    
    self.pickerView = [DBPickerView create:DBPickerViewModeItems];
    self.pickerView.pickerDelegate = self;
    self.pickerView.title = NSLocalizedString(@"Количество персон", nil);
    [self.pickerView configureWithItems:self.titles];
    
    [self.iconImageView templateImageWithName:@"user_group_icon"];
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationNewPersonsCount selector:@selector(reload)];
}

- (void)dealloc {
    [[OrderCoordinator sharedInstance] removeObserver:self];
}

- (void)reload:(BOOL)animated {
    [self reloadTitle];
    [super reload:animated];
}

- (void)reloadTitle {
    if ([OrderCoordinator sharedInstance].orderManager.personsCount == 0) {
        self.titleLabel.textColor = [UIColor db_grayColor];
        self.titleLabel.text = NSLocalizedString(@"Количество персон", nil);
    } else {
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.text = self.titles[[OrderCoordinator sharedInstance].orderManager.personsCount - 1];
    };
}

- (void)touchAtLocation:(CGPoint)location {
    [self.pickerView showOnView:self.ownerViewController.navigationController.view appearance:DBPopupAppearanceModal transition:DBPopupTransitionBottom];
}

#pragma mark - DBPickerViewDelegate

- (void)db_componentWillDismiss:(DBPopupComponent *)component {
    [OrderCoordinator sharedInstance].orderManager.personsCount = ((DBPickerView *)component).selectedIndex + 1;
    [self reload];
}

@end
