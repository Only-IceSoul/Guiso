//
//  MemOperation.swift
//  JJGuiso
//
//  Created by Juan J LF on 11/5/20.
//

import UIKit
class MemOperation : Operation {
 
    private var mKey: Key!
    private(set) var resImg: UIImage?
    private(set) var resAnim: AnimatedImage?
    private var mIsAnim = false
    private var mIsSave = false
    private(set) var status: Status = .none
    init(key:Key,img:UIImage?,anim:AnimatedImage?,isAnim:Bool,isSave:Bool){
        mKey = key
        resImg = img
        resAnim = anim
        mIsAnim = isAnim
    }
    
    func run(){
        if mIsAnim {
            if mIsSave {
                GuisoSaver.saveToMemoryCache(key: mKey,gif: resAnim)
            }else{
                if let res = self.loadFromMemoryAnim() {
                    resAnim = res
                    resImg = nil
                    status = .success
                }else{
                    resImg = nil
                    resAnim = nil
                    status = .failed
                }
               
            }
         
        }else{
            if mIsSave {
                GuisoSaver.saveToMemoryCache(key: mKey, image: resImg)
            }else{
                if let res = self.loadFromMemoryImg() {
                    resImg = res
                    resAnim = nil
                    status = .success
                }else{
                    resImg = nil
                    resAnim = nil
                    status = .failed
                }
               
            }
            
        }
        markFinished()
    }
    
    func loadFromMemoryImg() -> UIImage?{
        let cache = Guiso.getMemoryCache()
        if let img =  cache.get(mKey)  {
                return img
        }
        return nil
    }
    
    func loadFromMemoryAnim() -> AnimatedImage?{
        let cache = Guiso.getMemoryCacheGif()
        if let animImg =  cache.get(mKey) {
             return animImg
        }
        return nil
    }
    
    
    //MARK: Operation
    
    
    enum Status : Int {
        case failed = 0,
             success,
             none
    }
    
    func finishIfCancelled() -> Bool{
        if isCancelled {
            markFinished()
            return true
        }
        return false
    }
    
    override func start() {
        if finishIfCancelled() {  return  }
        isReady = false
        isExecuting = true
        isFinished = false
        run()
    }
    
    override func cancel() {
        isCancelled = true
    }

    
    private var mIsReady = false
    override var isReady: Bool {
        set{
            willChangeValue(for: \MemOperation.isReady)
            mIsReady = newValue
            didChangeValue(for: \MemOperation.isReady)
        }
        get{
            return mIsReady
        }
    }
    
    private var mIsExecuting = false
    override var isExecuting: Bool {
        set{
            willChangeValue(for: \MemOperation.isExecuting)
            mIsExecuting = newValue
            didChangeValue(for: \MemOperation.isExecuting)
        }
        get{
            return mIsExecuting
        }
    }
    
    private var mIsFinished = false
    override var isFinished: Bool {
        set{
            willChangeValue(for: \MemOperation.isFinished)
            mIsFinished = newValue
            didChangeValue(for: \MemOperation.isFinished)
        }
        get{
            return mIsFinished
        }
    }
    
    private var mIsCancelled = false
    override var isCancelled: Bool {
        set{
            willChangeValue(for: \MemOperation.isCancelled)
            mIsCancelled = newValue
            didChangeValue(for: \MemOperation.isCancelled)
        }
        get{
            return mIsCancelled
        }
    }
    
   
    
    
    func markFinished(){
        if !isFinished {
            isExecuting = true
            isExecuting = false
            isFinished = true
        }
    }
}
