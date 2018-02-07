//
//  File.swift
//  数据库
//
//  Created by lishaopeng on 17/1/17.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import Foundation
import FMDB

//最大的数据库缓存时间以s为单位
fileprivate let maxDBCacheTime: TimeInterval = -60//-5 * 24 * 60 * 60



//SQLite管理器
/**
 1.数据库本质上是保存在沙盒中的一个文件，首先需要创建并且打开数据库
 FMDB - 队列
 2.创建数据表
 3.增删改查
 */

//注意：数据库开发，程序代码几乎都是一样的，区别在于 SQL 开发数据库功能的时候，首先一定要在 navicat 中测试 SQL的正确性!


class LSSQLiteManager{
    //单例，全局数据库访问点
    static let shared = LSSQLiteManager()
    
    //数据库队列
    let queue: FMDatabaseQueue
    
    
    
    //构造函数
    fileprivate init(){
        
        //数据库的全路径 -path
        let dbName = "status.db"
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        path = (path as NSString).appendingPathComponent(dbName)
        print("数据库的路径" + path)
        
        //创建数据库队列,同时创建或者打开数据库
        queue = FMDatabaseQueue(path: path)
        
        //打开数据库
        createTable()
        
        
        //注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(clearDBCache), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:清理数据缓存
    //注意：SQLite的数据库不断增加数据，数据库文件大小，会不断的增加
    //--但是：如果删除了数据，数据库的大小，不会变小
    //--如果要变小
    //1>将数据库文件复制一个新的副本，status.old
    //2>新建一个空的数据库文件
    //3>自己编写SQL，从old中将所有的数据读出，写入新的数据库!
    @objc private func clearDBCache(){
        
        let dateString = Date.ls_dateString(delta: maxDBCacheTime)
        
        print("清理数据缓存\(dateString)")
        //准备SQL
        let sql = "DELETE FROM T_Status WHERE createTime < ?;"
        //执行SQL
        queue.inDatabase { (db) in
            
            if db?.executeUpdate(sql, withArgumentsIn: [dateString]) == true{
                print("删除了\(db?.changes())条记录")
            }
        }
    }
}


//MARK:--微博数据操作
extension LSSQLiteManager{
    
    /// 从数据库加载微博数组
    ///
    /// - Parameters:
    ///   - userId: 当前登录的用户账号
    ///   - since_id: 返回ID比since_id大的微博
    ///   - max_id: 返回ID小于max_id的微博
    /// - Returns: 返回的字典的数组，将数据库中 status字段对应的二进制数据反序列化，生成字典
    func loadStatus(userId: String,since_id: Int64 = 0,max_id: Int64 = 0) -> [[String : AnyObject]]{
        //1.准备SQL
        var sql = "SELECT statusId, userId, status FROM T_Status \n"
        sql += "WHERE userId = \(userId) \n"
        
        //上拉/下拉，都是针对同一个 id 进行排序
        if since_id > 0{
            sql += "AND statusId > \(since_id) \n"
        }else if max_id > 0{
            sql += "AND statusId < \(max_id) \n"
        }
        sql += "ORDER BY statusId DESC LIMIT 20"
        //拼接SQL 结束后一定一定要测试
       // print(sql)
        
         //2.执行SQL
        let array = execRecordSet(sql: sql)
        
        //3.遍历数组，将数组中的status反序列化 ->字典数组
        var reslut = [[String: AnyObject]]()
        
        for dict in array {
           guard  let jsonData = dict["status"] as? Data,
                  let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: AnyObject]
            else{
                continue
            }
            //追加到数组
            reslut.append(json ?? [:])
        }
        
        return reslut
    }
    
    
    
    
    
    
    
    //新增或者修改微博数据，微博数据在刷新的时候，可能会出现重叠
    //从网络加载结束后，返回的是微博的‘字典数组’，每一个字典对应一个完整的微博记录
    //-微博记录中，包含微博代号
    //微博记录中，没有‘当前登录用户代号’
    
    //userid:当前登录用户
    //array:从网络获取的字典数组
    func updateStatus(userId: String, array: [[String: AnyObject]]){
        
        //1.准备sql
        /*
         statusId：要保存的微博代号
         userId：当前用户的id
         status:完整微博字典的json 二进制数据
         */
        let sql = "INSERT OR REPLACE INTO T_Status (statusId, userId, status) VALUES (?,?,?);"
        //2.执行SQL
        queue.inTransaction { (db, rollBack) in
        
            //遍历数组，逐条插入微博数据
            for dict in array{
                
                //从字典获取微博代号/将字典序列化成二进制数据
              guard let statusId = dict["idstr"] as? String,
                        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])else{
                    continue
                }
                //执行 SQL
                if db?.executeUpdate(sql, withArgumentsIn: [statusId,userId,jsonData]) == false{
                    //插入失败需要回滚
                    //Xcode的自动语法转换，不会处理此处的代码
                    //OC中 *rollBack = YES
                    //Swift 1.0 & 2.0  ==> rollback.memory = true;
                    //Swift 3.0的写法
                    rollBack?.pointee = true
                    break;
                }
                //模拟回滚
//                rollBack?.pointee = true
//                break;
            }
        }
    }
}





//MARK:--创建数据表以及其他私有方法
extension LSSQLiteManager{
    
    /// 执行一个sql
    ///
    /// - Parameter sql: sql
    /// - Returns: 字典数组
    func execRecordSet(sql: String) -> [[String: AnyObject]]{
        
        var result = [[String: AnyObject]]()
        
        //执行SQL --查询数据不会修改数据，所以不需要开启事务
        queue.inDatabase { (db) in
            guard let rs = db?.executeQuery(sql, withArgumentsIn: [])else{
                return
            }
            //逐行 -- 遍历结果集合
            while rs.next(){
                //1.列数
                let  colCount = rs.columnCount()
                
                //2.遍历所有列
                
                for col in 0..<colCount{
                    //3.列名 -> KEY
                    guard let name = rs.columnName(for: col),
                    //4.值 ->Value
                        let value = rs.object(forColumnIndex: col)else{
                            continue
                    }
                    
                   // print("\(name)--\(value)")
                    //5.追加结果
                    result.append([name : value as AnyObject])
                }
            }
        }
        return result
    }
    
    
    
    //创建数据表
    func createTable(){
        //1.SQL
        guard  let path = Bundle.main.path(forResource: "status.sql", ofType: nil),
               let sql = try? String(contentsOfFile: path)
               else{
               return
            }
        //print(sql)
        
        //2.执行 SQL ---FMDB的内部队列是串行队列，同步执行
        //可以保证同一时间，只有一个任务操作数据库，从而保证数据库的读写安全
        queue.inDatabase { (db) in
            
            //只有在创表的时候，使用执行多条语句，可以一次创建多个数据表
            //在执行增删改的时候，一定不要使用Statements方法，否则有可能会被注入
            if db?.executeStatements(sql) == true{
                print("创表成功")
            }else{
                print("创表失败")
            }
            
        }
    } 
}
