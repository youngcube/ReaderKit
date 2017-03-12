//
//  ReaderKitManager.h
//  ReaderKit
//
//  Created by cube on 2017/3/12.
//  Copyright © 2017年 cube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReaderKitConstants.h"
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

@protocol ReaderKitManagerCaptureDelegate <NSObject>
- (BOOL)captureDelegateShouldShowWordCaptured:(NSString *)word rect:(CGRect)rect;
- (void)captureDelegateShouldClearCapturedWord;
@end



// Notification Object
@interface ReaderKitWordCaptureModel : NSObject
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, copy) NSString *word;
@property (nonatomic) CGRect rect;
- (instancetype)initWithWord:(NSString *)word rect:(CGRect)rect viewController:(UIViewController *)viewController;
@end

@interface ReaderKitManager : NSObject
{
    TessBaseAPI *tessOcr;
}
@property (nonatomic, readonly) TessBaseAPI *tessOcr;
@property (nonatomic, weak) id <ReaderKitManagerCaptureDelegate> captureDelegate;
+ (ReaderKitManager *)sharedInstance;

#pragma mark - Word Capture Method
+ (void)shouldShowWordCaptured:(NSString *)word viewController:(UIViewController *)vc rect:(CGRect)rect;
+ (void)shouldClearCapturedWord;

#pragma mark - StrOpt Method
+ (CHAR_TYPE)getCharType:(unichar)ch;
+ (BOOL)isCapital:(unichar)ch;
@end
