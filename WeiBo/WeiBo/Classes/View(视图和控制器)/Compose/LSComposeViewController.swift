//
//  LSComposeViewController.swift
//  WeiBo
//
//  Created by lishaopeng on 17/1/6.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import UIKit
import SVProgressHUD

/**
 加载视图控制器的时候，如果XIB和控制器同名，默认的构造函数，会优先加载XIB
 */
class LSComposeViewController: UIViewController {

   //文本编辑视图
    @IBOutlet weak var textView: LSComposeTextView!
    //底部工具栏
    @IBOutlet weak var toolBar: UIToolbar!
    //发布按钮
    @IBOutlet var sendButton: UIButton!
    //标题标签 - 换行的热键option + enter
    //逐行选中文本并且设置属性
    //如果想要调整行间距，可以增加一个空行，设置空行字体大小调整行间距
    @IBOutlet var titleLabel: UILabel!
    //工具栏底部约束
    @IBOutlet weak var toolBarBottoms: NSLayoutConstraint!
    
    //表情输入视图
    lazy var emoticonView: LSEmoticonInputView = LSEmoticonInputView.inputView { [weak self](emoticon) in
        // print(emoticon)
        self?.textView.insertEmoticon(em: emoticon)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
        //监听键盘通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardChanged),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //激活键盘
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //关闭键盘
        textView.resignFirstResponder()
    }
    
    deinit {
      
    }
    //MARK:-键盘监听方法
    @objc fileprivate func keyboardChanged(noti: Notification){
       // print(noti)
        //1.目标rect 
        guard let rect = (noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let duration = (noti.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
            else{
            return
        }
        
        
        //2.设置底部约束的高度
        let offset = view.bounds.height - rect.origin.y
        
        //3.更新底部约束
        self.toolBarBottoms.constant = offset
        
        //4.动画更新约束
        UIView.animate(withDuration: duration) {
           
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc fileprivate func close(){
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - 切换表情键盘
    @objc fileprivate func emoticonKeyboard(){
        //textView.inputView 就是文本的输入视图
        //如果使用系统默认的键盘，输入视图为nil
        
        //1>测试键盘视图 ----视图宽度可以随便指，就是屏幕宽度
//        let keyboardView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 253))
//        keyboardView.backgroundColor = UIColor.green
        
        //2>设置键盘视图
        textView.inputView = (textView.inputView == nil) ? emoticonView : nil
        
        //3>刷新键盘视图
        textView.reloadInputViews()
       
    }
    
    
    
    
   //MARK: - 发布按钮
    @IBAction func sendButtonClick(_ sender: Any) {
        print("发布微博")
        
        //1.获取微博文字
        let text = textView.emoticonText 
        //2.发布微博
        let image = UIImage(named: "icon_small_kangaroo_loading_1")
        
        LSNetworkManager.shared.postStatus(text: text, image: image) { (result, isSuccess) in
            //print(result)
            //修改指示器渐变
            SVProgressHUD.setDefaultStyle(.dark)
            let message = isSuccess ? "发布成功" : "网络不给力"
            SVProgressHUD.showInfo(withStatus: message)
            
            //如果成功，延时一段时间关闭当前窗口
            if isSuccess{
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    //恢复样式
                    SVProgressHUD.setDefaultStyle(.light)
                    
                    self.close()
                })
            }
        }
    }
    
//    lazy var sendButton: UIButton = {
//        let btn = UIButton()
//        btn.setTitle("发布", for: [])
//        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
//        //设置标题颜色
//        btn.setTitleColor(UIColor.white, for: [])
//        btn.setTitleColor(UIColor.gray, for: .disabled)
//        
//        //设置背景图片
//        btn.setBackgroundImage(UIImage(named: "common_button_orange"), for: [])
//        btn.setBackgroundImage(UIImage(named: "common_button_orange_highlighted"), for: .highlighted)
//        btn.setBackgroundImage(UIImage(named: "common_button_white_disable"), for: .disabled)
//        
//        //设置大小
//        btn.frame = CGRect(x: 0, y: 0, width: 45, height: 35)
//        
//        return btn
//    }()

}
//MARK: - UITextViewDelegate
/**
 代理:最后设置的代理对象有效
 */
extension LSComposeViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        sendButton.isEnabled = textView.hasText
    }
}

fileprivate extension LSComposeViewController{
    func setupUI(){
        view.backgroundColor = UIColor.white
        //设置navigationItem
        setupNavigationBar()
        //设置toolBar
        setupToolBar()
    }
    func setupNavigationBar(){

        //设置关闭按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", target: self, action: #selector(close))
        
        //设置发送按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sendButton)
        
        //设置标题视图
        navigationItem.titleView = titleLabel
        
       
    }
    //设置工具栏
    func setupToolBar(){
        
        let itemSettings = [["imageName": "compose_toolbar_picture"],
                            ["imageName": "compose_mentionbutton_background"],
                            ["imageName": "compose_trendbutton_background"],
                            ["imageName": "compose_emoticonbutton_background", "actionName": "emoticonKeyboard"],
                            ["imageName": "compose_add_background"]]
        //遍历数组
        var items = [UIBarButtonItem]()
        for s in itemSettings {
            
            guard let imageName = s["imageName"] else {
                continue
            }
            
            let image = UIImage(named: imageName)
            let imageHelight = UIImage(named: imageName + "_highlighted")
            let btn = UIButton()
            btn.setImage(image, for: [])
            btn.setImage(imageHelight, for: .highlighted)
            btn.sizeToFit()
            
            //判断actionName
            if let actionName = s["actionName"]{
                //给按钮添加监听方法
                btn.addTarget(self, action: Selector(actionName), for: .touchUpInside)
            }
            
            //追加按钮
            items.append(UIBarButtonItem(customView: btn))
            //追加弹簧
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        //删除末尾追加弹簧
        items.removeLast()
        toolBar.items = items
    }
}
