//
//  WQPermissionRequest.m
//  WQPermissionRequest
//
//  Created by admin on 17/2/14.
//  Copyright © 2017年 jolimark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <Contacts/Contacts.h>
#import <EventKit/EventKit.h>
#import <HealthKit/HealthKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreTelephony/CTCellularData.h>

#import "WQPermissionRequest.h"

typedef enum {
    WQAuthorizationStatusNotDetermined,  // 第一次请求授权
    WQAuthorizationStatusAuthorized,     // 已经授权成功
    WQAuthorizationStatusForbid          // 非第一次请求授权
}WQPermissionAuthorizationStatus;

@interface WQPermissionRequest ()
<
    CLLocationManagerDelegate
>
@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, copy, nullable) WQRequestResult locationResult;
@end

@implementation WQPermissionRequest
+ (WQPermissionRequest *)createWQPermissionRequest {
    return [[[self class] alloc] init];
}

- (UIViewController *)currentViewController {
    UIViewController *currentVC = nil;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow *tmpWindow in windows) {
            if (tmpWindow.windowLevel == UIWindowLevelNormal) {
                window = tmpWindow;
                break;
            }
        }
    }
    UIView *frontV = [[window subviews] objectAtIndex:0];
    id nextReqoner = [frontV nextResponder];
    if ([nextReqoner isKindOfClass:[UIViewController class]]) {
        currentVC = nextReqoner;
    }else {
        currentVC = window.rootViewController;
    }
    return currentVC;
}

- (BOOL)determinePermission:(WQPermission)permission {
    WQPermissionAuthorizationStatus determine = [self authorizationPermission:permission];
    return determine == WQAuthorizationStatusAuthorized;
}

- (void)requestPermission:(WQPermission)permission
                    title:(NSString *)title
              description:(NSString *)description
            requestResult:(WQRequestResult)result {
    WQPermissionAuthorizationStatus authorization = [self authorizationPermission:permission];
    if (result == nil) {
        result = ^(BOOL granted, NSError *error) {
        };;
    }
    switch (authorization) {
        case WQAuthorizationStatusNotDetermined:
            // 第一次请求
            [self requestPermission:permission
                      requestResult:result];
            return;
            break;
        case WQAuthorizationStatusForbid:
            // 之前请求过，现在禁了权限
            WQLogInf(@"之前请求过，现在禁了权限");
            self.locationResult = (permission == WQLocationAllows) ||
            (permission == WQLocationWhenInUse) ? result : nil;
            break;
        case WQAuthorizationStatusAuthorized:
            // 已经授权
            WQLogMes(@"已经授权");
            result(YES, nil);
            return;
            break;
    }
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:description
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *setting = [UIAlertAction actionWithTitle:WQLocalized(@"Setting")
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                            if([[UIApplication sharedApplication] canOpenURL:url]) {
                                                                NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];           [[UIApplication sharedApplication] openURL:url];
                                                            }
                                                        });
                                                    }];
    UIAlertAction *dontAllows = [UIAlertAction actionWithTitle:WQLocalized(@"Don't Allow")
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           NSError *error = [NSError errorWithDomain:WQErrorDomain
                                                                                                code:WQForbidPermission
                                                                                            userInfo:@{NSLocalizedDescriptionKey : WQLocalized(@"Forbid permission")}];
                                                           result(NO,error);
                                                           weakSelf.locationResult = nil;
                                                       }];
    [alert addAction:setting];
    [alert addAction:dontAllows];
    UIViewController *currentVC = [self currentViewController];
    [currentVC presentViewController:alert
                            animated:YES
                          completion:nil];
}


/**************************************** 权 限 请 求 ****************************************/
- (void)requestPermission:(WQPermission)permission
            requestResult:(WQRequestResult)result{
    switch (permission) {
        case WQCamera:{
            [self requestCamera:result];
            break;
        }
        case WQLocationAllows:{
            [self requestLocationAllows:result];
            break;
        }
        case WQLocationWhenInUse:{
            [self requestLocationWhenInUse:result];
            break;
        }
        case WQCalendars:{
            [self requestCalendars:result];
            break;
        }
        case WQReminders:{
            [self requestReminders:result];
            break;
        }
        case WQUserNotification:{
            [self requestUserNotification:result];
            break;
        }
        case WQPhotoLibrary:{
            [self requestPhotoLibrary:result];
            break;
        }
        case WQMicrophone:{
            [self requestMicrophone:result];
            break;
        }
        case WQHealth:{
            [self requestHealth:result];
            break;
        }
        case WQContacts:{
            [self requestContacts:result];
            break;
        }
        case WQNetwork:{
            [self requestNetwork:result];
            break;
        }
    }
}

