//
//  ReaderDocument+ReaderKit.m
//  ReaderKit
//
//  Created by cube on 2017/3/12.
//  Copyright © 2017年 cube. All rights reserved.
//

#import "ReaderDocument+ReaderKit.h"
#import "ReaderKitHook.h"

@implementation ReaderDocument (ReaderKit)
#pragma mark - Append Method
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL oriEmail = @selector(canEmail);
        SEL swiEmail = @selector(hook_canEmail);
        [ReaderKitHook swizzlingInClass:[self class] originalSelector:oriEmail swizzledSelector:swiEmail];
        
        SEL oriExport = @selector(canExport);
        SEL swiExport = @selector(hook_canExport);
        [ReaderKitHook swizzlingInClass:[self class] originalSelector:oriExport swizzledSelector:swiExport];
        
        SEL oriPrint = @selector(canPrint);
        SEL swiPrint = @selector(hook_canPrint);
        [ReaderKitHook swizzlingInClass:[self class] originalSelector:oriPrint swizzledSelector:swiPrint];
    });
}

- (BOOL)hook_canEmail
{
    return NO;
}

- (BOOL)hook_canExport
{
    return NO;
}

- (BOOL)hook_canPrint
{
    return NO;
}

@end
