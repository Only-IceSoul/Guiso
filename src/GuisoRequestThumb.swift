//
//  GuisoRequestThumb.swift
//  JJGuiso
//
//  Created by Juan J LF on 10/26/20.
//

import UIKit

public class GuisoRequestThumb: Equatable,Request {
 

    

    private var mModel: Any?
    private var mLoader : LoaderProtocol!
    private weak var mTarget : ViewTarget?
    private var mKey : Key!
    private var mOptions : GuisoOptions!
    private var mScale : Guiso.ScaleType!
    private var mAnimImgDecoder : AnimatedImageDecoderProtocol!
    private var mPrimarySignature = ""

    init(model:Any?,_ primarySignature:String,options:GuisoOptions,_ target: ViewTarget?, loader: LoaderProtocol,animImgDecoder : AnimatedImageDecoderProtocol?) {
        mOptions = options
        mPrimarySignature = primarySignature
        mModel = model
        mAnimImgDecoder = animImgDecoder
            
        mTarget = target
        mLoader = loader
        mScale = mOptions.getScaleType()  == .none ? .fitCenter : mOptions.getScaleType()
    
        mKey = makeKey()
        
    }
            

    func makeKey() -> Key {
        let key = mOptions.getIsOverride() ? Key(signature:mPrimarySignature ,extra:mOptions.getSignature(), width: mOptions.getWidth(), height: mOptions.getHeight(), scaleType: mScale, frame: mOptions.getFrameSecond()   ,exactFrame:mOptions.getExactFrame(), isAnim:mOptions.getAsAnimatedImage(), transform: mOptions.getTransformerSignature()) :
            Key(signature:mPrimarySignature,extra: mOptions.getSignature(), width: -1, height: -1, scaleType: .none,frame: mOptions.getFrameSecond()  ,exactFrame:mOptions.getExactFrame(), isAnim: mOptions.getAsAnimatedImage(),
        transform: mOptions.getTransformerSignature())
        return key
    }
    
  

    var isCancelled = false
    
    private func cancel(){
        isCancelled = true
        mOp?.cancel()
    }
    
    
    public func clear(){
        if status == .cleared {  return  }
        cancel()
        status = .cleared
    }
    
 
    
    public func begin(){
        if mModel == nil {
            mOptions.getFallbackHolder()?.load(mTarget)
            onLoadFailedFallback("Model is nil")
            return
        }
        
        if status == .running {
            fatalError("thumb request is running")
        }
        
        
        load()
    
    }
    
    private var mOp : FetcherOperation?
    func load(){

        
        status = .running
        if isCancelled { return  }

        //from memory
            if self.mOptions?.getAsAnimatedImage() == true {
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
        
            if self.isCancelled { return  }
          
            self.mOp = FetcherOperation(model: self.mModel, loader: self.mLoader!, key: self.mKey!, signature: self.mPrimarySignature, options: self.mOptions!, animDecoder: self.mAnimImgDecoder)
        
      
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
                
                self?.mOp = nil
            }
        }
        if self.isCancelled { return  }
           
            Guiso.getExecutor().fetcherQueue.addOperation(self.mOp!)
            self.mOp?.isReady = true
        
        
    }
    
   
    
  
    func loadFromMemoryImg() -> UIImage?{
        let cache = Guiso.getMemoryCache()
        let skipCache = mOptions.getSkipMemoryCache()
        
        if !skipCache ,let img =  cache.get(mKey)  {
                return img
        }
        return nil
    }
    
    func loadFromMemoryAnim() -> AnimatedImage?{
        let cache = Guiso.getMemoryCacheGif()
        let skipCache = mOptions.getSkipMemoryCache()
        if !skipCache {
            if let animImg =  cache.get(mKey) {
                 return animImg
            }
        }
        return nil
    }
    
    func onResourceReady(_ res:UIImage?,_ dataSource:Guiso.DataSource){
        if res == nil {
            onLoadFailedError("expected recieve a object uiimage but instead got nil, datasource: \(dataSource)")
            return
        }
        status = .complete
       
        
        if self.isCancelled { return}
        OperationQueue.main.addOperation {
            if self.isCancelled { return}
            self.mTarget?.onResourceReady(res!)
        }
        
    }
    func onResourceReady(_ res:AnimatedImage?,_ dataSource:Guiso.DataSource){
        if res == nil {
            onLoadFailedError("expected recieve a object animatedImage but instead got nil, datasource: \(dataSource)")
            return
        }
        status = .complete
       
        
        if self.isCancelled { return }
        let layer = AnimatedLayer(res!)
        OperationQueue.main.addOperation {
            if self.isCancelled { return }
            self.mTarget?.onResourceReady(layer)
        }
        
        
    }
    
    func onLoadFailedError(_ msg:String){
        status = .failed
        
        
    }
    func onLoadFailedFallback(_ msg:String){
        status = .failed
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
             waitingSize,
            
             failed, // failed to load media, may be restarted
             cleared
    }
    
    
    public static func == (lhs: GuisoRequestThumb, rhs: GuisoRequestThumb) -> Bool {
       return lhs.mKey == rhs.mKey
        && lhs.mOptions == rhs.mOptions
       
    
    }
}
