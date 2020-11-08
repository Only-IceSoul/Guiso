//
//  Pool.swift
//  JJGuiso
//
//  Created by Juan J LF on 11/5/20.
//

import Foundation


open class Pool<T> {
    
    public init() {
        
    }
    
    open func aquire() -> T?{
        return nil
    }
    
    open func release(ins:T) -> Bool {
        return false
    }
}
