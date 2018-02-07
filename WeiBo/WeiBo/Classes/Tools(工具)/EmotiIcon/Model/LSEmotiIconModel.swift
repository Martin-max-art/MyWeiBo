//
//  LSEmotiIconModel.swift
//  表情包
//
//  Created by lishaopeng on 17/1/10.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import UIKit
import YYModel

class LSEmotiIconModel: NSObject {
   //表情类型 false -图片表情 / true - emoji
    var type = false
    //表情字符串，发送给新浪微博的服务器(为了节约流量)
    var chs: String?
    //表情图片名称，用于本地图文混排
    var png: String?
    //emoji的十六进制编码
    var code: String?{
        didSet{
            guard let code = code else {
                return
            }
            let scanner = Scanner(string: code)
            var result: UInt32 = 0
            scanner.scanHexInt32(&result)
            emoji = String(Character(UnicodeScalar(result)!))
        }
    }
    //emoji的字符串
    var emoji:String?
    
    
    /**************自己加的属性*************/
    //表情使用次数
    var times:Int = 0
    
    //表情模型所在目录
    var directory: String?
    //图片/表情对应的图像------计算型属性
    var image: UIImage?{
        //判断表情类型
        if type{
            return nil
        }
        guard let directory = directory,
            let png = png,
            let path = Bundle.main.path(forResource: "Emoticon.bundle", ofType: nil),
            let bundle = Bundle(path: path),
            let image = UIImage(named: "\(directory)/\(png)", in: bundle, compatibleWith: nil)
        else { return nil }
        
        return image
        
    }
    
    
    //将当前的图像转换生成图片的属性文本
    func imageText(font: UIFont) -> NSAttributedString{
        //1.判断图像是否存在
        guard let image = image else {
            return NSAttributedString(string: "")
        }
        //2.创建文本附件
        let attachment = LSEmoticonAttachment()
        //记录属性文本文字
        attachment.chs = chs
        attachment.image = image
        let height = font.lineHeight
        attachment.bounds = CGRect(x: 0, y: -4, width: height, height: height)
        //3.返回图片属性文本
        let attrStrM = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        
        //设置字体属性
        attrStrM.addAttributes([NSFontAttributeName : font], range: NSRange(location: 0, length: 1))
        return attrStrM
    }
    
    
    override var description: String{
        return yy_modelDescription()
    }
}
