//
//  OrderItem.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 06.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "OrderItem.h"

#import "DBMenu.h"
#import "DBMenuPosition.h"
#import "DBMenuPositionModifier.h"
#import "DBMenuPositionModifierItem.h"

#import "NSDate+Difference.h"

#import "SDWebImageManager.h"

@implementation OrderItem

- (instancetype)initWithPosition:(DBMenuPosition *)position{
    self = [super init];
    
    self.position = position;
    
    return self;
}

+ (instancetype)orderItemFromResponceDict:(NSDictionary *)dict{
    OrderItem *item = [[OrderItem alloc] init];
    
    DBMenuPosition *position = [[DBMenu sharedInstance] findPositionWithId:dict[@"id"]];
    if(position){
        position = [position copy];
    } else {
        position = [[DBMenuPosition alloc] initWithHistoryDict:dict];
    }
    
    for(NSDictionary *modifier in dict[@"group_modifiers"]){
        [position selectItem:modifier[@"choice"] forGroupModifier:modifier[@"id"]];
    }
    
    for(NSDictionary *modifier in dict[@"single_modifiers"]){
        [position addSingleModifier:modifier[@"id"] count:[modifier[@"quantity"] integerValue]];
    }
    
    item.position = position;
    
    item.count = [dict[@"quantity"] integerValue];
    
    return item;
}

- (NSDictionary *)requestJson {
    NSMutableDictionary *itemDict = [NSMutableDictionary new];
    
    itemDict[@"item_id"] = _position.positionId;
    itemDict[@"quantity"] = @(_count);
    
    NSMutableArray *singleModifiers = [NSMutableArray new];
    for(DBMenuPositionModifier *modifier in _position.singleModifiers){
        [singleModifiers addObject:@{@"single_modifier_id": modifier.modifierId,
                                     @"quantity": @(modifier.selectedCount)}];
    }
    
    NSMutableArray *groupModifiers = [NSMutableArray new];
    for(DBMenuPositionModifier *modifier in _position.groupModifiers){
        if(!modifier.selectedItem)
            continue;
        
        [groupModifiers addObject:@{@"group_modifier_id": modifier.modifierId,
                                    @"choice": modifier.selectedItem.itemId,
                                    @"quantity": @1}];
    }
    
    itemDict[@"single_modifiers"] = singleModifiers;
    itemDict[@"group_modifiers"] = groupModifiers;
    
    return itemDict;
}

- (double)totalPrice{
    return self.position.actualPrice * self.count;
}

- (BOOL)valid {
    DBMenuPosition *position = [[DBMenu sharedInstance] findPositionWithId:self.position.positionId];
    
    return position != nil;
}


#pragma mark – UserActivityIndexing protocol
- (NSString *)activityTitle {
    return self.position.name;
}

- (NSDictionary *)activityUserInfo {
    return @{@"position_id": [[self position] positionId]};
}

- (CSSearchableItemAttributeSet *)activityAttributes {
    CSSearchableItemAttributeSet *set = [[CSSearchableItemAttributeSet alloc] init];
    double totalPrice = [self totalPrice];
    NSString *desc = [[self position] positionDescription];
    NSString *finalDescription = [NSString stringWithFormat:@"%@\n%0.2f₽", desc, totalPrice];
    if ([[self position] imageUrl]) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[NSURL URLWithString:[[self position] imageUrl]]
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 // progression tracking code
                             }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (image) {
                                    set.thumbnailData = UIImagePNGRepresentation(image);
                                }
                            }];
    }
    set.contentDescription = finalDescription;
    return set;
}

- (void)activityDidAppear {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:@"activity_position_%@", [[self position] positionId]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)activityIsAvailable {
    NSDate *lastPublicationDate = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"activity_position_%@", [[self position] positionId]]] ?: [NSDate dateWithTimeIntervalSince1970:0];
    return [[NSDate date] numberOfDaysUntil:lastPublicationDate] > 7;
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[OrderItem alloc] init];
    if(self != nil){
        self.position = [aDecoder decodeObjectForKey:@"position"];
        self.count = [[aDecoder decodeObjectForKey:@"count"] integerValue];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.position forKey:@"position"];
    [aCoder encodeObject:@(self.count) forKey:@"count"];
}

- (id)copyWithZone:(NSZone *)zone{
    OrderItem *orderItem = [[[self class] allocWithZone:zone] init];
    
    orderItem.position = [self.position copy];
    orderItem.count = self.count;
    
    return orderItem;
}


#pragma mark - DBWatchAppModelProtocol

- (NSDictionary *)plistRepresentation {
    NSMutableDictionary *plist = [NSMutableDictionary new];
    
    plist[@"position"] = [self.position plistRepresentation];
    plist[@"count"] = @(self.count);
    
    return plist;
}

+ (id)createWithPlistRepresentation:(NSDictionary *)plistDict {
    OrderItem *item = [OrderItem new];
    
    item.position = [DBMenuPosition createWithPlistRepresentation:plistDict[@"position"]];
    item.count = [plistDict[@"count"] integerValue];
    
    return item;
}

@end
