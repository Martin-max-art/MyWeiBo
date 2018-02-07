//
//  LSEmoticonTextView.swift
//  表情键盘
//
//  Created by lishaopeng on 17/1/13.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import UIKit
//可重用的标识符
fileprivate let cellId = "cellId"

//表情输入视图
class LSEmoticonInputView: UIView {

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var toolBar: LSEmoticonToolBar!
    
    @IBOutlet weak var pageControl: UIPageControl!
    //选中表情回调闭包的属性
    fileprivate var selectedEmoticonCallBack: ((_ emoticon: LSEmotiIconModel?)->())?
    
    //加载并且返回输入视图
    class func inputView(selectedEmoticon:@escaping (_ emoticon: LSEmotiIconModel?) -> ()) -> LSEmoticonInputView {
       
        let nib = UINib(nibName: "LSEmoticonInputView", bundle: nil)
        
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! LSEmoticonInputView
        
        //记录闭包
        v.selectedEmoticonCallBack = selectedEmoticon
        
        return v
        
    }
    override func awakeFromNib() {
        
        collectionView.backgroundColor = UIColor.white
        
        //注册可重用cell
        collectionView.register(LSEmoticonCell.self, forCellWithReuseIdentifier: cellId)
        
        //设置工具栏代理
        toolBar.delegate = self
        
        //设置分页控件的图片
        let bundle = LSEmotiIconManager.shared.bundle
        
        guard let normalImage = UIImage(named: "compose_keyboard_dot_normal", in: bundle, compatibleWith: nil),
            let selectedIamge = UIImage(named: "compose_keyboard_dot_selected", in: bundle, compatibleWith: nil) else{
                return
        }
        //使用了填充图片设置颜色--但是会把图片拉伸变形
        //        pageControl.pageIndicatorTintColor = UIColor(patternImage: normalImage)
        //        pageControl.currentPageIndicatorTintColor = UIColor(patternImage: selectedIamge)
        
        //使用KVC设置私有成员属性
        pageControl .setValue(normalImage, forKeyPath: "_pageImage")
        pageControl .setValue(selectedIamge, forKeyPath: "_currentPageImage")
    }
}

extension LSEmoticonInputView: LSEmoticonToolBarDelegate{
    func emoticonToolBarDidSelectedItermIndex(toolbar: LSEmoticonToolBar, index: Int) {
        //让collectView发生滚动
        let indexPath = IndexPath(item: 0, section: index)
        
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        
        //设置分组按钮的选中状态
        toolBar.selectedIdex = index
    }
}

extension LSEmoticonInputView: UICollectionViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //1.获取中心点
        var center = scrollView.center
        center.x += scrollView.contentOffset.x
        
        //2.获取当前显示的cell 的 indexPath
        let paths = collectionView.indexPathsForVisibleItems
        
        //3.判断中心点在哪一个indexPath上，在哪一个页面上
        var targetIndexPath: IndexPath?
        for indexPath in paths {
            //1>根据 indexPath 获得cell
            let cell = collectionView.cellForItem(at: indexPath)
            //2>判断中心点位置
            if cell?.frame.contains(center) == true {
                targetIndexPath = indexPath
                break
            }
        }
        
        guard let target = targetIndexPath else {
            return
        }
        
        //4.判断是否找到目标的indexPath--indexPath.section对应的就是分组
        toolBar.selectedIdex = target.section
        
        //5.设置分页控件
        //1>总页数，不同的分组，页数也不一样
        pageControl.numberOfPages = collectionView.numberOfItems(inSection: target.section)
        pageControl.currentPage = target.item
        
        
    }
}

extension LSEmoticonInputView: UICollectionViewDataSource{
    //分组数量
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return LSEmotiIconManager.shared.packagesArray.count
    }
    
    //返回每隔分组中的表情页
    //每个分组的表情包中  表情页面的数量 emoticons 数组 / 20
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LSEmotiIconManager.shared.packagesArray[section].numberOfPages 
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //1.取cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LSEmoticonCell
        //2.设置cell
        cell.emoticons = LSEmotiIconManager.shared.packagesArray[indexPath.section].emoticon(page: indexPath.item)
        cell.delegate = self
        //设置代理
        //3.返回cell
        return cell
    }
}
//MARK:--LSEmoticonCellDelegate
extension LSEmoticonInputView: LSEmotiIconCellDelegate{
    
    /// 选中的表情回调
    ///
    /// - Parameters:
    ///   - cell: 分页cell
    ///   - em: 选中的表情，删除键为nil
    func emoticonCellDidSelectedEmoticon(cell: LSEmoticonCell, em: LSEmotiIconModel?) {
        //print(em)
        //执行闭包，回调选中的表情
        selectedEmoticonCallBack?(em)
        
        //添加最近使用的表情
        guard let em = em else {
            return
        }
        //如果当前collectionView就是最近的分组，不添加最近使用的表情
        let indexPath = collectionView.indexPathsForVisibleItems[0]
        if indexPath.section == 0 {
            return
        }
        
        
        //添加最近使用的表情
        LSEmotiIconManager.shared.recentEmoticon(em: em)
        
        //刷新数据 --第0组
        var indexSet = IndexSet()
        indexSet.insert(0)
        collectionView.reloadSections(indexSet)
    }
}


