//
//  ConnectedComponent.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 30/06/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//

import UIKit

class ConnectedComponent: NSObject {
    var pixel:[(Int,Int)] //WARNING: pixel is stored in i,j coordinate which is y,x accordingly
    var left,right,up,down:Int
    var height,width:Int
    var boundBox:CGRect
    var row:Int!
    var col:Int!
    let outputSide = 29
    var GaussianKernal:[[Double]] = [[1.0/256.0,4.0/256.0,6.0/256.0,4.0/256.0,1.0/256.0],[4.0/256.0,16.0/256.0,24.0/256.0,16.0/256.0,4.0/256.0],[6.0/256.0,24.0/256.0,36.0/256.0,24.0/256.0,6.0/256.0],[4.0/256.0,16.0/256.0,24.0/256.0,16.0/256.0,4.0/256.0],[1.0/256.0,4.0/256.0,6.0/256.0,4.0/256.0,1.0/256.0]]
    
    init(pixel:[(Int,Int)],l:Int,r:Int,u:Int,d:Int) {
        self.left = l
        self.right = r
        self.pixel = pixel
        self.up = u
        self.down = d
        self.height = u-d
        self.width = r-l
        self.boundBox = CGRect(x: left, y: down, width: right-left, height: up-down)
    }
    
    private func center()->[[Double]]{
        var side:Int = Int(Double(max(height,width))*1.5)
        var result = [[Double]](count: side, repeatedValue: ([Double](count: side, repeatedValue: 255.0)))
        var horizontaloffset = (side-width)/2
        var verticaloffset = (side-height)/2
        for (y,x) in pixel {
            result[y-Int(boundBox.origin.y)+verticaloffset][x-Int(boundBox.origin.x)+horizontaloffset] = 0.0
        }
        return result
    }
    
    func output() -> [Double]{
        var centerIm = center()
        let ratio = Double(centerIm.count)/Double(outputSide)
        var result:[Double] = []
        for i in 0..<outputSide{
            for j in 0..<outputSide{
                var previ = Int(Double(i)*ratio)
                var prevj = Int(Double(j)*ratio)
                var sum:Double = 0
                var count = 0
                for ii in -2...2{
                    for jj in -2...2{
                        if (previ+ii)>=0 && (previ+ii)<centerIm.count && (prevj+jj)>=0 && (prevj+jj)<centerIm.count{
                            sum+=centerIm[previ+ii][prevj+jj]
                            count++
                        }
                    }
                }
                result.append((sum/Double(count))/128.0-1.0) //adjust to -1.0 to 1.0
            }
        }
        
        return result
    }
}
