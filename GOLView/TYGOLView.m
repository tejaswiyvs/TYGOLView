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

@interface TYGOLModel : NSObject<NSCopying>

@property (nonatomic) BOOL status;
@property (nonatomic) int neighborCount;
@property (nonatomic) int i;
@property (nonatomic) int j;

+ (TYGOLModel *)onModel;
+ (TYGOLModel *)offModel;

@end

@implementation TYGOLModel

+ (TYGOLModel *)onModel {
    TYGOLModel *model = [[TYGOLModel alloc] init];
    model.status = YES;
    model.neighborCount = 0;
    return model;
}

+ (TYGOLModel *)offModel {
    TYGOLModel *model = [[TYGOLModel alloc] init];
    model.status = NO;
    model.neighborCount = 0;
    return model;
}

- (id)copyWithZone:(NSZone *)zone {
    TYGOLModel *model = [[TYGOLModel alloc] init];
    model.status = self.status;
    model.neighborCount = self.neighborCount;
    model.i = self.i;
    model.j = self.j;
    return model;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"i = %d, j = %d, neighborCount = %d, status = %d", self.i, self.j, self.neighborCount, self.status];
}

@end

@interface TYGOLView ()

@property (nonatomic) CGSize cellSize;

@property (nonatomic, strong) NSMutableArray *currentIteration;
@property (nonatomic, strong) NSMutableArray *nextIteration;
@property (nonatomic, strong) NSMutableArray *updatedElementList;
@property (nonatomic, strong) NSMutableArray *views;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UILabel *benchmarksLbl;
@property (nonatomic) float avgTimePerIteration;
@property (nonatomic) int numberOfIterations;
@property (nonatomic) int totalCells;

@end

@implementation TYGOLView

- (id)initWithFrame:(CGRect)frame cellSize:(CGSize) size {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = YES;
        self.cellSize = size;
        self.updatedElementList = [NSMutableArray array];
        
        // Configure some UIView properties
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingNone;
        self.hidden = YES;
        self.alpha = 0.0f;
        self.clipsToBounds = YES;
        
        self.avgTimePerIteration = 0;
    }
    
    return self;
}

- (void)startAnimating {
    [UIView animateWithDuration:0.5f animations:^{
        self.hidden = NO;
        self.alpha = 1.0f;
     }
     completion:^(BOOL finished) {
         [self resetArrays];
         [self seedPattern];
         
         // Some benchmarking stuff.
         self.totalCells = [((NSArray *)[self.currentIteration objectAtIndex:0]) count] * [self.currentIteration count];
         self.numberOfIterations = 0;
         
#if DEBUG == 1
         // Sloppy ?
         self.benchmarksLbl = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 5.0f, self.frame.size.width, 10.0f)];
         [self.benchmarksLbl setHidden:NO];
         [self.benchmarksLbl setBackgroundColor:[UIColor clearColor]];
         [self.benchmarksLbl setTextColor:[UIColor blackColor]];
         [self.benchmarksLbl setFont:[UIFont boldSystemFontOfSize:10.0f]];
         [self addSubview:self.benchmarksLbl];
#endif
         
         [self startTimer];
         [self computeNextIteration];
     }
    ];
}

- (void)stopAnimating {
    [UIView animateWithDuration:0.5f animations:^{
        self.alpha = 0.0f;
        self.hidden = YES;
        [self.timer invalidate];
        self.timer = nil;
     }
    ];
}

- (void)dealloc {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        self.currentIteration = nil;
        self.nextIteration = nil;
        self.updatedElementList = nil;
        self.views = nil;
    }
}

#pragma mark - Game Impl.

- (void)startTimer {
    // Not sure if this is the best way to do this.
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(timerExpired:) userInfo:nil repeats:YES];
}

