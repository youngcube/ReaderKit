//
//  ReaderKitManager.h
//  ReaderKit
//
//  Created by cube on 2017/3/12.
//  Copyright © 2017年 cube. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TesseractOCR/allheaders.h>
#import <TesseractOCR/baseapi.h>
using namespace tesseract;

typedef NS_ENUM(NSInteger, CHAR_TYPE) {
    CHAR_TYPE_WESTEN,
    CHAR_TYPE_CHINESE,
    CHAR_TYPE_JP,
    CHAR_TYPE_KR,
    CHAR_TYPE_SPACE,
    CHAR_TYPE_OTHER,
    CHAR_TYPE_GUILLEMET
};

@interface ReaderKitManager : NSObject
{
    TessBaseAPI *tessOcr;
}
@property (nonatomic, readonly) TessBaseAPI *tessOcr;
+ (ReaderKitManager *)sharedInstance;

#pragma mark - StrOpt Method
+ (CHAR_TYPE)getCharType:(unichar)ch;
+ (BOOL)isCapital:(unichar)ch;
@end
