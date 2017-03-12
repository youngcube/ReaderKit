//
//  UIView+ReaderKitHook.m
//  ReaderKit
//
//  Created by Eusoft on 2017/3/10.
//  Copyright © 2017年 cube. All rights reserved.
//

#import "ReaderContentView+ReaderKitHook.h"
#import "ReaderKitHook.h"
#import "ReaderContentPage+ReaderKitHook.h"

@implementation ReaderContentView (ReaderKitHook)

@dynamic magnifierView;
@dynamic magniferLongPressCount;
@dynamic contentPage;


static char magnifierViewKey;
static char magniferLongPressCountKey;


#pragma mark - Property
- (EUMagnifierView *)magnifierView
{
    return objc_getAssociatedObject(self, &magnifierViewKey);
}

- (void)setMagnifierView:(EUMagnifierView *)magnifierView
{
    objc_setAssociatedObject(self, &magnifierViewKey, magnifierView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (int)magniferLongPressCount
{
    return [objc_getAssociatedObject(self, &magniferLongPressCountKey) intValue];
}

- (void)setMagniferLongPressCount:(int)magniferLongPressCount
{
    objc_setAssociatedObject(self, &magniferLongPressCountKey, [NSNumber numberWithInt:magniferLongPressCount],  OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL oriAppear = @selector(initWithFrame:fileURL:page:password:);
        SEL swiAppear = @selector(hook_initWithFrame:fileURL:page:password:);
        [ReaderKitHook swizzlingInClass:[self class] originalSelector:oriAppear swizzledSelector:swiAppear];
        
    });
}

- (ReaderContentPage *)contentPage
{
    return [self valueForKey:@"theContentPage"];
}

- (instancetype)hook_initWithFrame:(CGRect)frame fileURL:(NSURL *)fileURL page:(NSUInteger)page password:(NSString *)phrase
{
    ReaderContentView *contentView = [self hook_initWithFrame:frame fileURL:fileURL page:page password:phrase];
    
    //capture support
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longGesture.minimumPressDuration = 0.2; // too hard to long press
    [self addGestureRecognizer:longGesture];
    
    return contentView;
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)recognizer
{
    
    if (self.magnifierView == nil)
    {
        self.magnifierView = [[EUMagnifierView alloc] init];
        self.magnifierView.viewToMagnify = self.superview;
    }
    
    switch ([recognizer state]) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint touchPoint = [recognizer locationInView:self.superview];
            [self.superview addSubview:self.magnifierView];
            self.magnifierView.frame = CGRectMake(touchPoint.x, touchPoint.y, 0, 0);
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(showMagnifierAniDidFinished)];
            [self.magnifierView setHidden:NO];
            [self.magnifierView setTouchPoint:touchPoint];
            [UIView commitAnimations];
            
            self.magniferLongPressCount = 1;
            [self.magnifierView setNeedsDisplay];
            
            [self.contentPage updateFocusLayer:[recognizer locationInView:self.contentPage]];
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (![self.magnifierView isHidden]) {
                self.magnifierView.touchPoint =  [recognizer locationInView:self.superview];
                [self.magnifierView setNeedsDisplay];
                self.magniferLongPressCount++;
                
                    [self.contentPage updateFocusLayer:[recognizer locationInView:self.contentPage]];
                
                
            }
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if (![self.magnifierView isHidden]) {
                self.magniferLongPressCount--;
                if (self.magniferLongPressCount <= 0)
                {
                    CGPoint touchPoint = [recognizer locationInView:self.superview];
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:0.2];
                    [UIView setAnimationDelegate:self];
                    self.magnifierView.frame = CGRectMake(touchPoint.x, touchPoint.y, 0, 0);
                    [UIView setAnimationDidStopSelector:@selector(hideMagnifierAniDidFinished)];
                    [UIView commitAnimations];
                }
            }
            
        }
            break;
        default:
            break;
    }    
}

- (void)showMagnifierAniDidFinished
{
    [self.magnifierView setNeedsDisplay];
}
- (void)hideMagnifierAniDidFinished
{
    [self.magnifierView setHidden:YES];
    [self.magnifierView removeFromSuperview];
    if (![self.contentPage.focusLayer isHidden])
        [self.contentPage doCapture];
}


@end
