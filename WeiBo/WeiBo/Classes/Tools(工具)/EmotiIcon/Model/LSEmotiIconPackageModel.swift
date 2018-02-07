//
//  LSEmotiIconPackageModel.swift
//  表情包
//
//  Created by lishaopeng on 17/1/10.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import UIKit
//表情包内容
class LSEmotiIconPackageModel: NSObject {

    //表情包的分组名
    var groupName: String?
    //背景图片名称
    var bgImageName: String?
    //表情包目录，从目录下加载info.plist可以创建表情模型数组
    var directory: String?{
        didSet{
            //当设置目录时，从目录下加载info.plist可以创建模型数组
            guard let directory = directory,
                  let path = Bundle.main.path(forResource: "Emoticon.bundle", ofType: nil),
                  let bundle = Bundle(path: path),
                  let infoPath = bundle.path(forResource: "info.plist", ofType: nil, inDirectory: directory),
                  let array = NSArray(contentsOfFile: infoPath),
                  let models = NSArray.yy_modelArray(with: LSEmotiIconModel.self, json: array) as? [LSEmotiIconModel]
            else { return }
            
            
            //遍历models数组，设置每一个表情符号的吗目录
            for m in models {
                m.directory = directory
            }
            //设置表情模型数组
            emoticonsArray += models
            //print(emoticonsArray)
        }
        
    }
    
    //懒加载的表情模型的空数组
    //使用懒加载可以避免后续的解包
    lazy var emoticonsArray = [LSEmotiIconModel]()
    //表情页面数量
    var numberOfPages: Int {
        return (emoticonsArray.count - 1) / 20 + 1
    }
    //从懒加载的表情包中，按照page截取最多 20 个表情模拟的数组
    //例如有26个模型
    //例如 page == 0 返回0--19个模型
    //例如 page == 1 返回20--25个模型
    func emoticon(page: Int) -> [LSEmotiIconModel]{
        
        //每页的数量
        let count = 20
        let location = page * count
        var length = count
        
        //判断数组是否相等
        if location + length > emoticonsArray.count {
            length = emoticonsArray.count - location
        }
        let range = NSRange(location: location, length: length)
        
        //截取数组的子数组
        let subArray = (emoticonsArray as NSArray).subarray(with: range)
        
        return subArray as! [LSEmotiIconModel]
    }
    
    
    override var description: String{
       return yy_modelDescription()
    }
}
