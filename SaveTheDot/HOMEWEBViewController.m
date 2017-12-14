//
//  HOMEWEBViewController.m
//  aabxiu
//
//  Created by 改车吧 on 2017/10/18.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "HOMEWEBViewController.h"
#import <WebKit/WebKit.h>

@interface HOMEWEBViewController ()

@end

@implementation HOMEWEBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
}
- (void)setUrlStr:(NSString *)urlStr{
    _urlStr = urlStr;
    
    self.view.backgroundColor = [UIColor grayColor];
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]]];
    [self.view addSubview:webView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
