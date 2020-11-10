//
//  PhotosSyncronized.swift
//  JJGuiso
//
//  Created by Juan J LF on 11/8/20.
//

import UIKit
import Photos

public class PhotosSyncronized {

    private var mLock = pthread_rwlock_t()
    public init() {
        pthread_rwlock_init(&mLock, nil)
    }
    deinit {
        pthread_rwlock_destroy(&mLock)
    }
    
    
    public func requestContentEditingInput(asset:PHAsset,options:PHContentEditingInputRequestOptions,_ idBlock:@escaping (Int)->Void,_ completion:@escaping (PHContentEditingInput?, [AnyHashable : Any])->Void){
        pthread_rwlock_rdlock(&mLock) ; defer { pthread_rwlock_unlock(&mLock) }
        var isFinished = false
        var val :PHContentEditingInput?
        var inf = [AnyHashable : Any]()
       let id = asset.requestContentEditingInput(with: options) { (value, info) in
            val = value
            inf = info
            isFinished = true
            
         }
        idBlock(id)
        while !isFinished {
            Thread.sleep(forTimeInterval: 0.015)
        }
        completion(val,inf)
    }
    
    
    public func requestAVAsset(forVideo:PHAsset,options:PHVideoRequestOptions,_ idBlock:@escaping (PHImageRequestID)->Void,_ completion:@escaping (AVAsset?,AVAudioMix?, [AnyHashable : Any]?)->Void){
        
        var isFinished = false
        var r1 :AVAsset?
        var r2 : AVAudioMix?
        var r3 : [AnyHashable : Any]?
        let id = PHImageManager.default().requestAVAsset(forVideo: forVideo, options: options) { (av, avmix, dic) in
            r1 = av
            r2 = avmix
            r3 = dic
            isFinished = true
        }
        idBlock(id)
        while !isFinished {
            Thread.sleep(forTimeInterval: 0.015)
        }
        completion(r1,r2,r3)
    }
}
