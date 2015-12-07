//
//  DBMonthSubscriptionManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBSubscriptionManager.h"
#import "DBAPIClient.h"
#import "DBMenuCategory.h"
#import "DBCardsManager.h"
#import "DBConstants.h"

#import "GANHelper.h"
#import "IHSecureStore.h"

NSString *const kDBSubscriptionManagerCategoryIsAvailable = @"kDBSubscriptionManagerCategoryIsAvailable";

@interface DBSubscriptionManager()

@property (nonatomic, strong) NSMutableArray *subscriptionVariants;
@property (nonatomic) NSInteger currentCupsInOrder;
@property (nonatomic) BOOL enable;

@end

@implementation DBSubscriptionManager

- (instancetype)init {
    self = [super init];
    
    self.subscriptionVariants = [NSMutableArray new];
    [self loadCurrentSubscription];
    [self.currentSubscription calculateDays];
    [self saveCurrentSubscription];
    
    [self loadSubscriptionCategory];
    self.enable = [[DBSubscriptionManager valueForKey:@"__available"] boolValue];
    
    self.subscriptionScreenTitle = [DBSubscriptionManager valueForKey:@"__subscriptionScreenTitle"];
    self.subscriptionScreenText = [DBSubscriptionManager valueForKey:@"__subscriptionScreenText"];
    self.subscriptionMenuTitle = [DBSubscriptionManager valueForKey:@"__subscriptionMenuTitle"];
    self.subscriptionMenuText = [DBSubscriptionManager valueForKey:@"__subscriptionMenuText"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderCreated) name:kDBNewOrderCreatedNotification object:nil];
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)orderCreated {
    self.currentSubscription.amount = @([self.currentSubscription.amount integerValue] - self.currentCupsInOrder);
    self.currentCupsInOrder = 0;
    [self saveCurrentSubscription];
}

#pragma mark - Class methods

+ (BOOL)positionsAreAvailable {
    return [[DBSubscriptionManager sharedInstance] isEnabled] && [[DBSubscriptionManager sharedInstance] subscriptionCategory];
}

+ (BOOL)categoryIsSubscription:(DBMenuCategory *)category {
    return [[[[DBSubscriptionManager sharedInstance] subscriptionCategory] categoryId] isEqualToString:[category categoryId]];
}

+ (BOOL)isSubscriptionPosition:(NSIndexPath *)indexPath {
    return [[DBSubscriptionManager sharedInstance] isEnabled] && (indexPath.section == 0);
}

+ (SubscriptionInfoTableViewCell *)subscriptionCellForIndexPath:(NSIndexPath *)indexPath andCell:(SubscriptionInfoTableViewCell *)cell {
    if (indexPath.row == 0) {
        if ([[DBSubscriptionManager sharedInstance] isAvailable]) {
            cell.placeholderView.hidden = YES;
            cell.numberOfCupsLabel.text = [NSString stringWithFormat:@"x %ld", (long)[[DBSubscriptionManager sharedInstance] numberOfAvailableCups]];
            cell.numberOfDaysLabel.text = [NSString stringWithFormat:@"%@", [[[DBSubscriptionManager sharedInstance] currentSubscription] days]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.userInteractionEnabled = NO;
        } else {
            cell.placeholderView.hidden = NO;
            cell.subscriptionAds.text = [DBSubscriptionManager sharedInstance].subscriptionMenuTitle;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    return nil;
}

#pragma mark – Cache section

- (void)loadCurrentSubscription {
    self.currentSubscription = [NSKeyedUnarchiver unarchiveObjectWithData:[DBSubscriptionManager valueForKey:@"__currentSubscription"]];
}

- (void)saveCurrentSubscription {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.currentSubscription];
    [DBSubscriptionManager setValue:data forKey:@"__currentSubscription"];
}

- (void)loadSubscriptionCategory {
    self.subscriptionCategory = [NSKeyedUnarchiver unarchiveObjectWithData:[DBSubscriptionManager valueForKey:@"__subscriptionCategory"]];
}

- (void)saveSubscriptionCategory {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.subscriptionCategory];
    [DBSubscriptionManager setValue:data forKey:@"__subscriptionCategory"];
}

#pragma mark - Auxiliary

- (void)enableModule:(BOOL)enabled withDict:(NSDictionary *)moduleDict {
    self.enable = enabled;
    [DBSubscriptionManager setValue:@(enabled) forKey:@"__available"];
    if (self.enable) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDBSubscriptionManagerCategoryIsAvailable object:nil];
        
        self.subscriptionScreenText = moduleDict[@"info"][@"screen"][@"description"];
        self.subscriptionScreenTitle = moduleDict[@"info"][@"screen"][@"title"];
        self.subscriptionMenuText = moduleDict[@"info"][@"menu"][@"description"];
        self.subscriptionMenuTitle = moduleDict[@"info"][@"menu"][@"title"];
        
        [DBSubscriptionManager setValue:self.subscriptionScreenTitle forKey:@"__subscriptionScreenTitle"];
        [DBSubscriptionManager setValue:self.subscriptionScreenText forKey:@"__subscriptionScreenText"];
        [DBSubscriptionManager setValue:self.subscriptionMenuTitle forKey:@"__subscriptionMenuTitle"];
        [DBSubscriptionManager setValue:self.subscriptionMenuText forKey:@"__subscriptionMenuText"];
        
        [self subscriptionInfo:^(NSArray *info) {
            
        } failure:^(NSString *errorMessage) {
            
        }];
    }
}

