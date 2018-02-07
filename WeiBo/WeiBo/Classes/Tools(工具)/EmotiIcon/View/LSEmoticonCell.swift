//
//  LSEmoticonCell.swift
//  表情键盘
//
//  Created by lishaopeng on 17/1/13.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import UIKit

//表情 Cell的协议
@objc protocol LSEmotiIconCellDelegate: NSObjectProtocol{
    
    /// 表情cell 选中的表情模型
    ///
    /// - Parameter em: 表情模型==nil表示删除
    func emoticonCellDidSelectedEmoticon(cell: LSEmoticonCell, em: LSEmotiIconModel?)
    
}



///表情页面cell
//- 每一个cell就是和cellectionView一样大小
//- 每一个cell中用九宫格的算法，自行添加20个表情
//- 最后一个位置放置删除按钮
class LSEmoticonCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    //代理
    weak var delegate: LSEmotiIconCellDelegate?
    
    var emoticons: [LSEmotiIconModel]? {
        didSet{
            //print("表情包数量\(emoticons?.count)")
            //1.隐藏所有按钮
            for v in contentView.subviews {
                v.isHidden = true
            }
            //显示删除按钮
            contentView.subviews.last?.isHidden = false
            
            //2.遍历表情模型数组，设置按钮图像
            for (i, em) in (emoticons ?? []).enumerated() {
                //1>取出按钮
               if let btn = contentView.subviews[i] as? UIButton{
                    //如果图像为nil会清空图像，避免复用
                    btn.setImage(em.image, for: [])
                    //设置 emoji的字符串
                    btn.setTitle(em.emoji, for: [])
                    btn.isHidden = false
                }
            }
        }
    }
    //表情选择提示视图
    fileprivate var tipView = LSEmoticonTipView()
    
    override func awakeFromNib() {
        setupUI()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //当视图从界面上删除，同样会调用此方法 newWindow == nil
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        guard let w = newWindow else {
            return
        }
        //视图添加到窗口上
        w.addSubview(tipView)
        tipView.isHidden = true
    }
    
    
    //MARK: - 监听方法
    @objc fileprivate func selectedEmoticonButton(button: UIButton){
        //1.取tag 0~20   tag == 20 -->删除按钮
        let tag = button.tag
        
        //2.根据tag判断是否是删除按钮，如果不是删除按钮，取得表情
        var em: LSEmotiIconModel?
        if tag < (emoticons?.count)!{
            em = emoticons?[tag]
        }
        //3.如果为nil 对应的是删除按钮
       // print(em)
       delegate?.emoticonCellDidSelectedEmoticon(cell: self, em: em)
    }
    
    
    
    //长按手势识别 
    //可以保证一个对象监听两种点击手势，而且不需要考虑解决手势冲突
    @objc fileprivate func longGesture(gesture: UILongPressGestureRecognizer){
 
        //测试添加提示视图
       // addSubview(tipView)
       
        //1>获取触摸位置
        let location = gesture.location(in: self)
        //2>获取触摸位置对应的按钮
        guard let button = buttonWithLocation(location: location) else{
            tipView.isHidden = true
            return
        }
        
        //处理手势状态
        switch gesture.state {
        case .began, .changed:
            
            tipView.isHidden = false
            
            //坐标系的转换 --> 将按钮参照 cell 的坐标系，转换到window的坐标位置
            let center = self.convert(button.center, to: window)
            //设置提示视图的位置
            tipView.center = center
            
            //设置提示视图的表情模型
            if button.tag < (emoticons?.count)! {
                tipView.emoticon = emoticons?[button.tag]
            }
        case .ended:
            tipView.isHidden = true
            //执行选中按钮的函数
            selectedEmoticonButton(button: button)
        case .cancelled, .failed:
            tipView.isHidden = true
        default:
            break
        }
    }
    
    fileprivate func buttonWithLocation(location: CGPoint) -> UIButton?{
        //遍历 contentView 所有的子视图，如果可见，同时在location确认 是 按钮
        for btn in contentView.subviews as! [UIButton] {
            if btn.frame.contains(location) && !btn.isHidden && btn != contentView.subviews.last {
                return btn
            }
            
        }
        return nil
    }
}
//MARK:- 设置界面
fileprivate extension LSEmoticonCell{
   
    
    //从xib加载，bounds是xib中定义的大小，不是size的大小
    //从纯代码创建，bounds是布局属性中设置的itemSize
    func setupUI(){
        
        //总行
        let rowCount: Int = 3
        //总列
        let colCount: Int = 7
        //左右间距
        let leftMargin: CGFloat = 8
        //底部间距  为分页控件预留
        let bottomMargin: CGFloat = 16
        
        let w = (bounds.width - 2 * leftMargin) / CGFloat(colCount)
        let h = (bounds.height - bottomMargin) / CGFloat(rowCount)
        
        //连续创建21个按钮
        for i in 0..<21 {
            let row = i / colCount
            let col = i % colCount
            
            let btn = UIButton()
            
            //设置按钮大小
            let x = leftMargin + CGFloat(col) * w
            let y = CGFloat(row) * h
            btn.frame = CGRect(x: x, y: y, width: w, height: h)
            //btn.backgroundColor = UIColor.red
            //设置按钮的字体大小,lineHeight基本上和图片的大小差不多
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 32)
            contentView.addSubview(btn)
            
            //设置按钮的tag
            btn.tag = i
            //添加监听方法
            btn.addTarget(self, action: #selector(selectedEmoticonButton(button:)), for: .touchUpInside)
        }
        //取出末尾的删除按钮
        let removeButton = contentView.subviews.last as! UIButton
        
        //设置图像
        let image = UIImage(named: "compose_emotion_delete_highlighted", in: LSEmotiIconManager.shared.bundle, compatibleWith: nil)
        removeButton .setImage(image, for: [])
        
        
        //添加长按手势
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longGesture))
        longPress.minimumPressDuration = 0.1
        addGestureRecognizer(longPress)
    }
    
}
