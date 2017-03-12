//
//  ReaderKitTesseract.m
//  ReaderKit
//
//  Created by cube on 2017/3/12.
//  Copyright © 2017年 cube. All rights reserved.
//

#import "ReaderKitManager.h"

@implementation ReaderKitWordCaptureModel

- (instancetype)initWithWord:(NSString *)word rect:(CGRect)rect viewController:(UIViewController *)viewController
{
    if (self = [super init]){
        self.word = word;
        self.rect = rect;
        self.viewController = viewController;
    }
    return self;
}

@end


@implementation ReaderKitManager
+ (ReaderKitManager *)sharedInstance
{
    static ReaderKitManager *_sharedReaderKitHook = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedReaderKitHook = [[self alloc] init];
    });
    
    return _sharedReaderKitHook;
}

- (TessBaseAPI*)tessOcr
{
    if (tessOcr == NULL)
    {
        //init tesseract
        tessOcr = new TessBaseAPI();
        
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        setenv("TESSDATA_PREFIX", [[resourcePath stringByAppendingString:@"/"] UTF8String], 1); //have todo this
#ifdef _EUDIC_
        tessOcr->Init([[resourcePath stringByAppendingString:@"tessdata/"] UTF8String], "eng", OEM_TESSERACT_CUBE_COMBINED);
#else
        tessOcr->Init([[resourcePath stringByAppendingString:@"tessdata/"] UTF8String], READERKIT_OCR_LANG);
#endif
        
    }
    return tessOcr;
}

#pragma mark - Word Capture Method
+ (void)shouldShowWordCaptured:(NSString *)word viewController:(UIViewController *)vc rect:(CGRect)rect
{
    ReaderKitWordCaptureModel *model = [[ReaderKitWordCaptureModel alloc] initWithWord:word rect:rect viewController:vc];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReaderKitShouldShowWordCaptured object:model];
}

+ (void)shouldClearCapturedWord
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReaderKitShouldClearCapturedWord object:nil];
}

#pragma mark - StrOpt Method
+ (CHAR_TYPE)getCharType:(unichar)ch
{
    //windows 下面tolower会错误处理中文
    if (ch >= 0x4e00 && ch <= 0x9fa5)//\u4e00-\u9fa5 汉字的范围。 但我没有测试过！！
    {
        return CHAR_TYPE_CHINESE;
    }
    else if (ch >= 0x0800 && ch < 0x4e00)//\u4e00-\u9fa5 汉字的范围。 但我没有测试过！！
    {
        return CHAR_TYPE_JP;
    }
    else if ((ch >= 0xac00 && ch <= 0xd7ff) || (ch >= 0x3130 && ch <= 0x318f))//\u4e00-\u9fa5 汉字的范围。 但我没有测试过！！
    {
        return CHAR_TYPE_KR;
    }
    
    ch = __tolower(ch);
    if (ch == '\'' || ch == 8217 || ch == '-' || ch == '|')
    {
        return CHAR_TYPE_GUILLEMET;
    }
    else if ((ch >=97) && (ch<=122)) {
        return CHAR_TYPE_WESTEN;
    }
    else {
        /*
         ch = L'ù';249
         ch = L'ç';231
         ch = L'œ';339
         ch = L'æ';230
         ch = L'à';224
         ch = L'â';226
         ch = L'ï';239
         ch = L'é';233
         ch = L'è';232
         ch = L'ê';234
         ch = L'ë';235
         ch = L'î';238
         ch = L'ô';244
         ch = L'ö';246
         ch = L'ü';252
         ch = L'û';251
         ch = L'ä';228
         ch = L'ß';223
         ch = L'\'';39
         ch = L'’';8217
         ch = L'ñ';241
         */
        if (ch > 191 && ch < 1512){
            return CHAR_TYPE_WESTEN;
            //				case L'ù':case L'ç':case L'œ':case L'æ':case L'à':case L'â':case L'ï':case L'é':
            //				case L'è':case L'ê':case L'ë':case L'î':case L'ô':case L'ö':case L'ü':case L'û':
            //				case L'ä':case L'ß':case L'\'':case L'’':case L'ñ':
        }
        else {
            switch (ch) {
                case 32:
                    return CHAR_TYPE_SPACE;
                    break;
                case 39: case 8217:
                    return CHAR_TYPE_WESTEN;
                    break;
                default:
                    return CHAR_TYPE_OTHER;
                    break;
            }
        }
        
    }
}

+ (BOOL)isCapital:(unichar)ch
{
    if (ch == __tolower(ch)){
        return YES;
    }
    return NO;
}
@end
