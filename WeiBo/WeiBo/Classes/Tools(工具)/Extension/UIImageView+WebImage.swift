//
//  UIImageView+WebImage.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/28.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import SDWebImage

extension UIImageView {
    /// 隔离SDWebImage 设置图像函数
    ///
    /// - Parameters:
    ///   - urlString: 图像的url
    ///   - placeholderImage: 占位图像
    ///   - isAvatar: 是否头像
    func cz_setImage(urlString: String?,placeholderImage:UIImage?, isAvatar:Bool = false){
        
        //处理URL
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            //设置占位图像
            image = placeholderImage
            return
        }
        //可选项只是用在Swift,OC有的时候用 ! 同样可以传入nil
        
        sd_setImage(with: url, placeholderImage: placeholderImage, options: [], progress: nil) {[weak self] (image, _, _, _) in
           //完成回调 -判断是否是头像
            if isAvatar{
               self?.image = image?.cz_avatarImage(size: self?.bounds.size)
            }
            
        }
    }
}
