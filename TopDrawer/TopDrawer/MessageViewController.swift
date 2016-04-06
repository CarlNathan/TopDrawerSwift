//
//  MessageViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/25/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import CloudKit


class MessageViewController: JSQMessagesViewController, TopicMarkerSelectionDelegate {

    var topic: Topic?
    var messages = [Message]()
    var jsqMessages = [JSQMessage]() {
        didSet{
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.collectionView?.reloadData()
            self.initLastPath ()
            }
        }
    }
    var lastPath: Int!
    
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
        self.scrollToBottomAnimated(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessageViewController.newRemoteMessage(_:)), name: "RemoteMessage", object: nil)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Float(2.0) * Float(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.getMessages()
        }
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func newRemoteMessage(sender: NSNotification) {
        let recordID = sender.userInfo!["topicID"] as! CKRecordID
        InboxManager.sharedInstance.getMessageForID(recordID) { (message) -> Void in
            if message?.topicRef == self.topic?.recordID {
                self.messages.append(message!)
                self.addJSQMessage(message!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.collectionView?.reloadData()
                })
            } else {
                print("Off topic")
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMessages () {
        InboxManager.sharedInstance.getMessages(self.topic!) { (messages) -> Void in
            self.messages = messages!
            self.jsqMessagesFromMessages()
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
        newMessages.sortInPlace({ (a, b) -> Bool in
            a.date!.compare(b.date!) == NSComparisonResult.OrderedAscending
        })
        self.jsqMessages = newMessages
    }

    func addJSQMessage(message: Message) {
        let senderID = message.sender.recordID
        let senderName = message.sender.firstName! + " " + message.sender.familyName!
        let text = message.body
        let date = message.date
        let newMessage = JSQMessage(senderId: senderID, senderDisplayName: senderName, date: date, text: text)
        jsqMessages.append(newMessage)

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
        self.scrollToBottomAnimated(true)
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        self.performSegueWithIdentifier("showSelection", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSelection" {
            let selectionView = segue.destinationViewController as! TopicMarkerSelectionTableViewController
            selectionView.delegate = self
            selectionView.topic = self.topic

        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //self.toolbarItems
    }
    
    func initLastPath () {
        let point = CGPointMake(self.view.center.x, self.view.center.y + self.collectionView!.contentOffset.y)
        if let path = self.collectionView!.indexPathForItemAtPoint(point) {
            self.lastPath = path.row
        }else {
            self.lastPath = 0
        }

    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let point = CGPointMake(self.view.center.x, self.view.center.y + self.collectionView!.contentOffset.y)
        if let path = self.collectionView!.indexPathForItemAtPoint(point) {
            switch path.row - lastPath {
            case 1:
                //scroll down
                let message = self.jsqMessages[path.row]
                self.lastPath = path.row
                NSNotificationCenter.defaultCenter().postNotificationName("ScrollDown", object: self, userInfo: ["date" : message.date])
                break
            case -1:
                //scroll up
                let message = self.jsqMessages[path.row]
                self.lastPath = path.row
                NSNotificationCenter.defaultCenter().postNotificationName("ScrollUp", object: self, userInfo: ["date" : message.date])
                break
            default:
                //same cell
                return
            }
        }
    }
    
    //Mark: - TopicMarkerDelegate
    
    func didSelectPageForMarker(page: Page) {
        
        //save marker
        //send notificaiton
        InboxManager.sharedInstance.saveTopicMarker(page, topic: self.topic!)
        let marker = TopicMarker(page: page.pageID, date: NSDate(), topic: self.topic!.recordID!)
        NSNotificationCenter.defaultCenter().postNotificationName("NewTopicMarker", object: self, userInfo:["marker":marker])
        //insert marker message
        let message = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: NSDate(), text: "#" + page.name!)
        self.jsqMessages += [message]
        self.finishSendingMessage()
        
        //warning: save new messageobject
        let cloudMessage = Message(sender: Friend(firstName: nil, familyName: nil, recordIDString: senderId), body: "#" + page.name!, topic: (self.topic?.recordID)!, date: NSDate())
        InboxManager.sharedInstance.saveMessage(cloudMessage)
        self.scrollToBottomAnimated(true)
    }

}


