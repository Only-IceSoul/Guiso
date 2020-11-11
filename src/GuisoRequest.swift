//
//  ImageWorker.swift
//  react-native-jjkit
//
//  Created by Juan J LF on 4/22/20.
//


import UIKit


public class GuisoRequest: Equatable,Request {
 
    private var mModel: Any?
    private var mLoader : LoaderProtocol?
    private weak var mTarget : ViewTarget?
    private var mKey : Key?
    private var mOptions : GuisoOptions?
    private var mAnimImgDecoder : AnimatedImageDecoderProtocol?
    private var mThumb: GuisoRequestThumb?
    private var mPrimarySignature = ""
    private var mOp: FetcherOperation?
    private var mPool: FactoryPool<GuisoRequest>?
    private var mScale : Guiso.ScaleType = .fitCenter
    init(){}
    init(model:Any?,_ primarySignature:String,options:GuisoOptions,_ target: ViewTarget?, loader: LoaderProtocol,animImgDecoder : AnimatedImageDecoderProtocol?) {

        mOptions = options
        mPrimarySignature = primarySignature
        mModel = model
        mAnimImgDecoder = animImgDecoder
        mTarget = target
        mLoader = loader
        mScale = mOptions!.getScaleType() == .none ? getScaleType(target?.getContentMode()) : mOptions!.getScaleType()
        mKey = makeKey()
        
    }
    private func getScaleType(_ scale:UIView.ContentMode?)-> Guiso.ScaleType{
           if scale == nil { return .fitCenter}
           return scale! == UIView.ContentMode.scaleAspectFill ? .centerCrop : .fitCenter
    }
    
    func setup(model:Any?,_ primarySignature:String,options:GuisoOptions,_ target: ViewTarget?, loader: LoaderProtocol,animImgDecoder : AnimatedImageDecoderProtocol?,pool:FactoryPool<GuisoRequest>) {
        
        mOptions = options
        mPrimarySignature = primarySignature
        mModel = model
        mAnimImgDecoder = animImgDecoder
        mTarget = target
        mLoader = loader
        mScale = mOptions!.getScaleType() == .none ? getScaleType(target?.getContentMode()) : mOptions!.getScaleType()
        mKey = makeKey()
 
        
        status = .pending
        isCancelled = false
    }
    
  
    
    func setTarget(_ t:ViewTarget?){
        mTarget = t
    }

    func setThumb(_ t:GuisoRequestThumb?){
        mThumb = t
    }
        
    func makeKey() -> Key {
        let key = mOptions!.getIsOverride() ? Key(signature:mPrimarySignature ,extra:mOptions!.getSignature(), width: mOptions!.getWidth(), height: mOptions!.getHeight(), scaleType: mScale, frame: mOptions!.getFrameSecond()   ,exactFrame:mOptions!.getExactFrame(), isAnim:mOptions!.getAsAnimatedImage(), transform: mOptions!.getTransformerSignature()) :
            Key(signature:mPrimarySignature,extra: mOptions!.getSignature(), width: -1, height: -1, scaleType: .none,frame: mOptions!.getFrameSecond()  ,exactFrame:mOptions!.getExactFrame(), isAnim: mOptions!.getAsAnimatedImage(),
        transform: mOptions!.getTransformerSignature())
        return key
    }
    
    
   


    var isCancelled = false
    
    private func cancel(){
        isCancelled = true
        mThumb?.clear()
        self.mOp?.cancel()
       
    }
    
    
    private var resourceImg :UIImage?
    private var resourceAnimImg: AnimatedImage?
    
    public func clear(){
        if status == .cleared {  return  }
        cancel()
        let t = mTarget
        mTarget = nil
        if mOptions?.getPlaceHolder() != nil {
            mOptions!.getPlaceHolder()!.load(t)
        }else{
            t?.onHolder(nil)
        }
        releaseInternal()
        status = .cleared
    }
    
 
    
    public func begin(){
    
        if self.mModel == nil {
            self.mOptions?.getFallbackHolder()?.load(self.mTarget)
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
    
        
        self.mOptions?.getPlaceHolder()?.load(self.mTarget)

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
            if self.mThumb != nil {
                //init thumb
                self.mThumb?.begin()
            }
       
        self.mOp = FetcherOperation(model: self.mModel, loader: self.mLoader!, key: self.mKey!, signature: self.mPrimarySignature, options: self.mOptions!, animDecoder: self.mAnimImgDecoder,scale: mScale)
        

      
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
    
    private func saveToMemoryCache(_ img:UIImage){
        if  !(mKey?.isValidSignature() ?? false) { return }
        let sm = self.mOptions?.getSkipMemoryCache() ?? true
        if !sm {
            GuisoSaver.saveToMemoryCache(key: self.mKey!, image: img)
            
        }
    }
    
    private func saveToMemoryCache(_ gif:AnimatedImage){
        if  !(mKey?.isValidSignature() ?? false) { return }
        let sm = self.mOptions?.getSkipMemoryCache() ?? true
        if !sm {
            GuisoSaver.saveToMemoryCache(key: self.mKey!, gif:gif)

        }
    }
    
    func onResourceReady(_ res:UIImage,_ dataSource:Guiso.DataSource){
        resourceImg = res
        status = .complete
       
        self.mThumb?.clear()
        if mTarget == nil { return }
        if Thread.current.isMainThread {
            //sync from mem
            self.mTarget?.onResourceReady(res)
        }else{
            OperationQueue.main.addOperation {
                if self.isCancelled { return }
                self.mTarget?.onResourceReady(res)
                if dataSource != .memoryCache {
                    self.saveToMemoryCache(res)
                }
            }
        }
        
        
    }
    func onResourceReady(_ res:AnimatedImage,_ dataSource:Guiso.DataSource){
        resourceAnimImg = res
        status = .complete
   
        self.mThumb?.clear()
        if mTarget == nil { return }
        
        let layer = AnimatedLayer(res)
        if Thread.current.isMainThread {
            self.mTarget?.onResourceReady(layer)
        }else{
            OperationQueue.main.addOperation {
                if self.isCancelled { return }
                self.mTarget?.onResourceReady(layer)
                if dataSource != .memoryCache {
                    self.saveToMemoryCache(res)
                }
            }
        }
        
    }
    
    func onLoadFailedError(_ msg:String){
        status = .failed
        if !self.isCancelled {
            OperationQueue.main.addOperation {
                if self.isCancelled { return }
                self.mTarget?.onLoadFailed(msg)
                self.mOptions?.getErrorHolder()?.load(self.mTarget)
                
            }
        }
    }
    func onLoadFailedFallback(_ msg:String){
        status = .failed
        if !self.isCancelled {
            OperationQueue.main.addOperation {
                if self.isCancelled { return }
                self.mTarget?.onLoadFailed(msg)
                self.mOptions?.getFallbackHolder()?.load(self.mTarget)
            
            }
      
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
    
    
    public static func == (lhs: GuisoRequest, rhs: GuisoRequest) -> Bool {
        return lhs.mKey == rhs.mKey
        && lhs.mThumb == rhs.mThumb
        && lhs.mOptions == rhs.mOptions
       
    }
    
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
