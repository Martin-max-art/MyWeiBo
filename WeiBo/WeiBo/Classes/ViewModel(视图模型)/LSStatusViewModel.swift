//
//  LSStatusViewModel.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/28.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import Foundation

/**
 如果没有任何父类，如果希望在开发时调试，输出调试信息，需要
 1.遵守CustomStringConvertible
 2.实现description计算型属性
 关于表格的性能优化
 -尽量减少计算，所有需要的素材提前计算好
 -控件上不要设置圆角半径，所有图像渲染属性都需要注意
 -不要动态创建控件，所有需要的控件，都需要提前创建好，在显示的时候，根据数据隐藏/显示
 */
class LSStatusViewModel: CustomStringConvertible {
    //微博模型
    var status: LSStatusModel
    //会员图标---存储型属性(用内存换CPU)
    var vipIcon: UIImage?
    //认证图标
    var verifiedIcon: UIImage?
    //转发文字
    var retweetedStr: String?
    //评论文字
    var commentStr: String?
    //点赞文字
    var likeStr: String?
    //来源文字
  //  var sourceStr: String?
    //配图视图大小
    var picViewSize = CGSize()
    ///如果是被转发的微博，原创微博一定没有图
    var picURLs: [LSStatusPictureModel]?{
        //如果有被转发的微博，返回被转发微博的配图
        //如果没有被转发微博的微博，返回原创微博的配图
        //如果都没有返回nil
        return status.retweeted_status?.pic_urls ?? status.pic_urls
    }
    //被转发微博的文字的属性文本
    var retweetedAttrText: NSAttributedString?
    //微博正文的属性文本
    var statusAttrText: NSAttributedString?
    
    
    //行高
    var rowHeight: CGFloat = 0
    
    
    /// 构造函数
    ///
    /// - Parameter model: 微博模型
    //-微博的视图模型
    init(model:LSStatusModel) {
        self.status = model
        
        if (model.user?.mbrank)! >= 0 && (model.user?.mbrank)! < 7 {
            let imageName = "common_icon_membership_level\(model.user?.mbrank ?? 1)"
            vipIcon = UIImage(named: imageName)
        }
        //认证图标
        switch model.user?.verified_type ?? -1 {
        case 0:
            verifiedIcon = UIImage(named: "avatar_vip")
        case 2,3,5:
            verifiedIcon = UIImage(named: "avatar_enterprise_vip")
        case 220:
            verifiedIcon = UIImage(named: "avatar_grassroot")
        default:
            break
        }
       
        
        //设置底部计数字符串
        retweetedStr = countString(count: model.reports_count, defaultStr: "转发")
        commentStr = countString(count: model.comments_count, defaultStr: "评论")
        likeStr = countString(count: model.attitudes_count, defaultStr: "赞")
        
        //计算配图视图大小（有原创的计算原创的，有转发的计算转发的）
        picViewSize = calcuPictureViewSize(count: picURLs?.count)
        
        //--------设置被转发微博的文字---------
        let oringinalFont = UIFont.systemFont(ofSize:15)
        let retweetedFont = UIFont.systemFont(ofSize: 14)
        
        //微博正文的属性微博正文的属性文本
        statusAttrText = LSEmotiIconManager.shared.emoticonString(string: model.text ?? "",font: oringinalFont)
        
        
        //设置被转发微博的文字
        let rText = "@" + (model.retweeted_status?.user?.screen_name ?? "")
            + ":"
            + (model.retweeted_status?.text ?? "")
        retweetedAttrText =  LSEmotiIconManager.shared.emoticonString(string: rText,font: retweetedFont)
        
        
        //设置来源字符串
      //  sourceStr = (model.source?.ls_href()?.text ?? "")
        
        //计算行高
        updateRowHeight()
    }
    
