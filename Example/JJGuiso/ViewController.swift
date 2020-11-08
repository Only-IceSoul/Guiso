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
        DispatchQueue.global(qos: .userInitiated).async {
            Guiso.cleanDiskCache()
        }
        
       
        
        
    }
   
    @IBAction func handleButton(_ sender: UIButton) {
        
       //video
//      let url = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"

//        let url = "https://i.pinimg.com/originals/1b/06/9c/1b069c08879c4323b3a7362155124fad.gif"
        
        let url = "https://res.cloudinary.com/demo/image/upload/bored_animation.gif"
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
      

        
        Guiso.load(model:url)
       
            
            
            .asAnimatedImage()
            
            .thumbnail(Guiso.load(model: "https://cnnespanol.cnn.com/wp-content/uploads/2016/09/meme-anonimos.jpg?quality=100&strip=info&w=320&h=240&crop=1"))
  
         
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
        func loadData(model: Any?, width: CGFloat, height: CGFloat, options: GuisoOptions, callback: @escaping (Any?, Guiso.LoadType,String,Guiso.DataSource) -> Void) {
            
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

