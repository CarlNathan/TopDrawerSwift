//
//  ProfileTopView.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/13/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit
import Material

protocol ProfileTopViewDelegate {
    func openImagePicker()
}

class ProfileTopView: UIView {
    let user = MissionControl.sharedInstance.currentUserID
    let backgroundImageView = UIImageView()
    let profileImage = FabButton()
    let usernameLabel = UILabel()
    var delegate: ProfileTopViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackgroundImageView()
        setupProfileImage()
        setupUsernameLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBackgroundImageView()
        setupProfileImage()
        setupUsernameLabel()
    }
    
    func setupBackgroundImageView(){
        let blueImage = UIImage.imageWithColor(MaterialColor.blue.lighten2, size: CGSize(width: 100, height: 100))
        backgroundImageView.image = blueImage
        addSubview(backgroundImageView)
    }
    
    func setupProfileImage(){
        profileImage.setImage(UIImage(named: "contacts"), forState: .Normal)
        profileImage.layer.masksToBounds = true
        profileImage.addTarget(self, action: #selector(selectedImageButton), forControlEvents: .TouchUpInside)
        profileImage.backgroundColor = MaterialColor.white
        profileImage.borderColor = MaterialColor.grey.darken2
        profileImage.borderWidth = 2
        addSubview(profileImage)
    }
    
    func setupUsernameLabel(){
        usernameLabel.text = "Sample User Name"
        usernameLabel.font = RobotoFont.mediumWithSize(18)
        usernameLabel.textAlignment = .Center
        addSubview(usernameLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutBackgroundImageView()
        layoutProfileImage()
        layoutUserNameLabel()
    }
    
    func layoutBackgroundImageView() {
        backgroundImageView.frame = bounds
    }
    
    func layoutProfileImage() {
        profileImage.frame.size = CGSize(width: 100, height: 100)
        profileImage.layer.cornerRadius = (profileImage.frame.width/2)
        profileImage.center = center
    }
    
    func layoutUserNameLabel() {
        usernameLabel.frame = CGRect(x: 0, y: (profileImage.frame.maxY + 10), width: bounds.width, height: 30)
    }
}

extension ProfileTopView {
    func selectedImageButton() {
        if delegate != nil {
            delegate!.openImagePicker()
        }
    }
}

