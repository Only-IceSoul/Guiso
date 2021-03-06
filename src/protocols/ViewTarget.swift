//
//  GuisoImage.swift
//  react-native-jjkit
//
//  Created by Juan J LF on 4/22/20.
//

import UIKit


public protocol ViewTarget: AnyObject {
    
    func setRequest(_ tag:GuisoRequest?)
    func getRequest() -> GuisoRequest?
    func onResourceReady(_ gif:AnimatedLayer)
    func onResourceReady(_ img:UIImage)
    func onLoadFailed(_ error:String)
    func getContentMode() -> UIView.ContentMode
    func onHolder(_ image:UIImage?)
    func onFallback()

}
