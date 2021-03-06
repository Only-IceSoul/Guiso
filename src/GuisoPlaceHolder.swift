//
//  GuisoPlaceHolder.swift
//  Guiso
//
//  Created by Juan J LF on 5/19/20.
//

import UIKit

public class GuisoPlaceHolder : Equatable {
    public static func == (lhs: GuisoPlaceHolder, rhs: GuisoPlaceHolder) -> Bool {
        return lhs.mName == rhs.mName
            &&  (lhs.mImage == nil && rhs.mImage == nil)
            && lhs.mColor == rhs.mColor
            && lhs.mWidth == rhs.mWidth
            && lhs.mHeight == rhs.mHeight
    }
    
    private var mName:String?
    private var mImage:UIImage?
    private var mColor: UIColor?
    private var mWidth:CGFloat = 250
    private var mHeight:CGFloat = 250
    public init(_ name:String) {
       mName = name
       mImage = nil
       mColor = nil
    }

    public init(_ image:UIImage) {
        mName = nil
        mImage = image
        mColor = nil
    }
    public init(_ color:UIColor,w:CGFloat,h:CGFloat) {
        mName = nil
        mImage = nil
        mColor = color
        mWidth = w
        mHeight = h
    }


    public func load(_ target: ViewTarget?) {
       if mImage != nil {
            target?.onHolder(mImage)
       }else if mColor != nil {
        let img = GuisoUtils.imageColor(color: mColor!,w: mWidth,h:mHeight)
            target?.onHolder(img)
       }else if mName != nil {
           let img = UIImage(named: mName!)
            target?.onHolder(img)
       }else{
          target?.onHolder(nil)
       }
    }

    
    
}
