//
//  Guiso.swift
//  react-native-jjkit
//
//  Created by Juan J LF on 4/22/20.
//

import UIKit
import Photos
public class Guiso {
    
    static private var instance : Guiso?
    private static var mMemoryCache = GuisoCache(200)
    private static var mExecutor = Executor()
    private static var mDiskCache = GuisoDiskCache("Guiso", maxSize: 250)
    private static var mMemoryCacheGif = GuisoCacheGif(100)
    private static var mPhotos = PhotosSyncronized()
    private static var mFileSync = FileSyncronized()
    public static func load(model: Any?) -> GuisoRequestBuilder{
        return GuisoRequestBuilder(model:model)
    }
    public static func load(model:Any?,loader: LoaderProtocol) -> GuisoRequestBuilder{
           return GuisoRequestBuilder(model: model, loader: loader)
    }
  
    static func getPhotos()-> PhotosSyncronized{
        return mPhotos
    }
    static func getFileSync()-> FileSyncronized{
        return mFileSync
    }
    static func getExecutor() -> Executor {
        return mExecutor
    }

    static func getAsset(_ id:String) -> PHFetchResult<PHAsset> {
         let options = PHFetchOptions()
         options.predicate = NSPredicate(format: "localIdentifier == %@",id)
         return PHAsset.fetchAssets(with: options)
     }
    
    public static func cleanMemoryCache(){
        mMemoryCache.clear()
        mMemoryCacheGif.clear()
    }
    
    public static func clear(target:ViewTarget?){
        if target == nil { return }
        GuisoRequestManager.clear(target: target!)
    }
    
    public static func cleanDiskCache(){
        self.mDiskCache.clean()
    }
    
    static func getMemoryCache() -> GuisoCache {
        return mMemoryCache
    }
    static func getMemoryCacheGif() -> GuisoCacheGif {
        return mMemoryCacheGif
    }
  
    
    static func getDiskCache() -> GuisoDiskCache {
        return mDiskCache
    }
  
    
    public enum DiskCacheStrategy : Int{
        case none = 0,
        all,
        data,
        resource,
        automatic
    }
    
    public enum MediaType: Int {
        case image = 0,
        video,
        gif,
        audio
    }
    
  
    
    
    public enum ScaleType:Int {
        case fitCenter = 0,
        centerCrop,
        none
    }
   
    public enum Priority :Int {
        case background = 0,
        low,
        normal,
        high
    }
    
    public enum LoadType  :Int {
         case data = 0,
         uiimg,
         animatedImg
      }
    
    public enum DataSource  :Int {
        case local = 0,
             remote,
             memoryCache,
             dataDiskCache,
             resourceDiskCache
    }
      
    
    static func writeToCacheFolder(_ data:Data,name:String) -> URL? {
        do{
            let cacheDir = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
            let path = URL(fileURLWithPath: cacheDir).appendingPathComponent(name)
            try data.write(to: path)
            return path

        }catch let error as NSError {
            print("writeToCacheFolder - dataVideo  -> Image generation -  failed with error: \(error)")
            return nil
        }
    }
}
