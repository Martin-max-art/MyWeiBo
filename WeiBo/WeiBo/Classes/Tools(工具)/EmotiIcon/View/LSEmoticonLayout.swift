//
//  LSEmoticonLayout.swift
//  表情键盘
//
//  Created by lishaopeng on 17/1/13.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import UIKit
//表情集合视图的布局
class LSEmoticonLayout: UICollectionViewFlowLayout {
    
    //prepare就是OC中的prepareLayout
    override func prepare() {
        
        super.prepare()
        
        //在此方法中，collectionView的大小已经确定
        guard let collectionView = collectionView else{
            return
        }
        
        itemSize = collectionView.bounds.size
    
        //设定滚动方向
        //水平方向滚动，cell 垂直方向布局
        //垂直方向滚动，cell 水平方向布局
        scrollDirection = .horizontal
    }
}
