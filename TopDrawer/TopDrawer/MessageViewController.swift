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
import Material


class MessageViewController: JSQMessagesViewController, TopicMarkerSelectionDelegate {

    var topic: Topic?
    var messages = [Message]()
    var topicMarkers = [TopicMarker]()
    var headerTopics = [TopicMarker]()
    var markerFlag: Bool = false
    var messageFlag: Bool = false
    var dataSource = [String: [Message]]() {
        didSet{
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView?.reloadData()
            self.scrollToBottomAnimated(true)
            }
        }
    }
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBar = self.tabBarController as! TopicTabBarController
        topic = tabBar.topic
        senderId = InboxManager.sharedInstance.currentUserID.recordName
        senderDisplayName = InboxManager.sharedInstance.currentUserID.recordName
        collectionView.registerClass(TopicMarkerHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView")
        prepareCollectionViewFlowLayout()

        // Do any additional setup after loading the view.
        getMessages()
        getTopicMarkers()
        self.scrollToBottomAnimated(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessageViewController.newRemoteMessage(_:)), name: "RemoteMessage", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newTopicMarker), name: "NewTopicMarker", object: nil)
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Float(2.0) * Float(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
//            self.getMessages()
//        }
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func newTopicMarker(sender: NSNotification) {
        let marker = sender.userInfo!["marker"] as! TopicMarker
        let page = sender.userInfo!["page"] as! Page
        headerTopics.append(marker)
        dataSource[page.pageID.recordName] = []
    }
    
    func newRemoteMessage(sender: NSNotification) {
        let recordID = sender.userInfo!["topicID"] as! CKRecordID
        InboxManager.sharedInstance.getMessageForID(recordID) { (message) -> Void in
            if message?.topicRef == self.topic?.recordID {
                self.dataSource[self.topicMarkers.last!.page!.recordName]?.append(message!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.collectionView?.reloadData()
                    self.scrollToBottomAnimated(true)
                })
            } else {
                print("Off topic")
            }
        }

    }
    
    func prepareCollectionViewFlowLayout() {
        collectionView.collectionViewLayout = StickyHeaderFlowLayout()
        collectionView.collectionViewLayout.minimumInteritemSpacing = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMessages () {
        InboxManager.sharedInstance.getMessages(self.topic!) { (messages) -> Void in
            self.messages = messages!
            self.messageFlag = true
            self.getDataSource()
        }
    }
    
    func getTopicMarkers () {
        InboxManager.sharedInstance.getTopicMarkers(self.topic!) { (topicMarkers) in
            self.topicMarkers = topicMarkers!
            self.markerFlag = true
            self.getDataSource()
        }
    }
    
    func getDataSource() {
        if markerFlag && messageFlag {
            (self.dataSource, self.headerTopics) = MessageSorter.sortMessages(self.messages, topicMarkers: self.topicMarkers)
        }
    }
    
    func jsqMessageFromMessage(message: Message) -> JSQMessage {
        let senderID = message.sender.recordID
        let senderName = message.sender.firstName! + " " + message.sender.familyName!
        let text = message.body
        let date = message.date
        let newMessage = JSQMessage(senderId: senderID, senderDisplayName: senderName, date: date, text: text)
        return newMessage
    }
}


extension MessageViewController {
      // MARK: - DataSource
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = dataSource[headerTopics[indexPath.section].page!.recordName]![indexPath.row]
        let initials = message.sender.firstName![0] + message.sender.familyName![0]
        let userImage = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(initials, backgroundColor: MaterialColor.grey.darken1, textColor: MaterialColor.white, font: RobotoFont.mediumWithSize(30), diameter: 70)

        return userImage
    }
    
    //topicmarker views
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return headerTopics.count
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        

        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "headerView", forIndexPath: indexPath) as! TopicMarkerHeaderView
            let pageID = headerTopics[indexPath.section].page
            view.getPageForID(pageID!)
            return view
        }
        return UICollectionReusableView()
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let name = headerTopics[section].page!.recordName
        if name == "nil" {
            return CGSize.zero
        } else {
        return CGSize(width: 60, height: 60)
        }
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            let source = dataSource[headerTopics[section].page!.recordName]
            return source!.count
            
        }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = dataSource[(headerTopics[indexPath.section].page?.recordName)!]![indexPath.row]
            return jsqMessageFromMessage(data)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = dataSource[(headerTopics[indexPath.section].page?.recordName)!]![indexPath.row]
        let jsqData = jsqMessageFromMessage(data)
        switch(jsqData.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
}

//MARK: - Toolbar
extension MessageViewController {
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = Message(sender: Friend(firstName: nil, familyName: nil, recordIDString: senderId), body: text, topic: (self.topic?.recordID)!, date: date)
        dataSource[(headerTopics.last?.topicID?.recordName)!]?.append(message)
        InboxManager.sharedInstance.saveMessage(message)
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        //self.performSegueWithIdentifier("showSelection", sender: self)
        InsertTopicMarkerPopupVC.presentPopupCV(self, topic: topic!, delegate: self)
        
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
    
    
    //Mark: - TopicMarkerDelegate
    
    func didSelectPageForMarker(page: Page) {
        // update topic markers and message
        //save marker
        //send notificaiton
        InboxManager.sharedInstance.saveTopicMarker(page, topic: self.topic!)
        let marker = TopicMarker(page: page.pageID, date: NSDate(), topic: self.topic!.recordID!)
        NSNotificationCenter.defaultCenter().postNotificationName("NewTopicMarker", object: self, userInfo:["marker":marker, "page": page])
    }

}


