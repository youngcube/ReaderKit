//
//  EUMagnifierView.h
//  ciku_ios
//
//  Created by Yiqing XIAO on 9/5/11.
//  Copyright 2011 SNDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#define MAGNIFIER_RECT_WIDTH 205
#define MAGNIFIER_RECT_HEIGHT 71
#define MAGNIFIER_VISIBLE_WIDTH 180
#define MAGNIFIER_VISIBLE_HEIGHT 40

@interface EUMagnifierView : UIView
{
    UIView *viewToMagnify;
	CGPoint touchPoint;
    BOOL rendering;
} 
@property (nonatomic, strong) UIView *viewToMagnify;
@property (assign) CGPoint touchPoint;

@end
