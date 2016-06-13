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

private enum tabIndex: Int {
    case savedPages = 0
    case topics = 1
    case sharedTopics = 2
    case profile = 3
}

protocol TabViewDelegate {
    func selected(index:Int)
}

class TabView: MaterialView {
    let savedPageTab = CustomTabBarButton(index: tabIndex.savedPages)
    let topicsTab = CustomTabBarButton(index: tabIndex.topics)
    let sharedTopicsTab = CustomTabBarButton(index: tabIndex.sharedTopics)
    let profileTab = CustomTabBarButton(index: tabIndex.profile)
    var tabViewDelegate: TabViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackground()
        setupSavedPageTab()
        setupTopicsTab()
        setupSharedTopicsTab()
        setupProfileTab()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBackground()
        setupTopicsTab()
        setupSavedPageTab()
        setupSharedTopicsTab()
        setupProfileTab()

    }
    
    func setupBackground(){
        backgroundColor = MaterialColor.grey.darken3
        depth = .Depth4
        borderWidth = 2
        borderColor = MaterialColor.blue.base
    }
    
    func setupSavedPageTab(){
        savedPageTab.setImage(UIImage(named: "cm_photo_library_white")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        savedPageTab.backgroundColor = MaterialColor.grey.darken2
        savedPageTab.depth = .Depth2
        savedPageTab.buttonDelegate = self
        addSubview(savedPageTab)
    }
    
    func setupTopicsTab(){
        topicsTab.setImage(UIImage(named: "cm_photo_library_white")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        topicsTab.buttonDelegate = self
        addSubview(topicsTab)
    }
    
    func setupSharedTopicsTab(){
        sharedTopicsTab.setImage(UIImage(named: "cm_photo_library_white")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        sharedTopicsTab.buttonDelegate = self
        addSubview(sharedTopicsTab)
    }
    
    func setupProfileTab(){
        profileTab.setImage(UIImage(named: "cm_photo_library_white")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        profileTab.buttonDelegate = self
        addSubview(profileTab)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutSavedPageTab()
        layoutTopicsTab()
        layoutSharedTopicsTab()
        layoutProfileTab()
    }
    
    func layoutSavedPageTab(){
        savedPageTab.frame = CGRect(x: 0, y: 0, width: bounds.width/3, height: bounds.height)
        print(savedPageTab.frame.origin.x)
    }
    
    func layoutTopicsTab(){
        topicsTab.frame = CGRect(x: savedPageTab.frame.maxX, y: 0, width: bounds.width*(2/9), height: bounds.height)
        print(topicsTab.frame.origin.x)

    }
    
    func layoutSharedTopicsTab(){
        sharedTopicsTab.frame = CGRect(x: topicsTab.frame.maxX, y: 0, width: bounds.width*(2/9), height: bounds.height)
        print(sharedTopicsTab.frame.origin.x)
    }
    
    func layoutProfileTab(){
        profileTab.frame = CGRect(x: sharedTopicsTab.frame.maxX, y: 0, width: bounds.width*(2/9), height: bounds.height)
        print(profileTab.frame.origin.x)
    }
    
}

extension TabView: CustomTabBarButtonDelegate {
    func didSelectTab(sender: CustomTabBarButton) {
        if tabViewDelegate != nil {
            tabViewDelegate!.selected(sender.index.rawValue)
        }
        savedPageTab.backgroundColor = MaterialColor.grey.darken3
        topicsTab.backgroundColor = MaterialColor.grey.darken3
        sharedTopicsTab.backgroundColor = MaterialColor.grey.darken3
        profileTab.backgroundColor = MaterialColor.grey.darken3
        sender.backgroundColor = MaterialColor.grey.darken1
        
    }
}

extension TabView: UITabBarControllerDelegate {
    
}

protocol CustomTabBarButtonDelegate {
    func didSelectTab(sender: CustomTabBarButton)
}

class CustomTabBarButton: FlatButton {
    
    private var index: tabIndex!
    var buttonDelegate: CustomTabBarButtonDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.index = tabIndex.savedPages
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private init(index: tabIndex) {
        super.init(frame: CGRect.zero)
        self.index = index
        setupButton()
    }
    
    func setupButton() {
        backgroundColor = MaterialColor.grey.darken4
        tintColor = UIColor.whiteColor()
        cornerRadius = 0
        pulseScale = false
        addTarget(self, action: #selector(buttonPressed), forControlEvents: .TouchUpInside)
    }
    
    func buttonPressed() {
        if buttonDelegate != nil {
            buttonDelegate!.didSelectTab(self)
        }
    }
}