- (void)computeNextIteration {
#if DEBUG == 1
    self.numberOfIterations++;
    long startTime = [NSDate timeIntervalSinceReferenceDate];
#endif
    
    NSMutableArray *tempArr = [NSMutableArray array];
    NSMutableDictionary *lookupDict = [NSMutableDictionary dictionary];
    
    // Loop only through all the indices we need to check & not the entire array.
    // This way, instead of evaluating an n^2 elements, we just evaluate n^2 / 10 elements.
    for (NSArray *idxArr in self.updatedElementList) {
        TYGOLModel *model = [self elementAtIndex1:[idxArr[0] intValue] index2:[idxArr[1] intValue]];
        
        // If it's currently on, and is about to go off
        if (model.status && model.neighborCount < 2) {
            [self updateElementAtIndex1:model.i index2:model.j value:0];
            [self updateViewAtIndex:model.i index2:model.j value:0];
            [self decrementNeighborCountForIndex1:model.i index2:model.j];
            
            [lookupDict setValuesForKeysWithDictionary:[self neighborsForElementAtIndex1:model.i index2:model.j]];
        }
        
//        Have to do nothing here since the cell is off, and it's staying off.
//
//        else if (model.neighborCount < 2 && !model.status) {
//            
//        }
//
//        Cell is currently on, and has two neighbors, so it should stay on.
//        or, Cell's off and has two neighbors, so should stay off.
//        Basically, do nothing
//
//        else if (model.neighborCount == 2 && model.status) {
//        }
        
        else if (model.neighborCount == 3 && !model.status) {
            [self updateElementAtIndex1:model.i index2:model.j value:1];
            [self updateViewAtIndex:model.i index2:model.j value:1];
            [self incrementNeighborCountForIndex1:model.i index2:model.j];
            
            [lookupDict setValuesForKeysWithDictionary:[self neighborsForElementAtIndex1:model.i index2:model.j]];
        }
        else if (model.neighborCount > 3 && model.status) {
            [self updateElementAtIndex1:model.i index2:model.j value:0];
            [self updateViewAtIndex:model.i index2:model.j value:0];
            [self decrementNeighborCountForIndex1:model.i index2:model.j];
            
            [lookupDict setValuesForKeysWithDictionary:[self neighborsForElementAtIndex1:model.i index2:model.j]];
        }
    }
    
    for (NSString *key in [lookupDict allKeys]) {
        NSArray *elements = [key componentsSeparatedByString:@"-"];
        [tempArr addObject:@[elements[0], elements[1]]];
    }
    
    self.updatedElementList = tempArr;
    
    // Leaving this here because calling `copy` does not perform a true deep copy.
    // This causes the pointers in currentIteration and the nextIteration to point to the same
    // memory addresses. And updating one will inadvertently update the other.
//    self.currentIteration = [self.nextIteration copy];
    
    // Performing deep copy manually
    [self copyNextIterationToCurrentIteration];
    
#if DEBUG == 1
    long endTime = [NSDate timeIntervalSinceReferenceDate];
    long iterationTime = (endTime - startTime);
    int numberOfCellsAlive = [self.updatedElementList count];
    self.avgTimePerIteration = ((self.numberOfIterations - 1) * self.avgTimePerIteration + iterationTime) / self.numberOfIterations;
    
    NSString *lblTxt = [NSString stringWithFormat:@"Iteration: %d - Cells Alive: %d - Avg Iteration Time: %f", self.numberOfIterations, numberOfCellsAlive, self.avgTimePerIteration];
    [self.benchmarksLbl setText:lblTxt];
#endif    
}

- (void)timerExpired:(NSTimer *) timer {
    [self computeNextIteration];
}

#pragma mark - Helpers

- (void)copyNextIterationToCurrentIteration {
    for (int i = 0; i < self.currentIteration.count; i++) {
        NSMutableArray *array = self.currentIteration[i];
        for (int j = 0; j < [array count]; j++) {
            TYGOLModel *model = self.nextIteration[i][j];
            self.currentIteration[i][j] = [model copy];
        }
    }
}

