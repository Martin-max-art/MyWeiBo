//
//  LSStatusListViewModel.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/15.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import Foundation

//上拉刷新最大尝试次数
private let maxPullupTryTimes = 3
//如果类需要使用“KVC” 或者字典转模型设置对象值，类就需要继承自 NSObject
class LSStatusListViewModel {
    
    //列表视图模型
   lazy var statuList = [LSStatusModel]()
    //上拉刷新错误次数
   private var pullupErrorTimes = 0
    
    func  loadStatus(pullup: Bool,completion: @escaping (_ isSuccess: Bool , _ hasMorePullup: Bool) -> ())  {
        
        //判断是否是上拉刷新
        if pullup && pullupErrorTimes > maxPullupTryTimes{
           
            completion(true,false)
            return
        }
        
        
        //since_id 取出数组中第一条微博的id  如果是上拉刷新
        let since_id = pullup ? 0 : (statuList.first?.id ?? 0)
        //如果是下拉刷新
        let max_id = !pullup ? 0 : (statuList.last?.id ?? 0)
        
        
     LSNetworkManager.shared.statusList(since_id: since_id,max_id: max_id) { (list, isSuccess) in
          //1.字典转模型
        guard let array = NSArray.yy_modelArray(with: LSStatusModel.self, json: list ?? []) as? [LSStatusModel] else{
            completion(isSuccess,false)
            return
        }
        print("刷新了\(array.count)")
          //2.拼接数据
        
        if pullup{
            //上拉刷新应当将结果拼接在数组末尾
            self.statuList += array
        }else{
            //下拉刷新，应该将结果数组拼接在数组前面
           self.statuList = array + self.statuList
        }
        //判断上拉刷新数据
        if pullup && array.count == 0{
            self.pullupErrorTimes += 1
            
            completion(isSuccess,false)
        }else{
            //完成回调
            completion(isSuccess,true)
        }
        }
        
        
    }
}