- (void)requestCamera:(WQRequestResult)result {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:^(BOOL granted) {
                                 NSError *error;
                                 if (granted) {
                                     WQLogMes(@"开启成功");
                                 }else {
                                     WQLogErr(@"开启失败");
                                     error = [NSError errorWithDomain:WQErrorDomain
                                                                 code:WQFailueAuthorize
                                                             userInfo:@{NSLocalizedDescriptionKey : WQLocalized(@"Failue authorize")}];
                                 }
                                 result(granted, error);
                             }];
}

- (void)requestLocationAllows:(WQRequestResult)result {
    if (!self.manager) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
    }
    self.locationResult = result;
    [self.manager requestAlwaysAuthorization];
}

- (void)requestLocationWhenInUse:(WQRequestResult)result {
    if (!self.manager) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
    }
    self.locationResult = result;
    [self.manager requestWhenInUseAuthorization];
}

- (void)requestCalendars:(WQRequestResult)result {
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent
                          completion:^(BOOL granted,
                                       NSError * _Nullable error) {
                              if (error) {
                                  WQLogErr(@"error: %@",error);
                              }else {
                                  if (granted) {
                                      WQLogMes(@"请求成功");
                                  }else {
                                      WQLogErr(@"请求失败");
                                  }
                              }
                              result(granted, error);
                          }];
}

- (void)requestReminders:(WQRequestResult)result {
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeReminder
                          completion:^(BOOL granted,
                                       NSError * _Nullable error) {
                              if (error) {
                                  WQLogErr(@"error: %@",error);
                              }else {
                                  if (granted) {
                                      WQLogMes(@"请求成功");
                                  }else {
                                      WQLogErr(@"请求失败");
                                  }
                              }
                              result(granted, error);
                          }];
}

- (void)requestUserNotification:(WQRequestResult)result {
    UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:
                                           UIUserNotificationTypeSound |
                                           UIUserNotificationTypeAlert |
                                           UIUserNotificationTypeBadge
                                                                            categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
}

- (void)requestPhotoLibrary:(WQRequestResult)result {
    if ([[UIDevice currentDevice].systemVersion floatValue] > 8.0) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            NSError *error;
            BOOL granted = NO;
            if (status == PHAuthorizationStatusAuthorized) {
                WQLogMes(@"授权成功");
                granted = YES;
            }else {
                WQLogErr(@"授权失败");
                error = [NSError errorWithDomain:WQErrorDomain
                                            code:WQFailueAuthorize
                                        userInfo:@{NSLocalizedDescriptionKey : WQLocalized(@"Failue authorize")}];
            }
            result(granted, error);
        }];
    }
}

- (void)requestMicrophone:(WQRequestResult)result {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session requestRecordPermission:^(BOOL granted) {
        NSError *error;
        if (granted) {
            WQLogMes(@"请求成功");
        }else {
            WQLogErr(@"请求失败");
            error = [NSError errorWithDomain:WQErrorDomain
                                        code:WQFailueAuthorize
                                    userInfo:@{NSLocalizedDescriptionKey : WQLocalized(@"Failue authorize")}];
        }
        result(granted, error);
    }];
}

- (void)requestHealth:(WQRequestResult)result {
    if (![HKHealthStore isHealthDataAvailable]) {
        WQLogErr(@"不支持 Health");
        NSError *error = [NSError errorWithDomain:WQErrorDomain
                                             code:WQUnsuportAuthorize
                                         userInfo:@{NSLocalizedDescriptionKey : WQLocalized(@"Unsuport authorize")}];
        result(NO, error);
        return;
    }
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
    // Share body mass, height and body mass index
    NSSet *shareObjectTypes = [NSSet setWithObjects:
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex],
                               nil];
    // Read date of birth, biological sex and step count
    NSSet *readObjectTypes  = [NSSet setWithObjects:
                               [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth],
                               [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                               nil];
    // Request access
    [healthStore requestAuthorizationToShareTypes:shareObjectTypes
                                        readTypes:readObjectTypes
                                       completion:^(BOOL success,
                                                    NSError *error) {
                                           if (error) {
                                               WQLogErr(@"error: %@",error);
                                           }else {
                                               if(success == YES){
                                                   WQLogMes(@"请求成功");
                                               }
                                               else{
                                                   WQLogErr(@"请求失败");
                                               }
                                           }
                                           result(success, error);
                                       }];
}

