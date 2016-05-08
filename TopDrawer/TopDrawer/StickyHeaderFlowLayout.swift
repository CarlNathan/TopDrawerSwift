//
//  StickyHeaderFlowLayout.swift
//  TopDrawer
//
//  Created by Carl Udren on 4/20/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit
import JSQMessagesViewController

class StickyHeaderFlowLayout: JSQMessagesCollectionViewFlowLayout {
    
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        
        var superAttributes: [UICollectionViewLayoutAttributes]? = super.layoutAttributesForElementsInRect(rect)
        
        if superAttributes == nil {
            // If superAttributes couldn't cast, return
            return super.layoutAttributesForElementsInRect(rect)!
        }
        
        let contentOffset = collectionView!.contentOffset
        let missingSections = NSMutableIndexSet()
        
        for layoutAttributes in superAttributes! {
            if (layoutAttributes.representedElementCategory == .Cell) {
                    missingSections.addIndex(layoutAttributes.indexPath.section)
            }
        }
        
        for layoutAttributes in superAttributes! {
            if let representedElementKind = layoutAttributes.representedElementKind {
                if representedElementKind == UICollectionElementKindSectionHeader {
                    let indexPath = layoutAttributes.indexPath
                    missingSections.removeIndex(indexPath.section)
                    
                }
            }
        }
        
        missingSections.enumerateIndexesUsingBlock { idx, stop in
            let indexPath = NSIndexPath(forItem: 0, inSection: idx)
            if let layoutAttributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath) {
                superAttributes!.append(layoutAttributes)
            }
        }
        
        for layoutAttributes in superAttributes! {
            if let representedElementKind = layoutAttributes.representedElementKind {
                if representedElementKind == UICollectionElementKindSectionHeader {
                    let section = layoutAttributes.indexPath.section
                    let numberOfItemsInSection = collectionView!.numberOfItemsInSection(section)
                    
                    let firstCellIndexPath = NSIndexPath(forItem: 0, inSection: section)
                    let lastCellIndexPath = NSIndexPath(forItem: max(0, (numberOfItemsInSection - 1)), inSection: section)
                    
                    
                    var firstCellAttributes: UICollectionViewLayoutAttributes!
                    var lastCellAttributes: UICollectionViewLayoutAttributes!
                    if self.collectionView!.numberOfItemsInSection(section) > 0 {
                        firstCellAttributes = layoutAttributesForItemAtIndexPath(firstCellIndexPath)
                        lastCellAttributes = layoutAttributesForItemAtIndexPath(lastCellIndexPath)
                    } else {
                        firstCellAttributes = layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: firstCellIndexPath)
                        lastCellAttributes = layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionFooter, atIndexPath: lastCellIndexPath)
                        }
                    
                    let headerHeight = CGRectGetHeight(layoutAttributes.frame)
                    var origin = layoutAttributes.frame.origin
                    
                    //origin.y = min(contentOffset.y, (CGRectGetMaxY(lastCellAttributes.frame) - headerHeight))
                    // Uncomment this line for normal behaviour:
                     origin.y = min(max(contentOffset.y, (CGRectGetMinY(firstCellAttributes.frame) - headerHeight - 10)), (CGRectGetMaxY(lastCellAttributes.frame) - headerHeight + 10))
                    
                    layoutAttributes.zIndex = 1024
                    layoutAttributes.frame = CGRect(origin: origin, size: layoutAttributes.frame.size)
                }
            }
        }
        
        return superAttributes!
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
}