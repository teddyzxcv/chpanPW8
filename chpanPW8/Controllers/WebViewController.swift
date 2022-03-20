//
//  WebViewController.swift
//  chpanPW8
//
//  Created by ZhengWu Pan on 19.03.2022.
//

import Foundation

import Foundation
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate{
    var webView = WKWebView()
    
    var url: URL?
    
    override func viewDidLoad() {
        webView.load(URLRequest(url: url!))
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        webView.pinRight(to: view)
        webView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor)
        webView.pinLeft(to: view)
    }
}
