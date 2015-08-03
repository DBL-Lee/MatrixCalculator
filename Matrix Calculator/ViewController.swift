//
//  ViewController.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 12/02/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//
import MobileCoreServices
import UIKit

protocol inputMatrixDelegate{
    func didFinishInputMatrix(nrow:Int,ncol:Int,entries:[Int],alias:String)
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var matrixLabel: UILabel!
    
    var delegate:inputMatrixDelegate!
    
    @IBOutlet weak var CameraButton: UIButton!
    
    var NN:NeuralNetwork!
    var newMedia:Bool?
    var image:UIImage!

    var imagePicker:UIImagePickerController!
    
    let BLACKTHRESHOLD = 80
    let DETECTIONTHRESHOLD = 100
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0), {
            self.NN = NeuralNetwork()
        })
        updateLabel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: printing matrix
    let MAXROW = 10
    let MAXCOLUMN = 10

    var matrix:Matrix = Matrix(r: 2, c: 2)
    var width:[Int] = [1,1]    
    var currentCursor = (0,0)
    
    var entering = false //flag to indicate whether user is entering
    
    
    func updateLabel(){
        var aString = NSMutableAttributedString()
        for i in 0..<matrix.row {
            for j in 0..<matrix.column{
                if i!=currentCursor.0 || j!=currentCursor.1 || !entering {
                    let entry:String = matrix.matrix[i][j].toString()
                }else{
                    let entry:String = (negative ? "-" : "") + numerator + (numberlineEntered ? "/" : "") + denominator
                }
                var spaceBefore = (width[j]-count(entry))/2
                let spaceAfter = width[j]-spaceBefore
                if (j>0) {spaceBefore++}
                let str = String(count: spaceBefore, repeatedValue: " " as Character)+entry+String(count: spaceAfter, repeatedValue: " " as Character)
                let currentString = NSMutableAttributedString(string: str)
                if i==currentCursor.0 && j==currentCursor.1 {
                    currentString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: NSRange(location: spaceBefore, length: count(entry)) )
                }
                aString.appendAttributedString(currentString)
            }
            aString.appendAttributedString(NSAttributedString(string: "\n"))
            
        }
        self.matrixLabel.attributedText = aString
    }

    //MARK: inputvalue
    var numerator:String = "0"
    var denominator:String = ""
    var floatingPoint:Int = 1
    let FLOATPOINTUPPER = 5

    //flags
    var negative = false
    var floatpointEntered:Bool = false
    var numberlineEntered:Bool = false

    //user started entering
    @IBAction func digitPressed(sender: UIButton) {
        switch sender.titleLabel.text {
            case "DEL": {
                if numberlineEntered && denominator=="" {
                    numberlineEntered = false
                    width[currentCursor.1]--
                }else{
                    if !numberlineEntered {
                        if count(numerator)==1 {
                            numerator = "0"
                        }else{
                            numerator = dropLast(numerator)
                            width[currentCursor.1]--
                        }
                    }else{
                        denominator = dropLast(denominator)
                        width[currentCursor.1]--
                        floatingPoint--
                    }
                }
            }
            case ".": {
                if !floatpointEntered{
                    if !numberlineEntered{
                        numerator+="."
                    }else{
                        denominator+="."
                    }
                    floatpointEntered = true
                    width[currentCursor.1]++
                }
            }
            case "/": {
                if !numberlineEntered{
                    width[currentCursor.1]++
                    floatingPoint = 1
                    numberlineEntered = true
                    floatpointEntered = false
                }
            }
            case "+/-": {
                negative = !negative
            }
            default:{                
                if !numberlineEntered{
                    if numerator == "0" {
                        numerator = sender.titleLabel.text
                    }else{
                        numerator += sender.titleLabel.text
                        width[currentCursor.1]++
                    }
                }else{
                    if floatingPoint<FLOATPOINTUPPER {
                        denominator += sender.titleLabel.text
                        floatingPoint ++
                        width[currentCursor.1]++
                    }
                }
            }
        }
        entering = true
        updateLabel()
    }


    private func calculateCurrentCell(){
        entering = false
        let n = Fraction(NSString(string:(negative ? "-" : "")+numerator).doublevalue())
        if numberlineEntered {
            d = Fraction(NSString(string:denominator).doublevalue())
        }else {
            d = Fraction(1)
        }
        matrix.matrix[currentCursor.0][currentCursor.1] = n/d

        //change width
        width[currentCursor.1] = count(matrix.matrix[currentCursor.0][currentCursor.1].toString())

        //reset to default
        numerator:String = "0"
        denominator:String = ""
        floatingPoint:Int = 1
        negative = false
        floatpointEntered:Bool = false
        numberlineEntered:Bool = false
    }

    //User is moving across cells
    @IBAction func directionPressed(sender: UIButton) {
        if entering { // calculate the current value and insert to matrix
            calculateCurrentCell()
        }
        switch sender.tag {
            case 0 : //up
            {
                if currentCursor.1-1>=0 {
                    currentCursor.1--
                    updateLabel()
                }
            }
            case 1 : //down
            {
                if currentCursor.1+1< matrix.column {
                    currentCursor.1++
                    updateLabel()
                }
            }
            case 2 : //left
            {
                if currentCursor.0-1>=0 {
                    currentCursor.0--
                    updateLabel()
                }
            }
            case 3 : //right
            {
                if currentCursor.0+1< matrix.row {
                    currentCursor.0++
                    updateLabel()
                }
            }
            default:
        }

    }

    //User is changing size of matrix
    @IBAction func sizeChange(sender: UIButton) {
        if entering { // calculate the current value and insert to matrix
            calculateCurrentCell()
        }
        switch sender.tag {
            case 0 : //addrow
            {
                if matrix.row+1<=MAXROW {
                    matrix = matrix.addRow()
                    updateLabel()
                }
            }
            case 1 : //removerow
            {
                if matrix.row-1>0 {
                    matrix = matrix.removeRow()
                    if currentCursor.0 >= matrix.row {
                         currentCursor.0--
                    }
                    for j in 0..<matrix.column{
                        for i in 0..<matrix.row{
                            width[i] = max(width[i],count(matrix.matrix[i][j].toString()))
                        }
                    }
                    updateLabel()
                }
            }
            case 2 : //addcolumn
            {
                if matrix.column+1<=MAXCOLUMN {
                    matrix = matrix.addColumn()
                    width.append(1)
                    updateLabel()
                }
                
            }
            case 3 : //removecolumn
            {
                if matrix.column-1>0 {
                    matrix = matrix.removeColumn()
                    if currentCursor.1 >= matrix.column {
                         currentCursor.1--
                    }
                    width.removeLast()
                    updateLabel()
                }
            }
            default:
        }
    }  
    
    // MARK: Camera


    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showAlertViewWithPicker(){
        
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.Camera) {
                
                imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                imagePicker.sourceType =
                    UIImagePickerControllerSourceType.Camera
                imagePicker.mediaTypes = [kUTTypeImage as NSString]
                imagePicker.allowsEditing = false
                
                
                newMedia = true
        }
        

    }
    
    
    
    
    @IBAction func useCamera(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.Camera) {
                
                imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                imagePicker.sourceType =
                    UIImagePickerControllerSourceType.Camera
                imagePicker.mediaTypes = [kUTTypeImage as NSString]
                imagePicker.allowsEditing = false
                
                newMedia = true
        }
        self.presentViewController(self.imagePicker, animated: true,
            completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if mediaType.isEqualToString(kUTTypeImage as String) {
            var image:UIImage = info[UIImagePickerControllerOriginalImage]
                as! UIImage
        
            
            image = scaledownImage(image)
            
            var blackWhite = grayScaleImage(image)
            
            var cc = connectedComponents(blackWhite)
            
            
            
            println(cc.count)
            
            
            var currentrow = 0
            var finished:[[ConnectedComponent]] = []
            
            while (!cc.isEmpty){
                finished.append([])
                var highest:CGFloat = CGFloat(blackWhite.count)
                var highestBox:CGRect!
                for c in cc {
                    if c.boundBox.minY<highest{
                        highest = c.boundBox.minY
                        highestBox = c.boundBox
                    }
                }
                highestBox = CGRect(x: 0.0, y: highestBox.origin.y, width: CGFloat(blackWhite[0].count), height: highestBox.height)
                
                for c in cc {
                    if c.boundBox.intersects(highestBox) {
                        c.row = currentrow
                        cc.removeAtIndex(find(cc, c)!)
                        finished[currentrow].append(c)
                    }
                }
                
                finished[currentrow].sort({
                    (cc1:ConnectedComponent,cc2:ConnectedComponent) -> Bool in
                        return cc1.boundBox.midX<cc2.boundBox.midX
                })
                

                

                    
                currentrow++
            }
            
            
            //distance and index          
            var distance:[(CGFloat,Int)] = []
            
            for i in 0..<finished[0].count-1{
                distance.append(finished[0][i+1].boundBox.minX-finished[0][i].boundBox.maxX,i)
            }
            
            distance.append(CGFloat(10.0),finished[0].count)
            
            distance.sort({
                (a,b) -> Bool in
                return a.0<b.0
            })
            
            //distance between distance
            var distance2:[(CGFloat,Int)] = []
            
            for i in 0..<distance.count-1{
                distance2.append(CGFloat(distance[i+1].0)-CGFloat(distance[i].0),i)
            }
        
            distance2.sort({
                (a,b) -> Bool in
                return a.0<b.0
            })
            
            var splitDistance:CGFloat!
            
            let maxIndex:Int = distance2[distance2.count-1].1
            splitDistance = distance[maxIndex].0
            
            splitDistance = (distance[maxIndex+1].0-splitDistance)/2
            
           
            
            for ccs in finished{
                var currentCol = 0
                ccs[0].col = currentCol
                for i in 1..<ccs.count{
                    if ccs[i].boundBox.minX-ccs[i-1].boundBox.maxX>splitDistance {currentCol++}
                    ccs[i].col = currentCol
                }
            }
            for ccs in finished{
                var currentCol = 0
                for c in ccs{
                    
//                    let out = c.output()
//                    for i in 0..<29{
//                        for j in 0..<29{
//                            if out[i*29+j]>0.99218 {
//                                print(" ")
//                            }else{
//                                print("*")
//                            }
//                        }
//                        println()
//                    }

                    if c.col>currentCol {print(" ");currentCol=c.col}
                    print(NN.calculate(c.output()))
                    
                }
                println()
            }
            
        }
    }
    
    
    
    func scaledownImage(image:UIImage)->UIImage {
        let N:CGFloat = 0.5
        var rect:CGRect! //= CGRectMake(0, 0, image.size.width/2, image.size.height/2)
        if image.size.width > image.size.height {
            rect = CGRectMake(0, 0, 1280, 960)
        }else{
            rect = CGRectMake(0, 0, 960, 1280)
        }
        return image.resizedImage(rect.size, interpolationQuality: kCGInterpolationHigh)
    }
    
    func grayScaleImage(image:UIImage) ->[[Bool]] {
        let imageRect = CGRectMake(0, 0, image.size.width, image.size.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGBitmapContextCreate(nil, Int(image.size.width), Int(image.size.height), 8, Int(image.size.width), colorSpace, CGBitmapInfo(CGImageAlphaInfo.None.rawValue))
        CGContextDrawImage(context, imageRect, image.CGImage)
        let imageRef = CGBitmapContextCreateImage(context)
        let newImage = UIImage(CGImage: imageRef)
        

        var pixelData = CGDataProviderCopyData(CGImageGetDataProvider(newImage!.CGImage))
        var data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let bytesPerRow = Int(CGImageGetBytesPerRow(newImage!.CGImage))
        let bytesPerColumn = Int(newImage!.size.height)
        var imin = 10000,jmin = 10000
        var imax:Int=0,jmax:Int = 0
        var allempty = true
        var flag = [[Bool]](count: bytesPerColumn, repeatedValue: ([Bool](count: bytesPerRow, repeatedValue: false)))
        for i in 0..<bytesPerColumn {
            allempty = true
            var tempjmin = 10000
            var tempjmax = 0
            for j in 0..<bytesPerRow{
                if Int(data[i*bytesPerRow+j])<BLACKTHRESHOLD {
                    if j<tempjmin {tempjmin = j}
                    if j>tempjmax {tempjmax = j}
                    allempty = false
                    flag[i][j] = true
                }else{
                    
                }
            }
            if tempjmin<jmin {jmin=tempjmin}
            if tempjmax>jmax {jmax=tempjmax}
            if !allempty{
                if i<imin {imin=i}
                if i>imax {imax=i}
            }
        }
        var result:[[Bool]] = []
        for i in imin...imax{
            result.append(Array(flag[i][jmin...jmax]))
        }
        return result
    }
    

    
    func connectedComponents(image:[[Bool]]) -> [ConnectedComponent]{
        var nrow = image.count
        var ncol = image[0].count


        var flag:[[Bool]] = []
        
        for i in 0..<nrow{
            flag.append([])
            for j in 0..<ncol{
                flag[i].append(false)
            }
        }
        
        var result:[ConnectedComponent] = []
        
        for i in 0..<nrow {
            for j in 0..<ncol {
                if !flag[i][j] && image[i][j] {
                    var temp:[(Int,Int)] = [(Int,Int)]()
                    
                    var q = Queue<(Int,Int)>()
                    q.enqueue(i,j)
                    flag[i][j] = true
                    var l = j,r = j ,u = i ,d = i
                    
                    while !q.isEmpty() {
                        var (thisi,thisj) = q.dequeue()
                        
                        if l>thisj {l=thisj}
                        if u<thisi {u=thisi}
                        if r<thisj {r=thisj}
                        if d>thisi {d=thisi}
                        
                        let tuple:(Int,Int) = (thisi,thisj)
                        temp.append(tuple)
                        
                        if thisi+1<nrow && image[thisi+1][thisj] && !flag[thisi+1][thisj]{
                            let tuple = (thisi+1,thisj)
                            flag[thisi+1][thisj] = true
                            q.enqueue(tuple)
                        }
                        if thisj+1<ncol && image[thisi][thisj+1] && !flag[thisi][thisj+1]{
                            let tuple = (thisi,thisj+1)
                            flag[thisi][thisj+1] = true
                            q.enqueue(tuple)
                        }
                        if thisi-1>=0 && image[thisi-1][thisj] && !flag[thisi-1][thisj]{
                            let tuple = (thisi-1,thisj)
                            flag[thisi-1][thisj] = true
                            q.enqueue(tuple)
                        }
                        if thisj-1>=0 && image[thisi][thisj-1] && !flag[thisi][thisj-1]{
                            let tuple = (thisi,thisj-1)
                            flag[thisi][thisj-1] = true
                            q.enqueue(tuple)
                        }
                    }
                    
                    
                    //var (l,r,u,d,answer,flag) = DFS(i,j: j,imageArray: image, pixels: temp, flag: flag)
                    
                    
                    if temp.count>DETECTIONTHRESHOLD{
                        result.append(ConnectedComponent(pixel: temp, l: l, r: r, u: u, d: d))
                    }
                }
            }
        }
        return result
    }
    
}

