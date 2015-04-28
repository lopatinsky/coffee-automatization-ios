//
//  IHMenu.m
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.08.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBMenu.h"
#import "DBMenuCategory.h"

#import "DBAPIClient.h"

@interface DBMenu ()
@property(strong, nonatomic) NSArray *categories;
@end

@implementation DBMenu

+ (instancetype)sharedInstance{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [self new];
    });
    
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    
    [self loadMenuFromDeviceMemory];
    
    return self;
}

- (NSArray *)getMenu{
    if(!self.categories){
        [self loadMenuFromDeviceMemory];
    }
    
    return self.categories;
}

- (NSArray *)getMenuForVenue:(Venue *)venue{
    if(!self.categories){
        [self loadMenuFromDeviceMemory];
    }
    
    return [self filterMenuForVenue:venue];
}

- (NSArray *)getMenuForVenue:(Venue *)venue remoteMenu:(void (^)(BOOL success, NSArray *categories))remoteMenuCallback{
    [self updateMenuForVenue:venue remoteMenu:remoteMenuCallback];
    return [self getMenuForVenue:venue];
}

- (void)updateMenuForVenue:(Venue *)venue remoteMenu:(void (^)(BOOL success, NSArray *categories))remoteMenuCallback{
    [self fetchMenu:^(BOOL success, NSArray *categories) {
        NSArray *filteredCategories;
        
        if(success){
            filteredCategories = [self filterMenuForVenue:venue];
        }
        
        if(remoteMenuCallback){
            remoteMenuCallback(success, filteredCategories);
        }
    }];
}

- (void)fetchMenu:(void (^)(BOOL success, NSArray *categories))remoteMenuCallback{
    [[DBAPIClient sharedClient] GET:@"menu.php"
                         parameters:@{}
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                NSLog(@"%@", responseObject);
                                
                                [GANHelper analyzeEvent:@"menu_update_success" category:MENU_SCREEN];
                                
                                [self synchronizeWithResponseMenu:responseObject[@"menu"]];
                                
                                if(remoteMenuCallback)
                                    remoteMenuCallback(YES, self.categories);
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                [GANHelper analyzeEvent:@"manu_update_failed" label:error.localizedDescription category:MENU_SCREEN];
                                
                                if(remoteMenuCallback)
                                    remoteMenuCallback(NO, nil);
                            }];
}

- (NSArray *)filterMenuForVenue:(Venue *)venue{
    NSMutableArray *categories = [NSMutableArray new];
    
    for(DBMenuCategory *category in self.categories){
        if([category availableInVenue:venue]){
            DBMenuCategory *newCategory = [category copy];
            newCategory.positions = [newCategory filterPositionsForVenue:venue];
            if([newCategory.positions count] > 0){
                [categories addObject:newCategory];
            }
        }
    }
    
    return categories;
}

- (void)synchronizeWithResponseMenu:(NSArray *)responseMenu{
    NSMutableArray *newCategories = [[NSMutableArray alloc] init];
    
    for(NSDictionary *categoryDictionary in responseMenu){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryId == %@", categoryDictionary[@"info"][@"category_id"]];
        DBMenuCategory *sameCategory = [[self.categories filteredArrayUsingPredicate:predicate] firstObject];
        if(sameCategory){
            [sameCategory synchronizeWithResponseDictionary:categoryDictionary];
            [newCategories addObject:sameCategory];
        } else {
            [newCategories addObject:[DBMenuCategory categoryFromResponseDictionary:categoryDictionary]];
        }
    }
    
    self.categories = newCategories;
    
    [self saveMenuToDeviceMemory];
}

- (DBMenuPosition *)findPositionWithId:(NSString *)positionId{
    DBMenuPosition *resultPosition;
    
    for(DBMenuCategory *category in self.categories){
        DBMenuPosition *position = [category findPositionWithId:positionId];
        if(position){
            resultPosition = position;
            break;
        }
    }
    
    return resultPosition;
}


- (void)saveMenuToDeviceMemory{
    if(self.categories){
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/menu.txt"];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.categories];
        NSError *error;
        [data writeToFile:path options:NSDataWritingAtomic error:&error];
        if(error != nil){
            NSLog(@"%@", error);
        }
    }
}

- (void)loadMenuFromDeviceMemory{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/menu.txt"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    self.categories = [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

@end
