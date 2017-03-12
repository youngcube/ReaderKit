//
//  ReaderViewController+ReaderKitHook.m
//  ReaderKit
//
//  Created by cube on 2017/3/12.
//  Copyright © 2017年 cube. All rights reserved.
//

#import "ReaderViewController+ReaderKit.h"
#import "ReaderKitHook.h"

@implementation ReaderViewController (ReaderKit)

#pragma mark - Append Method
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL oriAppear = @selector(viewDidAppear:);
        SEL swiAppear = @selector(hook_viewDidAppear:);
        [ReaderKitHook swizzlingInClass:[self class] originalSelector:oriAppear swizzledSelector:swiAppear];
        
        SEL oriDisappear = @selector(viewDidDisappear:);
        SEL swiDisappear = @selector(hook_viewDidDisappear:);
        [ReaderKitHook swizzlingInClass:[self class] originalSelector:oriDisappear swizzledSelector:swiDisappear];
        
    });
}

- (void)hook_viewDidAppear:(BOOL)animated
{
    [ReaderKitManager sharedInstance].captureDelegate = self;
    [self hook_viewDidAppear:animated];
}

- (void)hook_viewDidDisappear:(BOOL)animated
{
    [ReaderKitManager sharedInstance].captureDelegate = nil;
    [self hook_viewDidDisappear:animated];
}

- (BOOL)captureDelegateShouldShowWordCaptured:(NSString *)word rect:(CGRect)rect
{
    if (word.length > 0){
        [ReaderKitManager shouldShowWordCaptured:word viewController:self rect:rect];
        return YES;
    }
    return NO;
}

- (void)captureDelegateShouldClearCapturedWord
{
    [ReaderKitManager shouldClearCapturedWord];
}

@end
