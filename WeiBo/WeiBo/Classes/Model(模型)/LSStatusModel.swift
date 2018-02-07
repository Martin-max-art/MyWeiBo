//
//  LSStatusModel.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/15.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import UIKit
import YYModel
//数据模型
class LSStatusModel: NSObject {
    //微博ID
    var id: Int64 = 0
    //微博信息内容
    var text: String?
    //转发数
    var reports_count: Int = 0
    //评论数
    var comments_count: Int = 0
    //点赞数
    var attitudes_count: Int = 0
    //微博创建日期
    var createdDate: Date?
    //微博创建时间
    var created_at: String?{
        didSet{
            createdDate = Date.ls_sinaDate(string: created_at ?? "")
        }
    }
    //微博来源 -发布微博使用的客户端
    var source: String?{
        //在didSet中给source再次设置值，不会调用didSet
        didSet{
            source = "来自" + (source?.ls_href()?.text ?? "")
        }
    }
    
    //微博用户- 注意和服务器返回的KEY要一致
    var user: LSUserModel?
    //提示：所有的第三方框架几乎都是如此
    //微博配图模型数组 YYModel字典转模型时，如果发现一个数组的属性 就会尝试调用类方法  如果实现 YYModel就尝试使用类来实例化数组中的对象
    var pic_urls: [LSStatusPictureModel]?
    //被转发的原始微博
    var retweeted_status: LSStatusModel?
    
    
    
    
    
    //重写description的计算型属性
    override var description: String{
        return yy_modelDescription()
    }
    
    
    ///类函数 -> 告诉第三方框架 YY_Model 如果遇到数组类型的属性，数组中存放的对象是什么类?
    //NSArray 中保存对象的类型通常是 id 类型
    //OC中的泛型是Swift推出后，苹果为了兼容给OC增加的，从运行时角度仍然不知道数组中应该存放什么类型的对象
    class func modelContainerPropertyGenericClass() -> [String: AnyClass]{
        return ["pic_urls": LSStatusPictureModel.self]
    }
}
