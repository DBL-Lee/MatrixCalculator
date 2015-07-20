//
//  Queue.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 30/06/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//

import UIKit

class Queue<T>: NSObject {
    private var queue:[T] = []
    
    func enqueue(e:T) {
        queue.append(e)
    }
    
    func size() -> Int {
        return queue.count
    }
    
    func isEmpty() -> Bool {
        return queue.isEmpty
    }
    
    func dequeue() -> T {
        assert(!queue.isEmpty, "queue is empty")
        return queue.removeAtIndex(0)
    }
}
