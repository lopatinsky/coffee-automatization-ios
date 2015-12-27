//
//  CompanyNews.h
//  
//
//  Created by Balaban Alexander on 25/08/15.
//
//

#import <Foundation/Foundation.h>

@interface CompanyNews : NSObject

@property (nonatomic, strong) NSNumber *newsId;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *date;

@end
