//
//  MessageViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/25/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import JSQMessagesViewController


class MessageViewController: JSQMessagesViewController {

    var topic: Topic?
    var messages = [Message]()
    var jsqMessages = [JSQMessage]()
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBar = self.tabBarController as! TopicTabBarController
        self.topic = tabBar.topic
        self.senderId = InboxManager.sharedInstance.currentUserID.recordName
        self.senderDisplayName = InboxManager.sharedInstance.currentUserID.recordName

        // Do any additional setup after loading the view.
        getMessages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMessages () {
        InboxManager.sharedInstance.getMessages(self.topic!) { (messages) -> Void in
            self.messages = messages!
            self.jsqMessagesFromMessages()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView?.reloadData()
            })
        }
    }
    
    func jsqMessagesFromMessages () {
        var newMessages = [JSQMessage]()
        for message in self.messages {
            let senderID = message.sender.recordID
            let senderName = message.sender.firstName! + " " + message.sender.familyName!
            let text = message.body
            let date = message.date
            let newMessage = JSQMessage(senderId: senderID, senderDisplayName: senderName, date: date, text: text)
            newMessages.append(newMessage)
            
        }
        self.jsqMessages = newMessages
    }

}

extension MessageViewController {
      // MARK: - DataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.jsqMessages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.jsqMessages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.jsqMessages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = jsqMessages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
}

//MARK: - Toolbar
extension MessageViewController {
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.jsqMessages += [message]
        self.finishSendingMessage()
        
        //warning: save new messageobject
        let cloudMessage = Message(sender: Friend(firstName: nil, familyName: nil, recordIDString: senderId), body: text, topic: (self.topic?.recordID)!, date: date)
        InboxManager.sharedInstance.saveMessage(cloudMessage)
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
    }
}
