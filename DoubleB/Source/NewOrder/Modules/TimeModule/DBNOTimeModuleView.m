//
//  DBNOTimeModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOTimeModuleView.h"
#import "DBTimePickerView.h"

#import "OrderCoordinator.h"

@interface DBNOTimeModuleView ()<DBTimePickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *timeImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) DBTimePickerView *pickerView;

@property (strong, nonatomic) OrderCoordinator *orderCoordinator;

@end

@implementation DBNOTimeModuleView

+ (NSString *)xibName {
    return @"DBNOTimeModuleView";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.timeImageView templateImageWithName:@"time_icon_active"];
    
    self.pickerView = [[DBTimePickerView alloc] initWithDelegate:self];
    _orderCoordinator = [OrderCoordinator sharedInstance];
    [_orderCoordinator addObserver:self withKeyPaths:@[CoordinatorNotificationNewSelectedTime, CoordinatorNotificationNewDeliveryType] selector:@selector(reload)];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_orderCoordinator removeObserver:self];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    self.titleLabel.text = [self selectedTimeString];
}

- (void)reloadTimePicker {
    switch (_orderCoordinator.deliverySettings.deliveryType.timeMode) {
        case TimeModeTime: {
            self.pickerView.type = DBTimePickerTypeTime;
            self.pickerView.selectedDate = _orderCoordinator.deliverySettings.selectedTime;
        }
            break;
        case TimeModeDateTime: {
            self.pickerView.type = DBTimePickerTypeDateTime;
            self.pickerView.selectedDate = _orderCoordinator.deliverySettings.selectedTime;
        }
            break;
        case TimeModeSlots: {
            self.pickerView.type = DBTimePickerTypeItems;
            self.pickerView.items = _orderCoordinator.deliverySettings.deliveryType.timeSlotsNames;
            self.pickerView.selectedItem = [_orderCoordinator.deliverySettings.deliveryType.timeSlots indexOfObject:_orderCoordinator.deliverySettings.selectedTimeSlot];
        }
            break;
        case TimeModeDateSlots: {
            self.pickerView.type = DBTimePickerTypeDateAndItems;
            self.pickerView.items = _orderCoordinator.deliverySettings.deliveryType.timeSlotsNames;
            self.pickerView.minDate = _orderCoordinator.deliverySettings.deliveryType.minDate;
            self.pickerView.maxDate = _orderCoordinator.deliverySettings.deliveryType.maxDate;
            break;
        }
        case TimeModeDual: {
            self.pickerView.type = DBTimePickerTypeDual;
            self.pickerView.items = _orderCoordinator.deliverySettings.deliveryType.timeSlotsNames;
            self.pickerView.minDate = _orderCoordinator.deliverySettings.deliveryType.minDate;
            self.pickerView.maxDate = _orderCoordinator.deliverySettings.deliveryType.maxDate;
            self.pickerView.selectedItem = [_orderCoordinator.deliverySettings.deliveryType.timeSlots indexOfObject:_orderCoordinator.deliverySettings.selectedTimeSlot];
            break;
        }
        default:
            break;
    }
    
    [self.pickerView configure];
}

- (void)touchAtLocation:(CGPoint)location {
    [GANHelper analyzeEvent:@"time_click" category:self.analyticsCategory];
    
    [self reloadTimePicker];
    
    if ([self.delegate respondsToSelector:@selector(db_moduleViewModalComponentContainer:)]){
        [self.pickerView showOnView:[self.delegate db_moduleViewModalComponentContainer:self]];
    }
}

#pragma mark - helper methods

