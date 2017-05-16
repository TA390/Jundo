//
//  List.swift
//  Jundo
//
//  Created by TA on 04/05/2017.
//  Copyright © 2017 Splynter Inc. All rights reserved.
//

import Foundation

class Node<T> {
    
    var value: T
    var next: Node?
    
    init(_ value: T, _ next: Node? = nil){
        self.value = value
        self.next = next
    }
    
};

class List<T> {
    
    private var head: Node<T>?
    private var tail: Node<T>?
    var isEmpty: Bool { return head == nil }
    
    init() {
        head = nil
        tail = nil
    }
    
    func push_front(_ value: T){
        let node = Node<T>(value, head)
        if head == nil {
            tail = node
        }
        head = node
    }
    
    func push_back(_ value: T){
        let node = Node<T>(value)
        if tail == nil {
            head = node
        } else {
            tail!.next = node
        }
        tail = node
    }
    
    func pop_front() -> T {
        let node = head
        head = head!.next
        if head == nil {
            tail = nil
        }
        node!.next = nil
        return node!.value
    }
    
    func front() -> T {
        return head!.value
    }
    
    func back() -> T {
        return tail!.value
    }
    
}
