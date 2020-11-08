//
//  GuisoErrorHolder.swift
//  Guiso
//
//  Created by Juan J LF on 5/20/20.
//

import UIKit


class GuisoErrorHolder : Equatable {
   
    static func == (lhs: GuisoErrorHolder, rhs: GuisoErrorHolder) -> Bool {
        return lhs.mName == rhs.mName
            && (lhs.mImage == nil && rhs.mImage == nil)
            && lhs.mColor == rhs.mColor
            && (lhs.mBuilder == nil && rhs.mBuilder == nil)
    }
    
    private var mName:String?
    private var mImage:UIImage?
    private var mTarget: ViewTarget?
    private var mColor: UIColor?
    private var mBuilder: GuisoRequestBuilder?
    
    init(_ builder:GuisoRequestBuilder) {
        mName = nil
        mImage = nil
        mColor = nil
        mBuilder = builder
    }
    init(_ name:String) {
        mName = name
        mImage = nil
        mColor = nil
    }
    
    init(_ image:UIImage) {
       mName = nil
       mImage = image
        mColor = nil
    }
    init(_ color:UIColor) {
       mName = nil
       mImage = nil
        mColor = color
    }
    
    
    func load(_ target:ViewTarget?) {
     
        if mImage != nil {
            target?.onHolder(mImage)
        }else if mColor != nil {
            let img = GuisoUtils.imageColor(color: mColor!)
            target?.onHolder(img)
        }else if mName != nil {
            let img = UIImage(named: mName ?? "")
            target?.onHolder(img)
        }else{
            if  let builder = mBuilder {
               
                    let mainRequest = GuisoRequest(model:builder.getModel(),builder.getPrimarySignature(),options: builder.getOptions(),target,loader:builder.getLoader(),animImgDecoder: builder.getAnimatedImageDecoder())
                
                    target?.setRequest(mainRequest)
                    mainRequest.begin()
               
            }
        }
        
    }
    
    
    

}
