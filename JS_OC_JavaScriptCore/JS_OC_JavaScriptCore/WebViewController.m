//
//  WebViewController.m
//  JS_OC_JavaScriptCore
//
//  Created by Harvey on 16/8/4.
//  Copyright © 2016年 Haley. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
/*
 #import "JSContext.h" // JSContext是为JavaScript的执行提供运行环境，所有的JavaScript的执行都必须在JSContext环境中。JSContext也管理JSVirtualMachine中对象的生命周期。每一个JSValue对象都要强引用关联一个JSContext。当与某JSContext对象关联的所有JSValue释放后，JSContext也会被释放。
 
 #import "JSValue.h"// JSValue都是通过JSContext返回或者创建的，并且没有构造方法。JSValue包含了每一个JavaScript类型的值，通过JSValue可以将Objective-C中的类型转换为JavaScript中的类型，也可以将JavaScript中的类型转换为的Objective-C中的类型
 
 #import "JSManagedValue.h"// JSManagedValue主要用途是解决JSValue对象在Objective-C中堆放的安全引用问题。把JSValue保存进Objective-C对象中是不正确的，这很容易引发循环引用，而导致JSContext不能释放。
 #import "JSVirtualMachine.h"//JSVirtualMachine看名字直译是JS虚拟机，也就是说JavaScript是在一个虚拟的环境中执行，而JSVirtualMachine为其执行提供底层资源。
 #import "JSExport.h" // JSExport是一个协议类，但是该协议并没有任何属性和方法。
 
 */

#import "WebViewController.h"

@interface WebViewController ()<UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"UIWebView-JavaScriptCore";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.webView.delegate = self;
    NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"index.html" withExtension:nil];
//    NSURL *htmlURL = [NSURL URLWithString:@"http://www.baidu.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:htmlURL];
    
    self.webView.backgroundColor = [UIColor clearColor];
    // UIWebView 滚动的比较慢，这里设置为正常速度
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

#pragma mark - private method - html加载成功后，添加要调用的原生oc方法
- (void)addCustomActions
{
    // 1. html加载成功后
    // 2. 添加需要调用的原生oc方法
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    [context evaluateScript:@"var arr = [3, 4, 'abc'];"];
#pragma mark - JSContext的两种方法
    /*
     NSString *jsStr = [NSString stringWithFormat:@"payResult('%@')",@"支付成功"];
     //        [[JSContext currentContext] evaluateScript:jsStr];
     [[JSContext currentContext][@"payResult"] callWithArguments:@[@"支付成功"]];
     */
    [self addScanWithContext:context];
    
    [self addLocationWithContext:context];
    
    [self addSetBGColorWithContext:context];
    
    [self addShareWithContext:context];
    
    [self addPayActionWithContext:context];
    
    [self addShakeActionWithContext:context];
    
    [self addGoBackWithContext:context];
}

- (void)addScanWithContext:(JSContext *)context
{
    context[@"scan"] = ^() {
        NSLog(@"扫一扫啦");
    };
}

- (void)addLocationWithContext:(JSContext *)context
{
    context[@"getLocation"] = ^() {
        // 获取位置信息
        
        // 将结果返回给js
        NSString *jsStr = [NSString stringWithFormat:@"setLocation('%@')",@"广东省深圳市南山区学府路XXXX号"];
        [[JSContext currentContext] evaluateScript:jsStr];
    };
}

- (void)addShareWithContext:(JSContext *)context
{
    context[@"share"] = ^() {
        NSArray *args = [JSContext currentArguments]; //JSValue类型 通过JSContext 返回
        
        if (args.count < 3) {
            return ;
        }
        NSString *title = [args[0] toString];
        NSString *content = [args[1] toString];
        NSString *url = [args[2] toString];
        // 在这里执行分享的操作
        
        // 将分享结果返回给js
        NSString *jsStr = [NSString stringWithFormat:@"shareResult('%@','%@','%@')",title,content,url];
        [[JSContext currentContext] evaluateScript:jsStr];
    };
}

- (void)addSetBGColorWithContext:(JSContext *)context
{
    __weak typeof(self) weakSelf = self;
    context[@"setColor"] = ^() {
        NSArray *args = [JSContext currentArguments];
        
        if (args.count < 4) {
            return ;
        }
        
        CGFloat r = [[args[0] toNumber] floatValue];
        CGFloat g = [[args[1] toNumber] floatValue];
        CGFloat b = [[args[2] toNumber] floatValue];
        CGFloat a = [[args[3] toNumber] floatValue];
 
        weakSelf.view.backgroundColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
    };
}

- (void)addPayActionWithContext:(JSContext *)context
{
    context[@"payAction"] = ^() {
        NSArray *args = [JSContext currentArguments];
        
        if (args.count < 4) {
            return ;
        }
        
        NSString *orderNo = [args[0] toString];
        NSString *channel = [args[1] toString];
        long long amount = [[args[2] toNumber] longLongValue];
        NSString *subject = [args[3] toString];
        
        // 支付操作
        NSLog(@"orderNo:%@---channel:%@---amount:%lld---subject:%@",orderNo,channel,amount,subject);
        
        // 将支付结果返回给js
//        NSString *jsStr = [NSString stringWithFormat:@"payResult('%@')",@"支付成功"];
//        [[JSContext currentContext] evaluateScript:jsStr];
        [[JSContext currentContext][@"payResult"] callWithArguments:@[@"支付成功"]];
    };
}

- (void)addShakeActionWithContext:(JSContext *)context
{
    
    context[@"shake"] = ^() {
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    };
}

- (void)addGoBackWithContext:(JSContext *)context
{
    __weak typeof(self) weakSelf = self;
    context[@"goBack"] = ^() {
        [weakSelf.webView goBack];
    };
}


#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
    
    [self addCustomActions]; // html加载成功后，添加要调用的原生oc方法
}

@end
