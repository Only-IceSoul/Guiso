//
//  LinkedList.swift
//  react-native-jjkit
//
//  Created by Juan J LF on 4/20/20.
//

import Foundation

public final class LinkedList<U,T> {

    fileprivate var head: Node<U,T>?

    public init() {}

    public var isEmpty: Bool {
        
        return head == nil
    }

    public var first: Node<U,T>? {
        return head
    }

    public var last: Node<U,T>? {
        if var node = head {
            while let next = node.next {
                node = next
            }
            return node
        } else {
            return nil
        }
    }

    public var count: Int {
        if var node = head {
            var c = 1
            while let next = node.next {
                node = next
                c += 1
            }
            return c
        } else {
            return 0
        }
    }

    public func node(atIndex index: Int) -> Node<U,T>? {
        if index >= 0 {
            var node = head
            var i = index
            while node != nil {
                if i == 0 { return node }
                i -= 1
                node = node!.next
            }
        }
        return nil
    }

    public subscript(index: Int) -> T {
        let node = self.node(atIndex: index)
        assert(node != nil)
        return node!.value
    }

    public func append(key:U,_ value: T) {
        let newNode = Node(key: key, value: value)
        self.append(newNode)
    }

    public func append(_ node: Node<U,T>) {
        let newNode = Node(key: node.key, value: node.value)
        if let lastNode = last {
            newNode.previous = lastNode
            lastNode.next = newNode
        } else {
            head = newNode
        }
    }

    public func append(_ list: LinkedList) {
        var nodeToCopy = list.head
        while let node = nodeToCopy {
            self.append(key:node.key,node.value)
            nodeToCopy = node.next
        }
    }

    private func nodesBeforeAndAfter(index: Int) -> (Node<U,T>?, Node<U,T>?) {
        assert(index >= 0)

        var i = index
        var next = head
        var prev: Node<U,T>?

        while next != nil && i > 0 {
            i -= 1
            prev = next
            next = next!.next
        }
        assert(i == 0)  // if > 0, then specified index was too large
        return (prev, next)
    }

    public func insert(key:U,_ value: T, atIndex index: Int) {
        let newNode = Node(key:key,value: value)
        self.insert(newNode, atIndex: index)
    }

    public func insert(_ node: Node<U,T>, atIndex index: Int) {
        let (prev, next) = nodesBeforeAndAfter(index: index)
        let newNode = Node(key: node.key, value: node.value)
        newNode.previous = prev
        newNode.next = next
        prev?.next = newNode
        next?.previous = newNode

        if prev == nil {
            head = newNode
        }
    }

    public func insert(_ list: LinkedList, atIndex index: Int) {
        if list.isEmpty { return }
        var (prev, next) = nodesBeforeAndAfter(index: index)
        var nodeToCopy = list.head
        var newNode: Node<U,T>?
        while let node = nodeToCopy {
            newNode = Node(key: node.key, value: node.value)
            newNode?.previous = prev
            if let previous = prev {
                previous.next = newNode
            } else {
                self.head = newNode
            }
            nodeToCopy = nodeToCopy?.next
            prev = newNode
        }
        prev?.next = next
        next?.previous = prev
    }

    public func removeAll() {
        head = nil
    }

    @discardableResult public func remove(node: Node<U,T>) -> T {
        let prev = node.previous
        let next = node.next

        if let prev = prev {
            prev.next = next
        } else {
            head = next
        }
        next?.previous = prev

        node.previous = nil
        node.next = nil
        return node.value
    }

    @discardableResult public func removeLast() -> T {
        assert(!isEmpty)
        return remove(node: last!)
    }

    @discardableResult public func remove(atIndex index: Int) -> T {
        let node = self.node(atIndex: index)
        assert(node != nil)
        return remove(node: node!)
    }
}

extension LinkedList: CustomStringConvertible {
    public var description: String {
        var s = "["
        var node = head
        while node != nil {
            s += "\(node!.value)"
            node = node!.next
            if node != nil { s += ", " }
        }
        return s + "]"
    }
}

extension LinkedList {
    public func reverse() {
        var node = head
        while let currentNode = node {
            node = currentNode.next
            swap(&currentNode.next, &currentNode.previous)
            head = currentNode
        }
    }
}

extension LinkedList {
    public func map<Z>(transform: (T) -> Z) -> LinkedList<U,Z> {
        let result = LinkedList<U,Z>()
        var node = head
        while node != nil {
            result.append(key:node!.key,transform(node!.value))
            node = node!.next
        }
        return result
    }

    public func filter(predicate: (T) -> Bool) -> LinkedList<U,T> {
        let result = LinkedList<U,T>()
        var node = head
        while node != nil {
            if predicate(node!.value) {
                result.append(key:node!.key,node!.value)
            }
            node = node!.next
        }
        return result
    }
}


