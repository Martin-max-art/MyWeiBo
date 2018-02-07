//
//  LSComposeTextView.swift
//  WeiBo
//
//  Created by lishaopeng on 17/1/12.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import UIKit
//撰写文本视图
class LSComposeTextView: UITextView {
    
    fileprivate lazy var placeholderLabel = UILabel()
    
    override func awakeFromNib() {
        setupUI()
    }
    deinit {
        //注销通知
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: - 监听方法
    @objc fileprivate func textChanged(){
       //如果有文本，不显示占位标签，否则显示
        placeholderLabel.isHidden = self.hasText
    }
    
}

//MARK: - 表情键盘专属方法
extension LSComposeTextView{
    
    //返回textView对应的纯文本的字符串(将属性图片转换成文字)
    var emoticonText: String{
        
        //1.获取textView的属性文本
        guard let attsStr = attributedText else{
            return ""
        }
        
        //2.需要获得属性文本中的图片（附件 Attachment）
        var result = String()
        attsStr.enumerateAttributes(in: NSRange(location: 0, length: attsStr.length), options: [], using: { (dict, range, _) in
            print(dict)
            print(range)
            //如果字典中包含NSAttachment 'key'说明是图片，否则是文本
            if let attchment = dict["NSAttachment"] as? LSEmoticonAttachment{
                //                print("图片\(attchment)")
                result += attchment.chs ?? ""
            }else{
                let subStr = (attsStr.string as NSString).substring(with: range)
                result += subStr
            }
        })
        //        print(result)
        return result
    }
    
    
    
    
    
    
    ///向文本视图插入表情符号
    //--em:选中的表情符号 nil表示删除
    func insertEmoticon(em: LSEmotiIconModel?){
        
        //1.em == nil是删除按钮
        guard let em = em else {
            //删除文本
            deleteBackward()
            return
        }
        //2.emoji 字符串
        if let emoji = em.emoji,
            let textRange = selectedTextRange{
            
            //UITextRange仅用在此处!
            replace(textRange, withText: emoji)
            
            return
        }
        //3.代码执行到此，都是图片表情
        //0>获取表情中图像属性文本
        //所有的排版系统中，几乎都有一个共同特点，插入字符的显示，跟随前一个字符的属性，但是本身没有属性
        //        let imageText = NSMutableAttributedString(attributedString: em.imageText(font: .font!))
        //        //设置图像文字属性
        //        imageText.addAttributes([NSFontAttributeName : textView.font!], range: NSRange(location: 0, length: 1))
        
        let imageText = em.imageText(font: font!)
        
        
        //1>获取当前textView属性文本
        let attrStrM = NSMutableAttributedString(attributedString: attributedText)
        //2>将图像的属性文本插入到当前的光标位置
        attrStrM.replaceCharacters(in: selectedRange, with: imageText)
        //3>重新设置属性文本
        
        //记录光标位置
        let range = selectedRange
        
        //设置文本
        attributedText = attrStrM
        
        //恢复的光标位置 length是选中字符的长度，输入文本之后应该是0
        selectedRange = NSRange(location: range.location + 1, length:0)
        
        //4.让代理执行文本变方法 --- 在需要的时候，通知代理执行协议方法
        delegate?.textViewDidChange?(self)
        
        //5.执行当前对象的文本变化方法
        textChanged()
    }

}

fileprivate extension LSComposeTextView{
    
    func setupUI(){
        
        
        //0.注册通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textChanged),
                                               name: NSNotification.Name.UITextViewTextDidChange,
                                               object: self)
        
        
        //1.设置占位标签
        placeholderLabel.text = "分享新鲜事..."
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 8)
        placeholderLabel.sizeToFit()
        addSubview(placeholderLabel)
        

    }
}


