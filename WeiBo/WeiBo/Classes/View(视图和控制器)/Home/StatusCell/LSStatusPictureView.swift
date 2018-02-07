//
//  LSStatusPictureView.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/29.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import UIKit

class LSStatusPictureView: UIView {

    var viewModel:LSStatusViewModel?{
        didSet{
            calcViewSize()
            //设置微博视图的url（被转发和原创）
            urls = viewModel?.picURLs
        }
    }
    //根据配图视图的大小调整显示内容
    fileprivate func calcViewSize(){
        //处理宽度
        
        if viewModel?.picURLs?.count == 1{//a.单图，根据配图视图的大小修改subViews[0]的宽度
            
            let viewSize = viewModel?.picViewSize ?? CGSize()
            let v = subviews[0]
            v.frame = CGRect(x: 0, y: LSPictureOutMargin, width: viewSize.width, height: viewSize.height - LSPictureOutMargin)
            
        }else{//b.多图，恢复subviews[0]的宽度，保证九宫格布局完整
            let v = subviews[0]
            v.frame = CGRect(x: 0, y: LSPictureOutMargin, width: LSPicWidth, height: LSPicWidth)
        }

        //修改高度
        picviewHeight.constant = viewModel?.picViewSize.height ?? 0
    }
    
    
   fileprivate var urls: [LSStatusPictureModel]?{
        didSet{
            //1.隐藏所有的imageView
            for v in subviews {
                v.isHidden = true
            }
            //2.遍历urls 数组，顺序设置图像
            var index = 0
            for url in urls ?? [] {
                
                //获得对应索引的imageView
                let iv = subviews[index] as! UIImageView
                
                //4张图像的处理
                if index == 1 && urls?.count == 4 {
                    index += 1
                }
                
                //设置图像
                iv.cz_setImage(urlString: url.thumbnail_pic, placeholderImage: nil)
                
                
                //判断是否 gif
                iv.subviews[0].isHidden = (((url.thumbnail_pic ?? "") as NSString).pathExtension.lowercased() != "gif")
                
                iv.isHidden = false
                
                index += 1
            }
        }
    }
    
   @IBOutlet weak var picviewHeight: NSLayoutConstraint!
   
    override func awakeFromNib() {
       setupUI()
    }
    
    //MARK:手机监听方法
    @objc fileprivate func tapImageView(tap: UITapGestureRecognizer){
       
        guard let iv = tap.view,
              let picURLs = viewModel?.picURLs else{
            return
        }
        
        var selectedIndex = iv.tag
        
        //针对四张图处理
        if picURLs.count == 4 && selectedIndex > 1 {
            selectedIndex -= 1
        }
        
        let urls = (picURLs as NSArray).value(forKey: "largePic") as! [String]
        
        //处理可见的图像视图数组
        var imageViewList = [UIImageView]()
        
        for iv in subviews as! [UIImageView] {
            
            if !iv.isHidden {
                imageViewList.append(iv)
            }
            
        }
        
        //发送通知
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: LSStautsCellBrowserPhotoNotification),
                                    object: self,
                                    userInfo: [ LSStatusCellBrowserPhotoURLsKey: urls,
                                                LSStatusCellBrowserPhotoSelectedIndexKey: selectedIndex,
                                                LSStatusCellBrowserPhotoImageViewsKey:imageViewList
                                              ])
    }
    
}
extension LSStatusPictureView{
    //1.cell中所有的控件都是提前准备好
    //2.设置的时候，根据数据决定是否显示
    //3.不要动态创建控件
    fileprivate func setupUI(){
        
        
        //设置背景颜色
        backgroundColor = superview?.backgroundColor
        
        //超出边界的内容不显示
        clipsToBounds = true
        
        let count = 3
        let rect = CGRect(x: 0,
                          y: LSPictureOutMargin,
                          width: LSPicWidth,
                          height: LSPicWidth)
        
        for i in 0..<count * count {
            
            let iv = UIImageView()
            //设置contenrMode
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            //行
            let row = CGFloat(i / count)
            //列
            let col = CGFloat(i % count)
            
            let xOffset = col * (LSPicWidth + LSPictureInMargin)
            
            let yOffset = row * (LSPicWidth + LSPictureInMargin)
            
            iv.frame = rect.offsetBy(dx: xOffset, dy: yOffset)
            
            addSubview(iv)
            
            //让imageView能够接收用户交互
            iv.isUserInteractionEnabled = true
            //添加手势识别
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapImageView))
            iv.addGestureRecognizer(tap)
            //设置imageView的tag
            iv.tag = i
            
            addGifView(iv: iv)
        }
    }
    
    //向图像视图添加gif提示图像
    fileprivate func addGifView(iv: UIImageView){
        
        let gifImageView = UIImageView(image: UIImage(named: "timeline_image_gif"))
        iv.addSubview(gifImageView)
        
        //自动布局
        gifImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //右边
        iv.addConstraint(NSLayoutConstraint(item: gifImageView,
                                            attribute: .right,
                                            relatedBy: .equal,
                                            toItem: iv,
                                            attribute: .right,
                                            multiplier: 1.0,
                                            constant: 0))
       //下边
        iv.addConstraint(NSLayoutConstraint(item: gifImageView,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: iv,
                                            attribute: .bottom,
                                            multiplier: 1.0,
                                            constant: 0))
    
    }
    
}
