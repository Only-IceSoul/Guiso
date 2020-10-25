//
//  ViewController.swift
//  JJGuiso
//
//  Created by only-icesoul on 10/14/2020.
//  Copyright (c) 2020 only-icesoul. All rights reserved.
//

import UIKit
import JJGuiso

class ViewController: UIViewController {

    @IBOutlet weak var mImageView: GuisoView!
    
    @IBOutlet weak var mImageView2: GuisoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    
    }

    @IBAction func handleButton2(_ sender: UIButton) {
        mImageView.backgroundColor = UIColor.purple
        Guiso.get().cleanDiskCache()
        
        
    }
   
    @IBAction func handleButton(_ sender: UIButton) {
        
       //video
//      let url = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"

//        guard let p = Bundle.main.url(forResource: "IMG_0021", withExtension: "GIF"),
//            let data = try? Data(contentsOf: p)
//            else { return }
//
//        let s = data.base64EncodedString()
//

//        Guiso.load(model:"base64,\(s)",loader:CustomLoader())
//        .asGif().fitCenter().override(150, 150)
//      .transform(signature: "gray", CustomTransform())
//        .signature(string: "IMG_Small") //Data or custom need a signature
//            .into(mImageView)
    
        //4k
       let url = "https://res.cloudinary.com/demo/image/upload/fl_awebp/bored_animation.webp"

        
        Guiso.load(model:url)
            .asAnimatedImage(.webp)
            
//            .frame(50,exact:true)
//            .thumbnail(Guiso.load(model: "https://scontent.fvvi1-1.fna.fbcdn.net/v/t1.0-9/20708267_503484543329533_7853583049637214163_n.png?_nc_cat=108&_nc_sid=730e14&_nc_ohc=f-ZfdnwclzsAX_qx0uk&_nc_ht=scontent.fvvi1-1.fna&oh=7f2a7f7e12bb3600a7009c9dd89d05cd&oe=5F9BD93B")
//                )
            .into(mImageView2)
        

    }
  
 
    
    
    class CustomTransform : TransformProtocol {
        func transformGif(cg: CGImage, outWidth: CGFloat, outHeight: CGFloat) -> CGImage? {
            return  TransformationUtils.convertToGrayScale(cg: cg)
        }
        
        func transformImage(img: UIImage, outWidth: CGFloat, outHeight: CGFloat) -> UIImage? {
            
            return TransformationUtils.convertToGrayScale(image: img)
        }
        
    }
    
    class CustomLoader : LoaderProtocol{
        func loadData(model: Any, width: CGFloat, height: CGFloat, options: GuisoOptions, callback: @escaping (Any?, Guiso.LoadType,String,Guiso.DataSource) -> Void) {
            
            guard let m =  model as? String else{
                callback(nil,.data,"Custom error nil or not string",.remote)
                return
            }
    
       
            let s = m.split(separator: ",")[1]
            let ms = String(s)
            let d = Data(base64Encoded: ms)
            callback(d,.data,"success",.remote)
            
            
        }
        
        func cancel(){
            
        }
           
        func pause(){
            
        }
        
        func resume(){
            
        }
    }

}

