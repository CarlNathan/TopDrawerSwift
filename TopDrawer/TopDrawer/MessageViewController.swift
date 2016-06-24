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
        senderId = DataCoordinatorInterface.sharedInstance.user!.ID
        senderDisplayName = DataCoordinatorInterface.sharedInstance.user!.ID
        collectionView.registerClass(TopicMarkerHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView")
        prepareCollectionViewFlowLayout()

        // Do any additional setup after loading the view.
        getData()
        self.scrollToBottomAnimated(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(getData), name: "ReloadData", object: nil)
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func prepareCollectionViewFlowLayout() {
        collectionView.collectionViewLayout = StickyHeaderFlowLayout()
        collectionView.collectionViewLayout.minimumInteritemSpacing = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getData () {
        DataSource.sharedInstance.getMessagesAndTopicMarkersForTopic(topic!.recordID!) { (topicMarkers, messages) in
            self.messages = messages
            self.topicMarkers = topicMarkers
            (self.dataSource, self.headerTopics) = MessageSorter.sortMessages(self.messages, topicMarkers: self.topicMarkers)
        }
    }
    
    func jsqMessageFromMessage(message: Message) -> JSQMessage {
        let senderID = message.sender
        let sender = DataSource.sharedInstance.friendForID(senderID!)
        let senderName = "Sender"
        let text = message.body
        let date = message.date
        let newMessage = JSQMessage(senderId: senderID, senderDisplayName: senderName, date: date, text: text)
        return newMessage
    }
}


extension MessageViewController {
      // MARK: - DataSource
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = dataSource[headerTopics[indexPath.section].page!]![indexPath.row]
        let initials = "AZ"
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
        let name = headerTopics[section].page!
        if name == "nil" {
            return CGSize.zero
        } else {
        return CGSize(width: 60, height: 60)
        }
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            let source = dataSource[headerTopics[section].page!]
            return source!.count
            
        }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = dataSource[(headerTopics[indexPath.section].page)!]![indexPath.row]
            return jsqMessageFromMessage(data)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = dataSource[(headerTopics[indexPath.section].page)!]![indexPath.row]
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
        let message = Message(sender: senderId, body: text, topic: (self.topic?.recordID)!, date: date)
        dataSource[(headerTopics.last?.topicID)!]?.append(message)
        SavingInterface.sharedInstance.saveMessage(message)
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
        let topicMarker = TopicMarker(page: page.pageID, date: nil, topic: topic!.recordID!)
        SavingInterface.sharedInstance.saveTopicMarker(topicMarker)
        let marker = TopicMarker(page: page.pageID, date: NSDate(), topic: self.topic!.recordID!)
        NSNotificationCenter.defaultCenter().postNotificationName("NewTopicMarker", object: self, userInfo:["marker":marker, "page": page])
    }

}


