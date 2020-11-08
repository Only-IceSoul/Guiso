//
//  FetcherOperation.swift
//  JJGuiso
//
//  Created by Juan J LF on 11/4/20.
//

import UIKit

class FetcherOperation : Operation {
    
    
    enum Status : Int {
        case failed = 0,
             success,
             none
    }
    
    var status : Status = .none
    var resAnim:AnimatedImage?
    var resImg : UIImage?
    var dataSource : Guiso.DataSource = .resourceDiskCache
    var error  = ""

    
    private var mOptions : GuisoOptions!
    private var mKey: Key!
    private var mModel:Any?
    private var mLoader : LoaderProtocol!
    private var mAnimImgDecoder : AnimatedImageDecoderProtocol?
    private var mPrimarySignature = ""

    init(model:Any?,loader:LoaderProtocol,key:Key, signature:String,options:GuisoOptions,animDecoder:AnimatedImageDecoderProtocol?){
        mOptions = options
        mKey = key
        mModel = model
        mLoader = loader
        mAnimImgDecoder = animDecoder
        mPrimarySignature = signature
    }

     func run() {
 
        if finishIfCancelled() {   return  }
  
        //diskcache
        if mOptions.getDiskCacheStrategy() != .none {
            let op = DiskOperation(key: mKey, img: nil, anim: nil, isAnim: mOptions.getAsAnimatedImage(), isSave: false)

            Guiso.getExecutor().diskQueue.addOperation(op)
            op.isReady = true
            while !isCancelled && !op.isFinished {
                Thread.sleep(forTimeInterval: 0.1)
              
            }
            op.cancel()
            if finishIfCancelled() {   return  }
            if op.status == .success {
                if op.resAnim != nil {
                    onResourceReady(op.resAnim, .resourceDiskCache)
                }else if op.resImg != nil{
                    onResourceReady(op.resImg, .resourceDiskCache)
                }else{
                    markFinished()
                }
                return
            }
        }

        if finishIfCancelled() { return  }
        //source
        if mOptions.getDiskCacheStrategy() != .none {
            let  op = DiskOperation(key: sourceKey(), img: nil, anim: nil, isAnim: mOptions.getAsAnimatedImage(), isSave: false)

            Guiso.getExecutor().diskQueue.addOperation(op)
            op.isReady = true
            while !isCancelled && !op.isFinished {
                Thread.sleep(forTimeInterval: 0.1)
            }
            op.cancel()
            if finishIfCancelled() {   return  }
            if op.status == .success {
                    if op.resAnim != nil {
                        self.handleAnimImg(op.resAnim, type: .animatedImg, "", .dataDiskCache)
                    }else if op.resImg != nil{
                        self.handleAnimImg(op.resImg, type: .animatedImg, "", .dataDiskCache)
                    }else{
                        markFinished()
                    }


                return
            }

        }

        if finishIfCancelled() { return  }
 
        //fetcher
        let on = NetOperation(model: mModel, loader: mLoader, options: mOptions)
        Guiso.getExecutor().netQueue.addOperation(on)
        on.isReady = true
        while !isCancelled && !on.isFinished {
            Thread.sleep(forTimeInterval: 0.1)
        }
        on.cancel()
        if finishIfCancelled() {   return  }
        if on.status == .success {
            if self.mOptions.getAsAnimatedImage() {
                self.handleAnimImg(on.result, type: on.type,on.error,on.dataSource)
            }else{
                self.handleImage(on.result,type:on.type,on.error,on.dataSource)
            }

        }else{
            onLoadFailedError(on.error)
        }


        
    }
    func handleImage(_ result:Any?,type:Guiso.LoadType,_ error:String,_ dataSource: Guiso.DataSource){
        if type == .data {
           
            guard let data = result as? Data
                else {
                self.onLoadFailedError("Data to image ,loader error -> \(error)")
                    return
            }
            if finishIfCancelled() {  return  }
            guard let img = UIImage(data: data) else {
                self.onLoadFailedError("Data to image ,loader error -> maybe its not a static image")
                return
                
            }
            
            if finishIfCancelled() {  return  }
             saveData(img,dataSource)
             transformDisplayCacheImage(img,dataSource)
            
        }
        if finishIfCancelled() {  return  }
        if type == .uiimg{
            guard let img = result as? UIImage
               else {
                  self.onLoadFailedError("UIImage result cast ,loader error -> \(error)")
                   return
            }
            if finishIfCancelled() {  return  }
            saveData(img,dataSource)
            transformDisplayCacheImage(img,dataSource)
        }
    }
    
 
    func handleAnimImg(_ result:Any?,type:Guiso.LoadType,_ error:String,_ dataSource: Guiso.DataSource){
        if type == .data {
          guard let data = result as? Data
           else {
            self.onLoadFailedError("decoding gif, loader error -> \(error)")
              return
          }
            if finishIfCancelled() {  return  }
            guard let gif = self.mAnimImgDecoder?.decode(data:data) else{
                self.onLoadFailedError("decoding animatedImage, error -> maybe its not a animated image or animated Decoder is nil")
                return
            }
            if finishIfCancelled() {   return  }
             saveData(gif,dataSource)
             transformDisplayCacheAnim(gif,dataSource)
        
        }
        if finishIfCancelled() {  return  }
        if type == .uiimg {
            guard let img = result as? UIImage
              else{
                self.onLoadFailedError("getting gift from uiimage, loader error -> \(error)")
                  return
            }
            if finishIfCancelled() { return  }
            saveData(img,dataSource)
            onResourceReady(img, dataSource)
           
            
        }
        if finishIfCancelled() {  return  }
        if type == .animatedImg {
            guard let gif = result as? AnimatedImage
            else {
              self.onLoadFailedError("error: casting any to gif")
                return
            }
            if finishIfCancelled() { return  }
            saveData(gif,dataSource)
            transformDisplayCacheAnim(gif,dataSource)
        }
        
    }
    
    

