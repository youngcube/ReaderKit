//
//  NSImage+ReaderKitHook.m
//  ReaderKit
//
//  Created by cube on 2017/3/10.
//  Copyright © 2017年 cube. All rights reserved.
//

#import "ReaderContentPage+ReaderKit.h"
#import "ReaderKitHook.h"
#import "ReaderKitManager.h"
#import "ReaderKitConstants.h"

@implementation ReaderContentPage (ReaderKit)

#pragma mark - Property
@dynamic focusLayer;
@dynamic pdfPage;
static char focusLayerKey;
- (REKPDFFocusLayer *)focusLayer
{
    return objc_getAssociatedObject(self, &focusLayerKey);
}

- (void)setFocusLayer:(REKPDFFocusLayer *)focusLayer
{
    objc_setAssociatedObject(self, &focusLayerKey, focusLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPDFPageRef)pdfPage
{
    Ivar ivar = class_getInstanceVariable([self class], "_PDFPageRef");
    return (__bridge CGPDFPageRef)(object_getIvar(self, ivar));
}

#pragma mark - Append Method
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL oriInit = @selector(initWithFrame:);
        SEL swiInit = @selector(hook_initWithFrame:);
        [ReaderKitHook swizzlingInClass:[self class] originalSelector:oriInit swizzledSelector:swiInit];
        
        SEL oriSingleTap = @selector(processSingleTap:);
        SEL swiSingleTap = @selector(hook_processSingleTap:);
        [ReaderKitHook swizzlingInClass:[self class] originalSelector:oriSingleTap swizzledSelector:swiSingleTap];
    });
}

- (instancetype)hook_initWithFrame:(CGRect)frame
{
    ReaderContentPage *contentPage = [self hook_initWithFrame:frame];
    
    self.focusLayer = [REKPDFFocusLayer layer];
    [self.focusLayer setHidden:YES];
    [self.layer addSublayer:self.focusLayer];
    
    return contentPage;
}

- (id)hook_processSingleTap:(UITapGestureRecognizer *)recognizer
{
    if (![self.focusLayer isHidden]){
        [self.focusLayer setHidden:YES];
        [self.focusLayer setNeedsDisplay];
        [[ReaderKitManager sharedInstance].captureDelegate captureDelegateShouldClearCapturedWord];
        return @"handled";
    }
    return [self hook_processSingleTap:recognizer];
}

#ifdef _DEHELPER_
#define CAPTURE_WIDTH 200
#else
#define CAPTURE_WIDTH 100
#endif
#define CAPTURE_HEIGHT 25
#define SCALE_FACTOR 3