- (NSString *)selectedTimeString {
    NSString *timeString;
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    switch (_orderCoordinator.deliverySettings.deliveryType.timeMode) {
        case TimeModeTime:{
            formatter.dateFormat = @"HH:mm";
            timeString = [formatter stringFromDate:_orderCoordinator.deliverySettings.selectedTime];
            break;
        }
        case TimeModeDateTime:{
            formatter.dateFormat = @"dd/MM/yy HH:mm";
            timeString = [formatter stringFromDate:_orderCoordinator.deliverySettings.selectedTime];
            break;
        }
        case TimeModeSlots:{
            timeString = _orderCoordinator.deliverySettings.selectedTimeSlot.slotTitle;
            break;
        }
        case TimeModeDateSlots:{
            formatter.dateFormat = @"ccc d";
            timeString = [NSString stringWithFormat:@"%@, %@", [formatter stringFromDate:_orderCoordinator.deliverySettings.selectedTime], _orderCoordinator.deliverySettings.selectedTimeSlot.slotTitle];
            break;
        }
        case TimeModeDual: {
            if (_orderCoordinator.deliverySettings.deliveryType.dualCurrentMode == TimeModeSlots) {
                timeString = _orderCoordinator.deliverySettings.selectedTimeSlot.slotTitle;
            } else {
                formatter.dateFormat = @"HH:mm";
                timeString = [formatter stringFromDate:_orderCoordinator.deliverySettings.selectedTime];
            }
            break;
        }
        default:
            break;
    }
    
    return timeString;
}

- (NSString *)stringFromTime:(NSDate *)date{
    NSDateFormatter *formatter = [NSDateFormatter new];
    if(_orderCoordinator.deliverySettings.deliveryType.timeMode == TimeModeTime){
        formatter.dateFormat = @"HH:mm";
    } else {
        formatter.dateFormat = @"dd/MM/yy HH:mm";
    }
    
    return [formatter stringFromDate:date];
}

#pragma mark - DBTimePickerViewDelegate

- (void)db_updateDualMode:(BOOL)isSlots {
    if (isSlots) {
        _orderCoordinator.deliverySettings.deliveryType.dualCurrentMode = TimeModeSlots;
    } else {
        _orderCoordinator.deliverySettings.deliveryType.dualCurrentMode = TimeModeTime;
    }
}

- (void)db_timePickerView:(DBTimePickerView *)view didSelectRowAtIndex:(NSInteger)index{
    DBTimeSlot *timeSlot = _orderCoordinator.deliverySettings.deliveryType.timeSlots[index];
    _orderCoordinator.deliverySettings.selectedTimeSlot = timeSlot;
    [self reload];
    
    [GANHelper analyzeEvent:@"delivery_slot_selected" label:timeSlot.slotTitle category:ORDER_SCREEN];
}

- (void)db_timePickerView:(DBTimePickerView *)view didSelectDate:(NSDate *)date{
    NSInteger comparisonResult = [_orderCoordinator.deliverySettings setNewSelectedTime:date];
    
    if (_orderCoordinator.deliverySettings.deliveryType.timeMode == TimeModeTime ||
        _orderCoordinator.deliverySettings.deliveryType.timeMode == TimeModeDateTime ||
        _orderCoordinator.deliverySettings.deliveryType.timeMode == TimeModeDual) {
        NSString *message;
        if(comparisonResult == NSOrderedAscending){
            message = [NSString stringWithFormat:@"Минимальное время для выбора - %@", [self stringFromTime:_orderCoordinator.deliverySettings.deliveryType.minDate]];
            [self.ownerViewController showAlert:message];
        }
        
        if(comparisonResult == NSOrderedDescending){
            message = [NSString stringWithFormat:@"Максимальное время для выбора - %@", [self stringFromTime:_orderCoordinator.deliverySettings.deliveryType.maxDate]];
            [self.ownerViewController showAlert:message];
        }
    }
    
    int interval = [date timeIntervalSince1970];
    [GANHelper analyzeEvent:@"delivery_time_selected" number:@(interval) category:self.analyticsCategory];
}

- (BOOL)db_shouldHideTimePickerView{
    [self reload];
    
    [GANHelper analyzeEvent:@"time_spinner_closed" category:self.analyticsCategory];
    
    return YES;
}

@end
