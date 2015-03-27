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

//+ (NSArray *)getMenuForVenue:(Venue *)venue remoteMenu:(void (^)(NSArray *categories))remoteMenuCallback{
//    
//}

- (void)updateMenuForVenue:(Venue *)venue remoteMenu:(void (^)(BOOL success, NSArray *categories))remoteMenuCallback{
    [[DBAPIClient sharedClient] GET:@""
                         parameters:@{}
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                NSLog(@"%@", responseObject);
                                
                                [self synchronizeWithResponseMenu:responseObject[@"menu"]];
                                
                                if(remoteMenuCallback)
                                    remoteMenuCallback(YES, self.categories);
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                if(remoteMenuCallback)
                                    remoteMenuCallback(NO, nil);
                            }];
}

- (void)synchronizeWithResponseMenu:(NSArray *)responseMenu{
    NSMutableArray *newCategories = [[NSMutableArray alloc] init];
    
    for(NSDictionary *categoryDictionary in responseMenu){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryId == %@", categoryDictionary[@"id"]];
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

- (NSInteger)getCount{
    return [self.categories count];
}

@end
