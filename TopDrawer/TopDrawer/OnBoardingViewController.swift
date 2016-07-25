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
import MBProgressHUD

class OnBoardingViewController: UIViewController {
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let settingsButton = RaisedButton()
    let button = RaisedButton()
    
    override func viewDidLoad() {
        setupView()
        setupImageView()
        setupTitleLabel()
        setupSubtitleLabel()
        setupSettingsButton()
        setupButton()
    }
    
    func setupView() {
        view.backgroundColor = UIColor.whiteColor()
    }
    
    func setupImageView() {
        imageView.image = UIImage(named: "iCloud")?.imageWithRenderingMode(.AlwaysTemplate)
        imageView.tintColor = MaterialColor.blue.accent1
        imageView.contentMode = .ScaleToFill
        view.addSubview(imageView)
    }
    
    func setupTitleLabel() {
        titleLabel.text = "Error connecting to iCloud"
        titleLabel.font = RobotoFont.boldWithSize(20)
        titleLabel.textColor = MaterialColor.blue.accent1
        titleLabel.textAlignment = .Center
        titleLabel.numberOfLines = 2
        view.addSubview(titleLabel)
    }
    
    func setupSubtitleLabel() {
        subtitleLabel.text = "Please go to: Settings -> iCould to ensure you are signed in to continue"
        subtitleLabel.font = RobotoFont.lightWithSize(14)
        subtitleLabel.textColor = MaterialColor.blue.accent1
        subtitleLabel.numberOfLines = 3
        subtitleLabel.textAlignment = .Center
        view.addSubview(subtitleLabel)
    }
    
    func setupSettingsButton() {
        settingsButton.backgroundColor = MaterialColor.grey.darken2
        settingsButton.setTitle("GO TO SETTINGS", forState: .Normal)
        settingsButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        settingsButton.addTarget(self, action: #selector(launchiCloudSettings), forControlEvents: .TouchUpInside)
        view.addSubview(settingsButton)
    }
    
    func setupButton() {
        button.setTitle("RETRY", forState: .Normal)
        button.addTarget(self, action: #selector(retryLogin), forControlEvents: .TouchUpInside)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.backgroundColor = MaterialColor.amber.base
        view.addSubview(button)
    }
    
    override func viewDidLayoutSubviews() {
        layoutImageView()
        layoutTitleLabel()
        layoutSubtitleLabel()
        layoutButton()
        layoutSettingsButton()
    }
    
    func layoutImageView() {
        imageView.frame = CGRect(x: view.bounds.width/4, y: view.bounds.height/6, width: view.bounds.width/2, height: view.bounds.width/3)
    }
    
    func layoutTitleLabel() {
        titleLabel.frame = CGRect(x: 40, y: imageView.frame.maxY + 30, width: view.bounds.width - 80, height: 50)
    }
    
    func layoutSubtitleLabel() {
        subtitleLabel.frame = CGRect(x: 40, y: titleLabel.frame.maxY + 10, width: view.bounds.width - 80, height: 60)
    }
    
    func layoutButton() {
        button.frame = CGRect(x: view.bounds.width / 8, y: view.bounds.height - 100, width: view.bounds.width * 3 / 4, height: 50)
    }
    
    func layoutSettingsButton() {
        settingsButton.frame = CGRect(x: view.bounds.width / 8, y: button.frame.minY - 80, width: view.bounds.width * 3 / 4, height: 50)
    }
    
}

extension OnBoardingViewController {
    func retryLogin() {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.label.text = "Checking iCloud"
        DataCoordinatorInterface.sharedInstance.signIn({
            dispatch_async(dispatch_get_main_queue(), {
                DataCoordinatorInterface.sharedInstance.startupSequence()
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            }) {
                dispatch_async(dispatch_get_main_queue(), {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.subtitleLabel.textColor = UIColor.whiteColor()
                    UIView.animateWithDuration(0.2, animations: {
                        self.subtitleLabel.textColor = MaterialColor.red.darken2
                    })
                })
                //login failed do nothing...
        }
    }
    
    func launchiCloudSettings() {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
}