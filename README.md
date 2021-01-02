# Guiso
[![Version](https://img.shields.io/cocoapods/v/Guiso.svg?style=flat)](https://cocoapods.org/pods/Guiso)
[![License](https://img.shields.io/cocoapods/l/Guiso.svg?style=flat)](https://cocoapods.org/pods/Guiso)
[![Platform](https://img.shields.io/cocoapods/p/Guiso.svg?style=flat)](https://cocoapods.org/pods/Guiso)

Guiso is image loading framework for IOS that wraps media decoding, memory and disk caching.
By default Guiso uses URLSession. Supports fetching, decoding, and displaying video stills, images, and animated GIFs.
Guiso's primary focus is on making scrolling any kind of a list of images as smooth and fast as possible, but Guiso is also effective for almost any case where you need to fetch, resize, and display a remote image.

## Requirements

```
 ios developer target 10.0
```

## Installation

Guiso is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JJGuiso'
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


## Freatures

- [x] url web
- [x] uri
- [x] asset local identifier
- [x] Data
- [x] Custom Model and loader
- [x] Custom Transform
- [x] Custon Animated Image Decoder
- [x] Preload
- [x] thumbanil,placeholder,error,fallback
- [x] Options 

## Usage

Guiso send result to View who implement protocol ViewTarget.

Use GuisoView.

```swift
import Guiso

let img = GuisoView()  // ViewTarget
Guiso.load(url).into(img)

//by default caching is disabled for Data object.
Guiso.load(data).into(img)
//There's no efficient way to compute a cache name for a byte array. 
// You can supply your own name using signature(). short names "IMG_WA\(self.count)"
Guiso.load(data).signature("IMG_WA001").into(img)

```

### ViewTarget

Targets are responsible for displaying loaded resources. GuisoView display gif and UIImage using ImageView. Users can also implement their own Targets.

```swift
class MyViewTarget : ViewTarget {

}
```

### **Transform**

Transformations in Guiso take a resource, mutate it, and return the mutated resource. Typically transformations are used to crop or resize a UIImage, but they can also be used to transform animated GIFs.

**fitCenter(aspectFit):**
Scales the image uniformly (maintaining the image's aspect ratio) so that one of the dimensions of the image will be equal to the given dimension and the other will be less than the given dimension.

**centerCrop(aspectFill):**  
Scale the image so that either the width of the image matches the given width and the height of the image is greater than the given height or vice versa, and then crop the larger dimension to match the given dimension. Does not maintain the image's aspect ratio  


Applying Transformations:

```swift
let width = 200
let height = 200
let view = GuisoView()

Guiso.load(url).fitCenter().override(width,height).into(view)

Guiso.load(Data).centerCrop().override(width,height).into(view)

```

## Animated Gif 

```swift

Guiso.load("url").asAnimatedImage().into(myViewTarget) // gif

```

## Animated Webp

```swift
// use https://cocoapods.org/pods/JJGuisoWebP
//create a class and implement AnimatedImageDecoderProtocol
let decoder:  AnimatedImageDecoderProtocol = MyClass()
Guiso.load("url").asAnimatedImage().animatedImageDecoder(decoder).into(myViewTarget) // gif

```

## Priority

Priorities for completing loads. If more than one load is queued at a time, the load with the higher priority will be started first. Priorities are considered best effort, there are no guarantees about the order in which loads will start or finish.

- background
- low
- normal
- high

## Header

Headers to load images 

```swift

let headers = GuisoHeader().addHeader(key:"Authorization",value:"token")

Guiso.load(urlWeb).headers(headers).into(target)

```
