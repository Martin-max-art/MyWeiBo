//
//  LSEmotiIconManager.swift
//  表情包
//
//  Created by lishaopeng on 17/12/13.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import UIKit
///表情管理器
class LSEmotiIconManager {
    //为了便于表情的复用，建立一个单例，只加载一次表情数据
    static let shared = LSEmotiIconManager()
    //表情包的懒加载数组 -- >第一个数组是最近表情，加载之后，表情数组为空
    lazy var packagesArray = [LSEmotiIconPackageModel]()
    //表情素材的bundle
    lazy var bundle: Bundle = {
        let path = Bundle.main.path(forResource: "Emoticon.bundle", ofType: nil)
        return Bundle(path: path!)!
    }()
    
    //构造函数,如果在init之前加fileprivate修饰符，可以要求调用者必须通过shared访问对象
    //OC中要重写allocWithZone方法
    fileprivate init() {
        loadPackages()
    }
    
    
    /// 添加最近使用的表情
    /// - Parameter em: 选中的表情
    func recentEmoticon(em: LSEmotiIconModel){
        //1.增加表情的使用次数
        em.times += 1
        //2.判断是否已经记录了该表情，如果没有记录，添加记录
        if !packagesArray[0].emoticonsArray.contains(em) {
            packagesArray[0].emoticonsArray.append(em)
        }
        //3.根据使用排序，使用次数高的排序靠前
        //对当前数组排序
//        packagesArray[0].emoticonsArray.sort { (em1, em2) -> Bool in
//            return em1.times > em2.times
//        }
        
        //在 swift中，如果闭包只有一个return，参数可以省略，参数名用 $0...替代
        packagesArray[0].emoticonsArray.sort { $0.times > $1.times}
        
        //4.判断表情数组是否超出20，如果超出，删除末尾的表情
        if packagesArray[0].emoticonsArray.count > 20{
            packagesArray[0].emoticonsArray.removeSubrange(20..<packagesArray[0].emoticonsArray.count)
        }
    }
    
    
}


//MARK:-表情字符串的处理
extension LSEmotiIconManager{
    /// 将给定的字符串转换成属性文本
    /// 关键点:要按照匹配结果倒序替换属性文本
    /// - Parameter string: 完整的字符串
    /// - Returns: 属性文本
    func emoticonString(string: String,font: UIFont) -> NSAttributedString{
        
        let attrString = NSMutableAttributedString(string: string)
        //1.建立正在表达式
        //[] ()都是正则表达式的关键字，如果需要参与匹配，需要转义
        let pattern = "\\[.*?\\]"
        guard let regx = try? NSRegularExpression(pattern: pattern, options: []) else {
            return attrString
        }
        //2.匹配所有项
        let matchs = regx.matches(in: string, options: [], range: NSRange(location: 0, length: attrString.length))
        
        //3.遍历所有匹配结果
        for m in matchs.reversed() {
            let r = m.rangeAt(0)
            //print(r.location)
            //print(r.length)
            let subStr = (attrString.string as NSString).substring(with: r)
            //1>使用subStr查找对应的表情符号
            if let em = LSEmotiIconManager.shared.findEmoticon(string: subStr){
               // print(em)
                //2>使用表情符号中的属性文本，替换原有的属性文本内容
                attrString.replaceCharacters(in: r, with: em.imageText(font: font))
            }
            
        }
        //4.统一设置一遍字符串的属性，除了设置字体，还需要设置颜色
        attrString.addAttributes([NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: UIColor.darkGray], range: NSRange(location: 0, length: attrString.length))
        return attrString
    }
}



//MARK:-表情符号处理
extension LSEmotiIconManager{
    
    
    /// 根据string [] 在所有的表情符号中找到对应的表情模型对象
    ///
    /// - 如果找到，返回表情模型
    /// - 否则返回nil
    func findEmoticon(string: String) -> LSEmotiIconModel?{
        //1.遍历表情包
        //OC中过滤数组用(谓词)
        for p in packagesArray {
            
            //方法一
//            //2.在表情数组中过滤string
//            let result =  p.emoticonsArray.filter({ (em) -> Bool in
//                return em.chs == string
//            })
            //方法二 ----尾随闭包
//            //2.在表情数组中过滤string
//            let result =  p.emoticonsArray.filter(){ (em) -> Bool in
//                return em.chs == string
//            }
            //方法三 ----如果闭包中只有一句话并且返回
            //1>闭包格式定义可以省略
            //2>参数省略之后，使用$0，$1...一次替代原有参数
            //3>return 也可以省略
            
            //2.在表情数组中过滤string
            let result =  p.emoticonsArray.filter(){
                return $0.chs == string
            }
            //3.判断结果数组的数量
            if result.count == 1 {
                return result[0]
            }
        }
        return nil
    }
   
    
}




//MARK: - 表情包处理
fileprivate extension LSEmotiIconManager{
    
    func loadPackages(){
        //调取emoticons.plist
        //只要按照Bundle默认的目录结构设定，就可以直接读取Resouces目录下的文件
        guard  let path = Bundle.main.path(forResource: "Emoticon.bundle", ofType: nil),
        let bundle = Bundle(path: path),
        let plistPath = bundle.path(forResource: "emoticons.plist", ofType: nil),
        let array = NSArray(contentsOfFile: plistPath) as? [[String: String]],
        let models = NSArray.yy_modelArray(with: LSEmotiIconPackageModel.self, json: array) as? [LSEmotiIconPackageModel]
        else{
            return
        }
        //设置表情包数据
        //使用 += 不会再次分配内存空间，直接追加数据
        packagesArray += models

    }
}
