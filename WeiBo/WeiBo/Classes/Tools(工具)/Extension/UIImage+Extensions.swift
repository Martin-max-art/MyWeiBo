//
//  UIImage+Extensions.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/28.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// 生成裁切后的图像
    ///
    /// - Parameters:
    ///   - size: 尺寸
    ///   - backColor: 背景颜色
    ///   - lineColor: 线条颜色
    /// - Returns: 裁切后的图像
    func cz_avatarImage(size: CGSize?,backColor: UIColor = UIColor.white,lineColor: UIColor = UIColor.lightGray) -> UIImage?{
        var size = size
        if size == nil {
            size = self.size
        }
        let rect = CGRect(origin: CGPoint(), size: size!)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        backColor.setFill()
        UIRectFill(rect)
        
        let path = UIBezierPath(ovalIn: rect)
        path.addClip()
        
        draw(in: rect)
        
        let ovalPath = UIBezierPath(ovalIn: rect)
        ovalPath.lineWidth = 2
        lineColor.setStroke()
        ovalPath.stroke()
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return result
    }
    
    /// 生成指定大小的不透明图像
    ///
    /// - Parameters:
    ///   - size: 尺寸
    ///   - backColor: 背景颜色
    /// - Returns: 图像
    func cz_image(size:CGSize? = nil,backColor: UIColor = UIColor.white) -> UIImage?{
        var size = size
        if size == nil {
            size = self.size
        }
        let rect = CGRect(origin: CGPoint(), size: size!)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        backColor.setFill()
        UIRectFill(rect)
        draw(in: rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
        
    }
}
