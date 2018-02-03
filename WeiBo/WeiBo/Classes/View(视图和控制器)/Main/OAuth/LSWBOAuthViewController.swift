//
//  LSWBOAuthViewController.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/19.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import UIKit
import SVProgressHUD

class LSWBOAuthViewController: UIViewController {

    lazy var webView: UIWebView = UIWebView()
    
    
    override func loadView() {
        view = webView
        view.backgroundColor = UIColor.white
        
        
        title = "登录新浪"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", fontSize: 14, target: self, action: #selector(closeView), isBack: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "自动填充", target: self, action: #selector(auotoFill))
        
      }
     func closeView() {//关闭控制器
        SVProgressHUD.dismiss()
        dismiss(animated: true, completion: nil)
    }
    
    //自动填充 - webView的注入 直接通过js 修改 本地浏览器缓存页面内容
    //点击登录按钮 执行submit() 将本地数据提交给服务器
   @objc private func auotoFill() {
        let js = "document.getElementById('userId').value = '15581554271';" + "document.getElementById('passwd').value = 'lsp13289435849';"
        webView.stringByEvaluatingJavaScript(from: js)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //加载授权页面
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=3348409467&redirect_uri=http://www.baidu.com"
        
        //1.URL 确定要访问的资源
        guard let url = URL(string: urlString) else {
            return
        }
        //2.建立请求
        let request = URLRequest(url: url)
        //3.加载请求
        webView.loadRequest(request)
        webView.delegate = self
        //取消滚动
        webView.scrollView.isScrollEnabled = false
    }

}
extension LSWBOAuthViewController: UIWebViewDelegate{
    /// 将要加载的请求
    ///
    /// - Parameters:
    ///   - webView:
    ///   - request: 要加载的请求
    ///   - navigationType: 导航类型
    /// - Returns: 是否加载request
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        print("加载网络--\(request.url?.absoluteString)")
        if request.url?.absoluteString.hasPrefix(AppRedirectURL) == false{
            return true
        }

        if request.url?.query?.hasPrefix("code=") == false{
            print("取消授权")
            closeView()
            return false
        }
        //从query中获取授权码代码走到此处 url中一定包含字符串  "code=".endIndex:从code=的结尾
       let code = request.url?.query?.substring(from: "code=".endIndex) ?? ""
        print("获取授权码code..\(code)")
        
        //使用授权码获取AccessToken
        LSNetworkManager.shared.loadAccessToken(code: code) { (isSuccess) in
            if !isSuccess{
                SVProgressHUD.showInfo(withStatus: "网络请求失败")
                
            }else{
               // SVProgressHUD.showInfo(withStatus: "登录成功")
                //下一步跳转界面
                //1.发送通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: LSUserLoginSuccessNotification), object: nil)
                //2.关闭界面
                self.closeView()
            }
        }
//        LSNetworkManager.shared.loadAccessToken(code: code)
        
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {//开始的时候加载菊花
        SVProgressHUD.show()
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {//结束的时候隐藏菊花
        SVProgressHUD.dismiss()
    }
    
}
