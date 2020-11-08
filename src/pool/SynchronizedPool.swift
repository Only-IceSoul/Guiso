//
//  SynchronizedPool.swift
//  JJGuiso
//
//  Created by Juan J LF on 11/5/20.
//

import Foundation


public class SynchronizedPool<T:Equatable>: SimplePool<T> {
    
    private var mLock = pthread_rwlock_t()
    
    public override init(max: Int) {
        super.init(max: max)
        pthread_rwlock_init(&mLock, nil)
    }
    
    deinit {
        pthread_rwlock_destroy(&mLock)
    }
    
    
    public override func aquire() -> T? {
        pthread_rwlock_wrlock(&mLock) ; defer { pthread_rwlock_unlock(&mLock) }
        return super.aquire()
    }
    
    
    public override func release(ins: T) -> Bool {
        pthread_rwlock_wrlock(&mLock) ; defer { pthread_rwlock_unlock(&mLock) }
        return super.release(ins: ins)
    }
}
