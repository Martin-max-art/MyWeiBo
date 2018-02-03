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
    
    //重写description的计算型属性
    override var description: String{
        return yy_modelDescription()
    }
    
}
