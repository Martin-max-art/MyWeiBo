//
//  LSStatusListDAL.swift
//  WeiBo
//
//  Created by lishaopeng on 17/1/22.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import Foundation
///DAL -- Data Access Layer 数据访问层
//使命:负责处理数据库和网络数据，给ListViewModel返回微博的(字典数组)
class LSStatusListDAL {
    
        /// 从本地数据库或者网络加载数据
        ///
        /// - Parameters:
        ///   - since_id: 下拉刷新 id
        ///   - max_id: 上拉刷新 id
        ///   - completion: 完成回调(微博的字典数组)
      class func loadStatus(since_id: Int64 = 0, max_id: Int64 = 0,completion:@escaping (_ list: [[String: AnyObject]]?, _ isSuccess: Bool) -> ()){
        
            //0.获取用户代号
//            guard let userId = LSNetworkManager.shared.userAccount.uid else{
//                return
//            }
        
            //1.检查本地数据，如果有，直接返回
            let array = LSSQLiteManager.shared.loadStatus(userId: "1", since_id: since_id, max_id: max_id)
        
           //判断数组的数量，没有数据返回的是没有数据的空数组[]
            if array.count > 0 {
                completion(array, true)
            }
            
            //2.加载网络数据
            LSNetworkManager.shared.statusList(since_id: since_id, max_id: max_id) { (list, isSuccess) in
                
                //判断网络请求是否成功
                if !isSuccess {
                    completion(nil, false)
                    return
                }
                
                
                //3.加载完成之后，将网络数据(字典数组)，写入数据库
                //判断数据
                guard let list = list else{
                    completion(nil, isSuccess)
                    return
                }
                LSSQLiteManager.shared.updateStatus(userId: "1", array: list)
                
                
                //4.返回网络数据
                completion(list, isSuccess)
              }
            
        
        }
    
    
    
}