- (void)requestContacts:(WQRequestResult)result {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 9.0) {
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts
                        completionHandler:^(BOOL granted,
                                            NSError * _Nullable error) {
                            if (error) {
                                WQLogErr(@"error: %@",error);
                            }else {
                                if (granted) {
                                    WQLogMes(@"请求成功");
                                }else {
                                    WQLogErr(@"请求失败");
                                }
                            }
                            result(granted, error);
                        }];
    }else {
        ABAddressBookRef addressBook = ABAddressBookCreate();
        ABAddressBookRequestAccessWithCompletion(addressBook,
                                                 ^(bool granted,
                                                   CFErrorRef error) {
                                                     if (error) {
                                                         WQLogErr(@"error: %@",error);
                                                     }else {
                                                         if (granted) {
                                                             WQLogMes(@"请求成功");
                                                         }else {
                                                             WQLogErr(@"请求失败");
                                                         }
                                                     }
                                                     result(granted, (__bridge NSError *)(error));
                                                 });
    }
}

- (void)requestNetwork:(WQRequestResult)result {
    NSAssert(0, @"* * * * * * 网络手动授权还未实现 * * * * * *");
}



/**************************************** 权 限 判 断 ****************************************/
- (WQPermissionAuthorizationStatus)authorizationPermission:(WQPermission)permission {
    WQPermissionAuthorizationStatus authorization;
    switch (permission) {
        case WQCamera:
            authorization = [self determineCamera];
            break;
        case WQLocationAllows:
            authorization = [self determineLocationAllows];
            break;
        case WQLocationWhenInUse:
            authorization = [self determineLocationWhenInUse];
            break;
        case WQCalendars:
            authorization = [self determineCalendars];
            break;
        case WQReminders:
            authorization = [self determineReminders];
            break;
        case WQPhotoLibrary:
            authorization = [self determinePhotoLibrary];
            break;
        case WQUserNotification:
            authorization = [self determineUserNotification];
            break;
        case WQMicrophone:
            authorization = [self determineMicrophone];
            break;
        case WQHealth:
            authorization = [self determineHealth];
            break;
        case WQContacts:
            authorization = [self determineContacts];
            break;
        case WQNetwork:
            authorization = [self determineNetwork];
            break;
    }
    return authorization;
}

