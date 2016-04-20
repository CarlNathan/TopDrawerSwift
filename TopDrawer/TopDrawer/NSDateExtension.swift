//
//  NSDateExtension.swift
//  TopDrawer
//
//  Created by Carl Udren on 4/18/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation

extension NSDate {
    func isBetweeen(date date1: NSDate, andDate date2: NSDate) -> Bool {
        return date1.compare(self) == self.compare(date2)
    }
}