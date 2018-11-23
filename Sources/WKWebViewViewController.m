//
//  WKWebViewViewController.m
//  XYLJProject
//
//  Created by lzhmac on 2016/12/9.
//  Copyright © 2016年 LZH. All rights reserved.
//

#import "WKWebViewViewController.h"
//要导入其框架
#import <WebKit/WKWebView.h>
#import <WebKit/WebKit.h>

@interface WKWebViewViewController ()<WKUIDelegate,WKNavigationDelegate,UIScrollViewDelegate,WKScriptMessageHandler,JTShareViewDelegate>
//创建一个实体变量

/**
 WKWebView 变量
 */
@property(nonatomic,strong) WKWebView * ZSJ_WkwebView;

@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic,strong) UIImage *image;

@end

@implementation WKWebViewViewController
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    if (self.isJSWithOC) {
        
        if (self.ActivityState == Activity_integral) {
            [self.navigationController setNavigationBarHidden:YES];
            
            
            //OC注册供JS调用的方法
            [[self.ZSJ_WkwebView configuration].userContentController addScriptMessageHandler:self name:@"Back"];
        }else{
            
            
            //OC注册供JS调用的方法
            [[self.ZSJ_WkwebView configuration].userContentController addScriptMessageHandler:self name:@"Share"];
            
        }
        
       
  
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    
    if (self.isJSWithOC) {
        if (self.ActivityState == Activity_integral) {
            [self.ZSJ_WkwebView.configuration.userContentController removeScriptMessageHandlerForName:@"Back"];
            [self.navigationController setNavigationBarHidden:NO];
        }else{
              [self.ZSJ_WkwebView.configuration.userContentController removeScriptMessageHandlerForName:@"Share"];
        }
    
  
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.ZSJ_WkwebView.hidden = YES;
    [JTProgressHUD show];
    self.ZSJ_WkwebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 64)];
    self.ZSJ_WkwebView.UIDelegate = self;
    self.ZSJ_WkwebView.contentScaleFactor = 1.0;
    
//    self.ZSJ_WkwebView.scrollView.scrollEnabled = false;
    self.ZSJ_WkwebView.scrollView.delegate = self;
    
    self.ZSJ_WkwebView.navigationDelegate = self;
    
    if (!self.html_str) {
//         2.创建请求
            NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
//         3.加载网页
            [self.ZSJ_WkwebView loadRequest:request];
    }else{
        // 3.加载网页
        [self.ZSJ_WkwebView loadHTMLString:self.html_str baseURL:[NSURL URLWithString:kMainUrlString_API]];
    }
    
    
  

    // 最后将webView添加到界面
    [self.view addSubview:self.ZSJ_WkwebView];
    [self.ZSJ_WkwebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];

    
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 0.5)];
    
    lineView.backgroundColor = kColorRGB(224, 224, 224);
    
    [self.view addSubview:lineView];
    //进度条初始化
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 2)];
    self.progressView.backgroundColor = [UIColor blueColor];
    //设置进度条的高度，下面这句代码表示进度条的宽度变为原来的1倍，高度变为原来的1.5倍.
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.view addSubview:self.progressView];
    

 
    WKWebView* webView = self.ZSJ_WkwebView ;
    
    NSString *jScript = @"var meta = document.createElement('meta'); \
    meta.name = 'viewport'; \
    meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; \
    var head = document.getElementsByTagName('head')[0];\
    head.appendChild(meta);";
    
        WKUserScript *wkUScript = [[NSClassFromString(@"WKUserScript") alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
        [webView.configuration.userContentController addUserScript:wkUScript];
    if (self.isJSWithOC) {
        
        if (self.ActivityState == Activity_integral) {
            if (KIsiPhoneX) {
                self.ZSJ_WkwebView.frame = CGRectMake(0, -50, self.view.frame.size.width, self.view.frame.size.height+50);
                
            }else{
                self.ZSJ_WkwebView.frame = CGRectMake(0, -30, self.view.frame.size.width, self.view.frame.size.height+30);
                
            }
        }else{
            //邀请活动
        }
        
      
        

        
    }
  
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{

    if ([message.name isEqualToString:@"Back"]) {
        [self.navigationController popViewControllerAnimated:YES];

    }
    if ([message.name isEqualToString:@"Share"]) {

        
        NSArray *imageArray = @[@"icon_wx1",@"icon_qq1",@"icon_pengyouquan"];
        NSArray *titleArray = @[@"微信",@"QQ",@"朋友圈"];
        
        JTShareView *publishView = [[JTShareView alloc]initWithFrame:[UIScreen mainScreen].bounds imageArray:imageArray titleArray:titleArray];
        
        
        publishView.delegate = self;
        
        [publishView show];

    }
    

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ---  UIWebViewDelegate

//这个是网页加载完成，导航的变化
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    /*
     主意：这个方法是当网页的内容全部显示（网页内的所有图片必须都正常显示）的时候调用（不是出现的时候就调用），，否则不显示，或则部分显示时这个方法就不调用。
     */
    NSLog(@"加载完成调用");
    // 获取加载网页的标题
    NSLog(@"加载的标题：%@",self.ZSJ_WkwebView.title);
    self.ZSJ_WkwebView.hidden = NO;
    [JTProgressHUD dissmiss];

    
//    //设置JS
//    NSString *inputValueJS = @"document.getElementsByName('back')[0].attributes['value'].value";
//    //执行JS
//    [self.ZSJ_WkwebView evaluateJavaScript:inputValueJS completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//        NSLog(@"value: %@ error: %@", response, error);
//    }];

}
//开始加载
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    //开始加载的时候，让加载进度条显示
    self.progressView.hidden = NO;
    NSLog(@"开始加载的时候调用。。");
    NSLog(@"%lf",   self.ZSJ_WkwebView.estimatedProgress);
    
}
//内容返回时调用
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"当内容返回的时候调用");
    NSLog(@"%lf",   self.ZSJ_WkwebView.estimatedProgress);
    [JTProgressHUD dissmiss];

}

