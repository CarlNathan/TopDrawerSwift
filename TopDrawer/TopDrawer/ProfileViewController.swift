//
//  ProfileViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/23/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import CloudKit
import Contacts
import Material

class ProfileViewController: UIViewController {
    
    let tableView = UITableView()
    let topView = ProfileTopView()
    var friends = [Friend]() {
        didSet {
            friends.sortInPlace { (a, b) -> Bool in
                a.familyName!.compare(b.familyName!) == NSComparisonResult.OrderedDescending
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopView()
        setupTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getFriends()

    }
    func setupTopView(){
        topView.delegate = self
        view.addSubview(topView)
    }
    
    func setupTableView(){
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "FriendCell")
        view.addSubview(tableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutTopView()
        layoutTableView()
    }
    
    func layoutTopView(){
        topView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height/2)
    }
    
    func layoutTableView(){
        tableView.frame = CGRect(x: 0, y: topView.frame.maxY, width: view.bounds.width, height: view.bounds.height - topView.bounds.height)
    }
    
    func getFriends () {
        friends = SearchAndSortAssistant().sortFriends(DataSource.sharedInstance.allFriends())
    }

}



extension ProfileViewController: UITableViewDataSource {
    // MARK: - Table view data source


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friends.count
    }

   
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath)

        // Configure the cell...
        let name = self.friends[indexPath.row].firstName! + " " + self.friends[indexPath.row].familyName!
        cell.textLabel!.text = name
        //cell.detailTextLabel!.text = "Hi!  I'm using TopDrawer!"

        return cell
    }


}

extension ProfileViewController: UIImagePickerControllerDelegate, ProfileTopViewDelegate, UINavigationControllerDelegate {
    func openImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .Camera
        picker.allowsEditing = false
        presentViewController(picker, animated: true) { 
            //
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let ratio = pickedImage.size.height/pickedImage.width
            let scaledImage = pickedImage.scaleImage(CGSize(width: 100, height: ratio*100))
            topView.profileImage.setImage(scaledImage, forState: .Normal)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
