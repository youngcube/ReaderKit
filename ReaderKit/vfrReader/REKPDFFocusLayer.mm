//
//  REKPDFFocusLayer.m
//  ciku_ios
//
//  Created by XIAOYQ on 10/7/11.
//  Copyright (c) 2011 SNDA. All rights reserved.
//

#import "REKPDFFocusLayer.h"

@implementation REKPDFFocusLayer
@synthesize isFound;
-(id)init
{
    self = [super init];
    //self.backgroundColor = [UIColor blueColor];
    self.cornerRadius = 1.0;   
    return self;
}
-(void)drawInContext:(CGContextRef)ctx
{
    if (isFound)
    {
        self.backgroundColor = [UIColor colorWithRed:65.0 / 255.0 green:103.0 / 255.0 blue:165.0 / 255.0 alpha:0.3].CGColor;
        // CGContextSetRGBFillColor(ctx, 65.0 / 255.0, 103.0 / 255.0, 165.0 / 255.0, 0.3);
        //CGContextFillRect(ctx, self.bounds);   
    }
    else
    {
        self.backgroundColor = [UIColor colorWithRed:255.0 / 255.0 green:184.0 / 255.0 blue:165.0 / 173.0 alpha:0.3].CGColor;
        
        // CGContextSetRGBFillColor(ctx, 255.0 / 255.0, 184.0 / 255.0, 173.0 / 255.0, 0.3);
        //CGContextFillRect(ctx, self.bounds);
    }
}
@end
