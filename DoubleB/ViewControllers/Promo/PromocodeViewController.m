//
//  PromocodeViewController.m
//  
//
//  Created by Balaban Alexander on 25/08/15.
//
//

#import "PromocodeViewController.h"
#import "DBServerAPI.h"

@interface PromocodeViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *activationButton;
@property (weak, nonatomic) IBOutlet UITableView *activatedPromosTableView;
@property (weak, nonatomic) IBOutlet UITextField *promoTextField;

@property (nonatomic, strong) NSArray *activatedPromos;

@end

@implementation PromocodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.activatedPromosTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"promo_cell"];
    
    self.navigationItem.title = NSLocalizedString(@"Промокоды", nil);
    self.activationButton.backgroundColor = [UIColor db_defaultColor];
    self.activationButton.layer.cornerRadius = 4.f;
    self.activationButton.clipsToBounds = YES;
    
    [self.activationButton setTitle:NSLocalizedString(@"Активировать", nil) forState:UIControlStateNormal];
    
    self.activatedPromosTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [self reloadhistory];
}

- (void)reloadhistory {
    [DBServerAPI fetchActivatedPromoCodesWithCallback:^(BOOL success, NSDictionary *response) {
        if (success) {
            self.activatedPromos = [response objectForKey:@"history"];
            [self.activatedPromosTableView reloadData];
        }
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)activateButtonPressed:(id)sender {
    [self.promoTextField resignFirstResponder];
    NSString *promocodeInput = self.promoTextField.text;
    [DBServerAPI activatePromoCode:promocodeInput withCallback:^(BOOL success, NSDictionary *response) {
        if (success) {
            if (![[response objectForKey:@"success"] boolValue]) {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ошибка", nil) message:[response objectForKey:@"description"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Успех", nil) message:[response objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                [self reloadhistory];
            }
        } else {
             [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ошибка", nil) message:NSLocalizedString(@"Проверьте соединение с интернетом и попробуйте ещё раз", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.activatedPromos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.activatedPromosTableView dequeueReusableCellWithIdentifier:@"promo_cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", [self.activatedPromos[indexPath.row] objectForKey:@"title"], [self.activatedPromos[indexPath.row] objectForKey:@"status"]];
    return cell;
}

#pragma mark - UITableViewDelegate 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.activatedPromosTableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