- (void)copyCurrentIterationToNextIteration {
    for (int i = 0; i < self.currentIteration.count; i++) {
        NSMutableArray *array = self.currentIteration[i];
        for (int j = 0; j < [array count]; j++) {
            TYGOLModel *model = self.currentIteration[i][j];
            self.nextIteration[i][j] = [model copy];
        }
    }
}

- (NSDictionary *)neighborsForElementAtIndex1:(int) i index2:(int) j {
    NSString *str1 = [[self normalizeIndex1:(i-1) index2:(j-1)] componentsJoinedByString:@"-"];
    NSString *str2 = [[self normalizeIndex1:(i-1) index2:(j)] componentsJoinedByString:@"-"];
    NSString *str3 = [[self normalizeIndex1:(i-1) index2:(j+1)] componentsJoinedByString:@"-"];
    NSString *str4 = [[self normalizeIndex1:(i) index2:(j-1)] componentsJoinedByString:@"-"];
    NSString *str5 = [[self normalizeIndex1:(i) index2:(j)] componentsJoinedByString:@"-"];
    NSString *str6 = [[self normalizeIndex1:(i) index2:(j+1)] componentsJoinedByString:@"-"];
    NSString *str7 = [[self normalizeIndex1:(i+1) index2:(j-1)] componentsJoinedByString:@"-"];
    NSString *str8 = [[self normalizeIndex1:(i+1) index2:(j)] componentsJoinedByString:@"-"];
    NSString *str9 = [[self normalizeIndex1:(i+1) index2:(j+1)] componentsJoinedByString:@"-"];
    
    return @{ str1 : @(YES), str2 : @(YES), str3 : @(YES), str4 : @(YES), str5 : @(YES), str6 : @(YES), str7 : @(YES), str8 : @(YES), str9 : @(YES) };
}

- (void)incrementNeighborCountForIndex1:(int) i index2:(int) j {
    ((TYGOLModel *) [self nextIterationElementAtIndex1:(i-1) index2:(j-1)]).neighborCount++;
    ((TYGOLModel *) [self nextIterationElementAtIndex1:(i-1) index2:(j)]).neighborCount++;
    ((TYGOLModel *) [self nextIterationElementAtIndex1:(i-1) index2:(j+1)]).neighborCount++;
    ((TYGOLModel *) [self nextIterationElementAtIndex1:(i) index2:(j-1)]).neighborCount++;
    ((TYGOLModel *) [self nextIterationElementAtIndex1:(i) index2:(j+1)]).neighborCount++;
    ((TYGOLModel *) [self nextIterationElementAtIndex1:(i+1) index2:(j-1)]).neighborCount++;
    ((TYGOLModel *) [self nextIterationElementAtIndex1:(i+1) index2:(j)]).neighborCount++;
    ((TYGOLModel *) [self nextIterationElementAtIndex1:(i+1) index2:(j+1)]).neighborCount++;
}

- (void)decrementNeighborCountForIndex1:(int) i index2:(int) j {
    ((TYGOLModel *) [self nextIterationElementAtIndex1:(i-1) index2:(j-1)]).neighborCount--;
    ((TYGOLModel *) [self nextIterationElementAtIndex1:(i-1) index2:(j)]).neighborCount--;
    ((TYGOLModel *) [self nextIterationElementAtIndex1:(i-1) index2:(j+1)]).neighborCount--;
    ((TYGOLModel *) [self nextIterationElementAtIndex1:(i) index2:(j-1)]).neighborCount--;
    ((TYGOLModel *) [self nextIterationElementAtIndex1:(i) index2:(j+1)]).neighborCount--;
    ((TYGOLModel *) [self nextIterationElementAtIndex1:(i+1) index2:(j-1)]).neighborCount--;
    ((TYGOLModel *) [self nextIterationElementAtIndex1:(i+1) index2:(j)]).neighborCount--;
    ((TYGOLModel *) [self nextIterationElementAtIndex1:(i+1) index2:(j+1)]).neighborCount--;
}

