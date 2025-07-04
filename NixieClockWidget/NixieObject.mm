//
//  NixieObject.mm
//  NixieClock
//
//  Created by zignis on 03/07/25.
//  Taken from https://github.com/pookjw/ClearAndBlurredWidgets
//

#import "NixieObject.h"
#import <objc/message.h>
#import <objc/runtime.h>

@interface NixieDescriptorFetchResult : NSObject <NSSecureCoding> {
    NSArray *_activityDescriptors;
    NSArray *_controlDescriptors;
    NSArray *_widgetDescriptors;
}
@end
@implementation NixieDescriptorFetchResult

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        NSArray *activityDescriptors = [coder decodeObjectOfClasses:[NSSet setWithObjects:NSArray.class, objc_lookUpClass("CHSWidgetDescriptor"), nil] forKey:@"activityDescriptors"];
        NSArray *controlDescriptors = [coder decodeObjectOfClasses:[NSSet setWithObjects:NSArray.class, objc_lookUpClass("CHSControlDescriptor"), nil] forKey:@"controlDescriptors"];
        NSArray *widgetDescriptors = [coder decodeObjectOfClasses:[NSSet setWithObjects:NSArray.class, objc_lookUpClass("CHSWidgetDescriptor"), nil] forKey:@"widgetDescriptors"];
        
        //
        
        NSMutableArray *newWidgetDescriptors = [[NSMutableArray alloc] initWithCapacity:widgetDescriptors.count];
        
        for (id widgetDescriptor in widgetDescriptors) {
            NSString *kind = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(widgetDescriptor, sel_registerName("kind"));
            
            if ([kind isEqualToString:@"NixieWidget"]) {
                id mutableWidgetDescriptor = [widgetDescriptor mutableCopy];
                reinterpret_cast<void (*)(id, SEL, BOOL)>(objc_msgSend)(mutableWidgetDescriptor, sel_registerName("setBackgroundRemovable:"), YES);
                reinterpret_cast<void (*)(id, SEL, BOOL)>(objc_msgSend)(mutableWidgetDescriptor, sel_registerName("setTransparent:"), YES);
                reinterpret_cast<void (*)(id, SEL, BOOL)>(objc_msgSend)(mutableWidgetDescriptor, sel_registerName("setSupportsVibrantContent:"), YES);
                reinterpret_cast<void (*)(id, SEL, NSUInteger)>(objc_msgSend)(mutableWidgetDescriptor, sel_registerName("setPreferredBackgroundStyle:"), 0x2);
                [newWidgetDescriptors addObject:mutableWidgetDescriptor];
                [mutableWidgetDescriptor release];
            } else {
                [newWidgetDescriptors addObject:widgetDescriptor];
            }
        }
        
        _widgetDescriptors = [newWidgetDescriptors copy];
        [newWidgetDescriptors release];
        _controlDescriptors = [controlDescriptors retain];
        _activityDescriptors = [activityDescriptors retain];
    }
    
    return self;
}

- (void)dealloc {
    [_activityDescriptors release];
    [_controlDescriptors release];
    [_widgetDescriptors release];
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_activityDescriptors forKey:@"activityDescriptors"];
    [coder encodeObject:_controlDescriptors forKey:@"controlDescriptors"];
    [coder encodeObject:_widgetDescriptors forKey:@"widgetDescriptors"];
}

@end

namespace custom_ExportedObject {
    namespace getAllCurrentDescriptorsWithCompletion {
        void (*original)(id, SEL, id);
        void custom(id self, SEL _cmd, void (^completion)(id fetchResult)) {
            original(self, _cmd, ^(id fetchResult_1) {
                NSError * _Nullable error = nil;
                
                NSKeyedArchiver *archiver_1 = [[NSKeyedArchiver alloc] initRequiringSecureCoding:YES];
                [fetchResult_1 encodeWithCoder:archiver_1];
                
                NSData *encodedData_1 = archiver_1.encodedData;
                [archiver_1 release];
                
                //
                
                NSKeyedUnarchiver *unarchiver_1 = [[NSKeyedUnarchiver alloc] initForReadingFromData:encodedData_1 error:&error];
                if (error != nil) {
                    completion(fetchResult_1);
                    [unarchiver_1 release];
                    return;
                }
                
                NixieDescriptorFetchResult *fetchResult_2 = [[NixieDescriptorFetchResult alloc] initWithCoder:unarchiver_1];
                [unarchiver_1 release];
                
                NSKeyedArchiver *archiver_2 = [[NSKeyedArchiver alloc] initRequiringSecureCoding:YES];
                [fetchResult_2 encodeWithCoder:archiver_2];
                [fetchResult_2 release];
                NSData *encodedData_2 = archiver_2.encodedData;
                [archiver_2 release];
                
                //
                
                NSKeyedUnarchiver *unarchiver_3 = [[NSKeyedUnarchiver alloc] initForReadingFromData:encodedData_2 error:&error];
                if (error != nil) {
                    [unarchiver_3 release];
                    completion(fetchResult_1);
                    return;
                }
                
                id fetchResult_3 = reinterpret_cast<id (*)(id, SEL, id)>(objc_msgSend)([objc_lookUpClass("_TtC9WidgetKit21DescriptorFetchResult") alloc], @selector(initWithCoder:), unarchiver_3);
                [unarchiver_3 release];
                
                completion(fetchResult_3);
                [fetchResult_3 release];
            });
        }
        void swizzle() {
            Method method = class_getInstanceMethod(objc_lookUpClass("_TtCC9WidgetKit24WidgetExtensionXPCServer14ExportedObject"), sel_registerName("getAllCurrentDescriptorsWithCompletion:"));
            original = reinterpret_cast<decltype(original)>(method_getImplementation(method));
            method_setImplementation(method, reinterpret_cast<IMP>(custom));
        }
    }
}

@implementation NixieObject

+ (void)load {
    custom_ExportedObject::getAllCurrentDescriptorsWithCompletion::swizzle();
}

@end
