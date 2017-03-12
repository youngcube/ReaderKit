//
//  NSImage+ReaderKitHook.h
//  ReaderKit
//
//  Created by cube on 2017/3/10.
//  Copyright © 2017年 cube. All rights reserved.
//

#import <vfrReader/ReaderContentPage.h>
#import "EUPDFFocusLayer.h"
#import <TesseractOCR/TesseractOCR.h>

@interface ReaderContentPage (ReaderKitHook)<G8TesseractDelegate>
@property (nonatomic, weak) EUPDFFocusLayer *focusLayer;
@property (nonatomic) CGPDFPageRef pdfPage;

- (void)updateFocusLayer:(CGPoint)tapLocation;
- (void)doCapture;
@end