- (void)computeInitialNeighborCounts {
    for (int i=0; i < [_currentIteration count]; i++) {
        NSMutableArray *array = [_currentIteration objectAtIndex:i];
        for (int j=0; j < [array count]; j++) {
            
            int n1 = ((TYGOLModel *) [self elementAtIndex1:(i-1) index2:(j-1)]).status;
            int n2 = ((TYGOLModel *) [self elementAtIndex1:(i-1) index2:(j)]).status;
            int n3 = ((TYGOLModel *) [self elementAtIndex1:(i-1) index2:(j+1)]).status;
            int n4 = ((TYGOLModel *) [self elementAtIndex1:(i) index2:(j-1)]).status;
            int n5 = ((TYGOLModel *) [self elementAtIndex1:(i) index2:(j+1)]).status;
            int n6 = ((TYGOLModel *) [self elementAtIndex1:(i+1) index2:(j-1)]).status;
            int n7 = ((TYGOLModel *) [self elementAtIndex1:(i+1) index2:(j)]).status;
            int n8 = ((TYGOLModel *) [self elementAtIndex1:(i+1) index2:(j+1)]).status;
            
            ((TYGOLModel *) [self elementAtIndex1:i index2:j]).neighborCount = (n1 + n2 + n3 + n4 + n5 + n6 + n7 + n8);
        }
    }
}

- (TYGOLModel *)elementAtIndex1:(int) idx1 index2:(int) idx2 {
    // If idx > array.length / idx < 0 loop back around
    NSArray *idxArr = [self normalizeIndex1:idx1 index2:idx2];
    idx1 = [idxArr[0] intValue];
    idx2 = [idxArr[1] intValue];
    NSMutableArray *array = [self.currentIteration objectAtIndex:idx1];
    return array[idx2];
}

- (TYGOLModel *)nextIterationElementAtIndex1:(int) idx1 index2:(int) idx2 {
    // If idx > array.length / idx < 0 loop back around
    NSArray *idxArr = [self normalizeIndex1:idx1 index2:idx2];
    idx1 = [idxArr[0] intValue];
    idx2 = [idxArr[1] intValue];
    NSMutableArray *array = [self.nextIteration objectAtIndex:idx1];
    return array[idx2];
}

- (void)updateElementAtIndex1:(int) idx1 index2:(int) idx2 value:(int) value {
    // If idx > array.length / idx < 0 loop back around
    NSArray *idxArr = [self normalizeIndex1:idx1 index2:idx2];
    idx1 = [idxArr[0] intValue];
    idx2 = [idxArr[1] intValue];
    
    NSMutableArray *array = [self.nextIteration objectAtIndex:idx1];
    if (value) {
        ((TYGOLModel *) array[idx2]).status = YES;
    }
    else {
        ((TYGOLModel *) array[idx2]).status = NO;
    }
}

- (void)updateViewAtIndex:(int) idx1 index2:(int) idx2 value:(int) value {
    // If idx > array.length / idx < 0 loop back around
    NSArray *idxArr = [self normalizeIndex1:idx1 index2:idx2];
    idx1 = [idxArr[0] intValue];
    idx2 = [idxArr[1] intValue];
    
    UIView *view = self.views[idx1][idx2];
    
    if (value == 0) {
        [view setBackgroundColor:GOLDeadCellColor];
        [view.layer setBorderWidth:0.0f];
        [view.layer setBackgroundColor:[GOLDeadCellBorderColor CGColor]];
    }
    if (value == 1) {
        [view setBackgroundColor:GOLLiveCellColor];
        [view.layer setBorderWidth:0.5f];
        [view.layer setBorderColor:[GOLLiveCellBorderColor CGColor]];
    }

}

