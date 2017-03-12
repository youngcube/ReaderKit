//
//  REKMagnifierView.m
//  ciku_ios
//
//  Created by Yiqing XIAO on 9/5/11.
//  Copyright 2011 SNDA. All rights reserved.
//

#import "REKMagnifierView.h"

@implementation REKMagnifierView
@synthesize viewToMagnify, touchPoint;
- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:CGRectMake(0, 0, MAGNIFIER_RECT_WIDTH, MAGNIFIER_RECT_HEIGHT)]) {
		// make the circle-shape outline with a nice border.
        self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)setTouchPoint:(CGPoint)pt {
	touchPoint = pt;
	// whenever touchPoint is set, 
	// update the position of the magnifier (to just above what's being magnified)
 
    self.frame = CGRectMake(pt.x - MAGNIFIER_RECT_WIDTH/2, pt.y - MAGNIFIER_RECT_HEIGHT - 22, MAGNIFIER_RECT_WIDTH, MAGNIFIER_RECT_HEIGHT);  
}
-(CGPoint)touchPoint
{
    return touchPoint;
}

- (void)drawRect:(CGRect)rect {
	// here we're just doing some transforms on the view we're magnifying,
	// and rendering that view directly into this view,
	// rather than the previous method of copying an image.
    if (rendering)
        return;
    rendering = true;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	  
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx,1*(MAGNIFIER_RECT_WIDTH*0.5),1*(MAGNIFIER_RECT_HEIGHT*0.5) - 8);
	CGContextScaleCTM(ctx, 1.5, 1.5);
   	CGContextTranslateCTM(ctx, -1*(touchPoint.x), -1*(touchPoint.y - 7));
    CGContextClipToRect(ctx, CGRectMake(touchPoint.x - 60, touchPoint.y - 15, MAGNIFIER_VISIBLE_WIDTH / 1.5, MAGNIFIER_VISIBLE_HEIGHT / 1.5));

	[self.viewToMagnify.layer renderInContext:ctx];
    CGContextRestoreGState(ctx);
    [[UIImage imageNamed:@"icon_magnifier"] drawAtPoint:CGPointMake(0, 0)];
    rendering = false;
}



@end
