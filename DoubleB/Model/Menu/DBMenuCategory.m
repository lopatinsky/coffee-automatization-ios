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
@property(strong, nonatomic) NSString *imageUrl;
@property(strong, nonatomic) NSDictionary *categoryDictionary;
@end

@implementation DBMenuCategory

+ (instancetype)categoryFromResponseDictionary:(NSDictionary *)categoryDictionary{
    DBMenuCategory *category = [DBMenuCategory new];
    
    [category copyFromResponseDictionary:categoryDictionary[@"info"]];
    
    NSArray *positions = categoryDictionary[@"items"];
    category.positions = [[NSMutableArray alloc] init];
    for(NSDictionary *position in positions)
        [category.positions addObject:[DBMenuPosition positionFromResponseDictionary:position]];
    
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
            [positions addObject:[DBMenuPosition positionFromResponseDictionary:remotePosition]];
        }
    }
    
    _positions = positions;
}

- (void)copyFromResponseDictionary:(NSDictionary *)categoryDictionary{
    _categoryId = [categoryDictionary getValueForKey:@"category_id"] ?: @"";
    _name = [categoryDictionary getValueForKey:@"title"] ?: @"";
    _imageUrl = [categoryDictionary getValueForKey:@"pic"] ?: @"";
    _venuesRestrictions = [categoryDictionary[@"restrictions"] getValueForKey:@"venues"] ?: @[];
    _categoryDictionary = categoryDictionary;
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

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone{
    DBMenuCategory *copyCategory = [[[self class] allocWithZone:zone] init];
    copyCategory.categoryId = [self.categoryId copy];
    copyCategory.name = [self.name copy];
    copyCategory.imageUrl = [self.imageUrl copy];
    
    copyCategory.positions = [NSMutableArray new];
    for(DBMenuPosition *position in self.positions)
        [copyCategory.positions addObject:[position copyWithZone:zone]];
    
    copyCategory.categoryDictionary = [self.categoryDictionary copy];
    
    return copyCategory;
}

@end