-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"这是服务器请求跳转的时候调用");
}
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    // 内容加载失败时候调用
    NSLog(@"这是加载失败时候调用");
    [JTProgressHUD dissmiss];

    NSLog(@"%@",error);
}
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"通过导航跳转失败的时候调用");
}
-(void)webViewDidClose:(WKWebView *)webView{
    NSLog(@"网页关闭的时候调用");
}
-(void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    NSLog(@"%lf",   webView.estimatedProgress);
    
}
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    completionHandler();

    // 获取js 里面的提示
}
-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    // js 信息的交流
    
    completionHandler(YES);
    
}
-(void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    completionHandler(@"111");

    // 交互。可输入的文本。
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{


    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.ZSJ_WkwebView.estimatedProgress;
        NSLog(@"-=-=-=--=-=->>>>>>%lf",   self.ZSJ_WkwebView.estimatedProgress);

        if (self.progressView.progress == 1) {
            /*
             *添加一个简单的动画，将progressView的Height变为1.4倍，在开始加载网页的代理中会恢复为1.5倍
             *动画时长0.25s，延时0.3s后开始动画
             *动画结束后将progressView隐藏
             */
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.progressView.hidden = YES;
                
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }


}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
}




- (void)dealloc {
    
    if (self.isJSWithOC) {
        
        if (self.ActivityState == Activity_integral) {
            [self.navigationController setNavigationBarHidden:NO];

        }else{
            //邀请
        }
    }
    
    [self.ZSJ_WkwebView removeObserver:self forKeyPath:@"estimatedProgress"];

    [self clearWebCache];
}


- (void)clearWebCache {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        
        if (@available(iOS 9.0, *)) {
            NSSet *websiteDataTypes
            
            = [NSSet setWithArray:@[
                                    WKWebsiteDataTypeDiskCache,
                                    
                                    //WKWebsiteDataTypeOfflineWebApplicationCache,
                                    
                                    WKWebsiteDataTypeMemoryCache,
                                    
                                    //WKWebsiteDataTypeLocalStorage,
                                    
                                    //WKWebsiteDataTypeCookies,
                                    
                                    //WKWebsiteDataTypeSessionStorage,
                                    
                                    //WKWebsiteDataTypeIndexedDBDatabases,
                                    
                                    //WKWebsiteDataTypeWebSQLDatabases
                                    ]];
            
            //// All kinds of data
            
            //NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
            
            //// Date from
            
            NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
            
            //// Execute
            
            [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
                
                // Done
                
            }];
        } else {
            // Fallback on earlier versions
        }
    } else {
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        
        NSError *errors;
        
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)didSelecteBtnWithBtntag:(NSInteger)tag {
    

    
    NSString *shreUrl = [NSString stringWithFormat:@"%@phoneNumber=%@",SahreUrl_invite_URL,[JTUserInfoManager sharedInstance].personMsgModel.tel];
    
    NSString *title = @"找电工，上电电！推荐朋友注册，即可领取现金红包，赶快转发吧~";
    
    NSString *description = @"解决电力需求就上电电！推荐有奖，超大红包等你来抢，速速转发吧~";
    
    UIImage *img = [UIImage imageNamed:@"AppIcon"];
    
    
    
    
    switch (tag) {
        case 0:
        {
            
            [JTShareClass shareWithUrl:shreUrl title:title description:description img:img tag:2 viewController:self];
            
        }
            break;
        case 1:
        {
            [JTShareClass shareWithUrl:shreUrl title:title description:description img:img tag:1 viewController:self];
            
        }
            break;
        case 2:
        {
            [self screenView:self.ZSJ_WkwebView.scrollView];

            
            [JTShareClass shareImageToPlatformType:(UMSocialPlatformType_WechatTimeLine) img:self.image viewController:self title:@"" description:@""];
        }
            break;
            
        default:
            break;
    }
    
    //         2.创建请求
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    //         3.加载网页
    [self.ZSJ_WkwebView loadRequest:request];
    
}

- (void)JTShareRefresh{
    
    //         2.创建请求
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    //         3.加载网页
    [self.ZSJ_WkwebView loadRequest:request];
    
}




/// 截图
- (void)screenView:(UIScrollView *)view
{
    // 设置截图大小
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(kMainScreenWidth,view.frame.size.height), YES, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = viewImage.CGImage;
    UIImage *sendImage = [[UIImage alloc] initWithCGImage:imageRef];
    NSLog(@"sendImage==%@",sendImage);
    //保存图片到照片库 （iOS10 以上记得在info.plist添加相册访问权限，否则可能崩溃）
    self.image = sendImage;
    
    UIImageWriteToSavedPhotosAlbum(sendImage, nil, nil, nil);
    
    
    
}




@end
