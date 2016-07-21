//
//  SearchView.swift
//  PullTabView
//
//  Created by Carl Udren on 7/19/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit
import Material

protocol SearchViewDelegate {
    func searchInputDidChange(text: String)
    func searchButtonPressed()
}

class SearchView: UIView {
    
    let delegate: SearchViewDelegate
    let searchButton = FabButton()
    let searchEntryField = TextField()
    
    init(delegate: SearchViewDelegate) {
        self.delegate = delegate
        super.init(frame: CGRect.zero)
        setupBackground()
        setupSearchButton()
        setupSearchEntryField()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBackground() {
        backgroundColor = MaterialColor.amber.base
    }
    
    func setupSearchButton() {
        searchButton.setImage(UIImage(named: "ic_search_white")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        searchButton.backgroundColor = MaterialColor.grey.darken3
        searchButton.addTarget(self, action: #selector(searchButtonPressed), forControlEvents: .TouchUpInside)
        searchButton.tintColor = UIColor.whiteColor()
        //addSubview(searchButton)
    }
    
    func setupSearchEntryField() {
        searchEntryField.placeholder = "Search"
        searchEntryField.backgroundColor = UIColor.whiteColor()
        searchEntryField.cornerRadius = 5
        searchEntryField.textAlignment = .Center
        searchEntryField.clearButtonMode = .Always
        searchEntryField.clearButton = RaisedButton()
        searchEntryField.clearButton?.setTitle("clear", forState: .Normal)
        searchEntryField.font = RobotoFont.lightWithSize(14)
        searchEntryField.bottomBorderColor = MaterialColor.clear
        searchEntryField.delegate = self
        addSubview(searchEntryField)
        searchEntryField.hidden = true
    }
    
    override func layoutSubviews() {
        layoutSearchButton()
        layoutSearchEntryField()
        setMask()
    }
    
    func layoutSearchButton() {
        searchButton.frame = CGRect(x: 50, y: 5, width: 20, height: 20)
    }
    
    func layoutSearchEntryField() {
        searchEntryField.frame = CGRect(x: 40, y: 6, width: bounds.width - 50, height: bounds.height - 10)
    }
    
    func setMask() {
        let maskLayer = CAShapeLayer()
        maskLayer.path = getPath().CGPath
        layer.mask = maskLayer
    }
    
    func getPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: bounds.height))
        path.addLineToPoint(CGPoint(x: bounds.width, y: bounds.height))
        path.addLineToPoint(CGPoint(x: bounds.width, y: 0))
        path.addLineToPoint(CGPoint(x: 20, y: 0))
        
        return path
    }
    
    func searchButtonPressed() {
        delegate.searchButtonPressed()
    }
    
    func enableSearch() {
        searchEntryField.hidden = false
        searchEntryField.alpha = 0
        UIView.animateWithDuration(0.2) { 
            self.searchEntryField.alpha = 1
        }
        searchEntryField.becomeFirstResponder()
        searchButton.setImage(UIImage(named: "ic_close_white")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
    }
    
    func disableSearch() {
        UIView.animateWithDuration(0.2, animations: {
            self.searchEntryField.alpha = 0
            }) { (completed) in
                self.searchEntryField.hidden = true
        }
        searchEntryField.resignFirstResponder()
        searchButton.setImage(UIImage(named: "ic_search_white")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        searchEntryField.text = ""
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return getPath().containsPoint(point)
    }

}

extension SearchView: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        delegate.searchInputDidChange(string)
        return true
    }
}