    func transformDisplayCacheImage(_ img: UIImage,_ dataSource:Guiso.DataSource){
        var isTransformed = false
        var final: UIImage? = img
        
        if self.mOptions.getIsOverride() {
            isTransformed = true
            final = GuisoTransform.transformImage(img: img, outWidth: mOptions.getWidth(), outHeight: mOptions.getHeight(),scale:mOptions.getScaleType()  == .none ? .fitCenter : mOptions.getScaleType(),l: mOptions.getLanczos())
        }
        
        if finishIfCancelled() {  return  }
        
        if self.mOptions.getTransformer() != nil {
            isTransformed = true
        final  = self.mOptions.getTransformer()?.transformImage(img: img, outWidth: mOptions.getWidth(), outHeight: mOptions.getHeight())
        }
        if finishIfCancelled() {  return  }
        
        if final != nil {
            onResourceReady(final,dataSource)
            saveResource(final!,dataSource,isTransformed)
        }else{
            self.onLoadFailedError("failed transformation")
        }
    }

    func transformDisplayCacheAnim(_ gifObj:AnimatedImage,_ dataSource:Guiso.DataSource){
        let gif = gifObj
        var isTransformed = false
        
        if self.mOptions.getIsOverride() {
            isTransformed = true
            var images = [CGImage]()
            gif.frames.forEach { (cg) in
             let i = GuisoTransform.transformGif(cg: cg, outWidth: self.mOptions.getWidth(), outHeight: self.mOptions.getHeight(),scale:mOptions.getScaleType()  == .none ? .fitCenter : mOptions.getScaleType(),l: mOptions.getLanczos())
                if i != nil { images.append(i!) }
            }
            gif.frames = images
        }
        
        if finishIfCancelled() {  return  }
        
        if self.mOptions.getTransformer() != nil {
            isTransformed = true
            var images = [CGImage]()
            gif.frames.forEach { (cg) in
                let i = self.mOptions.getTransformer()!.transformGif(cg: cg, outWidth: self.mOptions.getWidth(), outHeight: self.mOptions.getHeight())
                if i != nil { images.append(i!) }
            }
            gif.frames = images
        }
        
        if finishIfCancelled() {  return  }
        
        let drawable = TransformationUtils.cleanGif(gif)
        onResourceReady(drawable,dataSource)
        saveResource(drawable,dataSource,isTransformed)
        
    }

   
    
