//
//  TransformOperation.swift
//  JJGuiso
//
//  Created by Juan J LF on 11/11/20.
//

import UIKit

class TransformOperation : Operation {

    private(set) var resImg: UIImage?
    private(set) var resAnim: AnimatedImage?
    private var mIsAnim = false
    private(set) var status: Status = .none
    private var mOutWidth:CGFloat = 200
    private var mOutHeight:CGFloat = 200
    private var mScale: Guiso.ScaleType = .fitCenter
    private var mLancoz = false
    private(set) var error = ""
    private var mTrasnformer : TransformProtocol?
    private var mIsOverride = false
    init(transformer:TransformProtocol?, img:UIImage?,anim:AnimatedImage?,isOverride:Bool,ow:CGFloat,oh:CGFloat,isAnim:Bool,scale:Guiso.ScaleType,lancoz:Bool){
        resImg = img
        resAnim = anim
        mIsAnim = isAnim
        mOutWidth = ow
        mOutHeight = ow
        mLancoz = lancoz
        mScale = scale
        mTrasnformer = transformer
        mIsOverride = isOverride
    }
    
    func run(){
        if finishIfCancelled() {  return  }
        
        if mIsAnim {
           
            if  transformGif() {
                markSuccessAnim()
            }else{
                markFailed()
            }
            
        }else{
            
            if  transformImg() {
                markSuccessImg()
            }else{
                markFailed()
            }
                
        }
            
        
        markFinished()
    }
    
    func transformImg() -> Bool{
        if mIsOverride {
            let img = GuisoTransform.transformImage(img: resImg!, outWidth: mOutWidth, outHeight: mOutHeight, scale: mScale, l: mLancoz)
             resImg = img
        }
        if isCancelled {  return false }
        if mTrasnformer != nil && resImg != nil {
           let img = mTrasnformer?.transformImage(img: resImg!, outWidth: mOutWidth, outHeight: mOutHeight)
            resImg = img
        }
        return resImg != nil
    }
    
    func transformGif() -> Bool {
        var err = false
        if mIsOverride {
            var images = [CGImage]()
            for i in 0..<resAnim!.frames.count {
                let img = GuisoTransform.transformGif(cg: resAnim!.frames[i], outWidth: mOutWidth, outHeight: mOutWidth,scale:mScale,l: mLancoz)
                   if img != nil { images.append(img!) }
                   else{
                    err = true
                    break }
            }
             resAnim!.frames = images
        }
        if isCancelled {  return false }
        if self.mTrasnformer != nil && !err {
            var images = [CGImage]()
            for i in 0..<resAnim!.frames.count {
                let img = mTrasnformer!.transformGif(cg: resAnim!.frames[i], outWidth: mOutWidth, outHeight: mOutWidth)
                   if img != nil { images.append(img!) }
                   else{
                    err = true
                    break }
            }
            resAnim!.frames = images
        }
        return !err
    }
    
   
    
    //MARK: Operation
    
    private func markFailed(){
        if resImg != nil { resImg = nil }
        if resAnim != nil { resAnim = nil }
        error = "Transformation failed"
        status = .failed
    }
    
    private func markSuccessImg(){
        if resAnim != nil {  resAnim = nil }
        status = .success
    }
    
    private func markSuccessAnim(){
        if resImg != nil { resImg = nil }
        status = .success
    }
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
            willChangeValue(for: \TransformOperation.isCancelled)
            mIsCancelled = newValue
            didChangeValue(for: \TransformOperation.isCancelled)
        }
        get{
            return mIsCancelled
        }
    }
    
    
    private var mIsReady = false
    override var isReady: Bool {
        set{
            willChangeValue(for: \TransformOperation.isReady)
            mIsReady = newValue
            didChangeValue(for: \TransformOperation.isReady)
        }
        get{
            return mIsReady
        }
    }
    
    
    private var mIsExecuting = false
    override var isExecuting: Bool {
        set{
            willChangeValue(for: \TransformOperation.isExecuting)
            mIsExecuting = newValue
            didChangeValue(for: \TransformOperation.isExecuting)
        }
        get{
            return mIsExecuting
        }
    }
    
    private var mIsFinished = false
    override var isFinished: Bool {
        set{
            willChangeValue(for: \TransformOperation.isFinished)
            mIsFinished = newValue
            didChangeValue(for: \TransformOperation.isFinished)
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
