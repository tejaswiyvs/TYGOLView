//
//  TYConwayViewController.h
//  Playground
//
//  Created by Tejaswi on 7/22/13.
//  Copyright (c) 2013 Tejaswi Yerukalapudi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TYGOLMaskTypeNone,
    TYGOLMaskTypeClear,
    TYGOLMaskTypeBlack
} TYGOLMaskType;

#define GOLDeadCellColor        [UIColor whiteColor]
#define GOLDeadCellBorderColor  [UIColor whiteColor]
#define GOLLiveCellColor        [UIColor colorWithRed:(193.0f / 255.0f) \
                                                green:(207.0f / 255.0f) \
                                                 blue:(247.0f / 255.0f) \
                                                alpha:1.0f]

#define GOLLiveCellBorderColor  [UIColor colorWithRed:(183.0f / 255.0f) \
                                                green:(197.0f / 255.0f) \
                                                 blue:(237.0f / 255.0f) \
                                                alpha:1.0f]
@interface TYGOLView : UIView

- (id)initWithFrame:(CGRect)frame cellSize:(CGSize) size;

- (void)stopAnimating;
- (void)startAnimating;

@end
