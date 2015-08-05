//
//  IHProductTableViewController.m
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IHProductsViewController.h"
#import "DBPositionCell.h"
#import "IHNewOrderViewController.h"
#import "DBPositionViewController.h"
#import "IHOrderManager.h"
#import "IHBarButtonItem.h"
#import "DBMenu.h"
#import "DBMenuCategory.h"
#import "DBMenuPosition.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"

#import "UINavigationController+DBAnimation.h"

@interface IHProductsViewController () <DBPositionCellDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IHOrderManager *orderManager;
@property (strong, nonatomic) NSArray *filteredPositions;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation IHProductsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.orderManager = [IHOrderManager sharedInstance];
    
    self.navigationItem.rightBarButtonItem = [[IHBarButtonItem alloc] initWithViewController:self action:@selector(goToOrderViewController)];
    
    [self IH_setTitle:self.category.name];
    self.navigationController.navigationBar.topItem.title = @"";

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor IH_defaultBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self hideSearchBarAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [IHGAITracker trackScreenWithName:PRODUCTS_SCREEN];
    [IHGAITracker trackEventWithCategory:PRODUCTS_SCREEN
                                  action:@"products_quantity"
                                   number:@([self.category.positions count])];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if(self.isMovingFromParentViewController){
        [IHGAITracker trackEventWithCategory:PRODUCTS_SCREEN action:@"back_click"];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return [self.filteredPositions count] + 1;
    } else {
        return [self.category.positions count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"DBPositionCell";
    DBPositionCell *cell = (DBPositionCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[DBPositionCell alloc] initWithType:DBPositionCellTypeFull];
        cell.delegate = self;
    }
    
    DBMenuPosition *position;
    if(tableView == self.searchDisplayController.searchResultsTableView){
        if(indexPath.row >= [self.filteredPositions count]){
            UITableViewCell *emptyCell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
            emptyCell.userInteractionEnabled = NO;
            emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return emptyCell;
        }
        
        NSDictionary *searchResultProduct = self.filteredPositions[indexPath.row];
        position = searchResultProduct[@"position"];
        [cell configureWithPosition:position];
        
        NSRange searchRange = [searchResultProduct[@"searchRange"] rangeValue];
        
        NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:position.name];
        [name addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:searchRange];
        [cell.titleLabel setAttributedText:name];
    } else {
        position = self.category.positions[indexPath.row];
        [cell configureWithPosition:position];
    }

    return cell;
}

#pragma mark - table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DBPositionCell *cell = (DBPositionCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    DBMenuPosition *position = cell.position;

    [IHGAITracker trackEventWithCategory:PRODUCTS_SCREEN
                                  action:@"item_product_click"
                                   label:position.positionId];
    
    
    
    DBPositionViewController *positionVC = [[DBPositionViewController alloc] initWithPosition:position mode:DBPositionViewControllerModeMenuPosition];
    [self.navigationController pushViewController:positionVC animated:YES];
}

- (void)goToOrderViewController {
    [IHGAITracker trackEventWithCategory:PRODUCTS_SCREEN
                                  action:@"order_title_click"
                                  number:@(self.orderManager.items.count)];
    
    IHNewOrderViewController *newOrderVC = [[IHNewOrderViewController alloc] init];
    [self.navigationController pushViewController:newOrderVC animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [IHGAITracker trackEventWithCategory:PRODUCTS_SCREEN action:@"products_scroll"];
}

#pragma mark - DBPositionCellDelegate

- (void)positionCellDidOrder:(DBPositionCell *)cell{
//    int viewSize = 16;
//    CGPoint viewOrigin = CGPointZero;
//    viewOrigin.x = cell.productOrderButton.frame.origin.x + cell.productOrderButton.frame.size.width / 2 - viewSize / 2;
//    viewOrigin.y = cell.productOrderButton.frame.origin.y + cell.productOrderButton.frame.size.height / 2 - viewSize / 2;
//    CGRect viewRect = CGRectMake(viewOrigin.x, viewOrigin.y, viewSize, viewSize);
//    viewRect = [cell convertRect:viewRect toView:self.navigationController.view];
//    
//    UIView *view = [[UIView alloc] initWithFrame:viewRect];
//    view.layer.cornerRadius = viewSize / 2;
//    view.backgroundColor = [UIColor IH_defaultColor];
//
//    [self.navigationController.view addSubview:view];
//
//    [UIView animateWithDuration:0.3
//                          delay:0
//                        options:UIViewAnimationOptionAllowUserInteraction
//                     animations:^{
//                         CGRect frame = view.frame;
//                         frame.origin.y = 40;
//                         view.frame = frame;
//                     }
//                     completion:^(BOOL finished) {
//                         [view removeFromSuperview];
//                     }];
//
//    [UIView animateWithDuration:0.2
//                          delay:0.1
//                        options:UIViewAnimationOptionAllowUserInteraction
//                     animations:^{
//                         view.alpha = 0;
//                     }
//                     completion:^(BOOL finished) {
//                         [view removeFromSuperview];
//                     }];
    
    [self.navigationController animateAddProductFromView:cell.priceLabel completion:^{
        [self.orderManager addPosition:cell.position];
    }];
}


#pragma mark - search Bar methods

-(void)hideSearchBarAnimated:(BOOL)animated{
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y += self.searchBar.bounds.size.height;
    
    if(animated){
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.tableView.bounds = newBounds;
                         }
                         completion:nil];
    } else {
        self.tableView.bounds = newBounds;
    }
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    self.filteredPositions = [[DBMenu sharedInstance] filterPositionsForSearchText:searchString];
    
    [IHGAITracker trackEventWithCategory:PRODUCTS_SCREEN
                                  action:@"search_entered"
                                   label:searchString];
    [IHGAITracker trackEventWithCategory:PRODUCTS_SCREEN
                                  action:@"search_success"
                                  number:@([self.filteredPositions count])];
    
    return YES;
}

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    UIBarButtonItem *cancelBarButton = [UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil];
    if(cancelBarButton)
        [cancelBarButton setTitle:@"Отмена"];
}

-(void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller{
    [IHGAITracker trackEventWithCategory:PRODUCTS_SCREEN action:@"search_started"];
}

-(void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    [self hideSearchBarAnimated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [IHGAITracker trackEventWithCategory:PRODUCTS_SCREEN
                                  action:@"search_entered_button"
                                   label:searchBar.text];
}

@end
