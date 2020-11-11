//
//  GuisoRequestManager.swift
//  Guiso
//
//  Created by Juan J LF on 5/21/20.
//

import Foundation

//should make a comunication betwen preload and request???????'
 class GuisoRequestManager {
    
   
    
    static func into(_ target: ViewTarget, builder:GuisoRequestBuilder) -> ViewTarget? {
  
   
            
            let request  = GuisoRequest(model:builder.getModel(),builder.getPrimarySignature(),options: builder.getOptions(),target,loader:builder.getLoader(),animImgDecoder: builder.getAnimatedImageDecoder())
//            let request = Guiso.mPoolRequest.aquire()!
//
//            request.setup(model:builder.getModel(),builder.getPrimarySignature(),options: builder.getOptions(),target,loader:builder.getLoader(),animImgDecoder: builder.getAnimatedImageDecoder(), pool: Guiso.mPoolRequest)
        
        if let tb = builder.getThumb() , builder.getThumb()?.getModel() != nil {
            
            let thumbRequest = GuisoRequestThumb(model: tb.getModel()!,tb.getPrimarySignature(), options: tb.getOptions(), target, loader: tb.getLoader(), animImgDecoder: tb.getAnimatedImageDecoder())
            
             request.setThumb(thumbRequest)
            
        }
    
           
        if let previous = target.getRequest() {
            if previous == request && !(builder.getOptions().getSkipMemoryCache() && previous.isComplete()) {
                
                if !previous.isRunning(){
                    previous.isCancelled = false
                    previous.begin()
                }
               return target
            
            }
        }
        
          
        
            clear(target: target)
            target.setRequest(request)
            request.begin()
        
          return target
    }
      
    static func clear(target:ViewTarget){
        target.getRequest()?.clear()
        target.setRequest(nil)

    }

  
      
 
    
    static func getPriority(_ priority:Guiso.Priority) -> DispatchQoS {
        switch priority {
        case .background:
          return .background
        case .high:
          return .userInteractive
        case .low:
          return .utility
        default:
          return .userInitiated
        }
    }
    
}
