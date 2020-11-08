//
//  SaveOperation.swift
//  JJGuiso
//
//  Created by Juan J LF on 11/5/20.
//

import UIKit


class DiskOperation : Operation {

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
        mIsSave = isSave
    }
    
    func run(){
        if finishIfCancelled() {  return  }
        if mIsAnim {
            if mIsSave {
                GuisoSaver.saveToDiskCache(key: mKey,gif: resAnim)
            }else{
                if let res = self.loadFromDiskAnim() {
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
                GuisoSaver.saveToDiskCache(key: mKey, image: resImg)
            }else{
                if let res = self.loadFromDiskImg() {
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
    
    
    
    func loadFromDiskImg() -> UIImage?{
        let diskCache = Guiso.getDiskCache()

        if let data = diskCache.get(mKey) {
            if let img =  UIImage(data: data) {
                return img
            }
        }
        
        return nil
    }
    
    func loadFromDiskAnim() -> AnimatedImage?{
        let diskCache = Guiso.getDiskCache()
        if let obj = diskCache.getClassObj(mKey) {
            if let gif = obj as? AnimatedImage{
                let drawable = TransformationUtils.cleanGif(gif)
                return drawable
            }
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

    private var mIsCancelled = false
    override var isCancelled: Bool {
        set{
            willChangeValue(for: \DiskOperation.isCancelled)
            mIsCancelled = newValue
            didChangeValue(for: \DiskOperation.isCancelled)
        }
        get{
            return mIsCancelled
        }
    }
    
    
    private var mIsReady = false
    override var isReady: Bool {
        set{
            willChangeValue(for: \DiskOperation.isReady)
            mIsReady = newValue
            didChangeValue(for: \DiskOperation.isReady)
        }
        get{
            return mIsReady
        }
    }
    
    
    private var mIsExecuting = false
    override var isExecuting: Bool {
        set{
            willChangeValue(for: \DiskOperation.isExecuting)
            mIsExecuting = newValue
            didChangeValue(for: \DiskOperation.isExecuting)
        }
        get{
            return mIsExecuting
        }
    }
    
    private var mIsFinished = false
    override var isFinished: Bool {
        set{
            willChangeValue(for: \DiskOperation.isFinished)
            mIsFinished = newValue
            didChangeValue(for: \DiskOperation.isFinished)
        }
        get{
            return mIsFinished
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
