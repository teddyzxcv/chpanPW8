//
//  TabBarController.swift
//  chpanPW8
//
//  Created by ZhengWu Pan on 19.03.2022.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpViewControllers()
    }
    
    private func setUpViewControllers(){
        viewControllers = [
            createNavigController(for: MoviesViewController(), title: "Movies", image: UIImage(named: "Movie")!),
            createNavigController(for: SearchViewController(), title: "Search", image: UIImage(named: "Search")!),
            createNavigController(for: PagingViewController(), title: "Pages", image: UIImage(named: "Page")!),
            createNavigController(for: ScrollViewController(), title: "Scroll", image: UIImage(named: "Scroll")!)
        ]
    }
    
    private func createNavigController(for rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController{
        let navVC = UINavigationController(rootViewController: rootViewController)
        navVC.tabBarItem.title = title
        navVC.tabBarItem.image = image
        navVC.navigationBar.prefersLargeTitles = true
        rootViewController.navigationItem.title = title
        return navVC
    }
    
}
