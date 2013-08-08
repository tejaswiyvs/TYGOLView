//
//  TYConwayViewController.m
//  Playground
//
//  Created by Tejaswi on 7/22/13.
//  Copyright (c) 2013 Tejaswi Yerukalapudi. All rights reserved.
//

#import "TYGOLView.h"
#import <math.h>
#import <QuartzCore/QuartzCore.h>

#if ! __has_feature(objc_arc)
#error You need to either convert your project to ARC or add the -fobjc-arc compiler flag to TYGOLView.
#endif

@interface TYGOLView ()

@property (atomic) BOOL showing;
@property (nonatomic) CGSize cellSize;
@property (nonatomic) TYGOLPattern pattern;

@property (nonatomic, strong) NSMutableArray *currentIteration;
@property (nonatomic, strong) NSMutableArray *nextIteration;
@property (nonatomic, strong) NSMutableArray *views;

@end

@implementation TYGOLView

- (id)initWithFrame:(CGRect)frame cellSize:(CGSize) size pattern:(TYGOLPattern) pattern {
    self = [super initWithFrame:frame];
    if (self) {
        self.pattern = pattern;
        self.showing = NO;
        self.cellSize = size;
        
        // Configure some UIView properties
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingNone;
        self.hidden = YES;
        self.alpha = 0.0f;
        self.clipsToBounds = YES;
    }
    
    return self;
}

- (void)startAnimating {
    self.showing = YES;
    
    [UIView animateWithDuration:0.5f animations:^{
        self.hidden = NO;
        self.alpha = 1.0f;
     }
     completion:^(BOOL finished) {
         [self resetArrays];
         [self seedPattern];
         [self computeNextIteration];
     }
    ];
}

- (void)stopAnimating {
    self.showing = NO;
    
    [UIView animateWithDuration:0.5f animations:^{
        self.alpha = 0.0f;
        self.hidden = YES;
     }
    ];
}

#pragma mark - Game Impl.

- (void)computeNextIteration {
    [self updateViews];
    
    for (int i=0; i < [_currentIteration count]; i++) {
        NSMutableArray *array = [_currentIteration objectAtIndex:i];
        for (int j=0; j < [array count]; j++) {
            int n = [self elementAtIndex1:i index2:j];
            
            // Naive implementaion. Get 8 neighbors. Calculate and update next state.
            int sum = [self numberOfNeighborsForElementAtIndex1:i index2:j];
            
            if (sum < 2) {
                [self updateElementAtIndex1:i index2:j value:0];
            }
            else if (sum == 2) {
                [self updateElementAtIndex1:i index2:j value:n];
            }
            else if (sum == 3) {
                [self updateElementAtIndex1:i index2:j value:1];
            }
            else {
                [self updateElementAtIndex1:i index2:j value:0];
            }
        }
    }
    
    self.currentIteration = [self.nextIteration copy];
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(timerExpired:) userInfo:nil repeats:NO];
}

- (void)timerExpired:(id) timer {
    [self computeNextIteration];
}

#pragma mark - Helpers

- (int)numberOfNeighborsForElementAtIndex1:(int) i index2:(int) j {
    int n1 = [self elementAtIndex1:(i-1) index2:(j-1)];
    int n2 = [self elementAtIndex1:(i-1) index2:(j)];
    int n3 = [self elementAtIndex1:(i-1) index2:(j+1)];
    int n4 = [self elementAtIndex1:(i) index2:(j-1)];
    int n5 = [self elementAtIndex1:(i) index2:(j+1)];
    int n6 = [self elementAtIndex1:(i+1) index2:(j-1)];
    int n7 = [self elementAtIndex1:(i+1) index2:(j)];
    int n8 = [self elementAtIndex1:(i+1) index2:(j+1)];
    
    int sum = (n1 + n2 + n3 + n4 + n5 + n6 + n7 + n8);
    return sum;
}

- (int)elementAtIndex1:(int) idx1 index2:(int) idx2 {
    if (idx1 < 0) {
        idx1 = [self.currentIteration count] - abs(idx1);
    }
    if (idx1 > ([self.currentIteration count] - 1)) {
        idx1 = (idx1 - [self.currentIteration count]);
    }
    
    NSMutableArray *array = [self.currentIteration objectAtIndex:idx1];
    if (idx2 < 0) {
        idx2 = [array count] - abs(idx2);
    }
    if (idx2 > ([array count] - 1)) {
        idx2 = (idx2 - [array count]);
    }
    
    return [array[idx2] intValue];
}