- (WQPermissionAuthorizationStatus)determineCamera {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined: {
            return WQAuthorizationStatusNotDetermined;
            break;
        }
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied: {
            return WQAuthorizationStatusForbid;
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            return WQAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (WQPermissionAuthorizationStatus)determineLocationAllows {
    if (!self.manager) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
    }
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    switch (authStatus) {
        case kCLAuthorizationStatusNotDetermined: {
            return WQAuthorizationStatusNotDetermined;
            break;
        }
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied: {
            return WQAuthorizationStatusForbid;
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            return WQAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (WQPermissionAuthorizationStatus)determineLocationWhenInUse {
    if (!self.manager) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
    }
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    switch (authStatus) {
        case kCLAuthorizationStatusNotDetermined: {
            return WQAuthorizationStatusNotDetermined;
            break;
        }
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied: {
            return WQAuthorizationStatusForbid;
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            return WQAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (WQPermissionAuthorizationStatus)determineCalendars {
    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    switch (authStatus) {
        case EKAuthorizationStatusNotDetermined: {
            return WQAuthorizationStatusNotDetermined;
            break;
        }
        case EKAuthorizationStatusRestricted:
        case EKAuthorizationStatusDenied: {
            return WQAuthorizationStatusForbid;
            break;
        }
        case EKAuthorizationStatusAuthorized: {
            return WQAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (WQPermissionAuthorizationStatus)determineReminders {
    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    switch (authStatus) {
        case EKAuthorizationStatusNotDetermined: {
            return WQAuthorizationStatusNotDetermined;
            break;
        }
        case EKAuthorizationStatusRestricted:
        case EKAuthorizationStatusDenied: {
            return WQAuthorizationStatusForbid;
            break;
        }
        case EKAuthorizationStatusAuthorized: {
            return WQAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (WQPermissionAuthorizationStatus)determinePhotoLibrary {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        ALAuthorizationStatus authStatus =[ALAssetsLibrary authorizationStatus];
        switch (authStatus) {
            case ALAuthorizationStatusNotDetermined: {
                return WQAuthorizationStatusNotDetermined;
                break;
            }
            case ALAuthorizationStatusRestricted:
            case ALAuthorizationStatusDenied: {
                return WQAuthorizationStatusForbid;
                break;
            }
            case ALAuthorizationStatusAuthorized: {
                return WQAuthorizationStatusAuthorized;
                break;
            }
        }
    } else {
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
        switch (authStatus) {
            case PHAuthorizationStatusNotDetermined: {
                return WQAuthorizationStatusNotDetermined;
                break;
            }
            case PHAuthorizationStatusRestricted:
            case PHAuthorizationStatusDenied: {
                return WQAuthorizationStatusForbid;
                break;
            }
            case PHAuthorizationStatusAuthorized: {
                return WQAuthorizationStatusAuthorized;
                break;
            }
        }
    }
}

- (WQPermissionAuthorizationStatus)determineUserNotification {
    UIUserNotificationType type = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
    switch (type) {
        case UIUserNotificationTypeNone: {
            return WQAuthorizationStatusNotDetermined;
            break;
        }
        case UIUserNotificationTypeBadge:
        case UIUserNotificationTypeSound:
        case UIUserNotificationTypeAlert: {
            return WQAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (WQPermissionAuthorizationStatus)determineMicrophone {
    AVAudioSessionRecordPermission authStatus = [[AVAudioSession sharedInstance] recordPermission];
    switch (authStatus) {
        case AVAudioSessionRecordPermissionUndetermined: {
            return WQAuthorizationStatusNotDetermined;
            break;
        }
        case AVAudioSessionRecordPermissionDenied: {
            return WQAuthorizationStatusForbid;
            break;
        }
        case AVAudioSessionRecordPermissionGranted: {
            return WQAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (WQPermissionAuthorizationStatus)determineHealth {
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
    HKObjectType *hkObjectType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKAuthorizationStatus authStatus = [healthStore authorizationStatusForType:hkObjectType];
    switch (authStatus) {
        case HKAuthorizationStatusNotDetermined: {
            return WQAuthorizationStatusNotDetermined;
            break;
        }
        case HKAuthorizationStatusSharingDenied: {
            return WQAuthorizationStatusForbid;
            break;
        }
        case HKAuthorizationStatusSharingAuthorized: {
            return WQAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (WQPermissionAuthorizationStatus)determineContacts {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 9.0) {
        CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        switch (authStatus) {
            case CNAuthorizationStatusNotDetermined: {
                return WQAuthorizationStatusNotDetermined;
                break;
            }
            case CNAuthorizationStatusRestricted:
            case CNAuthorizationStatusDenied: {
                return WQAuthorizationStatusForbid;
                break;
            }
            case CNAuthorizationStatusAuthorized: {
                return WQAuthorizationStatusAuthorized;
                break;
            }
        }
    }else {
        ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
        switch (authStatus) {
            case kABAuthorizationStatusNotDetermined: {
                return WQAuthorizationStatusNotDetermined;
                break;
            }
            case kABAuthorizationStatusRestricted:
            case kABAuthorizationStatusDenied: {
                return WQAuthorizationStatusForbid;
                break;
            }
            case kABAuthorizationStatusAuthorized: {
                return WQAuthorizationStatusAuthorized;
                break;
            }
        }
    }
}

- (WQPermissionAuthorizationStatus)determineNetwork {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 9.0) {
        CTCellularData *cellularData = [[CTCellularData alloc] init];
        CTCellularDataRestrictedState authStatus = cellularData.restrictedState;
        switch (authStatus) {
            case kCTCellularDataRestrictedStateUnknown: {
                WQLogMes(@"kCTCellularDataRestrictedStateUnknown");
                return WQAuthorizationStatusNotDetermined;
                break;
            }
            case kCTCellularDataRestricted: {
                WQLogMes(@"kCTCellularDataRestricted");
                return WQAuthorizationStatusForbid;
                break;
            }
            case kCTCellularDataNotRestricted: {
                WQLogMes(@"kCTCellularDataNotRestricted");
                return WQAuthorizationStatusAuthorized;
                break;
            }
        }
    }else {
        NSAssert(0, @"* * * * * * iOS 9.0 后才可使用网络授权 * * * * * *");
        return WQAuthorizationStatusForbid;
    }
}


#pragma mark  -- CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    WQLogMes(@"didChangeAuthorizationStatus: %d",status);
    if (status == kCLAuthorizationStatusAuthorizedAlways
        || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        if (self.locationResult) {
            self.locationResult(YES, nil);
            self.locationResult = nil;
        }
    }
}
@end









