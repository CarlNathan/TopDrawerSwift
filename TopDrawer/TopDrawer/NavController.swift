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

protocol CustomNavControllerSearchDelegate {
    func searchInputDidChange(text: String)
    func searchDidBecomeActive()
    func searchDidBecomeInactive()
}

class CustomNavController: UINavigationController {
    
    let navView = NavView(frame: CGRect.zero)
    var searchView: SearchView!
    let newButton = FabButton()
    var searchEnabled: Bool = false {
        didSet {
            if searchEnabled {
                searchDelegate?.searchDidBecomeActive()
            } else {
                searchDelegate?.searchDidBecomeInactive()
            }
        }
    }
    var searchDelegate: CustomNavControllerSearchDelegate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupSearchView()
        setupNavView()
        setupNewButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSearchView()
        setupNavView()
        setupNewButton()
    }
    
    func setupSearchView() {
        searchView = SearchView(delegate: self)
        view.addSubview(searchView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(searchButtonPressed), name: "SearchPressed", object: nil)
    }
    
    func setupNavView() {
        navigationBar.hidden = true
        delegate = navView
        view.addSubview(navView)
    }
    
    func setupNewButton() {
        newButton.backgroundColor = MaterialColor.grey.darken3
        newButton.setImage(UIImage(named: "ic_add_white")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        newButton.tintColor = UIColor.whiteColor()
        newButton.addTarget(self, action: #selector(addPressed), forControlEvents: .TouchUpInside)
        newButton.depth = .Depth3
        view.addSubview(newButton)
    }
    
    override func viewDidLayoutSubviews() {
        layoutSearchView()
        layoutNavView()
        layoutNewButton()
    }
    
    func layoutSearchView(){
        searchView.frame = CGRect(x: view.bounds.width * 2 / 5 + 4, y: 72, width: view.bounds.width + 30, height: 30)
    }
    
    func layoutNavView() {
        navView.frame = CGRect(x: -2, y: -2, width: view.bounds.width+4, height: 74)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    func layoutNewButton() {
        newButton.frame = CGRect(x: 20, y: view.bounds.height - 70, width: 50, height: 50)
    }
    
    func addPressed() {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "NewTopicPressed", object: nil, userInfo: nil))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        searchView.searchEntryField.resignFirstResponder()
    }

}

extension CustomNavController: SearchViewDelegate {
    func searchInputDidChange(text: String) {
        searchDelegate?.searchInputDidChange(text)
    }
    
    func searchButtonPressed() {
        if !searchEnabled {
            UIView.animateKeyframesWithDuration(0.2, delay: 0, options: .CalculationModeCubicPaced, animations: {
                self.searchView.frame = CGRect(x: -30, y: 72, width: self.view.bounds.width + 30, height: 30)
                }, completion: { (finished) in
            })
            searchEnabled = true
            searchView.enableSearch()
        } else {
            
            UIView.animateWithDuration(0.2, animations: {
                self.searchView.frame = CGRect(x: self.view.bounds.width * 2 / 5 + 4, y: 72, width: self.view.bounds.width + 30, height: 30)
                }, completion: { (finished) in
            })
            searchEnabled = false
            searchView.disableSearch()
        }
    }
    
}

