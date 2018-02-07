//
//  LSStatusPictureModel.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/29.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import UIKit

class LSStatusPictureModel: NSObject {
   //缩略图地址
    var thumbnail_pic: String?{
        didSet{
            
            //设置中等尺寸图片
            largePic = thumbnail_pic?.replacingOccurrences(of: "/thumbnail/", with: "/large/")
            
            //更改缩略图地址
            thumbnail_pic = thumbnail_pic?.replacingOccurrences(of: "/thumbnail/", with: "/wap360/")
        }
    }
    
    //中等尺寸图片
    var largePic: String?
    
    override var description: String{
        return yy_modelDescription()
    }
}
