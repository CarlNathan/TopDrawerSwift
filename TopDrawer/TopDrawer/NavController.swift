//
//  CustomNavController.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/10/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit
import Material

class CustomNavController: UINavigationController {
    
    let navView = NavView(frame: CGRect.zero)
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupNavView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNavView()
    }
    
    func setupNavView() {
        navigationBar.hidden = true
        delegate = navView
        view.addSubview(navView)
    }
    
    override func viewDidLayoutSubviews() {
        layoutNavView()
    }
    
    func layoutNavView() {
        navView.frame = CGRect(x: -2, y: -2, width: view.bounds.width+4, height: 74)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }

}
