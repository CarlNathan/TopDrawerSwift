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
    let grad = CAGradientLayer()
    let logo = UIImageView()
    let titleLabel = UILabel()
    private var searchEnabled: Bool = false
    let searchField = TextField()
    var searchDelegate: CustomNavSearchDelegate?
    var navDelegate: CustomNavigationDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackground()
        setupLogo()
        setupTitleLabel()
        setupLeftButton()
        setupRightButton()
        setupSearchField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBackground()
        setupLogo()
        setupTitleLabel()
        setupLeftButton()
        setupRightButton()
        setupSearchField()

    }
    
    func setupBackground(){
        backgroundColor = UIColor.whiteColor()
        grad.colors = [UIColor.blackColor().CGColor, UIColor.whiteColor().CGColor]
        grad.locations = [0.5,1.0]
        //layer.insertSublayer(grad, atIndex: 0)
        depth = .Depth4
        borderColor = MaterialColor.orange.accent1
        borderWidth = 2
    }
    
    func setupLogo(){
        logo.image = UIImage(named: "contacts")
        logo.tintColor = UIColor.blackColor()
        logo.contentMode = .ScaleToFill
        addSubview(logo)
    }
    
    func setupTitleLabel() {
        titleLabel.text = ""
        titleLabel.textColor = MaterialColor.grey.darken3
        titleLabel.font = RobotoFont.lightWithSize(14)
        titleLabel.backgroundColor = UIColor.clearColor()
        addSubview(titleLabel)
    }
    
    func setupLeftButton(){
        leftButton.backgroundColor = MaterialColor.white
        leftButton.imageView!.contentMode = .ScaleToFill
        leftButton.setImage(UIImage(named: "ic_arrow_back_white")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        leftButton.tintColor = UIColor.blackColor()
        leftButton.addTarget(self, action: #selector(backButtonPressed), forControlEvents: .TouchUpInside)
        addSubview(leftButton)
        leftButton.hidden = true
        
    }
    
    func setupRightButton(){
        rightButton.backgroundColor = MaterialColor.grey.darken3
        rightButton.setImage(UIImage(named: "cm_search_white")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        rightButton.tintColor = UIColor.whiteColor()
        rightButton.addTarget(self, action: #selector(searchButtonPressed), forControlEvents: .TouchUpInside)
        addSubview(rightButton)
        rightButton.hidden = false
    }
    
    func setupSearchField() {
        searchField.backgroundColor = UIColor.clearColor()
        searchField.placeholder = "Search"
        searchField.cornerRadius = 5
        searchField.textAlignment = .Center
        searchField.clearButtonMode = .WhileEditing
        searchField.font = RobotoFont.lightWithSize(14)
        searchField.bottomBorderColor = MaterialColor.blue.base
        searchField.delegate = self
        addSubview(searchField)
        searchField.hidden = true
        
    }
    
    override func layoutSubviews() {
        layoutGradient()
        layoutTitleLabel()
        layoutLogo()
        layoutLeftButton()
        layoutRightButton()
        layoutSearchSearchField()
    }
    
    func layoutGradient(){
        grad.frame = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: 25)
    }
    
    func layoutLogo(){
        logo.frame.size = CGSize(width: 30, height: 30)
        logo.center = CGPoint(x: center.x, y: center.y+10)
        if titleLabel.text == "" {
            logo.hidden = false
        } else {
            logo.hidden = true
        }
    }
    
    func layoutTitleLabel(){
        titleLabel.sizeToFit()
        titleLabel.center = center
        titleLabel.frame.origin.y += 10
    }
    
    func layoutLeftButton(){
        leftButton.frame = CGRect(x: 10, y: 30, width: 50, height: 30)
    }
    
    func layoutRightButton(){
        if searchEnabled {
            self.rightButton.frame = CGRect(x: self.leftButton.frame.maxX+5, y: 30, width: 30, height: 30)
        } else {
            rightButton.frame = CGRect(x: bounds.width - 40, y: 30, width: 30, height: 30)
        }
    }
    
    func layoutSearchSearchField(){
        searchField.frame = CGRect(x: leftButton.frame.maxX + 40, y: 30, width: bounds.width - leftButton.frame.maxX - 50, height: 25)
    }
    
    func searchButtonPressed() {
        if !searchEnabled {
            searchField.alpha = 0
            searchField.hidden = false
            UIView.animateWithDuration(0.2, animations: {
                self.titleLabel.alpha = 0
                self.logo.alpha = 0
                self.searchField.alpha = 1
                self.rightButton.frame = CGRect(x: self.leftButton.frame.maxX+5, y: 30, width: 30, height: 30)
                self.rightButton.setImage(UIImage(named:"cm_close_white")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                }, completion: { (finished) in
                    self.titleLabel.hidden = true
                    self.logo.hidden = true
            })
            searchEnabled = true
            searchField.becomeFirstResponder()
        } else {
            if titleLabel.text == "" {
                logo.hidden = false
            } else {
                logo.hidden = true
                titleLabel.hidden = false
            }

            UIView.animateWithDuration(0.2, animations: {
                self.rightButton.frame = CGRect(x: self.bounds.width - 40, y: 30, width: 30, height: 30)
                self.titleLabel.alpha = 1
                self.logo.alpha = 1
                self.searchField.alpha = 0
                self.rightButton.setImage(UIImage(named: "cm_search_white")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                }, completion: { (finished) in
                    self.searchField.hidden = true
            })
            searchEnabled = false
            searchField.resignFirstResponder()
        }
    }
}

extension NavView: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        let item = viewController.navigationItem
        if let title = item.title {
            titleLabel.text = title
        } else {
            titleLabel.text = ""
        }
        if !item.hidesBackButton {
            leftButton.hidden = false
        }
        if let rightItem = item.rightBarButtonItem {
            rightButton.hidden = false
            rightButton.setImage(rightItem.image, forState: .Normal)
        }
    }
}

extension NavView: TextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //search
        return true
    }
}

extension NavView {
    func backButtonPressed(){
        //nav delegate pop controller
    }
}