- (UIImage *)getImagewithTouchLocation:(CGPoint)touchPos{
    CGSize currentPageSize = self.layer.frame.size;
    CGRect cropRect = CGRectMake(touchPos.x - CAPTURE_WIDTH/2, touchPos.y - CAPTURE_HEIGHT/2, CAPTURE_WIDTH, CAPTURE_HEIGHT);
    UIGraphicsBeginImageContext(CGSizeMake(CAPTURE_WIDTH*SCALE_FACTOR, CAPTURE_HEIGHT*SCALE_FACTOR));
    //  UIGraphicsBeginImageContext(CGSizeMake(2000, 2000));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetRGBFillColor( context, 1.0, 1.0, 1.0, 1.0 );
    
    CGContextFillRect( context, CGContextGetClipBoundingBox( context ));
    
    CGContextTranslateCTM( context, 0.0, currentPageSize.height*SCALE_FACTOR );
    CGContextScaleCTM( context, 1.0, -1.0 );
    
    CGContextTranslateCTM(context, - cropRect.origin.x*SCALE_FACTOR,  cropRect.origin.y*SCALE_FACTOR);
    CGContextScaleCTM(context, SCALE_FACTOR, SCALE_FACTOR );
    CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(self.pdfPage, kCGPDFCropBox, CGRectMake( 0, 0, currentPageSize.width, currentPageSize.height), 0, true);
    
    CGContextConcatCTM(context, pdfTransform);
    
    CGContextDrawPDFPage(context, self.pdfPage);
    
    CGContextRestoreGState(context);
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

- (void)hideFocusLayer
{
    [self.focusLayer setHidden:YES];
    [self.focusLayer setNeedsDisplay];
}

- (void)doCapture
{
    CGPoint l = self.focusLayer.position;
    UIImage *image = [self getImagewithTouchLocation:l];
    [self offlineOcrCaptureWithImage:image touchLocation:l];
}

- (void)offlineOcrCaptureWithImage:(UIImage *)image touchLocation:(CGPoint)l
{
    CGPoint l_origin = CGPointMake(l.x - CAPTURE_WIDTH/(2), l.y - CAPTURE_HEIGHT/(2));
    CGSize imageSize = [image size];
    int bytes_per_line  = (int)CGImageGetBytesPerRow([image CGImage]);
    int bytes_per_pixel = (int)CGImageGetBitsPerPixel([image CGImage]) / 8.0;
    
    CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider([image CGImage]));
    const UInt8 *imageData = CFDataGetBytePtr(data);
    
    ImageThresholder *it = new ImageThresholder();
    it->SetImage(imageData, imageSize.width, imageSize.height, bytes_per_pixel, bytes_per_line);
    PIX *imgPix = it->GetPixRectGrey();
    CFRelease(data);
    delete it;
    
    ReaderKitManager *shell = [ReaderKitManager sharedInstance];
    shell.tessOcr->SetImage(imgPix);
    Pixa *pixaTemp = NULL;
    Boxa *boxaTemp = NULL;
    boxaTemp = shell.tessOcr->GetWords(&pixaTemp);
    if (pixaTemp)  pixaDestroy(&pixaTemp);
    if (boxaTemp != NULL)
    {
        CGPoint centerPoint = CGPointMake(imgPix->w/2, imgPix->h /2);
        Box **thisBox = boxaTemp->box;
        for (int i = 0; i < boxaTemp->n; i++) {
            CGRect boxRect = CGRectMake((*thisBox)->x, (*thisBox)->y, (*thisBox)->w, (*thisBox)->h);
            if (CGRectContainsPoint(boxRect, centerPoint)){
                //draw rect
                CGRect finalRect = CGRectMake(l_origin.x + boxRect.origin.x / SCALE_FACTOR, l_origin.y + boxRect.origin.y/SCALE_FACTOR, boxRect.size.width/SCALE_FACTOR, boxRect.size.height/SCALE_FACTOR);
                
                shell.tessOcr->SetRectangle((*thisBox)->x, (*thisBox)->y, (*thisBox)->w, (*thisBox)->h);
                NSString *capText = @(shell.tessOcr->GetUTF8Text());
                int *confidenceLevel = shell.tessOcr->AllWordConfidences();
                //isvalid 似乎没有什么作用
                //int isvalid = shell.tessOcr->IsValidWord([capText EUUTF8String]);
                //if (*confidenceLevel >= 30) {
                capText = [self getASCStringFromLine:capText startPos:[capText length] / 2 breakOnCapital:NO];
                //}
                if (/**confidenceLevel >= 30 &&*/
                    [[ReaderKitManager sharedInstance].captureDelegate captureDelegateShouldShowWordCaptured:capText rect:[self convertRect:finalRect toView:nil]])
                    
                {
                    [self.focusLayer setIsFound:YES];
                    [CATransaction begin];
                    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
                    [self.focusLayer setFrame:CGRectInset(finalRect, -3, -1)];
                    [CATransaction commit];
                    
                    [self.focusLayer setHidden:NO];
                    [self.focusLayer setNeedsDisplay];
                }
                else
                {
                    [self.focusLayer setIsFound:NO];
                    [CATransaction begin];
                    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
                    [self.focusLayer setFrame:CGRectInset(finalRect, -3, -1)];
                    [CATransaction commit];
                    
                    
                    [self.focusLayer setHidden:NO];
                    [self.focusLayer setNeedsDisplay];
                    [self performSelector:@selector(hideFocusLayer) withObject:nil afterDelay:1.0];
                }
                
                NSLog(@"reco = %@",capText);
                delete []confidenceLevel;
                break;
                
            }
            thisBox++;
        }
    }
    boxaDestroy(&boxaTemp);
    pixDestroy(&imgPix);
}

