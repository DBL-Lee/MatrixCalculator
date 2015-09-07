//
//  CameraViewController.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 26/04/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    let captureSession = AVCaptureSession()
    var captureDevice:AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
        
        if captureDevice != nil {
            beginSession()
        }
        // Do any additional setup after loading the view.
    }
    
    func beginSession() {
        do{
            captureSession.addInput(try AVCaptureDeviceInput(device: captureDevice))
        }catch{
            print(error)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer!)
        previewLayer?.frame = self.view.layer.frame
        captureSession.startRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
