//
//  DBCoffeeHostelSettingsViewController.m
//  
//
//  Created by Balaban Alexander on 25/08/15.
//
//

#import "DBCoffeeHostelSettingsViewController.h"
#import "PromocodeViewController.h"

@interface DBCoffeeHostelSettingsViewController ()
@property (strong, nonatomic) NSMutableArray *settingsItems;
@end

@implementation DBCoffeeHostelSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    DBApplicationSettingsViewController *applicationSettingsVC = [DBApplicationSettingsViewController new];
    [self.settingsItems insertObject:@{@"name": @"appPromoVC",
                                       @"title": NSLocalizedString(@"Промокоды", nil),
                                       @"image": @"none",
                                       @"viewController": [PromocodeViewController new]}
                             atIndex:0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    NSDictionary *settingsItemInfo;
    if (indexPath.row < [self.settingsItems count]) {
        settingsItemInfo = self.settingsItems[indexPath.row];
    }
    
    if ([settingsItemInfo[@"name"] isEqualToString:@"appPromoVC"]){
        [self.navigationController pushViewController:settingsItemInfo[@"viewController"] animated:YES];
    }
}

@end