    /// 使用单个图像，更新配图视图的大小
    ///新浪针对单张图片，都是缩略图，但是偶尔会有一张特别大的图 7000*9000多
    ///新浪微博为了鼓励原创，支持长微博，有些特别长的微博，长到宽度只有一个点
    /// - Parameter image: 网络缓存的单张图像
    func updateSingleImageSize(image: UIImage){
        var size = image.size
        
        //过宽图像处理
        let maxWidth: CGFloat = 300
        let minWidth: CGFloat = 40
        
        //过宽图像处理
        if size.width > maxWidth{
            //设置最大宽度
            size.width = 200
            //等比例调整高度
            size.height = size.width * image.size.height / image.size.width
        }
        
        //过窄图像处理
        if size.width < minWidth{
            
            size.width = minWidth
            //要特殊处理高度，否则会影响用户体验
            size.height = size.width * image.size.height / image.size.width / 4
        }
        
        //过高图片处理,图片填充模式就是 scaleToFill,高度减小，会自动裁切
        if size.height > 200{
            size.height = 200
        }
        
        
        //注意，尺寸需要增加顶部 的 12 个点，便于布局
        size.height += LSPictureOutMargin
        picViewSize = size
        //更新行高
        updateRowHeight()
    }
    
    func updateRowHeight() {
        //原创微博:顶部分隔视图(12) + 间距(12) + 图像高度(34) + 间距(12) + 正文高度(需要计算) + 配图视图高度(需要计算) + 间距(12) + 底部视图高度(35)
        //被转发微博:顶部分隔视图(12) + 间距(12) + 图像高度(34) + 间距(12) + 正文高度(需要计算) + 间距(12) + 间距(12) + 转发文本高度(需要计算) + 配图视图高度(需要计算) + 间距(12) + 底部视图高度(35)
        let margin: CGFloat = 12
        let iconHeight: CGFloat = 34
        let toolBarHeight: CGFloat = 35
        let viewSize = CGSize(width: UIScreen.cz_screenWidth() - 2 * margin, height: CGFloat(MAXFLOAT))
        
        var height:CGFloat = 0
        
        //1.计算顶部位置
        height = 2 * margin + iconHeight + margin
        //2.正文属性文本高度---属性文本中已经包含了字体属性
        if let text = statusAttrText{
          height += text.boundingRect(with: viewSize, options: [.usesLineFragmentOrigin], context: nil).height
        }
        //3.是否转发微博
        if status.retweeted_status != nil{
            height += 2 * margin
            
            //转发文本高度 ---一定用retweetedText,拼接 @用户名
            if let text = retweetedAttrText {
                height += text.boundingRect(with: viewSize, options: [.usesLineFragmentOrigin], context: nil).height
            }
        }
        //4.配图视图
        height += picViewSize.height
        height += margin
        
        //5.底部工具栏
        height += toolBarHeight
        
        rowHeight = height
    }
    
    
    var description: String{
        return status.description
    }
    
    /// 计算配图视图的大小
    ///
    /// - Parameter count: 配图数量
    /// - Returns: 配图视图的大小
    fileprivate func calcuPictureViewSize(count: Int?) -> CGSize{
        
        if  count == 0 || count == nil {
            return CGSize()
        }
        //1.计算高度
        //1>计算行数 根据count计算行数 1-9
        /**
         1 2 3 - 1 = 0 1 2 / 3 = 0 + 1 =1
         4 5 6 - 1 = 3 4 5 / 3 = 1 + 1 =2
         7 8 9 - 1 = 6 7 8 / 3 = 2 + 1 =3
         */
        let row = (count! - 1) / 3 + 1
        
        var height = LSPictureOutMargin
        height += CGFloat(row) * LSPicWidth
        height += CGFloat(row - 1) * LSPictureInMargin
        
        return CGSize(width: LSPictureViewWidth, height: height)
    }
    

    /// 给定义一个数字，返回对应的描述结果
    ///
    /// - Parameters:
    ///   - count: 数字
    ///   - defaultStr: 默认字符串，转发/评论/赞
    /// - Returns: 描述结果
    
    /**
     如果数量 == 0，显示默认标题
     如果数量超过 10000，显示x.xx万
     如果数量<10000显示实际数字
     */
    fileprivate func countString(count: Int,defaultStr: String) -> String{
        if count == 0 {
            return defaultStr
        }
        if count < 10000 {
            return count.description
        }
        return String(format: "%.02f 万",Double(count / 10000))
    }
}
