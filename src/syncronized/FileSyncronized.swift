//
//  FileSyncronized.swift
//  JJGuiso
//
//  Created by Juan J LF on 11/9/20.
//

import Foundation


public class FileSyncronized {
    
    private var mLock = pthread_rwlock_t()
    public init() {
        pthread_rwlock_init(&mLock, nil)
    }
    deinit {
        pthread_rwlock_destroy(&mLock)
    }
    
    
    func getData(urlAbsoluteString:String) -> Data? {
        pthread_rwlock_rdlock(&mLock) ; defer { pthread_rwlock_unlock(&mLock) }
        guard let url = URL(string: urlAbsoluteString),
            let data = try? Data(contentsOf: url)
                else {
                   return nil
               }
        return data
    }
    
    
}
