//
//  WBHomeViewController.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/9.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import UIKit
//定义全局常量，尽量使用 private
private let cellId = "cellId"

class LSHomeViewController: LSBaseViewController {
  
    //微博数据源
    lazy var statusList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    //显示好友
    func showFriends() {
        let vc = LSDemoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //列表视图模型
    lazy var listViewModel = LSStatusListViewModel()
   //创建假的数据源z
    override func loadData(){
           print("准备刷新，最后一条\(self.listViewModel.statuList.last?.text)")
            listViewModel.loadStatus(pullup: self.isPullRefresh) { (isSuccess,hasMorePullup) in
                //结束刷新控件
                self.refreshControl?.endRefreshing()
                //恢复上拉刷新标记
                self.isPullRefresh = false
                if hasMorePullup{
                    //刷新表格
                    self.tableView?.reloadData()
                }
               
            }
    }
}
//MARK:表格数据源方法
extension LSHomeViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listViewModel.statuList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = listViewModel.statuList[indexPath.row].text
        return cell
        
    }
}

extension LSHomeViewController{
    //重写父类的方法
    override func setUpTableView() {
    
        super.setUpTableView()
        
        //设置导航栏按钮  系统的无法高亮
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "好友", style: .plain, target: self, action: #selector(showFriends))
        navItem.leftBarButtonItem = UIBarButtonItem(title: "好友", target: self, action: #selector(showFriends))
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        setupNavTitle()
    }
    //设置导航栏标题
    @objc fileprivate func setupNavTitle(){
        
        let title = "lsp"
        let button = LSTitleButton(title: title)
        navItem.titleView = button
        button.addTarget(self, action: #selector(clickTitleButton), for: .touchUpInside)
    }
    @objc fileprivate func clickTitleButton(btn: UIButton){
        btn.isSelected = !btn.isSelected
    }
}
