//
//  ReaderKitHook.h
//  ReaderKit
//
//  Created by cube on 2017/3/10.
//  Copyright © 2017年 cube. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
//#import <TesseractOCR/allheaders.h>
//#import <TesseractOCR/baseapi.h>
//using namespace tesseract;

@interface ReaderKitHook : NSObject

+ (void)swizzlingInClass:(Class)cls originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;
@end



