//
//  LSNetworkManager+.swift
//  
//
//  Created by lishaopeng on 16/12/15.
//
//

import Foundation
//MARK : -封装新浪微博的网络请求方法
extension LSNetworkManager {
    
    /// 加载微博数据字典数组
    ///
    /// - Parameters:
    ///   - since_id: 返回ID比since_id大的微博 (即比since_id时间晚的微博)，默认为0
    ///   - max_id: 返回ID比
    ///   - completion: <#completion description#>
    func statusList(since_id: Int64 = 0,max_id: Int64 = 0,completion:@escaping (_ list: [[String: AnyObject]]?, _ isSuccess: Bool) -> ()){
        
        let urlString = "https://api.weibo.com/2/statuses/home_timeline.json"
        
        let params = ["since_id": since_id,"max_id": max_id > 0 ? max_id - 1 : 0]
      //  print(params)
        tokenRequest(urlString: urlString, parameters: params as [String : AnyObject]?){ (json , isSuccess) in
            //从接送中获取 statuses 字典数组
            let dic = json as AnyObject
        
            let result = dic["statuses"] as? [[String: AnyObject]]
            
            completion(result , isSuccess)
        }
        
    }
    ///返回微博的未读数
    func unreadCount(completion:@escaping (_ count: Int) -> ()) {
        guard let uid = userAccount.uid else {
            return
        }
        let urlString = "https://rm.api.weibo.com/2/remind/unread_count.json"
        let params = ["uid":uid]
       tokenRequest(urlString: urlString, parameters: params as [String : AnyObject]?) { (json, isSuccess) in
        
        let dict = json as? [String: AnyObject]
        let count = dict?["status"] as? Int
        completion(count ?? 0)
        
        }
    }
}
extension LSNetworkManager{
    
    //加载 AccessToken
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - code: 授权码
    ///   - completion: 完成回调
    func loadAccessToken(code: String, completion:@escaping (_ isSuccess:Bool)->()){
         let urlString = "https://api.weibo.com/oauth2/access_token"
    
         let paramter = [
                        "client_id":AppKey,
                        "client_secret ":AppSecret,
                        "grant_type":"authorization_code",
                        "code":code,
                        "redirect_uri":AppRedirectURL,
                        ]
        
       tokenRequest(method: .POST, urlString: urlString, parameters: paramter as [String : AnyObject]?) { (json, isSuccess) in
        
          //直接用字典设置UserAccount的属性
          self.userAccount.yy_modelSet(with: (json as? [String: AnyObject]) ?? [:])
          
        //  print("没有用户信息字典之前\(self.userAccount)")
        
        
        //加载当前用户信息
         self.loadUserInfo(completion: { (dict) in
            
           // print("用户信息\(dict)")
            //使用用户信息字典设置用户账户信息(昵称和头像地址)
            self.userAccount.yy_modelSet(with: dict)
            //保存模型
            self.userAccount.saveAccount()
           //  print("有用户信息字典之后\(self.userAccount)")
            //用户信息加载完成再    完成回调
            completion(isSuccess)
         })
        
        
        }
        
    }
}
//MARK: - 发布微博
extension LSNetworkManager{
    
    func postStatus(text: String, image: UIImage?, completion:@escaping (_ result: [String : AnyObject]?,_ isSuccess: Bool)->()) -> (){
        
        //1.url 
        // 1. url
        let urlString: String
        //根据是否有图像，选择不同的接口地址
        if image == nil {
            urlString = "https://api.weibo.com/2/statuses/update.json"
        } else {
            urlString = "https://upload.api.weibo.com/2/statuses/upload.json"
        }
        
        //2.参数字典
        let patams = ["status" : text]
        
        //3.如果图像不为空，需要设置name和data
        var name: String?
        var data: Data?
        if image != nil{
            name = "pic"
            data = UIImagePNGRepresentation(image!)
        }else{
            
        }
        //4.发起网络请求
        tokenRequest(method: .POST, urlString: urlString, parameters: patams as [String : AnyObject]?, name: name, data: data) { (json, isSuccess) in
            completion(json as! [String : AnyObject]?, isSuccess)
        }
        
    }
}

//MARK: - 用户信息
extension LSNetworkManager{
    //加载当前用户信息  用户登录后立即执行
    func loadUserInfo(completion:@escaping (_ dict:[String: AnyObject])->()){
        guard let uid = userAccount.uid else {
            return
        }
        let urlString = "https://api.weibo.com/2/users/show.json"
        let params = ["uid":uid]
        tokenRequest(urlString: urlString, parameters: params as [String : AnyObject]?) { (json, isSuccess) in
            completion((json as? [String : AnyObject]) ?? [:])
        }
    }
}
