import Foundation
import TensorFlowLite

class BertHelper
{
    private static var mInstance: BertHelper? = nil
    
    class func getInstance() -> BertHelper
    {
        if (mInstance == nil)
        {
            mInstance = BertHelper()
        }
        return mInstance!
    }
    
    init(){}
    
    public func getInputFeatures(text:String, converter:FeatureConverter)-> BertInputFeature
    {
        return converter.convert(text: text)
    }

    public func getProbability(res : Tensor) -> [Float32]
    {
        var size = 1
        for i in res.shape.dimensions
        { size *= i }
        let probabilities = UnsafeMutableBufferPointer<Float32>.allocate(capacity: size)
        res.data.copyBytes(to: probabilities)
        return Array(probabilities)
    }
    
    public func getMaximumIndex(array : [Float32])-> Int
    {
        var index = 0
        var maxValue: Float = 0
        var res = 0
        while index < array.count
        {
            let temp = array[index]
            if temp > maxValue
            {
                maxValue = temp
                res = index
            }
            index += 1
        }
        return res
    }
    
    public func getNEROutput(input: Tensor, labels:[String])->[String]
    {
        var size = 1
        for i in input.shape.dimensions
        { size *= i }
        let probabilities = UnsafeMutableBufferPointer<Float32>.allocate(capacity: size)
        input.data.copyBytes(to: probabilities)
        size = input.shape.dimensions[2]
        var res = [String]()
        var t = [Float]()
        for i in Array(probabilities)
        {
            if t.count < size
            { t.append(i) }
            if t.count == size
            {
                res.append(labels[getMaximumIndex(input: t)])
                t = [Float]()
            }
        }
        return res
    }
    
    private func getMaximumIndex(input:[Float])-> Int
    {
        var index = 0
        var maxValue: Float = 0
        var res = 0
        while index < input.count
        {
            let temp = input[index]
            if temp > maxValue
            {
                maxValue = temp
                res = index
            }
            index += 1
        }
        return res
    }
}

extension Data
{

    init<T>(copyingBufferOf array: [T])
    {
        self = array.withUnsafeBufferPointer(Data.init)
    }

    func toArray<T>(type: T.Type) -> [T] where T: AdditiveArithmetic
    {
        var array = [T](repeating: T.zero, count: self.count / MemoryLayout<T>.stride)
        _ = array.withUnsafeMutableBytes { self.copyBytes(to: $0) }
        return array
    }
    
    func toArray2D<T>(type: T.Type) -> [[T]] where T: AdditiveArithmetic
    {
        var array = [[T]](repeating: [T](repeating: T.zero, count: self.count), count: self.count / MemoryLayout<T>.stride)
        _ = array.withUnsafeMutableBytes { self.copyBytes(to: $0) }
        return [[T]]()
    }
}
