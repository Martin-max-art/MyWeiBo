//
//  LSStatusToolBar.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/29.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import UIKit

class LSStatusToolBar: UIView {
    
    var viewModel:LSStatusViewModel?{
        didSet{
//            retweetedButton.setTitle("\(viewModel?.status.reports_count)", for: .normal)
//            commentButton.setTitle("\(viewModel?.status.comments_count)", for: .normal)
//            likeButton.setTitle("\(viewModel?.status.attitudes_count)", for: .normal)
            retweetedButton.setTitle(viewModel?.retweetedStr, for: .normal)
            commentButton.setTitle(viewModel?.commentStr, for: .normal)
            likeButton.setTitle(viewModel?.likeStr, for: .normal)
        }
    }
    
    //转发
    @IBOutlet weak var retweetedButton: UIButton!
    //评论
    @IBOutlet weak var commentButton: UIButton!
    //点赞
    @IBOutlet weak var likeButton: UIButton!

}