- (void)updateElementAtIndex1:(int) idx1 index2:(int) idx2 value:(int) value {
    if (idx1 < 0) {
        idx1 = [self.nextIteration count] - abs(idx1);
    }
    if (idx1 > ([self.nextIteration count] - 1)) {
        idx1 = (idx1 - [self.nextIteration count]);
    }
    
    NSMutableArray *array = [self.nextIteration objectAtIndex:idx1];
    if (idx2 < 0) {
        idx2 = [array count] - abs(idx2);
    }
    if (idx2 > ([array count] - 1)) {
        idx2 = (idx2 - [array count]);
    }
    
    array[idx2] = @(value);
}

- (void)updateViews {
    for (int i = 0; i < [self.views count]; i++) {
        NSArray *array = [self.views objectAtIndex:i];
        for (int j = 0; j < [array count]; j++) {
            UIView *view = [array objectAtIndex:j];

            int element = [self elementAtIndex1:i index2:j];
            int sum = [self numberOfNeighborsForElementAtIndex1:i index2:j];
            if (element == 0) {
                [view setBackgroundColor:GOLDeadCellColor];
                [view.layer setBorderWidth:0.0f];
                [view.layer setBackgroundColor:[GOLDeadCellBorderColor CGColor]];
                view.alpha = 1.0f;
            }
            else if (element == 1 && sum == 2) {
                [view setBackgroundColor:GOLLiveCellColor1];
                [view.layer setBorderWidth:0.5f];
                [view.layer setBorderColor:[GOLLiveCellBorderColor1 CGColor]];
                view.alpha = 1.0f;
            }
            else if (element == 1 && sum == 3) {
                [view setBackgroundColor:GOLLiveCellColor2];
                [view.layer setBorderWidth:0.5f];
                [view.layer setBorderColor:[GOLLiveCellBorderColor2 CGColor]];
                view.alpha = 1.0f;
            }
        }
    }
}

- (void)seedPattern {
    [self resetArrays];
    
    switch (self.pattern) {
        case TYGOLPatternRandom:
            [self seedRandomPattern];
            break;
        case TYGOLPattern2:
            [self seedPattern2];
            break;
        case TYGOLPattern3:
            [self seedPattern3];
            break;
        default:
            [self seedRandomPattern];
            break;
    }
}

- (void)seedRandomPattern {
    for (int i = 0; i < [self.currentIteration count]; i++) {
        NSMutableArray *array = [self.currentIteration objectAtIndex:i];
        for (int j = 0; j < [array count]; j++) {
            int rand = abs(arc4random()) % 10;
            if (rand < 2) {
                array[j] = @(1);
            }
            else {
                array[j] = @(0);
            }
        }
    }
}

- (void)seedPattern2 {
    self.currentIteration[1][1] = @(1);
    self.currentIteration[1][2] = @(1);
    self.currentIteration[1][3] = @(1);
}

- (void)seedPattern3 {
}

- (void)resetArrays {
    int numRows = (self.frame.size.width / self.cellSize.width);
    int numCols = (self.frame.size.height / self.cellSize.height);
    
    // Init holder arrays
    self.currentIteration = [NSMutableArray arrayWithCapacity:numRows];
    self.nextIteration = [NSMutableArray arrayWithCapacity:numRows];
    self.views = [NSMutableArray arrayWithCapacity:numRows];
    
    for (int i = 0; i < numRows; i++) {
        self.currentIteration[i] = [NSMutableArray array];
        self.nextIteration[i] = [NSMutableArray array];
        self.views[i] = [NSMutableArray array];

        for (int j = 0; j < numCols; j++) {
            self.currentIteration[i][j] = @(0);
            self.nextIteration[i][j] = @(0);
            
            UIControl *view = [[UIControl alloc] initWithFrame:CGRectMake(i * self.cellSize.width, j * self.cellSize.height, self.cellSize.width, self.cellSize.height)];
            [view addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:view];
            
            self.views[i][j] = view;
        }
    }
}

@end
