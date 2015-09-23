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
    func didFinishInputMatrix(matrix:Matrix,alias:String)
}


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate{
    

    @IBOutlet weak var containerView: UIView!
    
    var delegate:inputMatrixDelegate!
    
    @IBOutlet weak var CameraButton: UIButton!
    
    @IBOutlet weak var matrixView: matrixTableView!
    
    var NN:NeuralNetwork!
    var newMedia:Bool?
    var image:UIImage!

    var imagePicker:UIImagePickerController!
	
	var tutorialView:TutorialOverlayView!
	var detectTouch = false
    
    //how black is black
    let BLACKTHRESHOLD = 80
    //how small is small
    let DETECTIONTHRESHOLD = 100
    

    @IBOutlet var grayButtons: [UIButton]!
    
    @IBOutlet var orangeButtons: [UIButton]!

    @IBOutlet var redButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0), {
//            self.NN = NeuralNetwork()
//        })
        self.view.backgroundColor = UIColor(white: 0.25, alpha: 1)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDown)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
        self.view.addGestureRecognizer(swipeUp)
        
		matrixView.setMatrix(matrix,underline:currentCursor)
        matrixView.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        matrixView.heightLimit = containerView.frame.height
        matrixView.widthLimit = containerView.frame.width
        
        
        let darkGray = UIColor(white: 0.8, alpha: 1.0)
        for button in grayButtons{
            button.setBackgroundImage(UIImage.imageWithColor(darkGray), forState: UIControlState.Normal)
            button.setBackgroundImage(UIImage.imageWithColor(darkGray.darker()), forState: UIControlState.Highlighted)
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.borderWidth = 1
        }
        for button in orangeButtons{
            button.setBackgroundImage(UIImage.imageWithColor(UIColor.orangeColor()), forState: UIControlState.Normal)
            button.setBackgroundImage(UIImage.imageWithColor(UIColor.orangeColor().darker()), forState: UIControlState.Highlighted)
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.borderWidth = 1
        }
        for button in redButtons{
            button.setBackgroundImage(UIImage.imageWithColor(UIColor.redColor()), forState: UIControlState.Normal)
            button.setBackgroundImage(UIImage.imageWithColor(UIColor.redColor().darker()), forState: UIControlState.Highlighted)
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.borderWidth = 1
        }
        for view in self.view.subviews{
            if view is UIButton{
                (view as! UIButton).titleLabel?.adjustsFontSizeToFitWidth = true
            }
        }
		
		if !NSUserDefaults.standardUserDefaults().boolForKey("SeenTutSwipe"){
            showTutorialView(NSLocalizedString("FirstTimeSwipe", comment: ""))            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "SeenTutSwipe")
        }
    }
	
 	private func showTutorialView(text:String){
		self.tutorialView = TutorialOverlayView(frame: self.view.frame, text: text)
        tutorialView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tutorialView)
		let viewsDict = ["tutorialView": tutorialView]
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[tutorialView]-0-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: viewsDict))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[tutorialView]-0-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: viewsDict))
        tutorialView.alpha = 0.0
		UIView.animateWithDuration(0.5, animations: {
            () in
            self.tutorialView.alpha = 1.0
        })
		self.detectTouch = true
	}   
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: printing matrix
    let MAXROW = 10
    let MAXCOLUMN = 10

    var matrix:Matrix = Matrix(r: 2, c: 2)
    var currentCursor = (0,0)
    var fraction = true
    
    var entering = false //flag to indicate whether user is entering

    //MARK: inputvalue
    var numerator:String = "0"
    var denominator:String = ""
    var floatingPoint:Int = 0
    var numeratorFloatingPoint = 0 //remember floating point of numerator
	var integerPart:Int = 1
	var numeratorIntegerPart = 1
    let FLOATPOINTUPPER = 5
	let INTEGERPARTUPPER = 5

    //flags
    var negative = false
    var floatpointEntered:Bool = false
    var numberlineEntered:Bool = false

    //user started entering
    @IBAction func digitPressed(sender: UIButton) {
        switch sender.titleLabel!.text! {
        case "DEL","退格":
            if numberlineEntered && denominator=="" { //Deleting numberline
                numberlineEntered = false
                if numeratorFloatingPoint > 0 { //Numerator is float
                    floatpointEntered = true
                }
                floatingPoint = numeratorFloatingPoint
				integerPart = numeratorIntegerPart
            }else{
                if !numberlineEntered {
                    if numerator.characters.count==1 { //Deleting last digit in numerator
                        numerator = "0"
                    }else{ 
                        if numerator.removeAtIndex(numerator.endIndex.predecessor())=="."{ //Deleting floating point in numerator
                            floatpointEntered = false
                        }else{  //Deleting a digit in numerator
                            if floatpointEntered{
                                floatingPoint--
                            }else{
								integerPart--
							}
                        }
                    }
                }else{
                    if denominator.removeAtIndex(denominator.endIndex.predecessor())=="."{ //Deleting floatingPoint in denominator
                        floatpointEntered = false
                    }else{  //Deleting a digit in denominator
                        if floatpointEntered{
                            floatingPoint--
                        }else{
							integerPart--
						}
                    }
                }
            }
        case ".":
            if !floatpointEntered{
                if !numberlineEntered{
                    numerator+="."
                }else{
                    if denominator==""{ //Case whereby denominator is empty
                        denominator = "0"
						integerPart++
                    }
                    denominator+="."
                }
                floatpointEntered = true
            }
        case "/":
            if !numberlineEntered{
                if numerator[numerator.endIndex.predecessor()] != "."{ //Previous character is not floating point
                    numeratorFloatingPoint = floatingPoint
					numeratorIntegerPart = integerPart
                }else{
                    numerator.removeAtIndex(numerator.endIndex.predecessor())
                }
                floatingPoint = 0
				integerPart = 0
                numberlineEntered = true
                floatpointEntered = false
            }
        case "+/-":
            negative = !negative
        default:
            if (floatpointEntered && floatingPoint<FLOATPOINTUPPER) || (!floatpointEntered && integerPart<INTEGERPARTUPPER) {
                if !self.numberlineEntered{
                    if self.numerator == "0" { //no digit entered yet
                        self.numerator = sender.titleLabel!.text!
                    }else{
                        if self.floatpointEntered {
							self.floatingPoint++
						}else{
							integerPart++
						}
                        self.numerator += sender.titleLabel!.text!
                    }
                }else{
                    if self.floatpointEntered {
						self.floatingPoint++
					}else{
						integerPart++
					}
                    self.denominator += sender.titleLabel!.text!
                }
            }
        }
        entering = true
        let entry = (negative ? "-" : "") + numerator + (numberlineEntered ? ("/"+denominator) : "")
		matrixView.setLabel(currentCursor.0,j: currentCursor.1,s: entry)
    }

    //This function is called when user finish editing a cell and move to another cell
    private func calculateCurrentCell(){
        entering = false
        if negative {
            numerator = "-"+numerator
        }
        let n = Fraction(i:(numerator as NSString).doubleValue)
        var d:Fraction!
        if numberlineEntered && denominator != "" {
            d = Fraction(i: NSString(string:denominator).doubleValue)
        }else {
            d = Fraction(i: 1)
        }

        //When user inputs 0 at denominator
        if d.n == 0 { d = Fraction(i: 1)}

        matrix.matrix[currentCursor.0][currentCursor.1] = n/d
		matrix.decimal[currentCursor.0][currentCursor.1] = floatpointEntered

        matrixView.setMatrix(matrix,underline:currentCursor)

        //reset to default
        numerator = "0"
        denominator = ""
        floatingPoint = 0
        numeratorFloatingPoint = 0
		integerPart = 1
		numeratorIntegerPart = 1
        negative = false
        floatpointEntered = false
        numberlineEntered = false
    }

    //User moving through cells
     func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if entering { // calculate the current value and insert to matrix
                calculateCurrentCell()
            }
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Left:
                if currentCursor.1-1>=0 {
                    currentCursor.1--
                    matrixView.shiftUnderline(2)
                }
            case UISwipeGestureRecognizerDirection.Right:
                if (currentCursor.1+1) < matrix.column {
                    currentCursor.1++
                    matrixView.shiftUnderline(3)
                }
            case UISwipeGestureRecognizerDirection.Up:
                if currentCursor.0-1>=0 {
                    currentCursor.0--
                    matrixView.shiftUnderline(0)
                }
            case UISwipeGestureRecognizerDirection.Down:
                if currentCursor.0+1 < matrix.row {
                    currentCursor.0++
                    matrixView.shiftUnderline(1)
                }
            default:
                break
            }
        }
    }

    //User is changing size of matrix
    @IBAction func sizeChange(sender: UIButton) {
        if entering { // calculate the current value and insert to matrix
            calculateCurrentCell()
        }
        switch sender.tag {
            case 0 : //addrow
                if matrix.row+1<=MAXROW {
                    matrix = matrix.addRow()
                    matrixView.setMatrix(matrix,underline:currentCursor)
                }
            case 1 : //removerow
                if matrix.row-1>0 {
                    matrix = matrix.removeBotRow()
                    if currentCursor.0 >= matrix.row {
                         currentCursor.0--
                    }
                    matrixView.setMatrix(matrix,underline:currentCursor)
                }
            case 2 : //addcolumn
                if matrix.column+1<=MAXCOLUMN {
                    matrix = matrix.addColumn()
                    matrixView.setMatrix(matrix,underline:currentCursor)
                }
            case 3 : //removecolumn
                if matrix.column-1>0 {
                    matrix = matrix.removeLastColumn()
                    if currentCursor.1 >= matrix.column {
                         currentCursor.1--
                    }
                    matrixView.setMatrix(matrix,underline:currentCursor)
                }
            default: ()
        }
    }  
    



    // MARK: Camera   
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func useCamera(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.Camera) {
                
                imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                imagePicker.sourceType =
                    UIImagePickerControllerSourceType.Camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                
                newMedia = true
        }
		self.entering = false
        self.presentViewController(self.imagePicker, animated: true,
            completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if mediaType.isEqualToString(kUTTypeImage as String) {
            var image:UIImage = info[UIImagePickerControllerOriginalImage]
                as! UIImage
        
            LoadingOverlay.shared.showOverlay(self.view)
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                image = self.scaledownImage(image)
                var blackWhite = self.grayScaleImage(image)
                var cc = self.connectedComponents(blackWhite)
                
                print(cc.count)
                
                if cc.count>0 {
                    var currentrow = 0
                    var finished:[[ConnectedComponent]] = []
                    
                    //label each row
                    while (!cc.isEmpty){
                        finished.append([])
                        var highest:CGFloat = CGFloat(blackWhite.count)
                        var highestBox:CGRect!
                        
                        //find highest bounding box
                        for c in cc {
                            if c.boundBox.minY<highest{
                                highest = c.boundBox.minY
                                highestBox = c.boundBox
                            }
                        }
                        
                        //change the bounding box to a horizontal strip
                        highestBox = CGRect(x: 0.0, y: highestBox.origin.y, width: CGFloat(blackWhite[0].count), height: highestBox.height)
                        
                        //find all cc that intersect this strip and label them in same row
                        for c in cc {
                            if c.boundBox.intersects(highestBox) {
                                c.row = currentrow
                                cc.removeAtIndex(cc.indexOf(c)!)
                                finished[currentrow].append(c)
                            }
                        }
                        
                        //sort according to left right
                        finished[currentrow].sortInPlace({
                            (cc1:ConnectedComponent,cc2:ConnectedComponent) -> Bool in
                            return cc1.boundBox.midX<cc2.boundBox.midX
                        })
                        
                        currentrow++
                    }
                    
                    var maxColumn = -1
                    
                    for cc in finished {
                        if cc.count == 1{
                            maxColumn = 0
                            break
                        }
                    }
                    
                    if maxColumn == 0{
                        for ccs in finished{
                            for cc in ccs{
                                cc.col = 0
                            }
                        }
                    }else{
                        
                        //Use clustering to separate out the columns
                        
                        //As the digit in same column must be close to each other
                        //while the digit in different column must be wider apart
                        //Therefore, we first find the distance between each cc and the
                        //next cc. Then we sort these distances, they should be grouped
                        //around a small value and a big value.
                        //Then we find distance between these distances. When there is a
                        //large jump, we treat this jump as the split between the distances.
                        
                        //distance and index
                        var distance:[(CGFloat,Int)] = []
                        for i in 0..<finished[0].count-1{
                            let dist = finished[0][i+1].boundBox.minX-finished[0][i].boundBox.maxX
                            distance.append((max(dist,0),i))
                        }
                        
                        //prevent situation of only one gap
                        distance.append((CGFloat(10.0),finished[0].count))
                        
                        distance.sortInPlace({
                            (a,b) -> Bool in
                            return a.0<b.0
                        })
                        
                        //distance between distance
                        var distance2:[(CGFloat,Int)] = []
                        for i in 0..<distance.count-1{
                            distance2.append((CGFloat(distance[i+1].0)-CGFloat(distance[i].0),i))
                        }
                        
                        distance2.sortInPlace({
                            (a,b) -> Bool in
                            return a.0<b.0
                        })
                        
                        var splitDistance:CGFloat!
                        //index of the distance
                        let maxIndex:Int = distance2[distance2.count-1].1
                        
                        //take the average
                        splitDistance = (distance[maxIndex+1].0+distance[maxIndex].0)/2
                        
                        
                        //label according to the splitDistance found
                        //if distance to next cc is less than splitDistance, they are in same column
                        for ccs in finished{
                            var currentCol = 0
                            ccs[0].col = currentCol
                            for i in 1..<ccs.count{
                                if ccs[i].boundBox.minX-ccs[i-1].boundBox.maxX>splitDistance {currentCol++}
                                ccs[i].col = currentCol
                                maxColumn = max(maxColumn,currentCol)
                            }
                        }
                    }
                    
                    self.matrix = Matrix(r: finished.count,c: maxColumn+1)
                    currentrow = 0
                    //Use NN to calculate corresponding digit
                    for ccs in finished{
                        var currentCol = 0
                        var currentEntry = 0
                        for c in ccs{
                            if c.col>currentCol {
                                self.matrix.matrix[currentrow][currentCol] = Fraction(i: currentEntry)
                                currentEntry = 0
                                currentCol=c.col
                            }
                            let thisDigit = self.NN.calculate(c.output())
                            print(thisDigit.description+" ")
                            currentEntry = currentEntry*10+thisDigit
                        }
                        self.matrix.matrix[currentrow][currentCol] = Fraction(i: currentEntry)
                        currentrow++
                    }
                    
                }
                print("finished")
                dispatch_async(dispatch_get_main_queue(), {
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    LoadingOverlay.shared.hideOverlayView()
                    self.currentCursor = (0,0)
					self.matrixView.setMatrix(self.matrix,underline:self.currentCursor)
                })
            })
            
        }
    }
    
    
    //First Step: scale the image down to 1280*960 or 960*1280
    func scaledownImage(image:UIImage)->UIImage {
//        var rect:CGRect! //= CGRectMake(0, 0, image.size.width/2, image.size.height/2)
//        if image.size.width > image.size.height {
//            rect = CGRectMake(0, 0, 1280, 960)
//        }else{
//            rect = CGRectMake(0, 0, 960, 1280)
//        }
        return UIImage()
//        return image.resizedImage(rect.size, interpolationQuality: CGInterpolationQuality.High)
    }
    
    //First Turn image to grayscale then apply threshold to obtain Binary image
    func grayScaleImage(image:UIImage) ->[[Bool]] {
        let imageRect = CGRectMake(0, 0, image.size.width, image.size.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGBitmapContextCreate(nil, Int(image.size.width), Int(image.size.height), 8, Int(image.size.width), colorSpace, CGBitmapInfo.AlphaInfoMask.rawValue)
        CGContextDrawImage(context, imageRect, image.CGImage)
        let imageRef = CGBitmapContextCreateImage(context)
        let newImage = UIImage(CGImage: imageRef!)
        

        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(newImage.CGImage))
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let bytesPerRow = Int(CGImageGetBytesPerRow(newImage.CGImage))
        let bytesPerColumn = Int(newImage.size.height)
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
    

    //Find connected component of an image using BFS
    func connectedComponents(image:[[Bool]]) -> [ConnectedComponent]{
        let nrow = image.count
        let ncol = image[0].count


        var flag:[[Bool]] = []
        
        for i in 0..<nrow{
            flag.append([])
            for _ in 0..<ncol{
                flag[i].append(false)
            }
        }
        
        var result:[ConnectedComponent] = []
        
        for i in 0..<nrow {
            for j in 0..<ncol {
                if !flag[i][j] && image[i][j] {
                    var temp:[(Int,Int)] = [(Int,Int)]()
                    
                    let q = Queue<(Int,Int)>()
                    q.enqueue(i,j)
                    flag[i][j] = true
                    var l = j,r = j ,u = i ,d = i
                    
                    while !q.isEmpty() {
                        let (thisi,thisj) = q.dequeue()
                        
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
                    
                    //Delete cc smaller than a threshold to remove noise
                    if temp.count>DETECTIONTHRESHOLD{
                        result.append(ConnectedComponent(pixel: temp, l: l, r: r, u: u, d: d))
                    }
                }
            }
        }
        return result
    }

    
    var usedCharacter:NSSet!

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let regex:NSRegularExpression = try! NSRegularExpression(pattern: "[a-zA-Z]", options: NSRegularExpressionOptions.CaseInsensitive)
        if (range.length + range.location > textField.text?.characters.count || (string=="") || (regex.matchesInString(string, options: [], range: NSMakeRange(0, string.characters.count)).count == 0))
        {
            return false
        }
        textField.text = string.uppercaseString
        let newLength = textField.text!.characters.count + string.characters.count - range.length
        return newLength <= 1
    }

    
    //MARK: DONE
    @IBAction func done(sender: UIButton) {
		if entering {
			calculateCurrentCell()
		}
        var inputTextField: UITextField?
        var message = NSLocalizedString("usedCharacter", comment: "")
        if usedCharacter.count == 0{
            message += NSLocalizedString("none", comment: "")
        }else{
            for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters{
                if self.usedCharacter.containsObject(String(c)){
                    message += String(c) + ","
                }
            }
            message.removeAtIndex(message.endIndex.predecessor())
        }
        message += NSLocalizedString("alertMsg", comment: "")
        let alert = UIAlertController(title: NSLocalizedString("saveTitle", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters{
                if !self.usedCharacter.containsObject(String(c)){
                    textField.text = String(c)
                    break
                }else{
                    textField.text = "A"
                }
            }
            inputTextField = textField
            inputTextField?.delegate = self
        })

        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: {
            action in
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("save", comment: ""), style: UIAlertActionStyle.Default, handler: ({
            action in
            self.delegate.didFinishInputMatrix(self.matrix,alias: inputTextField!.text!)
            self.dismissViewControllerAnimated(true,completion:nil)
        })))
        

        self.presentViewController(alert, animated: true, completion: nil)

        
    }    
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if detectTouch {
            UIView.animateWithDuration(0.5, animations: {
				() in
				self.tutorialView.alpha = 0.0
				}, completion: {
					bool in
					self.tutorialView.removeFromSuperview()
			})
            self.detectTouch = false
        }
    }
}

