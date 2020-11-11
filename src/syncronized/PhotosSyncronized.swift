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
    
    
    public func requestContentEditingInput(asset:PHAsset,options:PHContentEditingInputRequestOptions,_ completion:@escaping (PHContentEditingInput?, [AnyHashable : Any])->Void) -> Int{
        pthread_rwlock_rdlock(&mLock) ; defer { pthread_rwlock_unlock(&mLock) }
        return asset.requestContentEditingInput(with: options) { (value, info) in
            completion(value,info)
         }

    }
    
    
    public func requestAVAsset(forVideo:PHAsset,options:PHVideoRequestOptions,_ completion:@escaping (AVAsset?,AVAudioMix?, [AnyHashable : Any]?)->Void)->PHImageRequestID{
        pthread_rwlock_rdlock(&mLock) ; defer { pthread_rwlock_unlock(&mLock) }

        return PHImageManager.default().requestAVAsset(forVideo: forVideo, options: options) { (av, avmix, dic) in
            completion(av,avmix,dic)
        }
    }
    
}
