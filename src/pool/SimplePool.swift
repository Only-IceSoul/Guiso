//
//  SimplePool.swift
//  JJGuiso
//
//  Created by Juan J LF on 11/5/20.
//

import Foundation

public class SimplePool<T: Equatable>: Pool<T> {
    
    private var mPool : [T?]!
    
    public init(max:Int){
        if max <= 0 {
            fatalError( "The max pool size must be > 0")
        }
        mPool = [T?](repeating: nil, count: max)
    }
    
    public override func aquire() -> T? {
        if mPoolSize > 0 {
            let lastPooledIndex = mPoolSize - 1
            let ins = mPool[lastPooledIndex]
            mPool[lastPooledIndex] = nil
            mPoolSize -= 1
            return ins
        }
        return nil
    }
    
    public override func release(ins:T) -> Bool {
        if isInPool(ins: ins){
            fatalError("Already in the pool!")
        }
        
        if mPoolSize < mPool.count {
            mPool[mPoolSize] = ins
            mPoolSize += 1
            return true
        }
        return false
    }
    
    private var mPoolSize = 0
    
    private func isInPool(ins:T) -> Bool{
        for i in 0..<mPoolSize {
            if mPool[i] == ins {
                return true
            }
        }
        return false
    }
}
