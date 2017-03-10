//
//  NSImage+ReaderKitHook.m
//  ReaderKit
//
//  Created by cube on 2017/3/10.
//  Copyright © 2017年 cube. All rights reserved.
//

#import "ReaderContentPage+ReaderKitHook.h"
#import "ReaderKitHook.h"

@implementation ReaderContentPage (ReaderKitHook)
@dynamic focusLayer;
@dynamic pdfPage;
static char focusLayerKey;
- (EUPDFFocusLayer *)focusLayer
{
    return objc_getAssociatedObject(self, &focusLayerKey);
}

- (void)setFocusLayer:(EUPDFFocusLayer *)focusLayer
{
    objc_setAssociatedObject(self, &focusLayerKey, focusLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPDFPageRef)pdfPage
{
    
    Ivar ivar = class_getInstanceVariable([self class], "_PDFPageRef");
    return (__bridge CGPDFPageRef)(object_getIvar(self, ivar)); //无限制，返回值id类型
    
    
//    CGPDFPageRef page;
//    NSValue *extracted = [self valueForKey:@"_PDFPageRef"];
//    [extracted getValue:&page];
//    return page;
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
    
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"image.png"];
    //    [UIImagePNGRepresentation(image) writeToFile:path atomically:NO];
    
    CGSize imageSize = [image size];
    int bytes_per_line  = (int)CGImageGetBytesPerRow([image CGImage]);
    int bytes_per_pixel = (int)CGImageGetBitsPerPixel([image CGImage]) / 8.0;
    
    CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider([image CGImage]));
    const UInt8 *imageData = CFDataGetBytePtr(data);
    
//    ImageThresholder *it = new ImageThresholder();
//    it->SetImage(imageData, imageSize.width, imageSize.height, bytes_per_pixel, bytes_per_line);
//    PIX *imgPix = it->GetPixRectGrey();
//    CFRelease(data);
//    delete it;
//    // pixWrite([path EUUTF8String], imgPix, IFF_BMP);
//    EUAppShell *shell = [EUAppShell sharedShell];
//    shell.tessOcr->SetImage(imgPix);
//    Pixa *pixaTemp = NULL;
//    Boxa *boxaTemp = NULL;
//    boxaTemp = shell.tessOcr->GetWords(&pixaTemp);
//    if (pixaTemp)  pixaDestroy(&pixaTemp);
//    if (boxaTemp != NULL)
//    {
//        CGPoint centerPoint = CGPointMake(imgPix->w/2, imgPix->h /2);
//        Box **thisBox = boxaTemp->box;
//        for (int i = 0; i < boxaTemp->n; i++) {
//            CGRect boxRect = CGRectMake((*thisBox)->x, (*thisBox)->y, (*thisBox)->w, (*thisBox)->h);
//            if (CGRectContainsPoint(boxRect, centerPoint)){
//                //draw rect
//                CGRect finalRect = CGRectMake(l_origin.x + boxRect.origin.x / SCALE_FACTOR, l_origin.y + boxRect.origin.y/SCALE_FACTOR, boxRect.size.width/SCALE_FACTOR, boxRect.size.height/SCALE_FACTOR);
//                
//                [focusLayer setIsFound:YES];
//                [CATransaction begin];
//                [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
//                [focusLayer setFrame:CGRectInset(finalRect, -3, -1)];
//                [CATransaction commit];
//                
//                [focusLayer setHidden:NO];
//                [focusLayer setNeedsDisplay];
//                break;
//                
//            }
//            thisBox++;
//        }
//    }
//    boxaDestroy(&boxaTemp);
//    pixDestroy(&imgPix);
}

@end
