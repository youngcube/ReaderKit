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
- (instancetype)init
{
    self = [super init];
    self.cornerRadius = 1.0;   
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    if (isFound)
    {
        self.backgroundColor = [UIColor colorWithRed:65.0 / 255.0 green:103.0 / 255.0 blue:165.0 / 255.0 alpha:0.3].CGColor;
    }
    else
    {
        self.backgroundColor = [UIColor colorWithRed:255.0 / 255.0 green:184.0 / 255.0 blue:165.0 / 173.0 alpha:0.3].CGColor;
    }
}
@end
