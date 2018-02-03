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
    
    func statusList(since_id: Int64 = 0,max_id: Int64 = 0,completion:@escaping (_ list: [[String: AnyObject]]?, _ isSuccess: Bool) -> ()){
        
        let urlString = "https://api.weibo.com/2/statuses/home_timeline.json"
        
        let params = ["since_id": since_id,"max_id": max_id > 0 ? max_id - 1 : 0]
        print(params)
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
          
          print("没有用户信息字典之前\(self.userAccount)")
        
        
        //加载当前用户信息
         self.loadUserInfo(completion: { (dict) in
            
            print("用户信息\(dict)")
            //使用用户信息字典设置用户账户信息(昵称和头像地址)
            self.userAccount.yy_modelSet(with: dict)
            //保存模型
            self.userAccount.saveAccount()
             print("有用户信息字典之后\(self.userAccount)")
            //用户信息加载完成再    完成回调
            completion(isSuccess)
         })
        
        
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
