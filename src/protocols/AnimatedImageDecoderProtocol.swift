//
//  GifDecoderProtocol.swift
//  Guiso
//
//  Created by Juan J LF on 5/19/20.
//

import Foundation


public protocol AnimatedImageDecoderProtocol {
    
    func getFirstFrame(data:Data) -> CGImage?
    
    func decode(data:Data) -> AnimatedImage?
    
}
