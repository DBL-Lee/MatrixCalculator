//
//  NeuralNetwork.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 19/02/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//

import Foundation

class NNLayer {
    var neurons:[NNNeuron] = []
    var weights:[NNWeight] = []
    var previousLayer:NNLayer!
    func sigmoid(x:Double) -> Double{
        return (1.7159*tanh(0.66666667*x))
    }
    func calculate(){
        for n in neurons{
            var sum = weights[n.connections[0].WeightIndex].weight
            for i in 1..<n.connections.count{
                let c = n.connections[i]
                sum += weights[c.WeightIndex].weight * previousLayer.neurons[c.NeuronIndex].output
            }
            n.output = sigmoid(sum)
        }
    }
}

class NNNeuron{
    var connections:[NNConnection] = []
    var output:Double!
}

class NNWeight{
    var weight:Double
    init(weight:Double){
        self.weight = weight
    }
}

class NNConnection{
    var NeuronIndex:Int = 0
    var WeightIndex:Int = 0
}

class NeuralNetwork {
    
    var layers:[NNLayer] = []
    var nLayers:Int = 0
    init () {
        let path = NSBundle.mainBundle().pathForResource("weight", ofType: "txt")
        let string = try! String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        let scanner = NSScanner(string: string)
        
        scanner.scanInteger(&nLayers)
        for _ in 0..<nLayers {
            let layer = NNLayer()
            var nNeuron:Int = 0
            var nWeight:Int = 0
            layers.append(layer)
            scanner.scanInteger(&nNeuron)
            scanner.scanInteger(&nWeight)
            for _ in 0..<nNeuron{
                let neuron = NNNeuron()
                layer.neurons.append(neuron)
                var nConnection:Int = 0
                scanner.scanInteger(&nConnection)
                
                for _ in 0..<nConnection{
                    let connection = NNConnection()
                    scanner.scanInteger(&connection.NeuronIndex)
                    scanner.scanInteger(&connection.WeightIndex)
                    neuron.connections.append(connection)
                }
            }
            
            for _ in 0..<nWeight {
                var value:Double = 0.0
                scanner.scanDouble(&value)
                layer.weights.append(NNWeight(weight: value))
            }
        }
        for i in 1..<nLayers{
            layers[i].previousLayer = layers[i-1]
        }
    }
    
    func calculate(input:[Double]) -> Int{
        assert(input.count == layers[0].neurons.count, "input size is not correct")
        for i in 0..<layers[0].neurons.count {
            layers[0].neurons[i].output = input[i]
        }
        for i in 1..<nLayers{
            layers[i].calculate()
        }
        var max:Double = -2.0
        var res = -1
        for i in 0..<layers[nLayers-1].neurons.count{
            //print(layers[nLayers-1].neurons[i].output)
            if max<layers[nLayers-1].neurons[i].output{
                max = layers[nLayers-1].neurons[i].output
                res = i
            }
        }
        return res
    }
    
}