- (NSString*)getASCStringFromLine:(NSString*)line startPos:(NSInteger)nCursorPos breakOnCapital:(BOOL)breakOnCapital
{
    if ([line length]==0 || [line length] <= nCursorPos)
        return nil;
    
    NSInteger startPos; NSInteger endPos;
    for (startPos = nCursorPos; startPos >= 0; startPos--) {
        unichar ch = [line characterAtIndex:startPos];
        CHAR_TYPE chtype = [ReaderKitManager getCharType:ch];
        if (chtype != CHAR_TYPE_WESTEN && chtype != CHAR_TYPE_GUILLEMET)
        {
            break;
        }
        
        if (breakOnCapital && [ReaderKitManager isCapital:ch])
        {
            startPos--; //keep last Capital word
            break;
        }
    }
    startPos++;
    
    for (endPos = nCursorPos + 1; endPos <[line length]; endPos++) {
        int ch = [line characterAtIndex:endPos];
        CHAR_TYPE chtype = [ReaderKitManager getCharType:ch];
        if (chtype != CHAR_TYPE_WESTEN && chtype != CHAR_TYPE_GUILLEMET)
            break;
        if (breakOnCapital && [ReaderKitManager isCapital:ch])
        {
            break;
        }
    }
    nCursorPos = endPos + 1;
    
    if ((endPos > startPos)&&(endPos <= [line length])) {
        NSRange r  = NSMakeRange(startPos, endPos - startPos);
        return [line substringWithRange:r];
    }
    else
        return nil;
}

- (void)updateFocusLayer:(CGPoint)tapLocation
{
    if (![self.focusLayer isHidden] && CGRectContainsPoint(self.focusLayer.frame, tapLocation))
    {
        //减少不必要的update
        return;
    }
    [self.focusLayer setHidden:YES];
    
    CGPoint l_origin = CGPointMake(tapLocation.x - CAPTURE_WIDTH/2, tapLocation.y - CAPTURE_HEIGHT/2);
    
    UIImage *image = [self getImagewithTouchLocation:tapLocation];
    
    CGSize imageSize = [image size];
    int bytes_per_line  = (int)CGImageGetBytesPerRow([image CGImage]);
    int bytes_per_pixel = (int)CGImageGetBitsPerPixel([image CGImage]) / 8.0;
    
    CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider([image CGImage]));
    const UInt8 *imageData = CFDataGetBytePtr(data);

    ImageThresholder *it = new ImageThresholder();
    it->SetImage(imageData, imageSize.width, imageSize.height, bytes_per_pixel, bytes_per_line);
    PIX *imgPix = it->GetPixRectGrey();
    CFRelease(data);
    delete it;
    
    ReaderKitManager *shell = [ReaderKitManager sharedInstance];
    shell.tessOcr->SetImage(imgPix);
    Pixa *pixaTemp = NULL;
    Boxa *boxaTemp = NULL;
    boxaTemp = shell.tessOcr->GetWords(&pixaTemp);
    if (pixaTemp)  pixaDestroy(&pixaTemp);
    if (boxaTemp != NULL)
    {
        CGPoint centerPoint = CGPointMake(imgPix->w/2, imgPix->h /2);
        Box **thisBox = boxaTemp->box;
        for (int i = 0; i < boxaTemp->n; i++) {
            CGRect boxRect = CGRectMake((*thisBox)->x, (*thisBox)->y, (*thisBox)->w, (*thisBox)->h);
            if (CGRectContainsPoint(boxRect, centerPoint)){
                //draw rect
                CGRect finalRect = CGRectMake(l_origin.x + boxRect.origin.x / SCALE_FACTOR, l_origin.y + boxRect.origin.y/SCALE_FACTOR, boxRect.size.width/SCALE_FACTOR, boxRect.size.height/SCALE_FACTOR);
                
                [self.focusLayer setIsFound:YES];
                [CATransaction begin];
                [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
                [self.focusLayer setFrame:CGRectInset(finalRect, -3, -1)];
                [CATransaction commit];
                
                [self.focusLayer setHidden:NO];
                [self.focusLayer setNeedsDisplay];
                break;
            }
            thisBox++;
        }
    }
    boxaDestroy(&boxaTemp);
    pixDestroy(&imgPix);
}

@end
