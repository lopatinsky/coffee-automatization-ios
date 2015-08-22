//
//  IHMenuCategory.m
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.08.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBMenuCategory.h"
#import "DBMenuPosition.h"
#import "Venue.h"

@interface DBMenuCategory ()<NSCoding, NSCopying>
@property(strong, nonatomic) NSString *categoryId;
@property(strong, nonatomic) NSString *name;
@property(nonatomic) NSInteger order;
@property(strong, nonatomic) NSString *imageUrl;
@property(strong, nonatomic) NSDictionary *categoryDictionary;
@end

@implementation DBMenuCategory

+ (instancetype)categoryFromResponseDictionary:(NSDictionary *)categoryDictionary{
    DBMenuCategory *category = [DBMenuCategory new];
    
    [category copyFromResponseDictionary:categoryDictionary[@"info"]];
    
    category.positions = [[NSMutableArray alloc] init];
    for(NSDictionary *position in categoryDictionary[@"items"])
        [category.positions addObject:[[DBMenuPosition alloc] initWithResponseDictionary:position]];
    [category sortPositions];
 
    category.categories = [[NSMutableArray alloc] init];
    for(NSDictionary *nestedCategory in categoryDictionary[@"categories"])
        [category.categories addObject:[DBMenuCategory categoryFromResponseDictionary:nestedCategory]];
    [category sortCategories];
    
    return category;
}

- (void)synchronizeWithResponseDictionary:(NSDictionary *)categoryDictionary{
    [self copyFromResponseDictionary:categoryDictionary[@"info"]];
    
    NSMutableArray *positions = [[NSMutableArray alloc] init];
    for(NSDictionary *remotePosition in categoryDictionary[@"items"]){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"positionId == %@", remotePosition[@"id"]];
        DBMenuPosition *samePosition = [[_positions filteredArrayUsingPredicate:predicate] firstObject];
        if(samePosition){
            [samePosition synchronizeWithResponseDictionary:remotePosition];
            [positions addObject:samePosition];
        } else {
            [positions addObject:[[DBMenuPosition alloc] initWithResponseDictionary:remotePosition]];
        }
    }
    _positions = positions;
    [self sortPositions];
 
    NSMutableArray *nestedCategories = [[NSMutableArray alloc] init];
    for(NSDictionary *remoteCategory in categoryDictionary[@"categories"]){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryId == %@", remoteCategory[@"info"][@"category_id"]];
        DBMenuCategory *sameCategory = [[_categories filteredArrayUsingPredicate:predicate] firstObject];
        if(sameCategory){
            [sameCategory synchronizeWithResponseDictionary:remoteCategory];
            [nestedCategories addObject:sameCategory];
        } else {
            [nestedCategories addObject:[DBMenuCategory categoryFromResponseDictionary:remoteCategory]];
        }
    }
    _categories = nestedCategories;
    [self sortCategories];
}

- (void)copyFromResponseDictionary:(NSDictionary *)categoryDictionary{
    _categoryId = [categoryDictionary getValueForKey:@"category_id"] ?: @"";
    _name = [categoryDictionary getValueForKey:@"title"] ?: @"";
    _order = [[categoryDictionary getValueForKey:@"order"] integerValue];
    _imageUrl = [categoryDictionary getValueForKey:@"pic"] ?: @"";
    _venuesRestrictions = [categoryDictionary[@"restrictions"] getValueForKey:@"venues"] ?: @[];
    _categoryDictionary = categoryDictionary;
}

- (void)sortCategories{
    [self.categories sortUsingComparator:^NSComparisonResult(DBMenuCategory *obj1, DBMenuCategory *obj2) {
        return [@(obj1.order) compare:@(obj2.order)];
    }];
}

- (void)sortPositions{
    [self.positions sortUsingComparator:^NSComparisonResult(DBMenuPosition *obj1, DBMenuPosition *obj2) {
        return [@(obj1.order) compare:@(obj2.order)];
    }];
}

- (DBMenuCategoryType)type{
    return [self.categories count] > 0 ? DBMenuCategoryTypeParent : DBMenuCategoryTypeStandart;
}

- (BOOL)hasImage{
    BOOL result = self.imageUrl != nil;
    if(result){
        result = result && self.imageUrl.length > 0;
    }
    return result;
}

- (BOOL)categoryWithImages{
    BOOL result = NO;
    for(DBMenuPosition *position in self.positions){
        result = result || position.hasImage;
    }
    
    return result;
}

- (void)sortArray:(NSMutableArray *)array byField:(NSString *)field{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:field ascending:YES];
    [array sortUsingDescriptors:@[sortDescriptor]];
}


- (BOOL)availableInVenue:(Venue *)venue{
    return venue && ![_venuesRestrictions containsObject:venue.venueId];
}

- (NSMutableArray *)filterPositionsForVenue:(Venue *)venue{
    NSMutableArray *venuePositions = [NSMutableArray new];
    
    for(DBMenuPosition *position in _positions){
        if([position availableInVenue:venue])
            [venuePositions addObject:position];
    }
    
    return venuePositions;
}

- (NSMutableArray *)filterCategoriesForVenue:(Venue *)venue{
    NSMutableArray *venueCategories = [NSMutableArray new];
    
    for(DBMenuCategory *category in _categories){
        if([category availableInVenue:venue])
            [venueCategories addObject:category];
    }
    
    return venueCategories;
}

- (DBMenuPosition *)findPositionWithId:(NSString *)positionId{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"positionId == %@", positionId];
    return [[_positions filteredArrayUsingPredicate:predicate] firstObject];
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[DBMenuCategory alloc] init];
    if(self != nil){
        _categoryId = [aDecoder decodeObjectForKey:@"categoryId"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _order = [[aDecoder decodeObjectForKey:@"order"] integerValue];
        _imageUrl = [aDecoder decodeObjectForKey:@"imageUrl"];
        _categories = [aDecoder decodeObjectForKey:@"categories"];
        _positions = [aDecoder decodeObjectForKey:@"positions"];
        _categoryDictionary = [aDecoder decodeObjectForKey:@"categoryDictionary"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_categoryId forKey:@"categoryId"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:@(_order) forKey:@"order"];
    [aCoder encodeObject:_imageUrl forKey:@"imageUrl"];
    [aCoder encodeObject:_categories forKey:@"categories"];
    [aCoder encodeObject:_positions forKey:@"positions"];
    [aCoder encodeObject:self.categoryDictionary forKey:@"categoryDictionary"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone{
    DBMenuCategory *copyCategory = [[[self class] allocWithZone:zone] init];
    copyCategory.categoryId = [self.categoryId copy];
    copyCategory.name = [self.name copy];
    copyCategory.order = self.order;
    copyCategory.imageUrl = [self.imageUrl copy];
    
    copyCategory.categories = [NSMutableArray new];
    for(DBMenuCategory *category in self.categories)
        [copyCategory.categories addObject:[category copyWithZone:zone]];
    
    copyCategory.positions = [NSMutableArray new];
    for(DBMenuPosition *position in self.positions)
        [copyCategory.positions addObject:[position copyWithZone:zone]];
    
    copyCategory.categoryDictionary = [self.categoryDictionary copy];
    
    return copyCategory;
}

@end
