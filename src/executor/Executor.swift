//
//  GuisoExecutor.swift
//  react-native-jjkit
//
//  Created by Juan J LF on 4/22/20.
//

import Foundation


public class Executor {
    
    private var mQueue : DispatchQueue?
    
    private(set) var fetcherQueue : OperationQueue = {
        let o =  OperationQueue()
         o.maxConcurrentOperationCount = 60
         return o
     }()
    
    private(set) var netQueue : OperationQueue = {
        let o =  OperationQueue()
         o.maxConcurrentOperationCount = 4
         return o
     }()
    
//    private(set) var memQueue : OperationQueue = {
//       let o =  OperationQueue()
//        o.maxConcurrentOperationCount = 1
//        return o
//    }()
     
    private(set) var diskQueue : OperationQueue = {
       let o =  OperationQueue()
        o.maxConcurrentOperationCount = 1
        return o
    }()
    private(set) var transformQueue : OperationQueue = {
       let o =  OperationQueue()
        o.maxConcurrentOperationCount = 2
        return o
    }()
    
  
    public init(){
        
    }

    
    public init(_ label:String){
        mQueue = DispatchQueue(label: label, qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    }
    

    
    @discardableResult
    public func doWork(_ item : Runnable,priority: DispatchQoS,flags: DispatchWorkItemFlags)
    -> DispatchWorkItem {
        let work = DispatchWorkItem(qos: priority, flags: flags, block: item.run)
        item.setTask(work)
        mQueue?.async(execute: work)
        return work
    }
    
    public func doWork(_ work: @escaping () -> Void){
        mQueue?.async {
            work()
        }
    }

    public func doWorkSync(_ item:Runnable){
        mQueue?.sync {
            item.run()
        }
    }
    

    public func doWorkBarrier(_ item:Runnable){
        let work = DispatchWorkItem(qos: .default, flags: .barrier, block: item.run)
        
        mQueue?.async(execute: work)
    }
    
    public func doWorkBarrier(_ block: @escaping ()->Void){
        let work = DispatchWorkItem(qos: .default, flags: .barrier, block: block)
        
        mQueue?.async(execute: work)
    }
    
    public func doTask(_ item:Runnable) -> DispatchWorkItem{
        let task = DispatchWorkItem(qos: .userInitiated, flags: .inheritQoS, block: item.run)
        mQueue?.async(execute: task)
        return task
    }
    
}
