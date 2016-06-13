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
        InboxManager.sharedInstance.findUsers {
            self.friends = Array(InboxManager.sharedInstance.friends.values)
        }
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
            
            topView.profileImage.contentMode = .ScaleAspectFit
            topView.profileImage.setImage(pickedImage, forState: .Normal)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
