//
//  EUPDFFocusLayer.h
//  ciku_ios
//
//  Created by XIAOYQ on 10/7/11.
//  Copyright (c) 2011 SNDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CATiledLayer.h>

@interface EUPDFFocusLayer : CALayer
{
    BOOL isFound;
}
@property(nonatomic, assign) BOOL isFound;
@end