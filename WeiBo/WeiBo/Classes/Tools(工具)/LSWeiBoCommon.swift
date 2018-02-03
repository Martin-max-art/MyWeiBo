//
//  LSWeiBoCommon.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/19.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import Foundation

//MARK: - 全局通知定义


//https://api.weibo.com/oauth2/authorize?client_id=3348409467&redirect_uri=http://baidu.com
//应用程序ID
let AppKey = "3348409467"
//应用程序加密信息(开发者可以申请更改)
let AppSecret = "b98fc69d89cc272d9245eea53e112c1e"
//回调地址 登录完成跳转的URL
let AppRedirectURL = "http://www.baidu.com"

//用户需要登录通知
let LSUserHaveLoginNotification = "LSUserHaveLoginNotification"
//用户登录成功的通知
let LSUserLoginSuccessNotification = "LSUserLoginSuccessNotification"
