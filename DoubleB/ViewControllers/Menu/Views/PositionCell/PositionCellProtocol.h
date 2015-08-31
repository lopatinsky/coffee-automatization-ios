//
//  PositionCellProtocol.h
//  
//
//  Created by Balaban Alexander on 18/07/15.
//
//

#import <Foundation/Foundation.h>

@class DBMenuPosition;

@protocol PositionCellProtocol <NSObject>

- (DBMenuPosition *)position;

@end


@protocol DBPositionCellDelegate <NSObject>

-(void)positionCellDidOrder:(id<PositionCellProtocol>)cell;

@optional
-(void)positionCell:(id<PositionCellProtocol>)cell shouldSelectModifiersForPosition:(DBMenuPosition *)position;

@end