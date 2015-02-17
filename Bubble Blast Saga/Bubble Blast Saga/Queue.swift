//
//  Queue.swift
//  DataStructures
//
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//
//  Edited by : Lim Jing Rong (A0114395E)

struct Queue<T> {
    
    //  Implemented using generics <T>
    
    //  Ordered in the manner - Item with highest priority has smaller index
    
    var items = [T]()
    //  Adds an element to the tail of the queue.
    mutating func enqueue(item: T) {
        items.append(item)
        
    }
    
    //  Removes an element the head of the queue and return it.
    //  If the queue is empty, return nil.
    mutating func dequeue() -> T? {
        if (items.isEmpty){
            return nil
        }
        return items.removeAtIndex(0)
    }
    
    //  Returns, but does not remove, the element at the head of the queue.
    //  If the queue is empty, returns nil.
    func peek() -> T? {
        return items.isEmpty ? nil : items[0]
    }
    
    // Returns the number of elements currently in the queue.
    var count: Int {
        return items.count
    }
    
    //  Returns true if the queue is empty and false otherwise.
    var isEmpty: Bool {
        if (items.count == 0) { return true }
        return false
    }
    
    //  Removes all elements in the queue.
    mutating func removeAll() {
        items.removeAll()
    }
    
    //  Returns the array of elements of the queue in the order
    //  that they are dequeued i.e. first element in the array
    //  is the first element dequeued.
    func toArray() -> [T] {
        return items
    }
}