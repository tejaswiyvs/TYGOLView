//
//  TYTestViewController.m
//  GOLTestApp
//
//  Created by Tejaswi on 8/8/13.
//  Copyright (c) 2013 Tejaswi Yerukalapudi. All rights reserved.
//

#import "TYTestViewController.h"
#import "TYGOLView.h"

@interface TYTestViewController ()

@end

@implementation TYTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    TYGOLView *view = [[TYGOLView alloc] initWithFrame:self.view.bounds
                                        cellSize:CGSizeMake(10.0f, 10.0f)
                                         pattern:TYGOLPatternRandom];
    [view startAnimating];
    [self.view addSubview:view];
}

@end