- (void)seedPattern {
    [self resetArrays];
    
    [self seedRandomPattern];
    
    // Populate initial values. once the computation begins, views are only updated
    // when a cell status changes.
    self.updatedElementList = [NSMutableArray array];
    
    for (int i = 0; i < [self.currentIteration count]; i++) {
        NSMutableArray *array = self.currentIteration[i];
        for (int j = 0; j < [array count]; j++) {
            TYGOLModel *model = array[j];
            [self updateViewAtIndex:i index2:j value:model.status];
            [self.updatedElementList addObject:@[ @(model.i), @(model.j)]];
        }
    }
    
    [self computeInitialNeighborCounts];
    [self copyCurrentIterationToNextIteration];
}

- (void)seedRandomPattern {
    for (int i = 0; i < [self.currentIteration count]; i++) {
        NSMutableArray *array = [self.currentIteration objectAtIndex:i];
        for (int j = 0; j < [array count]; j++) {
            int rand = abs(arc4random()) % 10;
            if (rand < 2) {
                TYGOLModel *model = [TYGOLModel onModel];
                model.i = i;
                model.j = j;
                array[j] = model;
            }
            else {
                TYGOLModel *model = [TYGOLModel offModel];
                model.i = i;
                model.j = j;
                array[j] = model;
            }
        }
    }
    
//    TYGOLModel *model1 = [TYGOLModel onModel];
//    model1.i = 2;
//    model1.j = 2;
//    
//    TYGOLModel *model2 = [TYGOLModel onModel];
//    model2.i = 2;
//    model2.j = 3;
//    
//    TYGOLModel *model3 = [TYGOLModel onModel];
//    model3.i = 2;
//    model3.j = 4;
//    
//    self.currentIteration[2][2] = model1;
//    self.currentIteration[2][3] = model2;
//    self.currentIteration[2][4] = model3;
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
            TYGOLModel *offModel = [TYGOLModel offModel];
            offModel.i = i;
            offModel.j = j;
            self.currentIteration[i][j] = offModel;
            
            TYGOLModel *onModel = [TYGOLModel onModel];
            onModel.i = i;
            onModel.j = j;
            self.nextIteration[i][j] = onModel;
            
            UIControl *view = [[UIControl alloc] initWithFrame:CGRectMake(i * self.cellSize.width, j * self.cellSize.height, self.cellSize.width, self.cellSize.height)];
            view.opaque = NO;
            [view addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:view];
            
            self.views[i][j] = view;
        }
    }
}

- (void)logCurrentIteration {
    for (int i = 0; i < [self.currentIteration count]; i++) {
        NSArray *array = [self.currentIteration objectAtIndex:i];
        for (int j = 0; j < array.count; j++) {
            printf("%d ", ((TYGOLModel *) array[j]).status);
        }
        printf("\n");
    }
}

- (void)logNeighborCount {
    for (int i = 0; i < [self.currentIteration count]; i++) {
        NSArray *array = [self.currentIteration objectAtIndex:i];
        for (int j = 0; j < array.count; j++) {
            printf("%d ", ((TYGOLModel *) array[j]).neighborCount);
        }
        printf("\n");
    }
}

- (void)logNextIteration {
    for (int i = 0; i < [self.nextIteration count]; i++) {
        NSArray *array = [self.nextIteration objectAtIndex:i];
        for (int j = 0; j < array.count; j++) {
            printf("%d ", ((TYGOLModel *) array[j]).status);
        }
        printf("\n");
    }
}

- (void)logNextIterationNeighborCount {
    for (int i = 0; i < [self.nextIteration count]; i++) {
        NSArray *array = [self.nextIteration objectAtIndex:i];
        for (int j = 0; j < array.count; j++) {
            printf("%d ", ((TYGOLModel *) array[j]).neighborCount);
        }
        printf("\n");
    }
}

- (NSArray *)normalizeIndex1:(int) idx1 index2:(int) idx2 {
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

    return @[@(idx1), @(idx2)];
}


@end