    private func saveData(_ img:UIImage,_ dataSource:Guiso.DataSource){
        if !mKey.isValidSignature() { return }
        let st =  mOptions.getDiskCacheStrategy()
        if (st == .data && dataSource != .dataDiskCache)
            ||  (st == .automatic ||  st == .all &&  dataSource == .remote){
            let d = DiskOperation(key: sourceKey(), img: img, anim: nil, isAnim: false,isSave: true)
            Guiso.getExecutor().diskQueue.addOperation(d)
            d.isReady = true
            
        }
      
        
    }
    private func saveData(_ gif:AnimatedImage,_ dataSource:Guiso.DataSource){
        if !mKey.isValidSignature() { return }
        let st =  mOptions.getDiskCacheStrategy()
        if (st == .data && dataSource != .dataDiskCache)
            || (st == .automatic ||  st == .all &&  dataSource == .remote)  {
           let d = DiskOperation(key: sourceKey(), img: nil, anim: gif, isAnim: true,isSave:true)
            Guiso.getExecutor().diskQueue.addOperation(d)
            d.isReady = true
        }
      
    }
    
    private func saveResource(_ img:UIImage,_ dataSource:Guiso.DataSource,_ isTransformed:Bool){
        if !mKey.isValidSignature() { return }
       let st =  mOptions.getDiskCacheStrategy()
        
        if (st == .resource || st == .all && dataSource != .memoryCache
            && dataSource != .resourceDiskCache)
        || (st == .automatic && isTransformed)  {
            let d = DiskOperation(key: mKey, img: img, anim: nil, isAnim: false,isSave:true)
            Guiso.getExecutor().diskQueue.addOperation(d)
            d.isReady = true
           
       }
      
       
    }
    private func saveResource(_ gif:AnimatedImage,_ dataSource:Guiso.DataSource,_ isTransformed:Bool){
        if !mKey.isValidSignature() { return }
       let st =  mOptions.getDiskCacheStrategy()
        if (st == .resource || st == .all && dataSource != .memoryCache
                && dataSource != .resourceDiskCache)
            || (st == .automatic && isTransformed)  {
            let d = DiskOperation(key: mKey, img: nil, anim: gif, isAnim: true,isSave: true)
            Guiso.getExecutor().diskQueue.addOperation(d)
            d.isReady = true
       }
      
    }
    

    
   
    func sourceKey() -> Key {
        return  Key(signature: mPrimarySignature, extra: mOptions.getSignature(), width: -1, height: -1, scaleType: .none,frame: mOptions.getFrameSecond()  ,exactFrame:mOptions.getExactFrame(), isAnim: mOptions.getAsAnimatedImage(),
        transform: "")
    }
  
    
  
    
   
    
    func onResourceReady(_ res:UIImage?,_ dataSource:Guiso.DataSource){
        if res == nil {
            onLoadFailedError("expected recieve a object uiimage but instead got nil, datasource: \(dataSource)")
            return
        }
        status = .success
        
        resImg = res
        resAnim = nil
        
        self.dataSource = dataSource
        markFinished()

        
    }
    func onResourceReady(_ res:AnimatedImage?,_ dataSource:Guiso.DataSource){
        if res == nil {
            onLoadFailedError("expected recieve a object animatedImage but instead got nil, datasource: \(dataSource)")
            return
        }
        status = .success
        
        resImg = nil
        resAnim = res
        
        self.dataSource = dataSource
        markFinished()
        
        
    }
    
    func onLoadFailedError(_ msg:String){
            status = .failed
            resImg = nil
            resAnim = nil
            error = msg
            
            markFinished()
        
    }
    

    
    //MARK: Operation
    
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
            willChangeValue(for: \FetcherOperation.isReady)
            mIsReady = newValue
            didChangeValue(for: \FetcherOperation.isReady)
        }
        get{
            return mIsReady
        }
    }
    
    
    private var mIsCancelled = false
    override var isCancelled: Bool {
        set{
            willChangeValue(for: \FetcherOperation.isCancelled)
            mIsCancelled = newValue
            didChangeValue(for: \FetcherOperation.isCancelled)
        }
        get{
            return mIsCancelled
        }
    }
    

  
 
    
    private var mIsExecuting = false
    override var isExecuting: Bool {
        set{
            willChangeValue(for: \FetcherOperation.isExecuting)
            mIsExecuting = newValue
            didChangeValue(for: \FetcherOperation.isExecuting)
        }
        get{
            return mIsExecuting
        }
    }
    
    private var mIsFinished = false
    override var isFinished: Bool {
        set{
            willChangeValue(for: \FetcherOperation.isFinished)
            mIsFinished = newValue
            didChangeValue(for: \FetcherOperation.isFinished)
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
