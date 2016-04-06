//
//  DBPositionViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 21/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBPositionViewController.h"

#import "DBMPImageModuleView.h"
#import "DBMPInfoModuleView.h"
#import "DBMPModifiersModuleView.h"
#import "DBMPOrderModuleView.h"

#import "DBBarButtonItem.h"

#import "DBMenuPosition.h"

@interface DBPositionViewController () <DBOwnerViewControllerProtocol>
@property (strong, nonatomic) DBMPOrderModuleView *orderModule;
@end

@implementation DBPositionViewController

+ (instancetype)initWithPosition:(DBMenuPosition *)position mode:(PositionViewControllerMode)mode {
    DBPositionViewController *positionVC = [DBPositionViewController new];
    
    positionVC.position = position;
    positionVC.mode = mode;
    
    return positionVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.view.backgroundColor = [UIColor db_backgroundColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self db_setTitle:self.position.name];
    
    if(self.mode == PositionViewControllerModeMenuPosition){
        if (self.position.mode == DBMenuPositionModeRegular) {
            self.navigationItem.rightBarButtonItem = [DBBarButtonItem item:DBBarButtonTypeOrder handler:^{
                [self moveToOrder];
            }];
        }
    }
    
    self.analyticsCategory = PRODUCT_SCREEN;
    
    if (self.mode == PositionViewControllerModeMenuPosition) {
        _orderModule = [DBMPOrderModuleView create];
        _orderModule.analyticsCategory = self.analyticsCategory;
        _orderModule.ownerViewController = self;
        _orderModule.position = self.position;
        
        _orderModule.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_orderModule];
        [_orderModule alignLeading:@"0" trailing:@"0" toView:self.view];
        [_orderModule alignBottomEdgeWithView:self.view predicate:@"0"];
        
        self.bottomInset = _orderModule.frame.size.height + 5;
    } else {
        self.bottomInset = 5;
    }
    self.scrollView.bounces = NO;
    
    [self setupModules];
}

- (void)setupModules {
    DBMPImageModuleView *imageModule = [DBMPImageModuleView new];
    imageModule.position = self.position;
    [self addModule:imageModule];
    
    DBMPInfoModuleView *infoModule = [DBMPInfoModuleView create];
    infoModule.position = self.position;
    [self addModule:infoModule topOffset:5.f];
    
    DBMPModifiersModuleView *modifiersModule = [DBMPModifiersModuleView create];
    modifiersModule.position = self.position;
    [self addModule:modifiersModule topOffset:5.f];
    
    [self layoutModules];
}

- (void)reloadModules:(BOOL)animated {
    [super reloadModules:animated];
    
    [_orderModule reload:animated];
}

- (void)moveToOrder{
    [self.navigationController pushViewController:[DBClassLoader loadNewOrderVC] animated:YES];
    [GANHelper analyzeEvent:@"order_pressed" category:self.analyticsCategory];
}

@end
