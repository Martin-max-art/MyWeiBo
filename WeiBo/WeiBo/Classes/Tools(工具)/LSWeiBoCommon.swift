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

//MARK:图片浏览的通知
/// 实例化照片浏览器
///
/// @param selectedIndex    选中照片索引
/// @param urls             浏览照片 URL 字符串数组
/// @param parentImageViews 父视图的图像视图数组，用户展现和解除转场动画参照

///微博cell浏览照片的通知
let LSStautsCellBrowserPhotoNotification = "LSStautsCellBrowserPhotoNotification"
///选中索引的key
let LSStatusCellBrowserPhotoSelectedIndexKey = "LSStatusCellBrowserPhotoSelectedIndexKey"
///浏览照片 URL字符串数组的key
let LSStatusCellBrowserPhotoURLsKey = "LSStatusCellBrowserPhotoURLsKey"
///父视图的图像视图数组的key
let LSStatusCellBrowserPhotoImageViewsKey = "LSStatusCellBrowserPhotoImageViewsKey"




//MARK:微博视图常量
//常数准备
//配图视图外侧的间距
let LSPictureOutMargin = CGFloat(12)
//配图视图内侧的间距
let LSPictureInMargin = CGFloat(3)
//视图的宽度
let LSPictureViewWidth = UIScreen.cz_screenWidth() - 2 * LSPictureOutMargin

//每个item的width
let LSPicWidth = (LSPictureViewWidth - 2 * LSPictureInMargin) / 3
