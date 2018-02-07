//
//  LSStatusListViewModel.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/15.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import Foundation
import SDWebImage
//上拉刷新最大尝试次数
private let maxPullupTryTimes = 3
//如果类需要使用“KVC” 或者字典转模型设置对象值，类就需要继承自 NSObject
class LSStatusListViewModel {
    
    //列表视图模型
   lazy var statuList = [LSStatusViewModel]()
    //上拉刷新错误次数
   private var pullupErrorTimes = 0
    
    func  loadStatus(pullup: Bool,completion: @escaping (_ isSuccess: Bool , _ hasMorePullup: Bool) -> ())  {
        
        //判断是否是上拉刷新
        if pullup && pullupErrorTimes > maxPullupTryTimes{
           
            completion(true,false)
            return
        }
        
        
        //since_id 取出数组中第一条微博的id  如果是上拉刷新
        let since_id = pullup ? 0 : (statuList.first?.status.id ?? 0)
        //如果是下拉刷新
        let max_id = !pullup ? 0 : (statuList.last?.status.id ?? 0)
        
        
        //让数据访问层加载数据
        LSStatusListDAL.loadStatus(since_id: since_id, max_id: max_id) { (list, isSuccess) in
           print(list)
//        }
//     //发起网络请求，加载微博数据【字典的数组】 
//     LSNetworkManager.shared.statusList(since_id: since_id,max_id: max_id) { (list, isSuccess) in
        
        //0.判断网络请求是否成功
        if !isSuccess{
            completion(false,false)
            return
        }
        
          //1.字典转模型
        //1>定义结果可变数组
        var array = [LSStatusViewModel]()
        //2>遍历服务器返回的字典数组，字典模型
        for dict in list ?? []{
            //a.创建微博模型- 如果创建模型失败，继续后面的遍历
            guard let model = LSStatusModel.yy_model(with: dict) else{
                continue
            }
            //b.将试图模型添加到数组
            array.append(LSStatusViewModel(model: model))
        }
        
//        guard let array = NSArray.yy_modelArray(with: LSStatusModel.self, json: list ?? []) as? [LSStatusModel] else{
//            completion(isSuccess,false)
//            return
//        }
       // print("刷新了\(array.count) 数据=\(array)")
          //2.拼接数据
        
        if pullup{
            //上拉刷新应当将结果拼接在数组末尾
            self.statuList += array
        }else{
            //下拉刷新，应该将结果数组拼接在数组前面
           self.statuList = array + self.statuList
        }
        //3.判断上拉刷新数据
        if pullup && array.count == 0{
            self.pullupErrorTimes += 1
            
            completion(isSuccess,false)
        }else{
            //4.完成回调 闭包当做参数传递
            self.cacheSingleImage(list: array,finished: completion)
            //completion(isSuccess,true)
        }
        }
    }
    
    
    
    
    
    /// 缓存本次下载微博数据数组中的单张图像
    ///应该缓存完单张图像，并且修改过配图视图的大小之后，再回掉，才能保证表格等比例显示单张图像
    /// - Parameter list: 本次下载的视图模型数组
    fileprivate func cacheSingleImage(list:[LSStatusViewModel],finished: @escaping (_ isSuccess: Bool , _ hasMorePullup: Bool) -> ()){
        
        
        //调度组
        let group = DispatchGroup()
        
        
        //记录数据长度
        var length = 0
        
        //遍历数组，查找微博数据中单张图像，进行缓存
        for vm in list {
            //1.判断图像数量
            if vm.picURLs?.count != 1 {
                continue
            }
            //2>获取 图像模型  代码执行到此，数组中有且仅有一张图片
            guard  let pic  = vm.picURLs?[0].thumbnail_pic,
                let url = URL(string: pic) else{
                    return
            }
            
           // print("要缓存的URL是\(url)")
            
            //3>下载图像
            //downloadImage 是 SDWebImage的核心方法
            //图像下载完成之后会自动保存在沙盒中，文件路径是url的MD5
            //如果沙盒中已经存在缓存的图像，后需使用 SD 通过URL加载图像，都会加载本地沙盒的图像
            //不会发起网络请求，同时回调方法会调用
            //方法还是同样的方法调用还是同样的调用，不过内部不会再次发起网络请求
            /*注意点，如果要缓存的图像累计很大，要找后台要接口*/
            //a.入组
            group.enter()
            SDWebImageManager.shared().downloadImage(with: url, options: [], progress: nil, completed: { (image, _, _, _, _) in
                
               if let im = image,
                  let data = UIImagePNGRepresentation(im){
                   length += data.count
                
                //图像缓存成功，更新配图的大小
                 vm.updateSingleImageSize(image: im)
                }
               // print("缓存的头像是\(image)长度\(length)")
                //b出组
                group.leave()
            })
        }
        
        //监听调度组
        group.notify(queue: DispatchQueue.main) {
           // print("图像缓存完成 \(length / 1024)K")
            finished(true,true)
        }
    }
}
