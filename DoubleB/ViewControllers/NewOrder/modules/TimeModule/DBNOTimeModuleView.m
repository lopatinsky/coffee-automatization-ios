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

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBNOTimeModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.timeImageView templateImageWithName:@"clock"];
    
    self.pickerView = [[DBTimePickerView alloc] initWithDelegate:self];
    _orderCoordinator = [OrderCoordinator sharedInstance];
    [_orderCoordinator addObserver:self withKeyPath:CoordinatorNotificationNewSelectedTime selector:@selector(reload)];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    NSString *timeString = [self selectedTimeString];
    if(_orderCoordinator.deliverySettings.deliveryType.typeId == DeliveryTypeIdShipping){
        timeString = [NSString stringWithFormat:@"%@ | %@", timeString, NSLocalizedString(@"Доставка", nil)];
    }
    if(_orderCoordinator.deliverySettings.deliveryType.typeId == DeliveryTypeIdTakeaway){
        timeString = [NSString stringWithFormat:@"%@ | %@", timeString, NSLocalizedString(@"Возьму с собой", nil)];
    }
    if(_orderCoordinator.deliverySettings.deliveryType.typeId == DeliveryTypeIdInRestaurant){
        timeString = [NSString stringWithFormat:@"%@ | %@", timeString, NSLocalizedString(@"На месте", nil)];
    }
    
    self.titleLabel.text = timeString;
}

- (void)reloadTimePicker {
    if (_orderCoordinator.deliverySettings.deliveryType.typeId == DeliveryTypeIdShipping){
        self.pickerView.segments = @[];
    } else {
        NSMutableArray *titles = [NSMutableArray new];
        if([[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdInRestaurant]){
            [titles addObject:NSLocalizedString(@"С собой", nil)];
        }
        if([[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdTakeaway]){
            [titles addObject:NSLocalizedString(@"На месте", nil)];
        }
        self.pickerView.segments = titles;
        self.pickerView.selectedSegmentIndex = _orderCoordinator.deliverySettings.deliveryType.typeId == DeliveryTypeIdTakeaway ? 0 : 1;
    }
    
    switch (_orderCoordinator.deliverySettings.deliveryType.timeMode) {
        case TimeModeTime:{
            self.pickerView.type = DBTimePickerTypeTime;
            self.pickerView.selectedDate = _orderCoordinator.deliverySettings.selectedTime;
        }
            break;
        case TimeModeDateTime:{
            self.pickerView.type = DBTimePickerTypeDateTime;
            self.pickerView.selectedDate = _orderCoordinator.deliverySettings.selectedTime;
        }
            break;
        case TimeModeSlots:{
            self.pickerView.type = DBTimePickerTypeItems;
            self.pickerView.items = _orderCoordinator.deliverySettings.deliveryType.timeSlotsNames;
            self.pickerView.selectedItem = [_orderCoordinator.deliverySettings.deliveryType.timeSlots indexOfObject:_orderCoordinator.deliverySettings.selectedTimeSlot];
        }
            break;
        case TimeModeDateSlots:{
            self.pickerView.type = DBTimePickerTypeDateAndItems;
            self.pickerView.items = _orderCoordinator.deliverySettings.deliveryType.timeSlotsNames;
            self.pickerView.minDate = _orderCoordinator.deliverySettings.deliveryType.minDate;
            self.pickerView.maxDate = _orderCoordinator.deliverySettings.deliveryType.maxDate;
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

- (void)db_timePickerView:(DBTimePickerView *)view didSelectSegmentAtIndex:(NSInteger)index{
    DeliveryTypeId deliveryTypeId;
    if (index == 0){
        deliveryTypeId = DeliveryTypeIdTakeaway;
    } else {
        deliveryTypeId = DeliveryTypeIdInRestaurant;
    }
    
    [GANHelper analyzeEvent:@"delivery_type_selected" number:@(deliveryTypeId) category:ORDER_SCREEN];
    
    [_orderCoordinator.deliverySettings selectDeliveryType:[[DBCompanyInfo sharedInstance] deliveryTypeById:deliveryTypeId]];
    
    [self reloadTimePicker];
}

- (void)db_timePickerView:(DBTimePickerView *)view didSelectRowAtIndex:(NSInteger)index{
    DBTimeSlot *timeSlot = _orderCoordinator.deliverySettings.deliveryType.timeSlots[index];
    _orderCoordinator.deliverySettings.selectedTimeSlot = timeSlot;
    [self reload];
    
    [GANHelper analyzeEvent:@"delivery_slot_selected" label:timeSlot.slotTitle category:ORDER_SCREEN];
}

- (void)db_timePickerView:(DBTimePickerView *)view didSelectDate:(NSDate *)date{
    NSInteger comparisonResult = [_orderCoordinator.deliverySettings setNewSelectedTime:date];
    
    if(_orderCoordinator.deliverySettings.deliveryType.timeMode & (TimeModeTime | TimeModeDateTime)){
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
