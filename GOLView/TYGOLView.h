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

#define GOLDeadCellColor        [UIColor whiteColor]
#define GOLDeadCellBorderColor  [UIColor whiteColor]

#define GOLLiveCellColor1       [UIColor colorWithRed:(228.0f / 255.0f) \
                                                green:(235.0f / 255.0f) \
                                                blue:(248.0f / 255.0f) \
                                                alpha:1.0f]

#define GOLLiveCellBorderColor1 [UIColor colorWithRed:(218.0f / 255.0f) \
                                                green:(225.0f / 255.0f) \
                                                 blue:(248.0f / 255.0f) \
                                                alpha:1.0f]

#define GOLLiveCellColor2       [UIColor colorWithRed:(218.0f / 255.0f) \
                                                green:(225.0f / 255.0f) \
                                                 blue:(248.0f / 255.0f) \
                                                alpha:1.0f]

#define GOLLiveCellBorderColor2 [UIColor colorWithRed:(208.0f / 255.0f) \
                                                green:(215.0f / 255.0f) \
                                                 blue:(248.0f / 255.0f) \
                                                alpha:1.0f]

@interface TYGOLView : UIView

- (id)initWithFrame:(CGRect)frame cellSize:(CGSize) size pattern:(TYGOLPattern) pattern;

- (void)stopAnimating;
- (void)startAnimating;

@end
