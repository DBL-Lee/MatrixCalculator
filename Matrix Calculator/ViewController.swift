//
//  ViewController.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 12/02/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//
import MobileCoreServices
import UIKit
import GPUImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//    var lastPoint:CGPoint!
//    var brushWidth:CGFloat = 20
//    var mouseSwiped = false
    var NN:NeuralNetwork!
    
    @IBOutlet weak var imageView: UIImageView!
    var newMedia:Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.grayColor()
       
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0), {
            self.NN = NeuralNetwork()
        })
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func scaledownImage(image:UIImage)->UIImage {
        let N:CGFloat = 0.5
        var rect:CGRect! //= CGRectMake(0, 0, image.size.width/2, image.size.height/2)
        if image.size.width > image.size.height {
            rect = CGRectMake(0, 0, 1280, 960)
        }else{
            rect = CGRectMake(0, 0, 960, 1280)
        }
//        let gImage = GPUImagePicture(image: image)
//        let rescaleFilter = GPUImageLanczosResamplingFilter()
//        rescaleFilter.forceProcessingAtSize(rect.size)
//        gImage.addTarget(rescaleFilter)
//        rescaleFilter.useNextFrameForImageCapture()
//        gImage.processImage()
////        let resImage = UIImage(CGImage: rescaleFilter.imageFromCurrentFramebuffer().CGImage, scale: 1.0, orientation: image.imageOrientation)
////        return resImage!
//        
//        let imageRef = image.CGImage
//        
//        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
//        let context = UIGraphicsGetCurrentContext()
//        
//        // Set the quality level to use when rescaling
//        CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
//        let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, rect.size.height)
//        
//        CGContextConcatCTM(context, flipVertical)
//        // Draw into the context; this scales the image
//        CGContextDrawImage(context, rect, imageRef)
//        
//        let newImageRef = CGBitmapContextCreateImage(context) as CGImage
//        let newImage = UIImage(CGImage: newImageRef)
//        
//        // Get the resized image from the context and a UIImage
//        UIGraphicsEndImageContext()
//        
//        return newImage!

        
//        UIGraphicsBeginImageContext(rect.size)
//        image.drawInRect(rect)
//        var newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return newImage

//        var imageref:CGImage = image.CGImage
//        let width = 1280
//        let height = 960
//        let bitsPerComponent = CGImageGetBitsPerComponent(imageref)
//        let bytesPerRow = CGImageGetBytesPerRow(imageref)
//        let colorSpace = CGImageGetColorSpace(imageref)
//        let bitmapInfo = CGImageGetBitmapInfo(imageref)
//        
//        let context = CGBitmapContextCreate(nil, UInt(width), UInt(height), bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)
//        
//        CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
//        //CGContextRotateCTM(context, 90)
//        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: CGSize(width: CGFloat(width), height: CGFloat(height))), imageref)
//        
//        let scaledImage = UIImage(CGImage: CGBitmapContextCreateImage(context),scale: 1.0,orientation: image.imageOrientation)
//        return scaledImage!
        return image.resizedImage(rect.size, interpolationQuality: kCGInterpolationHigh)
    }
    
    func thresholdImage(image:UIImage)->UIImage {
//        var pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage))
//        var data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
//        let colorSpace = CGColorSpaceCreateDeviceGray()
//        var imWidth = Int(image.size.width), imHeight = Int(image.size.height)
//        let avContext = CGBitmapContextCreate(nil, 1, 1, 8, 0, colorSpace, CGBitmapInfo(CGImageAlphaInfo.None.rawValue))
//        CGContextDrawImage(avContext, CGRectMake(0, 0, 1, 1), image.CGImage)
//        let avPixelData = CGDataProviderCopyData(CGImageGetDataProvider(CGBitmapContextCreateImage(avContext)))
//        let avData: UnsafePointer<UInt8> = CFDataGetBytePtr(avPixelData)
//        //obtained average color
//        let averageColor:Int = 100
//        var newPixelArray = [UInt8](count: (pixelData as NSData).length, repeatedValue: 0)
//        let bytesPerRow = Int(CGImageGetBytesPerRow(image.CGImage))
//        for i in 0..<(pixelData as NSData).length {
//            //let surroundingColor = data[
//            if Int(data[0]) > averageColor {
//                newPixelArray[i] = 255
//            }
//            data = data+1
//        }
//        let bitmapInfo = CGImageGetBitmapInfo(image.CGImage)
//        let newContext = CGBitmapContextCreate(&newPixelArray, UInt(image.size.width), UInt(image.size.height), CGImageGetBitsPerComponent(image.CGImage), CGImageGetBytesPerRow(image.CGImage), colorSpace, bitmapInfo)
//        let imageRef = CGBitmapContextCreateImage(newContext)
//        let image = UIImage(CGImage: imageRef)
        let gImage = GPUImagePicture(image: image)
        let thresholdFilter = GPUImageAdaptiveThresholdFilter()
        thresholdFilter.blurRadiusInPixels = 6
        gImage.addTarget(thresholdFilter)
        thresholdFilter.useNextFrameForImageCapture()
        gImage.processImage()
        let image = thresholdFilter.imageFromCurrentFramebuffer()
        //let resImage = UIImage(CGImage: thresholdFilter.imageFromCurrentFramebuffer().CGImage, scale: 1.0, orientation: image.imageOrientation)
        let imageRect = CGRectMake(0, 0, image.size.width, image.size.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGBitmapContextCreate(nil, UInt(image.size.width), UInt(image.size.height), 8, UInt(image.size.width), colorSpace, CGBitmapInfo(CGImageAlphaInfo.None.rawValue))
        CGContextDrawImage(context, imageRect, image.CGImage)
        let imageRef = CGBitmapContextCreateImage(context)
        let newImage = UIImage(CGImage: imageRef)
        return newImage!
    }
    
    func connectedComponents(image:UIImage) -> UIImage{
        var pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage))
        var result:[[Int]] = []
        var flag = [Bool](count: (pixelData as NSData).length, repeatedValue: false)
        println(flag.count)
        var data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let bytesPerRow = Int(CGImageGetBytesPerRow(image.CGImage))
        var newPixelArray = [UInt8](count: (pixelData as NSData).length, repeatedValue: 255)
        let bytesPerColumn = Int(image.size.height)
        println(bytesPerRow,bytesPerColumn)
        for i in 0..<(pixelData as NSData).length {
            if !flag[i] && data[i]==0 {
                var temp:[Int] = []
                temp.append(i)
                let (l,r,u,d) = DFS(i,data: data,newPixelArray: &temp, flag: &flag,bytesPerRow: bytesPerRow,bytesPerColumn: bytesPerColumn)
                let width = r-l+1
                let height = d-u+1
                if Float(width)<Float(height)*2 && !(width<7 && height<7){
                    //println(temp.count)
                    println(l,r,u,d,temp.count)
                    result.append(temp)
                    for pixel in temp {
                        newPixelArray[Int(pixel)] = 0
                    }
                }
            }
        }
        func s(a:[Int],b:[Int])->Bool {
            return a.count>b.count
        }
        result.sort(s)
        
        
