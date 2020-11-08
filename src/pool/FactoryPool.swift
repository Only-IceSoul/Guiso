//
//  FactoryPool.swift
//  JJGuiso
//
//  Created by Juan J LF on 11/5/20.
//

import Foundation


public class FactoryPool<T: Equatable> : Pool<T>{
    
    private var mPool: Pool<T>!
    private var mFactory: Factory<T>!
    public init(pool:Pool<T>,factory:Factory<T>) {
        mPool = pool
        mFactory = factory
    }
    
    @discardableResult
    public override func aquire() -> T? {
        var result = mPool.aquire()
        if result == nil {
            result = mFactory.create()
        }
        if result == nil {
            fatalError("null pointer factory create")
        }
        return result
    }
    
    @discardableResult
    public override func release(ins: T) -> Bool {
        return mPool.release(ins: ins)
    }
}
