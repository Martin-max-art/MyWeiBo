//
//  LSNetworkManager.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/15.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD

//Swift的枚举支持任意数据类型
//switch/enum 在OC中只支持整数
/**
 ---*如果日常开发中，发现网络请求返回的状态码是405，不支持的网络请求方法
 ---首先应该查找网络请求方法是否正确 
 */
enum LSHTTPMethod{
    case GET
    case POST
}
//网络管理工具
class LSNetworkManager: AFHTTPSessionManager {
    //静态区 且是常量
    //闭包第一种写法
//    static let shared = { () ->LSNetworkManager in
//       //实例化对象
//        let instance = LSNetworkManager()
//        
//        return instance
//    }()
    
    //闭包第二种写法
    static let shared: LSNetworkManager = {
        //实例化对象
        let instance = LSNetworkManager()
        
        //设置反序列化支持的数据类型
        instance.responseSerializer.acceptableContentTypes?.insert("text/plain")
        
        return instance
    }()

    
    
//    //访问令牌
//    var accessToken:String?//= "2.00MoeccDmWnAHE4b82a582fd3E231E"
//    //uid
//    var uid: String? = "15581554271"
    
    //用户账户的懒加载属性
    lazy var userAccount = LSUserAccount()
    
    
    
    var userLogon:Bool{
        return userAccount.access_token != nil
    }
    
    
    
    //MARK:专门负责拼接token 的网络请求方法
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - method: GET/POST
    ///   - urlString: URLString
    ///   - parameters: 参数字典
    ///   - name: 上传文件使用的字段名，默认为nil,不上传文件
    ///   - data: 上传文件的二进制数据，默认为nil,不上传文件
    ///   - completion: 完成回调
    func tokenRequest(method : LSHTTPMethod = .GET,urlString : String,parameters: [String : AnyObject]?,name: String? = nil, data: Data? = nil, completion: @escaping (_ json: Any?, _ isSuccess: Bool)->()) {
       
        //如果没有token 直接返回
        guard let token = userAccount.access_token else {
           
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: LSUserHaveLoginNotification), object: nil)
            
            completion(nil, false)
            return
        }
        
        //1>判断字典是否存在
        var para = parameters
        
        if para == nil {
            para = [String : AnyObject]()
        }
        //2>
        para?["access_token"] = token as AnyObject?
        
        //3>判断name 和 data
        if let name = name,let data = data{
            //上传文件
            upload(URLString: urlString, paramaters: para, name: name, data: data, completion: completion)
        }else{
            //调用request方法
            //request(urlString: urlString, parameters: para , completion: completion)
            request(method: method, urlString: urlString, parameters: para, completion: completion)
        }

    }
    
    
    
    
    
    //MARK: -封装AFN上传文件的方法
    //上传文件必须是POST方法，GET只能获取数据
    
    /// 封装AFN上传文件的方法
    ///
    /// - Parameters:
    ///   - URLString: URLString
    ///   - paramaters: 参数字典
    ///   - name: 接收上传数据文件服务器字段
    ///   - data: 二进制数据
    ///   - completion: 完成回调
    func upload(URLString: String, paramaters: [String : AnyObject]?, name: String, data: Data,completion: @escaping (_ json: Any?, _ isSuccess: Bool)->()){
        

        post(URLString, parameters: paramaters, constructingBodyWith: { (fromData) in
            
            //FIXME创建fromData
            /**
             1.data:要上传的二进制数据
             2.name:服务器接收数据的字段名
             3.fileName:保存在服务器的文件名，大多数服务器，现在可以乱写
             很多服务器，上传图片完成后，会生成缩略图、中图、大图...
             4.mimeType:告诉服务器上传文件的类型，如果不想告诉，可以使用application/octet-stream image/png image/jpg image/gif
             */
            fromData.appendPart(withFileData: data, name: name, fileName: "xxx", mimeType: "application/octet-stream")
            
            
        }, progress: { (nil) in
            
        }, success: { (_, json) in
            
            completion(json, true)
            
        }) { (task, error) in
            if (task?.response as? HTTPURLResponse)?.statusCode == 403 {
                    print("token过期了")
    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: LSUserHaveLoginNotification), object: "badToken")
                }
                completion(nil, false)
        }
}
    
    
    
    
    
    
    
    
    //使用一个函数封装GET / POST请求
    func request(method : LSHTTPMethod = .GET,urlString : String,parameters : [String : AnyObject]?,completion: @escaping (_ json: Any?, _ isSuccess: Bool)->()){
       //成功回调
        let success = { (task: URLSessionDataTask, json: Any?)->() in
            completion(json, true)
        }
        //错误回调
        let failure = { (task: URLSessionDataTask?, error: Error)->() in
            print("请求失败\(error)")
            if (task?.response as? HTTPURLResponse)?.statusCode == 403 {
                print("token过期了")
                
                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: LSUserHaveLoginNotification), object: "badToken")
            }
            completion(nil, false)
        }
       
        if method == .GET {
           get(urlString, parameters: parameters, progress: nil, success: success, failure: failure)
            
        }else{
            
           post(urlString, parameters: parameters, progress: nil, success: success, failure: failure)
        }
    }
}