- (void)synchWithResponseInfo:(NSDictionary *)infoDict {
    
}

- (void)buySubscription:(DBSubscriptionVariant *)variant
               callback:(void(^)(BOOL success, NSString *errorMessage))callback{
    
    NSDictionary *params= @{@"return_url": @"alpha-payment://return-page",
                            @"type_id": @1,
                            @"card_pan": [DBCardsManager sharedInstance].defaultCard.pan,
                            @"binding_id": [DBCardsManager sharedInstance].defaultCard.token,
                            @"client_id": [IHSecureStore sharedInstance].clientId};
    
    [[DBAPIClient sharedClient] POST:@"subscription/buy"
                          parameters:@{@"payment" : [params encodedString],
                                       @"tariff_id" : variant.variantId}
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 if(callback)
                                     callback(YES, nil);
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"%@", error);
                                 
                                 NSString *errorMessage;
                                 if (operation.response.statusCode == 400) {
                                     errorMessage = operation.responseObject[@"description"];
                                 }
                                 
                                 if(callback)
                                     callback(NO, errorMessage);
                             }];
}

- (void)subscriptionInfo:(void(^)(NSArray *info))success
                 failure:(void(^)(NSString *errorMessage))failure {
    [[DBAPIClient sharedClient] GET:@"subscription/info"
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                if ([responseObject getValueForKey:@"amount"] && [responseObject getValueForKey:@"days"]) {
                                    DBCurrentSubscription *currentSubscription = [DBCurrentSubscription new];
                                    currentSubscription.amount = [responseObject objectForKey:@"amount"];
                                    currentSubscription.creationDate = [NSDate date];
                                    currentSubscription.days = [responseObject objectForKey:@"days"];
                                    self.currentSubscription = currentSubscription;
                                    [self saveCurrentSubscription];
                                }
                                if ([responseObject getValueForKey:@"category"]) {
                                    self.subscriptionCategory = [DBMenuCategory categoryFromResponseDictionary:[responseObject objectForKey:@"category"]];
                                    [self saveSubscriptionCategory];
                                }
                                if(success)
                                    success(@[]);
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                if(failure)
                                    failure(nil);
                            }];
}

- (void)checkSubscriptionVariants:(void(^)(NSArray *variants))success
                          failure:(void(^)(NSString *errorMessage))failure{
    [[DBAPIClient sharedClient] GET:@"subscription/tariffs"
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                NSMutableArray *variants = [NSMutableArray new];
                                for (NSDictionary *variantDict in responseObject[@"tariffs"]){
                                    [variants addObject:[[DBSubscriptionVariant alloc] initWithResponseDict:variantDict]];
                                }
                                
                                self.subscriptionVariants = variants;
                                
                                [GANHelper analyzeEvent:@"abonement_load_success" category:@"Abonement_screen"];
                                if(success)
                                    success(variants);
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                [GANHelper analyzeEvent:@"abonement_load_fail" label:[error localizedDescription] category:@"Abonement_screen"];
                                if(failure)
                                    failure(nil);
                            }];
}

- (NSDictionary *)cutSubscriptionCategory:(NSDictionary *)menu {
    NSMutableDictionary *mutableMenu = [NSMutableDictionary dictionaryWithDictionary:menu];
    NSMutableArray *categories = [NSMutableArray arrayWithArray:menu[@"menu"]];
    
    __block NSInteger index = -1;
    [categories enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[category[@"info"] objectForKey:@"category_id"] integerValue] == 1) {
            index = idx;
        }
    }];
    
    if (index != -1) {
        [categories removeObjectAtIndex:index];
        mutableMenu[@"menu"] = categories;
    }
    
    return mutableMenu;
}

- (NSArray<DBSubscriptionVariant *> *)subscriptionVariants {
    return _subscriptionVariants;
}

- (NSDictionary *)menuRequest {
    return @{@"request_subscription": self.enable ? @"true": @"false" };
}

- (DBMenuCategory *)subscriptionCategory {
    return _subscriptionCategory;
}

- (BOOL)isEnabled {
    return _enable;
}

- (BOOL)isAvailable {
    BOOL enabled = self.currentSubscription != nil;
    enabled = enabled && [[NSDate dateWithTimeIntervalSinceNow:[self.currentSubscription.days integerValue] * 24 * 60 * 60] compare:[NSDate date]] == NSOrderedDescending;
    enabled = enabled && [self.currentSubscription.amount integerValue] > 0;
    return enabled;
}

#pragma mark - Cups Managment

- (BOOL)cupIsAvailableToPurchase {
    return [self numberOfAvailableCups] > 0;
}

- (NSInteger)numberOfAvailableCups {
    NSInteger temp = [self.currentSubscription.amount integerValue] - self.currentCupsInOrder;
    return temp >= 0 ? temp : 0;
}

- (void)incrementNumberOfCupsInOrder:(NSString *)productId {
    [GANHelper analyzeEvent:@"abonement_product_select" label:productId category:MENU_SCREEN];
    [self incrementNumberOfCupsInOrder];
}

- (void)incrementNumberOfCupsInOrder {
    self.currentCupsInOrder += 1;
    [self.delegate currentSubscriptionStateChanged];
}

- (void)decrementNumberOfCupsInOrder {
    self.currentCupsInOrder -= 1;
    [self.delegate currentSubscriptionStateChanged];
}

+ (NSString *)db_managerStorageKey {
    return @"kDBDefaultsDBSubscriptionManager";
}

@end
