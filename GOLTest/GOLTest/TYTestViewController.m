//
//  TYTestViewController.m
//  GOLTest
//
//  Created by Tejaswi on 8/8/13.
//  Copyright (c) 2013 Tejaswi Yerukalapudi. All rights reserved.
//

#import "TYTestViewController.h"
#import "TYGOLView.h"

@interface TYTestViewController ()

@end

@implementation TYTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TYGOLView *golView = [[TYGOLView alloc] initWithFrame:self.view.bounds
                                                 cellSize:CGSizeMake(15.0f, 15.0f)];
    [golView startAnimating];
    [self.view addSubview:golView];
}

@end
