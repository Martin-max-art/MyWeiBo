//
//  LSUserAccount.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/20.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import UIKit

fileprivate let accounfFile: NSString = "useraccount.json"

//用户账户信息
class LSUserAccount: NSObject {
    //访问令牌
    var access_token: String?// = "2.00MoeccD_QabeDe862172222rlzW6E"
    //用户代号
    var uid: String?
    //开发者是5年  使用者是3天
    var expires_in: TimeInterval = 0{
        didSet{
            expiresDate = Date(timeIntervalSinceNow: expires_in)
        }
    }
    //过期日期
    var expiresDate: Date?
    
    //用户昵称
    var screen_name: String?
    
    //用户大图头像
    var avatar_large: String?
    
    
    override var description: String{
        
        return yy_modelDescription()
    }
    
   override init() {
        super.init()
        //1从磁盘加载保存的文件 -> 字典
    guard  let path = accounfFile.cz_appendCacheDir(),
           let data = NSData(contentsOfFile: path),
        let dict = try? JSONSerialization.jsonObject(with: data as Data, options: [])
        else {
        return
    }

       //2使用字典设置属性值
       yy_modelSet(with: dict as! [AnyHashable : Any])
       print("从沙盒加载用户信息\(self)")
    
       //3判断token是否过期    expiresDate<今天就是过期了  减一天
    
       //测试账号过期
       // expiresDate = Date(timeIntervalSinceNow: -3600 * 24)
    
        if expiresDate?.compare(Date()) != .orderedDescending {
            print("账户过期")
            //清空token
            access_token = nil
            uid = nil
            //删除账户文件
          _ =  try? FileManager.default.removeItem(atPath: path)
            
        }
          print("正常")
    }
    
    /*
     1.偏好设置(存小的)
     2.沙盒 -归档/plist/json
     3.数据库
     4.钥匙串(存小的 同时也会自动加密 -- 需要使用SSKeychain)
     */
    func saveAccount(){
        //1.模型转字典
        var dic = (self.yy_modelToJSONObject() as? [String: AnyObject]) ?? [:]
        //需要删除expires_in 值
        dic.removeValue(forKey: "expires_in")
        
        //2.字典序列化data
        guard let data = try? JSONSerialization.data(withJSONObject: dic, options: []),
              let fileName = accounfFile.cz_appendDocumentDir()
            else {
                
            return
        }
        
        //3.写入磁盘
        (data as NSData).write(toFile: fileName, atomically: true)
        print("用户保存成功\(fileName)")
    }
    
}
