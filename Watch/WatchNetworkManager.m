//
//  NetworkManager.m
//  DoubleB
//
//  Created by Balaban Alexander on 11/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "ApplicationInteractionManager.h"
#import "WatchNetworkManager.h"

#import "OrderWatch.h"

@implementation WatchNetworkManager

+ (void)makeReorder:(NSDictionary *)order onController:(WKInterfaceController *)controller {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:order
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSDictionary *params = @{@"order": jsonString,
                             @"gzip": @"Accept-Encoding",
                             @"application/json": @"Accept"
                             };
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://mycompany.test1.doubleb-automation-production.appspot.com/api/order"]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self httpBodyForParamsDictionary:params]];
    request.timeoutInterval = 30;
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@", resp);
        if (![[resp objectForKey:@"error"] boolValue]) {
            OrderWatch *currentOrder = [[ApplicationInteractionManager sharedManager] currentOrder];
            currentOrder.orderId = [NSString stringWithFormat:@"%@", [resp objectForKey:@"order_id"]];
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            currentOrder.time = [formatter dateFromString:[resp objectForKey:@"delivery_time"]];

            WKAlertAction *act = [WKAlertAction actionWithTitle:@"OK" style:WKAlertActionStyleCancel handler:^(void) {
                [[ApplicationInteractionManager sharedManager] makeReorder:currentOrder.orderId];
                currentOrder.active = YES;
                [[ApplicationInteractionManager sharedManager] saveOrder:currentOrder];
                [[NSNotificationCenter defaultCenter] postNotificationName:kWatchNetworkManagerOrderUpdated object:nil];
            }];
            NSArray *buttons = @[act];
            [controller presentAlertControllerWithTitle:@"Status" message:[NSString stringWithFormat: @"New order #%@ is created!", currentOrder.orderId]
                                         preferredStyle:WKAlertControllerStyleAlert actions:buttons];
        } else {
            WKAlertAction *act = [WKAlertAction actionWithTitle:@"OK" style:WKAlertActionStyleCancel handler:^(void) {
            }];
            NSArray *buttons = @[act];
            [controller presentAlertControllerWithTitle:@"Error" message:@"Try again later/from iPhone!"
                                         preferredStyle:WKAlertControllerStyleAlert actions:buttons];
        }

    }];
    
    [task resume];}

+ (void)cancelOrder:(OrderWatch *)order onController:(WKInterfaceController *)controller {
    NSDictionary *params = @{@"order_id": order.orderId,
                             @"reason_id": @"3",
                             @"reason_text": @"Cancel from Apple Watch",
                             @"gzip": @"Accept-Encoding",
                             @"application/json": @"Accept"
                             };
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://mycompany.test1.doubleb-automation-production.appspot.com/api/return"]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self httpBodyForParamsDictionary:params]];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        if (![[resp objectForKey:@"error"] boolValue]) {
            WKAlertAction *act = [WKAlertAction actionWithTitle:@"OK" style:WKAlertActionStyleCancel handler:^(void) {
                [[ApplicationInteractionManager sharedManager] cancelOrder];
            }];
            NSArray *buttons = @[act];
            [controller presentAlertControllerWithTitle:@"Status" message:[NSString stringWithFormat: @"Order #%@ is cancelled!", order.orderId]
                                         preferredStyle:WKAlertControllerStyleAlert actions:buttons];
        } else {
            WKAlertAction *act = [WKAlertAction actionWithTitle:@"OK" style:WKAlertActionStyleCancel handler:^(void) {
            }];
            NSArray *buttons = @[act];
            [controller presentAlertControllerWithTitle:@"Error" message:@"Try again later!"
                                         preferredStyle:WKAlertControllerStyleAlert actions:buttons];
        }
    }];
    
    [task resume];
}

+ (NSString *)percentEscapeString:(NSString *)string {
    static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@";
    static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
    
    return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
}

+ (NSData *)httpBodyForParamsDictionary:(NSDictionary *)paramDictionary {
    NSMutableArray *parameterArray = [NSMutableArray array];
    
    [paramDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        NSString *param = [NSString stringWithFormat:@"%@=%@", key, [self percentEscapeString:obj]];
        [parameterArray addObject:param];
    }];
    
    NSString *string = [parameterArray componentsJoinedByString:@"&"];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

@end