//        for x in 0...5 {
//            println(result[x].count)
//            for pixel in result[x] {
//                newPixelArray[Int(pixel)] = 0
//            }
//        }
        println(result.count)
        let colorSpace = CGImageGetColorSpace(image.CGImage)
        let bitmapInfo = CGImageGetBitmapInfo(image.CGImage)
        let newContext = CGBitmapContextCreate(&newPixelArray, UInt(image.size.width), UInt(image.size.height), CGImageGetBitsPerComponent(image.CGImage), CGImageGetBytesPerRow(image.CGImage), colorSpace, bitmapInfo)
        let imageRef = CGBitmapContextCreateImage(newContext)
        let image = UIImage(CGImage: imageRef)
        return image!
    }
    
    func DFS(i:Int,data:UnsafePointer<UInt8>,inout newPixelArray:[Int], inout flag:[Bool],bytesPerRow:Int,bytesPerColumn:Int) -> (Int,Int,Int,Int){
        flag[i] = true
        let y = i/bytesPerRow
        let x = i%bytesPerRow
        var l = x,r = x ,u = y ,d = y
        //println((i,i+1<bytesPerRow,data[i+1]==0,!flag[i+1]))
        if x+1<bytesPerRow && data[i+1]==0 && !flag[i+1]{
            newPixelArray.append(i+1)
            var (lv,rv,uv,dv) = DFS(i+1, data: data,newPixelArray: &newPixelArray, flag: &flag, bytesPerRow: bytesPerRow,bytesPerColumn: bytesPerColumn)
            //r = rv; u = uv; d = dv
            if l>lv {l=lv}
            if u>uv {u=uv}
            if r<rv {r=rv}
            if d<dv {d=dv}
        }
        if y+1<bytesPerColumn && data[i+bytesPerRow]==0 && !flag[i+bytesPerRow]{
            newPixelArray.append(i+bytesPerRow)
            var (lv,rv,uv,dv) = DFS(i+bytesPerRow, data: data,newPixelArray: &newPixelArray, flag: &flag, bytesPerRow: bytesPerRow,bytesPerColumn: bytesPerColumn)
            //l = lv; r = rv; d = dv
            if l>lv {l=lv}
            if u>uv {u=uv}
            if r<rv {r=rv}
            if d<dv {d=dv}
        }
        if x-1>=0 && data[i-1]==0 && !flag[i-1]{
            newPixelArray.append(i-1)
            var (lv,rv,uv,dv) = DFS(i-1, data: data,newPixelArray: &newPixelArray, flag: &flag, bytesPerRow: bytesPerRow,bytesPerColumn: bytesPerColumn)
            //l = lv; u = uv; d = dv
            if l>lv {l=lv}
            if u>uv {u=uv}
            if r<rv {r=rv}
            if d<dv {d=dv}
        }
        if y-1>=0 && data[i-bytesPerRow]==0 && !flag[i-bytesPerRow]{
            newPixelArray.append(i-bytesPerRow)
            var (lv,rv,uv,dv) = DFS(i-bytesPerRow, data: data,newPixelArray: &newPixelArray, flag: &flag, bytesPerRow: bytesPerRow,bytesPerColumn: bytesPerColumn)
            //l = lv; r = rv; u = uv
            if l>lv {l=lv}
            if u>uv {u=uv}
            if r<rv {r=rv}
            if d<dv {d=dv}
        }
//        if x+1<bytesPerRow && y+1<bytesPerColumn && data[i+bytesPerRow+1]==0 && !flag[i+bytesPerRow+1]{
//            newPixelArray.append(i+bytesPerRow+1)
//            var (lv,rv,uv,dv) = DFS(i+bytesPerRow+1, data: data,newPixelArray: &newPixelArray, flag: &flag, bytesPerRow: bytesPerRow,bytesPerColumn: bytesPerColumn)
//            r = rv; d = dv
//            if l>lv {l=lv}
//            if u>uv {u=uv}
//        }
//        if x+1<bytesPerRow && y-1>=0 && data[i-bytesPerRow+1]==0 && !flag[i-bytesPerRow+1]{
//            newPixelArray.append(i-bytesPerRow+1)
//            var (lv,rv,uv,dv) = DFS(i-bytesPerRow+1, data: data,newPixelArray: &newPixelArray, flag: &flag, bytesPerRow: bytesPerRow,bytesPerColumn: bytesPerColumn)
//            r = rv; u = uv
//            if l>lv {l=lv}
//            if d<dv {d=dv}
//        }
//        if x-1>=0 && y+1<bytesPerColumn && data[i+bytesPerRow-1]==0 && !flag[i+bytesPerRow-1]{
//            newPixelArray.append(i+bytesPerRow-1)
//            var (lv,rv,uv,dv) = DFS(i+bytesPerRow-1, data: data,newPixelArray: &newPixelArray, flag: &flag, bytesPerRow: bytesPerRow,bytesPerColumn: bytesPerColumn)
//            l = lv; d = dv
//            if r<rv {r=rv}
//            if u>uv {u=uv}
//        }
//        if x-1>=0 && y-1>=0 && data[i-bytesPerRow-1]==0 && !flag[i-bytesPerRow-1]{
//            newPixelArray.append(i-bytesPerRow-1)
//            var (lv,rv,uv,dv) = DFS(i-bytesPerRow-1, data: data,newPixelArray: &newPixelArray, flag: &flag, bytesPerRow: bytesPerRow,bytesPerColumn: bytesPerColumn)
//            l = lv; u = uv
//            if r<rv {r=rv}
//            if d<dv {d=dv}
//        }
        return (l,r,u,d)
    }
    
    func centerScaleImage(preimage:UIImage) -> UIImage {
        let THRESHOLD:Float = 1/300
        var pixelData = CGDataProviderCopyData(CGImageGetDataProvider(preimage.CGImage))
        var data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        var imWidth = Int(preimage.size.width), imHeight = Int(preimage.size.height)
        var bytesPerRow = CGImageGetBytesPerRow(preimage.CGImage)
        var botrow = 0, toprow = imHeight-1, leftcol = 0, rightcol = imWidth-1
        var blank = 0
        //botrow
        for var y = 0; y < imHeight ; y++ {
            for var x = 0; x < imWidth ; x++ {
                var pixelInfo: Int = Int(bytesPerRow)*y+x
                if data[pixelInfo] == 0 {
                    blank++
                }
            }
            if Float(blank)/Float(bytesPerRow) < THRESHOLD {
                botrow++
            }else{
                break
            }
        }
        botrow--
        //toprow
        blank = 0
        for var y = imHeight-1; y >= 0 ; y-- {
            for var x = 0; x < imWidth ; x++ {
                var pixelInfo: Int = Int(bytesPerRow)*y+x
                if data[pixelInfo] == 0 {
                    blank++
                }
            }
            if Float(blank)/Float(bytesPerRow) < THRESHOLD {
                toprow--
            }else{
                break
            }
        }
        toprow++
        blank = 0
        //leftcol
        for var x = 0; x < imWidth ; x++ {
            for var y = 0; y < imHeight ; y++ {
                var pixelInfo: Int = Int(bytesPerRow)*y+x
                if data[pixelInfo] == 0 {
                    blank++
                }

            }
            if Float(blank)/Float(preimage.size.height) < THRESHOLD {
                leftcol++
            }else{
                break
            }
        }
        leftcol--
        blank = 0
        //rightcol
        for var x = imWidth-1; x >= 0 ; x-- {
            for var y = 0; y < imHeight ; y++ {
                var pixelInfo: Int = Int(bytesPerRow)*y+x
                if data[pixelInfo] == 0 {
                    blank++
                }
            }
            if Float(blank)/Float(preimage.size.height) < THRESHOLD {
                rightcol--
            }else{
                break
            }
        }
        rightcol++
        
        println("\(botrow) \(toprow) \(leftcol) \(rightcol)")
        let newWidth = CGFloat(1-leftcol+rightcol), newHeight = CGFloat(1-botrow+toprow)
        let side:CGFloat = newWidth > newHeight ? newWidth : newHeight
        println(side)
        let rect = CGRectMake(0,0,side,side)
        
        UIGraphicsBeginImageContext(rect.size)
        preimage.drawAtPoint(CGPointMake((side-newWidth)/2 - CGFloat(leftcol), (side-newHeight)/2 - CGFloat(botrow)))
        let cropped_image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
//        UIGraphicsBeginImageContext(CGRectMake(0, 0, 28, 28).size)
//        cropped_image.drawInRect(CGRectMake(4,4,20,20))
//        var newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        println(newImage.size)
        return cropped_image
    }
    
    
    @IBAction func useCamera(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.Camera) {
                
                let imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                imagePicker.sourceType =
                    UIImagePickerControllerSourceType.Camera
                imagePicker.mediaTypes = [kUTTypeImage as NSString]
                imagePicker.allowsEditing = false
                
                self.presentViewController(imagePicker, animated: true, 
                    completion: nil)
                newMedia = true
        }
    }
    
    
    @IBAction func useAlbum(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.SavedPhotosAlbum) {
                let imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                imagePicker.sourceType =
                    UIImagePickerControllerSourceType.PhotoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as NSString]
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated: true,
                    completion: nil)
                newMedia = false
        }

    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as NSString
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if mediaType.isEqualToString(kUTTypeImage as NSString) {
            var image = info[UIImagePickerControllerOriginalImage]
                as UIImage
            image = scaledownImage(image)

            image = thresholdImage(image)
            image = connectedComponents(image)
            //image = centerScaleImage(image)
            imageView.image = image
            
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func testPressed(sender: UIButton) {
        let preimage = imageView.image!
        var rect = CGRect(x: 0, y: 0, width: preimage.size.width, height: preimage.size.height)
        UIGraphicsBeginImageContext(rect.size)
        preimage.drawInRect(CGRectMake(0,0,rect.size.width,rect.size.height), blendMode: kCGBlendModeLuminosity , alpha: 1.0)
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        newImage = centerScaleImage(newImage)
        var test:[[Double]] = [[Double]](count: 28*28, repeatedValue: [0.0])
        var pixelData = CGDataProviderCopyData(CGImageGetDataProvider(newImage.CGImage))
        var data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        var pixelInfo = 0
        for var y = 0; y < 28 ; y++ {
            for var x = 0; x < 28 ; x++ {
                pixelInfo = ((Int(32) * y) + x) * 4
                var a = CGFloat(data[pixelInfo+3])                //println("\(alpha) \(red)")
                test[28*y+x][0] = Double(CGFloat(a)/255.0)
            }
        }
        
        imageView.image = nil
        
        let alert = UIAlertView(title: "Input", message: String(NN.feedforward(test)), delegate: nil, cancelButtonTitle: "OK")
        alert.show()
//
//        let preimage = imageView.image!
//        var rect = CGRect(x: 0, y: 0, width: 28, height: 28)
//        UIGraphicsBeginImageContext(rect.size)
//        preimage.drawInRect(CGRectMake(0,0,rect.size.width,rect.size.height), blendMode: kCGBlendModeLuminosity , alpha: 1.0)
//        var newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        var test:[[Double]] = []
        
//        pixelData = CGDataProviderCopyData(CGImageGetDataProvider(newImage.CGImage))
//        data = CFDataGetBytePtr(pixelData)
//
//        var newPixelArray = [UInt8](count: 28*4*28, repeatedValue: 0)
//        for var y = 0; y < 28 ; y++ {
//            for var x = 0; x < 28 ; x++ {
//                var pixelInfo: Int = ((Int(28) * y) + x) * 4
//                newPixelArray[pixelInfo+3] = UInt8(test[28*y+x][0]*255)
//            }
//        }
//        let bitmapInfo = CGImageGetBitmapInfo(newImage.CGImage)
//        let provider = CGDataProviderCreateWithData(nil, &newPixelArray, UInt((pixelData as NSData).length), nil)
//        let newImageRef = CGImageCreate(28, 28, CGImageGetBitsPerComponent(newImage.CGImage), CGImageGetBitsPerPixel(newImage.CGImage), 4*28, CGColorSpaceCreateDeviceRGB(), bitmapInfo, provider, nil, false, kCGRenderingIntentDefault)
//        let image = UIImage(CGImage: newImageRef)
//        imageView.image = image

    }

        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

