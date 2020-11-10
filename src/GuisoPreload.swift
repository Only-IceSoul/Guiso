//
//  GuisoPreload.swift
//  JJGuiso
//
//  Created by Juan J LF on 10/26/20.
//

import UIKit
public class GuisoPreload: Equatable,Request {
 
    private var mModel: Any?
    private var mLoader : LoaderProtocol?
    private var mKey : Key?
    private var mOptions : GuisoOptions?
    private var mAnimImgDecoder : AnimatedImageDecoderProtocol?
    private var mPrimarySignature = ""
    private var mOp: FetcherOperation?
    private var mPool: FactoryPool<GuisoPreload>?
    public init(){
        
    }


    
    init(model:Any?,_ primarySignature:String,options:GuisoOptions, loader: LoaderProtocol,animImgDecoder : AnimatedImageDecoderProtocol?) {

        mOptions = options
        mPrimarySignature = primarySignature
        mModel = model
        mAnimImgDecoder = animImgDecoder
        mLoader = loader
        mKey = makeKey()
        
    }
  
     public func setup(model:Any?,_ primarySignature:String,options:GuisoOptions, loader: LoaderProtocol,animImgDecoder : AnimatedImageDecoderProtocol?,pool:FactoryPool<GuisoPreload>?) {
        
        mOptions = options
        mPrimarySignature = primarySignature
        mModel = model
        mAnimImgDecoder = animImgDecoder

        mLoader = loader
        mKey = makeKey()
 
        mPool = pool
        status = .pending
        cancel()
        isCancelled = false
    }
    
    
    func makeKey() -> Key {
        let key = mOptions!.getIsOverride() ? Key(signature:mPrimarySignature ,extra:mOptions!.getSignature(), width: mOptions!.getWidth(), height: mOptions!.getHeight(), scaleType: mOptions!.getScaleType()  == .none ? .fitCenter : mOptions!.getScaleType(), frame: mOptions!.getFrameSecond()   ,exactFrame:mOptions!.getExactFrame(), isAnim:mOptions!.getAsAnimatedImage(), transform: mOptions!.getTransformerSignature()) :
            Key(signature:mPrimarySignature,extra: mOptions!.getSignature(), width: -1, height: -1, scaleType: .none,frame: mOptions!.getFrameSecond()  ,exactFrame:mOptions!.getExactFrame(), isAnim: mOptions!.getAsAnimatedImage(),
        transform: mOptions!.getTransformerSignature())
        return key
    }
    
    
   


    private var isCancelled = false
    
    private func cancel(){
        isCancelled = true
        self.mOp?.cancel()
    }
    
    
    private(set) var resourceImg :UIImage?
    private(set) var resourceAnimImg: AnimatedImage?
    
    public func clear(){
        if status == .cleared {  return  }
        cancel()
        releaseInternal()
        status = .cleared
    }
    
 
    
    public func begin(){
    
        if self.mModel == nil {
            self.onLoadFailedFallback("Model is nil")
            return
        }
        
        if self.status == .running {
            return
        }
        
        if self.status == .complete {
            if self.mOptions!.getAsAnimatedImage() {
                self.onResourceReady(self.resourceAnimImg!,Guiso.DataSource.memoryCache)
            }else{
                self.onResourceReady(self.resourceImg!,Guiso.DataSource.memoryCache)
            }
            return
        }
    
        
        self.load()

    
    }
    
    func load(){
        
        status = .running
        if isCancelled { return  }
    
        //from memory
        if  !mOptions!.getSkipMemoryCache(){
            if self.mOptions!.getAsAnimatedImage() == true {
                if let res = self.loadFromMemoryAnim() {
                    self.onResourceReady(res, .memoryCache)
                    return
                }
            }else{
                if self.isCancelled { return }
                if let res = self.loadFromMemoryImg() {
                    self.onResourceReady(res, .memoryCache)
                    return
                }
            }
        }
        
            if self.isCancelled { return  }
        
       
        self.mOp = FetcherOperation(model: self.mModel, loader: self.mLoader!, key: self.mKey!, signature: self.mPrimarySignature, options: self.mOptions!, animDecoder: self.mAnimImgDecoder,scale:mOptions!.getScaleType() == .none ? .fitCenter : mOptions!.getScaleType())
        
      
            self.mOp?.completionBlock = { [ weak self ] in
            if let op = self?.mOp {
                
                if op.status == .success {
                    if op.resImg != nil {
                        self?.onResourceReady(op.resImg!, op.dataSource)
                    }else{
                        self?.onResourceReady(op.resAnim!, op.dataSource)
                    }
                }
                
                if op.status == .failed {
                    self?.onLoadFailedError(op.error)
                }
            
            }
        }
        if self.isCancelled { return  }
           
            Guiso.getExecutor().fetcherQueue.addOperation(self.mOp!)
            self.mOp?.isReady = true
        
    }
    
   
  
    
    func loadFromMemoryImg() -> UIImage?{
        let cache = Guiso.getMemoryCache()
        if let img =  cache.get(mKey!)  {
            return img
        }
        return nil
    }
    
    func loadFromMemoryAnim() -> AnimatedImage?{
        let cache = Guiso.getMemoryCacheGif()
        if let animImg =  cache.get(mKey!) {
             return animImg
        }
    
        return nil
    }
    
  
    
    func onResourceReady(_ res:UIImage,_ dataSource:Guiso.DataSource){
        resourceImg = res
        resourceAnimImg = nil
        status = .complete
        onResourceReady?(res,dataSource)
    }
    func onResourceReady(_ res:AnimatedImage,_ dataSource:Guiso.DataSource){
        resourceAnimImg = res
        resourceImg = nil
        status = .complete
        onResourceReadyAnim?(res,dataSource)
    }
    
    func onLoadFailedError(_ msg:String){
        status = .failed
        if !self.isCancelled {
            onLoadFailed?(msg)
        }
    }
    func onLoadFailedFallback(_ msg:String){
        status = .failed
        if !self.isCancelled {
            onLoadFailed?(msg)
        }
    }
    
    
    
    private var status: Status = .pending
 
    
    public func isComplete() -> Bool {
        return status == .complete
    }
    public func isRunning() -> Bool {
        return status == .running || status == .waitingSize
    }
    public func isCleared() -> Bool {
        return status == .cleared
    }
    enum Status {
        case complete, //finished loading media successfully
             running, // in the process of fetching media
             pending, // created but not yet running
             waitingSize, //w8 for a callback given to the target to be called to determine target dimensions
            
             failed, // failed to load media, may be restarted
             cleared  //cleared by the user with a placeholder set , may be restarted
    }
    
    
    public static func == (lhs: GuisoPreload, rhs: GuisoPreload) -> Bool {
        return lhs.mKey == rhs.mKey
        && lhs.mOptions == rhs.mOptions
       
    }
    
    public var onLoadFailed : ((String)->Void)?
    public var onResourceReady : ((UIImage,Guiso.DataSource)->Void)?
    public var onResourceReadyAnim : ((AnimatedImage,Guiso.DataSource)->Void)?
    
    func releaseInternal(){
        mOptions = nil
        mPrimarySignature = ""
        mModel = nil
        mAnimImgDecoder = nil
        mLoader = nil
        mKey = nil
        resourceImg = nil
        resourceAnimImg = nil
        mPool?.release(ins: self)
    }
}

