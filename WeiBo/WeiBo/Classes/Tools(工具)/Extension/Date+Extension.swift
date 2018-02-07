//
//  Date+Extension.swift
//  WeiBo
//
//  Created by lishaopeng on 17/2/4.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import Foundation

//日期格式化--不要频繁的释放和创建，会影响性能
fileprivate let dateFormatter = DateFormatter()
//当前日历对象
fileprivate let calender = Calendar.current

extension Date{
    
    
    /// 计算当前系统时间偏差 delta 描述的日期字符串
    /// 在 Swift中，如果要定义结构体的 ‘类’ 函数，使用 static 修饰 -> 静态函数
    static func ls_dateString(delta: TimeInterval) -> String{
        
        let date = Date(timeIntervalSinceNow: delta)
        
        //指定日期格式
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.string(from: date)

    }
    
    /// 将新浪格式的字符串转换成日期
    ///
    /// - Parameter string: Tue Sep 15 12:12:00 +0800 2015
    /// - Returns: 日期
    static func ls_sinaDate(string: String) -> Date?{
        //1.设置日期格式
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        print("\(string)----------------\(dateFormatter.date(from: string))")
        //2.转换并且返回日子
        return dateFormatter.date(from: string)
    }
    
    var ls_dateDescription: String{
        
        //1.判断日期是否是今天
        if calender.isDateInToday(self){
            
            let delta = -Int(self.timeIntervalSinceNow)
            
            if delta < 60 {
                return "刚刚"
            }
            
            if delta < 3600 {
                return "\(delta / 60)分钟前"
            }
            
            return "\(delta / 3600)小时前"
        }
        
        
        
        //2.其他天
        var fmt = " HH:mm"
        if calender.isDateInYesterday(self){
            fmt = "昨天" + fmt
        }else{
            fmt = "MM-dd" + fmt
            
           let year = calender.component(.year, from: self)
           let thisYear = calender.component(.year, from: Date())
            
            if year != thisYear{
                fmt = "yyyy-" + fmt
            }
            
        }
        //设置日期格式字符串
        dateFormatter.dateFormat = fmt
        return dateFormatter.string(from: self)
    }
}
