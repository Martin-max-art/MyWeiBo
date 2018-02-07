//
//  WBHomeViewController.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/9.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import UIKit
//定义全局常量，尽量使用 private
//被转发微博可重用 cellId
private let retweetedCellId = "retweetedCellId"
//原创微博可重用 cellId
private let originalCellId = "originalCellId"

class LSHomeViewController: LSBaseViewController {
  
    //微博数据源
    lazy var statusList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //注册通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(browserPhoto),
                                               name: NSNotification.Name(rawValue: LSStautsCellBrowserPhotoNotification),
                                               object: nil)
    }
    
    deinit {
        //注销通知
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:浏览照片的通知监听方法
    @objc fileprivate func browserPhoto(n: Notification){
        //1.从通知的userInfo提取参数
        guard let selectedIndex = n.userInfo?[LSStatusCellBrowserPhotoSelectedIndexKey] as? Int,
              let urls = n.userInfo?[LSStatusCellBrowserPhotoURLsKey] as? [String],
              let imageViewList = n.userInfo?[LSStatusCellBrowserPhotoImageViewsKey] as? [UIImageView]
            else{
                return
        }
        
        //展现照片浏览控制器
        let vc = HMPhotoBrowserController.photoBrowser(withSelectedIndex: selectedIndex,
                                                       urls: urls,
                                                       parentImageViews: imageViewList)
        present(vc, animated: true, completion: nil)
        
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
        //xcode8.0之后什么也不显示
        refreshControl?.beginRefreshing()
        
        //模拟延时
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            //print("准备刷新，最后一条\(self.listViewModel.statuList.last?.status.text)")
            
            self.listViewModel.loadStatus(pullup: self.isPullRefresh) { (isSuccess,hasMorePullup) in
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
}
//MARK:表格数据源方法
extension LSHomeViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listViewModel.statuList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        //0取视图模型
        let vm = listViewModel.statuList[indexPath.row]
        let cellId = (vm.status.retweeted_status != nil) ? retweetedCellId : originalCellId
        //FIXME:根据是否是转发微博选择cell
        //1.取cell
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! LSStatusCell
        //2.设置cell
        cell.viewModel = vm
        //3.设置代理
        cell.delegate = self
        
        return cell
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //1.根据indexPath获取视图模型
        let vm = listViewModel.statuList[indexPath.row]
        //2.返回计算好的行高
        return vm.rowHeight
    }
}
//MARK: - LSStatusCellDelegate
extension LSHomeViewController: LSStatusCellDelegate{
    func statusCellDidTapURLString(cell: LSStatusCell, urlString: String) {
        print(urlString)
        let vc = LSWebViewController()
        vc.urlString = urlString
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LSHomeViewController{
    //重写父类的方法
    override func setUpTableView() {
    
        super.setUpTableView()
        
        //设置导航栏按钮  系统的无法高亮
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "好友", style: .plain, target: self, action: #selector(showFriends))
        navItem.leftBarButtonItem = UIBarButtonItem(title: "好友", target: self, action: #selector(showFriends))
        
        tableView?.register(UINib(nibName: "LSStatusNomalCell", bundle: nil), forCellReuseIdentifier: originalCellId)
        tableView?.register(UINib(nibName: "LSStatusRetweedCell", bundle: nil), forCellReuseIdentifier: retweetedCellId)
        //设置行高
//        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 300
        //取消分割线
        tableView?.separatorStyle = .none
        
        
        
        setupNavTitle()
    }
    //设置导航栏标题
    @objc fileprivate func setupNavTitle(){
        
        let title = "LSP的微博"
        let button = LSTitleButton(title: title)
        navItem.titleView = button
        button.addTarget(self, action: #selector(clickTitleButton), for: .touchUpInside)
    }
    @objc fileprivate func clickTitleButton(btn: UIButton){
        btn.isSelected = !btn.isSelected
    }
}
