//
//  IHMenuCategory.m
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.08.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBMenuCategory.h"
#import "DBMenuPosition.h"

@interface DBMenuCategory ()<NSCoding>
@property(strong, nonatomic) NSString *categoryId;
@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *imageUrl;
@property(strong, nonatomic) NSMutableArray *positions;
@property(strong, nonatomic) NSDictionary *categoryDictionary;
@end

@implementation DBMenuCategory

+ (instancetype)categoryFromResponseDictionary:(NSDictionary *)categoryDictionary{
    DBMenuCategory *category = [DBMenuCategory new];
    
    [category copyFromResponseDictionary:categoryDictionary];
    
    NSArray *positions = categoryDictionary[@"items"];
    category.positions = [[NSMutableArray alloc] init];
    for(NSDictionary *position in positions)
        [category.positions addObject:[DBMenuPosition positionFromResponseDictionary:position]];
    
    return category;
}

- (void)synchronizeWithResponseDictionary:(NSDictionary *)categoryDictionary{
    [self copyFromResponseDictionary:categoryDictionary];
    
    NSMutableArray *positions = [[NSMutableArray alloc] init];
    
    for(NSDictionary *remotePosition in categoryDictionary[@"items"]){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"positionId == %@", remotePosition[@"id"]];
        DBMenuPosition *samePosition = [[_positions filteredArrayUsingPredicate:predicate] firstObject];
        if(samePosition){
            [samePosition synchronizeWithResponseDictionary:remotePosition];
            [positions addObject:samePosition];
        } else {
            [positions addObject:[DBMenuPosition positionFromResponseDictionary:remotePosition]];
        }
    }
    
    _positions = positions;
}

- (void)copyFromResponseDictionary:(NSDictionary *)categoryDictionary{
    _categoryId = [categoryDictionary getValueForKey:@"id"] ?: @"";
    _name = [categoryDictionary getValueForKey:@"name"] ?: @"";
    _imageUrl = [categoryDictionary getValueForKey:@"image"] ?: @"";
    _venuesRestrictions = [categoryDictionary[@"restrictions"] getValueForKey:@"venues"] ?: @[];
    _categoryDictionary = categoryDictionary;
}

- (void)sortArray:(NSMutableArray *)array byField:(NSString *)field{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:field ascending:YES];
    [array sortUsingDescriptors:@[sortDescriptor]];
}


#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[DBMenuCategory alloc] init];
    if(self != nil){
        _categoryId = [aDecoder decodeObjectForKey:@"categoryId"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _imageUrl = [aDecoder decodeObjectForKey:@"imageUrl"];
        _positions = [aDecoder decodeObjectForKey:@"positions"];
        _categoryDictionary = [aDecoder decodeObjectForKey:@"categoryDictionary"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_categoryId forKey:@"categoryId"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_imageUrl forKey:@"imageUrl"];
    [aCoder encodeObject:_positions forKey:@"positions"];
    [aCoder encodeObject:self.categoryDictionary forKey:@"categoryDictionary"];
}

@end
