//
//  ViewController.m
//  ResponderChain
//
//  Created by Honey on 2019/4/25.
//  Copyright © 2019 Honey. All rights reserved.
//

#import "ViewController.h"
#import "ViewD.h"
#import "CustomButton.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet ViewD *viewD;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.viewD addGestureRecognizer:tap];
}


- (void)tapGesture:(UITapGestureRecognizer *)tap {
    NSLog(@"ViewD-- tapGesture");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"ViewController-- touchesBegan");
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"ViewController-- touchesEnded");
}

- (IBAction)customButtonDidClick:(CustomButton *)sender {
    NSLog(@"CustomButton");
}



@end
