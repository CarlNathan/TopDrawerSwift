//
//  SignInView.swift
//  TopDrawer
//
//  Created by Carl Udren on 4/28/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit
import Material

class OnBoardingViewController: UIViewController {
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let button = RaisedButton()
    
    override func viewDidLoad() {
        setupImageView()
        setupTitleLabel()
        setupSubtitleLabel()
        setupButton()
    }
    
    func setupImageView() {
        view.addSubview(imageView)
    }
    
    func setupTitleLabel() {
        titleLabel.text = "Error connecting to iCloud"
        titleLabel.font = RobotoFont.mediumWithSize(20)
        titleLabel.textAlignment = .Center
        titleLabel.numberOfLines = 2
        view.addSubview(titleLabel)
    }
    
    func setupSubtitleLabel() {
        subtitleLabel.text = "Please go to: Settings -> iCould to ensure you are signed in to continue"
        subtitleLabel.font = RobotoFont.lightWithSize(14)
        view.addSubview(subtitleLabel)
    }
    
    func setupButton() {
        button.setTitle("RETRY", forState: .Normal)
        button.addTarget(self, action: #selector(retryLogin), forControlEvents: .TouchUpInside)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.backgroundColor = MaterialColor.blue.accent1
        view.addSubview(button)
    }
    
    override func viewDidLayoutSubviews() {
        layoutImageView()
        layoutTitleLabel()
        layoutSubtitleLabel()
        layoutButton()
    }
    
    func layoutImageView() {
        imageView.frame = CGRect(x: view.bounds.width/3, y: view.bounds.height/10, width: view.bounds.width/3, height: view.bounds.width/3)
    }
    
    func layoutTitleLabel() {
        titleLabel.frame = CGRect(x: 40, y: imageView.frame.maxY + 30, width: view.bounds.width - 80, height: 40)
    }
    
    func layoutSubtitleLabel() {
        subtitleLabel.frame = CGRect(x: 40, y: titleLabel.frame.maxY + 10, width: view.bounds.width - 80, height: 60)
    }
    
    func layoutButton() {
        button.frame = CGRect(x: view.bounds.width / 3, y: view.bounds.height - 80, width: view.bounds.width / 3, height: 40)
    }
    
}

extension OnBoardingViewController {
    func retryLogin() {
        DataCoordinatorInterface.sharedInstance.signIn({
            self.dismissViewControllerAnimated(true, completion: nil)
            }) { 
                //login failed do nothing...
        }
    }
}