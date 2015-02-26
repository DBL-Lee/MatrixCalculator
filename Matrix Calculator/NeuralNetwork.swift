//
//  NeuralNetwork.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 19/02/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//

import Foundation

func +(a:[[Double]],b:[[Double]])->[[Double]]{
    assert(a.count == b.count && a[0].count == b[0].count, "size error")
    var res:[[Double]] = []
    let rowN = a.count
    let colN = b[0].count
    for row in 0..<rowN{
        res.append([])
        for col in 0..<colN{
            res[row].append(a[row][col]+b[row][col])
        }
    }
    return res
}

class NeuralNetwork {
    let N1 = 784
    let N2 = 30
    let N3 = 10
    var weight:[[[Double]]] = [[],[]]
    var biase:[[[Double]]] = [[],[]]
    init () {
        let path = NSBundle.mainBundle().pathForResource("Output", ofType: "txt")
        let string = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
        var scanner = NSScanner(string: string!)
        //init biase
        for y in 0...N2-1{
            biase[0].append([0.0])
        }
        
        for y in 0...N3-1{
            biase[1].append([0.0])
        }
        
        //init weight
        for y in 0...N2-1{
            weight[0].append([])
            for z in 0...N1-1{
                weight[0][y].append(0.0)
            }
        }
        for y in 0...N3-1{
            weight[1].append([])
            for z in 0...N2-1{
                weight[1][y].append(0.0)
            }
        }
        //scan biase
        for y in 0...N2-1{
            scanner.scanDouble(&biase[0][y][0])
        }
        for y in 0...N3-1{
            scanner.scanDouble(&biase[1][y][0])
        }
        
        //scan weight
        for y in 0...N2-1{
            for z in 0...N1-1{
                scanner.scanDouble(&weight[0][y][z])
            }
        }
        for y in 0...N3-1{
            for z in 0...N2-1{
                scanner.scanDouble(&weight[1][y][z])
            }
        }
    }
    
    func dot(a:[[Double]],b:[[Double]])->[[Double]]{
        var res:[[Double]] = []
        let rowN = a.count
        let colN = b[0].count
        let kN = b.count
        for row in 0..<rowN{
            res.append([])
            for col in 0..<colN{
                var temp:Double = 0.0
                for k in 0..<kN{
                    temp = temp + a[row][k]*b[k][col]
                }
                res[row].append(temp)
            }
        }
        return res
    }
        
    func sigmoid_vec(a:[[Double]])->[[Double]]{
        var res:[[Double]] = []
        let rowN = a.count
        let colN = a[0].count
        for row in 0..<rowN{
            res.append([])
            for col in 0..<colN{
                res[row].append(1.0/(1.0+exp(-a[row][col])))
            }
        }
        return res
    }
    
    
    func feedforward(input:[[Double]])->Int{
        var a:[[Double]] = input
        for layers in 0...1{
            let w = weight[layers]
            let b = biase[layers]
            a = sigmoid_vec(dot(w, b: a)+b)
        }
        var max:Double = 0.0
        var res = -1
        println(a)
        for i in 0...9 {
            if a[i][0] > max {
                max = a[i][0]
                res = i
            }
        }
        return res
    }
}