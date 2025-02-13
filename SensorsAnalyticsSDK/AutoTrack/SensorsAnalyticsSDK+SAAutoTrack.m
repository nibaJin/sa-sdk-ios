//
// SensorsAnalyticsSDK+SAAutoTrack.m
// SensorsAnalyticsSDK
//
// Created by wenquan on 2021/4/2.
// Copyright © 2021 Sensors Data Co., Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import "SensorsAnalyticsSDK+SAAutoTrack.h"
#import "SensorsAnalyticsSDK+Private.h"
#import "SAAutoTrackUtils.h"
#import "SAAutoTrackManager.h"
#import "SAModuleManager.h"
#import "SAWeakPropertyContainer.h"
#include <objc/runtime.h>

@implementation UIImage (SensorsAnalytics)

- (NSString *)sensorsAnalyticsImageName {
    return objc_getAssociatedObject(self, @"sensorsAnalyticsImageName");
}

- (void)setSensorsAnalyticsImageName:(NSString *)sensorsAnalyticsImageName {
    objc_setAssociatedObject(self, @"sensorsAnalyticsImageName", sensorsAnalyticsImageName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

@implementation UIView (SensorsAnalytics)

//viewID
- (NSString *)sensorsAnalyticsViewID {
    return objc_getAssociatedObject(self, @"sensorsAnalyticsViewID");
}

- (void)setSensorsAnalyticsViewID:(NSString *)sensorsAnalyticsViewID {
    objc_setAssociatedObject(self, @"sensorsAnalyticsViewID", sensorsAnalyticsViewID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

//ignoreView
- (BOOL)sensorsAnalyticsIgnoreView {
    return [objc_getAssociatedObject(self, @"sensorsAnalyticsIgnoreView") boolValue];
}

- (void)setSensorsAnalyticsIgnoreView:(BOOL)sensorsAnalyticsIgnoreView {
    objc_setAssociatedObject(self, @"sensorsAnalyticsIgnoreView", [NSNumber numberWithBool:sensorsAnalyticsIgnoreView], OBJC_ASSOCIATION_ASSIGN);
}

//afterSendAction
- (BOOL)sensorsAnalyticsAutoTrackAfterSendAction {
    return [objc_getAssociatedObject(self, @"sensorsAnalyticsAutoTrackAfterSendAction") boolValue];
}

- (void)setSensorsAnalyticsAutoTrackAfterSendAction:(BOOL)sensorsAnalyticsAutoTrackAfterSendAction {
    objc_setAssociatedObject(self, @"sensorsAnalyticsAutoTrackAfterSendAction", [NSNumber numberWithBool:sensorsAnalyticsAutoTrackAfterSendAction], OBJC_ASSOCIATION_ASSIGN);
}

//viewProperty
- (NSDictionary *)sensorsAnalyticsViewProperties {
    return objc_getAssociatedObject(self, @"sensorsAnalyticsViewProperties");
}

- (void)setSensorsAnalyticsViewProperties:(NSDictionary *)sensorsAnalyticsViewProperties {
    objc_setAssociatedObject(self, @"sensorsAnalyticsViewProperties", sensorsAnalyticsViewProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<SAUIViewAutoTrackDelegate>)sensorsAnalyticsDelegate {
    SAWeakPropertyContainer *container = objc_getAssociatedObject(self, @"sensorsAnalyticsDelegate");
    return container.weakProperty;
}

- (void)setSensorsAnalyticsDelegate:(id<SAUIViewAutoTrackDelegate>)sensorsAnalyticsDelegate {
    SAWeakPropertyContainer *container = [SAWeakPropertyContainer containerWithWeakProperty:sensorsAnalyticsDelegate];
    objc_setAssociatedObject(self, @"sensorsAnalyticsDelegate", container, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark -

@implementation SensorsAnalyticsSDK (SAAutoTrack)

- (UIViewController *)currentViewController {
    return [SAAutoTrackUtils currentViewController];
}

- (BOOL)isAutoTrackEnabled {
    return [SAAutoTrackManager.defaultManager isAutoTrackEnabled];
}

#pragma mark - Ignore

- (BOOL)isAutoTrackEventTypeIgnored:(SensorsAnalyticsAutoTrackEventType)eventType {
    return [SAAutoTrackManager.defaultManager isAutoTrackEventTypeIgnored:eventType];
}

- (void)ignoreViewType:(Class)aClass {
    [SAAutoTrackManager.defaultManager.appClickTracker ignoreViewType:aClass];
}

- (BOOL)isViewTypeIgnored:(Class)aClass {
    return [SAAutoTrackManager.defaultManager.appClickTracker isViewTypeIgnored:aClass];
}

- (void)ignoreAutoTrackViewControllers:(NSArray<NSString *> *)controllers {
    [SAAutoTrackManager.defaultManager.appClickTracker ignoreAutoTrackViewControllers:controllers];
    [SAAutoTrackManager.defaultManager.appViewScreenTracker ignoreAutoTrackViewControllers:controllers];
}

- (BOOL)isViewControllerIgnored:(UIViewController *)viewController {
    BOOL isIgnoreAppClick = [SAAutoTrackManager.defaultManager.appClickTracker isViewControllerIgnored:viewController];
    BOOL isIgnoreAppViewScreen = [SAAutoTrackManager.defaultManager.appViewScreenTracker isViewControllerIgnored:viewController];

    return isIgnoreAppClick || isIgnoreAppViewScreen;
}

#pragma mark - Track

- (void)trackViewAppClick:(UIView *)view {
    [self trackViewAppClick:view withProperties:nil];
}

- (void)trackViewAppClick:(UIView *)view withProperties:(NSDictionary *)p {
    [SAAutoTrackManager.defaultManager.appClickTracker trackEventWithView:view properties:p];
}

- (void)trackViewScreen:(UIViewController *)controller {
    [self trackViewScreen:controller properties:nil];
}

- (void)trackViewScreen:(UIViewController *)controller properties:(nullable NSDictionary<NSString *, id> *)properties {
    [SAAutoTrackManager.defaultManager.appViewScreenTracker trackEventWithViewController:controller properties:properties];
}

- (void)trackViewScreen:(NSString *)url withProperties:(NSDictionary *)properties {
    [SAAutoTrackManager.defaultManager.appViewScreenTracker trackEventWithURL:url properties:properties];
}

#pragma mark - Deprecated

- (void)enableAutoTrack:(SensorsAnalyticsAutoTrackEventType)eventType {
    if (self.configOptions.autoTrackEventType != eventType) {
        self.configOptions.autoTrackEventType = eventType;

        SAAutoTrackManager.defaultManager.enable = YES;
        
        [SAAutoTrackManager.defaultManager updateAutoTrackEventType];
    }
}

@end
