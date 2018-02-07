//
//  LSStatusCell.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/27.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import UIKit

//微博cell的协议
//如果需要设置可选协议方法
//-协议需要是 @objc的
//-方法需要 @objc optional
@objc protocol LSStatusCellDelegate : NSObjectProtocol {
    //微博cel选中URL字符串
   @objc optional func statusCellDidTapURLString(cell: LSStatusCell,urlString: String)
}

class LSStatusCell: UITableViewCell {

    weak var delegate: LSStatusCellDelegate?
    
    //微博视图模型
    var viewModel:LSStatusViewModel?{
        didSet{
            //微博文本
            statusLabel.attributedText = viewModel?.statusAttrText
            //设置被转发微博的文字
            retweetedLabel?.attributedText = viewModel?.retweetedAttrText
            //姓名
            nameLabel.text = viewModel?.status.user?.screen_name
            //设置会员图标
            vipImageView.image = viewModel?.vipIcon
            //认证图标
            renZhenView.image = viewModel?.verifiedIcon
           
            //用户头像
            iconView.cz_setImage(urlString: viewModel?.status.user?.profile_image_url, placeholderImage: UIImage(named:"avatar_default_big"),isAvatar: true)
            //给顶部工具栏赋值
            toolBarView.viewModel = viewModel
            
            //测试修改配图视图的高度
          //  pictureView.picviewHeight.constant = viewModel?.picViewSize.height ?? 0
            //传递配图视图的模型
            pictureView.viewModel = viewModel
            
            
            //测试4张图像
//            if (viewModel?.status.pic_urls?.count)! > 4 {
//                //修改数组 -> 将末尾数据全部删除
//                var picURLs = viewModel?.status.pic_urls
//                picURLs?.removeSubrange(((picURLs?.startIndex)! + 4)..<(picURLs?.endIndex)!)
//                pictureView.urls = picURLs
//            }else{
//              pictureView.urls = viewModel?.status.pic_urls
//            }
            //设置微博视图的url（被转发和原创）
//            pictureView.urls = viewModel?.picURLs
            
            
            //设置来源
            soureLabel.text = viewModel?.status.source
            
            
            timeLabel.text = viewModel?.status.createdDate?.ls_dateDescription
        }
    }
    
    
    
    
    //头像
    @IBOutlet weak var iconView: UIImageView!
    //姓名
    @IBOutlet weak var nameLabel: UILabel!
    //会员图标
    @IBOutlet weak var vipImageView: UIImageView!
    //时间
    @IBOutlet weak var timeLabel: UILabel!
    //来源
    @IBOutlet weak var soureLabel: UILabel!
    //认证图标
    @IBOutlet weak var renZhenView: UIImageView!
    //正文
    @IBOutlet weak var statusLabel: FFLabel!
    //底部工具栏
    @IBOutlet weak var toolBarView: LSStatusToolBar!
    //配图视图
    @IBOutlet weak var pictureView: LSStatusPictureView!
    //被转发微博的标签   原创微博没有此控件  因此一定要用 ?
    @IBOutlet weak var retweetedLabel: FFLabel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //离屏渲染--异步绘制
        self.layer.drawsAsynchronously = true
        //栅格化---异步绘制，会生成一张独立的图像，cell在屏幕上滚动的时候，本质上是滚动这张图片
        //cell优化，要尽量减少图层的数量，相当于就只有一层
        //停止滚动之后，可以接收监听
        self.layer.shouldRasterize = true
        //使用栅格化必须注意指定屏幕的分辨率
        self.layer.rasterizationScale = UIScreen.main.scale
        //设置微博文本的代理
        statusLabel.delegate = self
        retweetedLabel?.delegate = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
extension LSStatusCell: FFLabelDelegate{
    func labelDidSelectedLinkText(label: FFLabel, text: String) {
        
        if !text.hasPrefix("http://") {
            return
        }
        
        //插入 ? 表示如果代理没有实现协议方法，就什么都不做
        //如果使用 ! 代理没有实现协议方法，仍然强行执行会奔溃
        delegate?.statusCellDidTapURLString?(cell: self, urlString: text)
    }
}
