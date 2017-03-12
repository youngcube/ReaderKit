//
//  NSImage+ReaderKitHook.h
//  ReaderKit
//
//  Created by cube on 2017/3/10.
//  Copyright © 2017年 cube. All rights reserved.
//

#import <vfrReader/ReaderContentPage.h>
#import "REKPDFFocusLayer.h"
#import <TesseractOCR/TesseractOCR.h>

@interface ReaderContentPage (ReaderKit) <G8TesseractDelegate>
@property (nonatomic, weak) REKPDFFocusLayer *focusLayer;
@property (nonatomic) CGPDFPageRef pdfPage;

- (void)updateFocusLayer:(CGPoint)tapLocation;
- (void)doCapture;
@end
