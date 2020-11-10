//
//  LRUCache.swift
//  react-native-jjkit
//
//  Created by Juan J LF on 4/20/20.
//

import UIKit
import Foundation

open class LRUCache<U:Hashable,T> {
  private var mMaxSize: Int64 = 0
  private var mCurrentSize : Int64 = 0
    private var mPriority: LinkedList<U,T> = LinkedList<U,T>()
  private var mCache: [U: Node<U,T>] = [U:Node<U,T>]()
    
    private var mLock = pthread_rwlock_t()
    private var mEvictSize:Int64 = 0
  public init(_ maxSize: Double) {
    pthread_rwlock_init(&mLock, nil)
    
    self.mMaxSize = maxSize < 1 ? 1 : mbToBytes(mb: maxSize)
    self.mEvictSize =  (self.mMaxSize * 90) / 100
  
    
    NotificationCenter.default.addObserver(self, selector: #selector(appMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
  }
    
    deinit {
        pthread_rwlock_destroy(&mLock)
        NotificationCenter.default.removeObserver(self)
    }
   
    
    func mbToBytes(mb:Double)->Int64{
        return Int64(mb * 1048576.0)
    }
    
    public func setMaxSize(_ maxSize: Double){
        pthread_rwlock_wrlock(&mLock) ; defer { pthread_rwlock_unlock(&mLock) }
        self.mMaxSize = mbToBytes(mb: maxSize)
        self.mEvictSize =  (self.mMaxSize * 90) / 100
    }
  
    public func get(_ key: U) -> T? {
        pthread_rwlock_rdlock(&mLock) ; defer { pthread_rwlock_unlock(&mLock) }
        guard let val = mCache[key] else  { return nil }
        return val.value
  }

    public func add(_ key: U, val: T) {
        pthread_rwlock_wrlock(&mLock) ; defer { pthread_rwlock_unlock(&mLock) }
        let sizeObjc = getSizeObject(obj: val)
        if sizeObjc >= mMaxSize {
            //evicted cb
            return
        }
        
        mCurrentSize += sizeObjc
        
        if let old = mCache[key] {
            mPriority.remove(node: old)
            mCurrentSize -= getSizeObject(obj: old.value)
            
            //if equal old and item false
            //cb evicted
        }
        
        mPriority.insert(key:key,val, atIndex: 0)
        guard let first = mPriority.first else {return}
        mCache[key] = first
        
        evict()
    }
    

    
    open func getSizeObject(obj: T) -> Int64 {
    
        return 1000
    }
    
  
    public func size()-> Int64 {
        return self.mCurrentSize
    }
  
  private func remove(_ key: U) {
    guard let node = mCache[key] else { return }
    let sizeObjc = getSizeObject(obj:node.value )
    mCurrentSize -= sizeObjc

    mPriority.remove(node: node)
    mCache.removeValue(forKey: key)
       
  }
  

    
    open func evict(){
        if mCurrentSize >= mMaxSize {
            while let key = self.mPriority.last?.key {
                if self.mCurrentSize <= mEvictSize {
                    if self.mCurrentSize < 0 { self.mCurrentSize = 0}
                    break
                    
                }
                   self.remove(key)

            }
        }
    }

    public func trimToSize(_ size: Int64){
        pthread_rwlock_wrlock(&mLock) ; defer { pthread_rwlock_unlock(&mLock) }
        while let key = self.mPriority.last?.key {
            if self.mCurrentSize <= size {
                if self.mCurrentSize < 0 { self.mCurrentSize = 0}
                break
                
            }
               self.remove(key)

        }
            
    }
    public func clear(){
        pthread_rwlock_wrlock(&mLock) ; defer { pthread_rwlock_unlock(&mLock) }
        mCache.removeAll()
        mPriority.removeAll()
        mCurrentSize = 0
    }
    
   @objc func appMemoryWarning(notification:Notification){
         clear()
    }
    
    private var mBgTaskID = UIBackgroundTaskIdentifier.invalid
    @objc func appDidEnterBackground(notification:Notification){
        mBgTaskID =  UIApplication.shared.beginBackgroundTask {

            UIApplication.shared.endBackgroundTask(self.mBgTaskID)
            self.mBgTaskID = .invalid
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.trimToSize((self.mMaxSize / 3))
            UIApplication.shared.endBackgroundTask(self.mBgTaskID)
            self.mBgTaskID = .invalid
        }

      
    }
    
     
}
