//
//  File.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/10/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit
import Material

class CustomTabBarController: UITabBarController {
    
    let tabView = TabView(frame: CGRect.zero)

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupTabView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTabView()
    }

    func setupTabView() {
        tabBar.hidden = true
        tabView.tabViewDelegate = self
        view.addSubview(tabView)
    }

    override func viewDidLayoutSubviews() {
        layoutNavView()
    }

    func layoutNavView() {
    tabView.frame = CGRect(x: -2, y: view.bounds.height-48, width: view.bounds.width+4, height: 50)
    }

}

extension CustomTabBarController: TabViewDelegate {
    func selected(index: Int) {
        selectedIndex = index
    }
}

