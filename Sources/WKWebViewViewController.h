//
//  WKWebViewViewController.h
//  XYLJProject
//
//  Created by lzhmac on 2016/12/9.
//  Copyright © 2016年 LZH. All rights reserved.
//  网页控制器

#import <UIKit/UIKit.h>

typedef enum _ActivityState {
    Activity_integral  = 0,
    Activity_invite
} ActivityState;


@interface WKWebViewViewController : UIViewController

/**
 html 字符串
 */
@property (strong, nonatomic) NSString *html_str;

/**
 url 字符串
 */
@property (strong, nonatomic) NSString *url;

@property (nonatomic,assign) BOOL isJSWithOC;

@property (nonatomic,assign) ActivityState ActivityState;


@end
