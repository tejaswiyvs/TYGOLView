//
//  TYConwayViewController.h
//  Playground
//
//  Created by Tejaswi on 7/22/13.
//  Copyright (c) 2013 Tejaswi Yerukalapudi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TYGOLPatternRandom,
    TYGOLPattern2,
    TYGOLPattern3
} TYGOLPattern;

typedef enum {
    TYGOLMaskTypeNone,
    TYGOLMaskTypeClear,
    TYGOLMaskTypeBlack
} TYGOLMaskType;

@interface TYGOLView : UIView

- (id)initWithFrame:(CGRect)frame cellSize:(CGSize) size pattern:(TYGOLPattern) pattern;

- (void)stopAnimating;
- (void)startAnimating;

@end
