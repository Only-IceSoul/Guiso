//
//  NetOperation.swift
//  JJGuiso
//
//  Created by Juan J LF on 11/7/20.
//

import UIKit


class NetOperation : Operation {
    
    private var mModel: Any?
    private var mOptions: GuisoOptions?
    private var mLoader: LoaderProtocol?
    private var mLock = pthread_rwlock_t()
    init(model:Any?,loader:LoaderProtocol,options:GuisoOptions) {
        pthread_rwlock_init(&mLock, nil)
        mModel = model
        mOptions = options
        mLoader = loader
    }
    deinit {
        pthread_rwlock_destroy(&mLock)
    }
        
    private(set) var result: Any?
    private(set) var status: Status = .none
    private(set) var error: String = ""
    private(set) var dataSource:Guiso.DataSource = .remote
    private(set) var type: Guiso.LoadType = .uiimg
    private var isFetcherFinished = false
    func run(){
   
        if finishIfCancelled() {  return  }
        
        if mOptions == nil || mLoader == nil {
            //fail
            error = "options or loader is nil"
            status = .failed
            self.markFinished()
            return
        }
        
        if finishIfCancelled() {  return  }
        
        mLoader?.loadData(model: mModel, width: mOptions!.getWidth(), height: mOptions!.getHeight(), options: mOptions!) { (result, type,error,dataSource) in
       
            
            self.dataSource = dataSource
            self.type = type
            self.error = error
            self.result = result
            self.status = result == nil ? .failed : .success
            
            self.isFetcherFinished = true
            
            
        }
    
    
        while true {
            if isCancelled { break }
            if isFetcherFinished { break }
        }
        isFetcherFinished = false
    
        self.markFinished()
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
        mLoader?.cancel()
        isCancelled = true
    }
    
    override var isAsynchronous: Bool{
        return true
    }
    private var mIsCancelled = false
    override var isCancelled: Bool {
        set{
            willChangeValue(for: \NetOperation.isCancelled)
            mIsCancelled = newValue
            didChangeValue(for: \NetOperation.isCancelled)
        }
        get{
            return mIsCancelled
        }
    }
    
    private var mIsReady = false
    override var isReady: Bool {
        set{
            willChangeValue(for: \NetOperation.isReady)
            mIsReady = newValue
            didChangeValue(for: \NetOperation.isReady)
        }
        get{
            return mIsReady
        }
    }
   
    private var mIsExecuting = false
    override var isExecuting: Bool {
        set{
            willChangeValue(for: \NetOperation.isExecuting)
            mIsExecuting = newValue
            didChangeValue(for: \NetOperation.isExecuting)
        }
        get{
            return mIsExecuting
        }
    }
    
    private var mIsFinished = false
    override var isFinished: Bool {
        set{
            willChangeValue(for: \NetOperation.isFinished)
            mIsFinished = newValue
            didChangeValue(for: \NetOperation.isFinished)
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
