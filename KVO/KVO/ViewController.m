//
//  ViewController.m
//  KVO
//
//  Created by Honey on 2019/5/7.
//  Copyright © 2019 Honey. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "Account.h"
#import "ManualObject.h"
#import "DependentKeys.h"
#import "DeepSearch.h"

static void *PersonAccountBalanceContext = &PersonAccountBalanceContext;
static void *PersonAccountInterestRateContext = &PersonAccountInterestRateContext;

@interface ViewController ()

@property (nonatomic, strong) Person *person;
@property (nonatomic, strong) Account *account;
@property (nonatomic, strong) ManualObject *manual;
@property (nonatomic, strong) DependentKeys *dependent;
@property (nonatomic, strong) DeepSearch *deep;

@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self basicUse];
//    [self contextTest];
//    [self manualTest];
//    [self dependentKeysTest];
    [self deepSearchTest];
}

/************************************************底层探究***********************************************************************/
- (void)deepSearchTest {
    DeepSearch *x = [[DeepSearch alloc] init];
    DeepSearch *y = [[DeepSearch alloc] init];
    DeepSearch *xy = [[DeepSearch alloc] init];
    DeepSearch *control = [[DeepSearch alloc] init];

    [x addObserver:x forKeyPath:@"x" options:0 context:NULL];
    [xy addObserver:xy forKeyPath:@"x" options:0 context:NULL];
    [y addObserver:y forKeyPath:@"y" options:0 context:NULL];
    [xy addObserver:xy forKeyPath:@"y" options:0 context:NULL];

    [DeepSearch PrintDescription:@"control" obj:control];
    [DeepSearch PrintDescription:@"x" obj:x];
    [DeepSearch PrintDescription:@"y" obj:y];
    [DeepSearch PrintDescription:@"xy" obj:xy];

    printf("Using NSObject methods, normal setX: is %p, overridden setX: is %p\n",
           [control methodForSelector:@selector(setX:)],
           [x methodForSelector:@selector(setX:)]);
    printf("Using libobjc functions, normal setX: is %p, overridden setX: is %p\n",
           method_getImplementation(class_getInstanceMethod(object_getClass(control),
                                                            @selector(setX:))),
           method_getImplementation(class_getInstanceMethod(object_getClass(x),
                                                            @selector(setX:))));
}

/************************************************键关联***********************************************************************/
- (void)dependentKeysTest {
    self.dependent = [[DependentKeys alloc] init];
    self.dependent.firstName = @"first";
    self.dependent.lastName = @"last";
    [self.dependent addObserver:self forKeyPath:@"fullName"options:NSKeyValueObservingOptionNew context:nil];
    [self.dependent addObserver:self forKeyPath:@"firstName"options:NSKeyValueObservingOptionNew context:nil];
    [self.dependent addObserver:self forKeyPath:@"lastName"options:NSKeyValueObservingOptionNew context:nil];
}

/***********************************************************************************************************************/

- (void)manualTest {
    self.manual = [[ManualObject alloc] init];
    self.manual.balance = 0.0;
    self.manual.transactions = [NSMutableArray arrayWithObjects:@"1", @"3", @"4", nil];
    [self.manual addObserver:self forKeyPath:@"balance"options:NSKeyValueObservingOptionNew context:nil];
    [self.manual addObserver:self forKeyPath:@"itemChanged"options:NSKeyValueObservingOptionNew context:nil];
    [self.manual addObserver:self forKeyPath:@"transactions"options:NSKeyValueObservingOptionNew context:nil];
}
// 上一个方法的dealloc
- (void)dealloc {
    if (self.manual != nil) {
        [self.manual removeObserver:self forKeyPath:@"balance" context:nil];
    }
}

/***********************************************************************************************************************/

//测试Context
- (void)contextTest {
    self.account = [[Account alloc] init];
    self.account.balance = 0.0;
    self.account.interestRate = 2.01;
    [self.account addObserver:self forKeyPath:@"balance" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:PersonAccountBalanceContext];
    [self.account addObserver:self forKeyPath:@"interestRate" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:PersonAccountInterestRateContext];
}
//// 上一个方法的dealloc
//- (void)dealloc {
//    if (self.account != nil) {
//        [self.account removeObserver:self forKeyPath:@"balance" context:nil];
//        [self.account removeObserver:self forKeyPath:@"interestRate" context:nil];
//    }
//}

/***********************************************************************************************************************/
//基本用法
- (void)basicUse {
    self.person = [[Person alloc] init];
    self.account = [[Account alloc] init];
    self.account.balance = 0.0;
    self.account.interestRate = 2.01;
    [self.account addObserver:self.person forKeyPath:@"balance" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
//    [self.account addObserver:self forKeyPath:@"balance" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}
// 上一个方法的dealloc
//- (void)dealloc {
//    if (self.account != nil) {
//        [self.account removeObserver:self.person forKeyPath:@"balance" context:nil];
//    }
//}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    self.array = [NSMutableArray array];
    self.account.balance = 1.0;
    self.manual.balance = 1.0;
//    [self.manual.transactions removeObjectAtIndex:0];
    [self.manual removeTransactionsAtIndexes:[NSIndexSet indexSetWithIndex:0]];
    self.dependent.lastName = @"aaaa";
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == PersonAccountBalanceContext) {
        NSLog(@"PersonAccountBalanceContext");
    } else if (context == PersonAccountInterestRateContext) {
        NSLog(@"PersonAccountInterestRateContext");
    } else if ([keyPath isEqualToString:@"balance"]){
        NSLog(@"ManualObject");
    } else if ([keyPath isEqualToString:@"itemChanged"]) {
        NSLog(@"balance更改的次数:%@", change);
    }  else if ([keyPath isEqualToString:@"transactions"]) {
        NSLog(@"transactions:%@--%@", change, self.manual.transactions);
    }  else if ([keyPath isEqualToString:@"fullName"])  {
        NSLog(@"fullname:%@--%@", change, self.dependent.fullName);
    }  else if ([keyPath isEqualToString:@"firstName"])  {
        NSLog(@"firstName:%@--%@", change, self.dependent.firstName);
    }  else if ([keyPath isEqualToString:@"lastName"])  {
        NSLog(@"lastName:%@--%@", change, self.dependent.lastName);
    } else {
        //因为没有对象处理这个消息会抛出一个NSInternalInconsistencyException异常
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}



@end
