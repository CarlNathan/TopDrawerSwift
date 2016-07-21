//
//  NavView.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/10/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit
import Material

protocol CustomNavSearchDelegate{
    
}

protocol CustomNavigationDelegate{
    
}

class NavView: MaterialView {
    
    let leftButton = FlatButton()
    let rightButton = FabButton()
    let logo = UIImageView()
    var searchDelegate: CustomNavSearchDelegate?
    var navDelegate: CustomNavigationDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackground()
        setupLogo()
        setupLeftButton()
        setupRightButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBackground()
        setupLogo()
        setupLeftButton()
        setupRightButton()

    }
    
    func setupBackground(){
        backgroundColor = UIColor.whiteColor()
        depth = .Depth4
        borderColor = MaterialColor.orange.accent1
        borderWidth = 2
    }
    
    func setupLogo(){
        logo.image = UIImage(named: "TopDrawer")
        logo.tintColor = UIColor.blackColor()
        logo.contentMode = .ScaleToFill
        addSubview(logo)
    }
    
    
    func setupLeftButton(){
        leftButton.backgroundColor = MaterialColor.white
        leftButton.imageView!.contentMode = .ScaleToFill
        leftButton.setImage(UIImage(named: "cm_menu_white")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        leftButton.tintColor = UIColor.blackColor()
        leftButton.addTarget(self, action: #selector(hamburgerPressed), forControlEvents: .TouchUpInside)
        addSubview(leftButton)        
    }
    
    func setupRightButton(){
        rightButton.backgroundColor = MaterialColor.grey.darken3
        rightButton.setImage(UIImage(named: "ic_search_white")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        rightButton.tintColor = UIColor.whiteColor()
        rightButton.addTarget(self, action: #selector(searchPressed), forControlEvents: .TouchUpInside)
        addSubview(rightButton)
        rightButton.hidden = false
    }
    
        
    override func layoutSubviews() {
        layoutLogo()
        layoutLeftButton()
        layoutRightButton()
    }
    
    
    func layoutLogo(){
        logo.frame.size = CGSize(width: 100, height: 20)
        logo.center = CGPoint(x: center.x, y: center.y+10)
    }
    
    
    func layoutLeftButton(){
        leftButton.frame = CGRect(x: 10, y: 30, width: 50, height: 30)
    }
    
    func layoutRightButton(){
        rightButton.frame = CGRect(x: bounds.width - 40, y: 30, width: 30, height: 30)
    }
}

extension NavView: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        let item = viewController.navigationItem
    }
}

extension NavView {
    func hamburgerPressed(){
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "PopDownMenu", object: nil, userInfo: nil))
        //nav delegate pop controller
    }
    
    func searchPressed() {
         NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "SearchPressed", object: nil, userInfo: nil))
        if !leftButton.hidden {
            leftButton.hidden = true
            rightButton.setImage(UIImage(named: "ic_close_white")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        } else {
            leftButton.hidden = false
            rightButton.setImage(UIImage(named: "ic_search_white")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        }
    }
}

