import Foundation
import TensorFlowLite

class BertClassificationClient
{
    
    private static var mInstance: BertClassificationClient? = nil
    private static var CLASS_CONFIG_NAME:String = "class_config"
    private static var CLASS_CONFIG_TYPE:String = "json"
    
    
    private var interpreter:Interpreter? = nil
    private var config:Dictionary<String,Any>? = nil
    private var featureConverter: FeatureConverter? = nil
    private var labels:[String] = []
    private var thresholds:Dictionary<String, NSNumber> = Dictionary<String, NSNumber>()
    private var dictionary: Dictionary<String, Int32> = Dictionary<String, Int32>()
    
    private var tflite:Dictionary<String, String> = Dictionary<String, String>()
    private var vocab:Dictionary<String, String> = Dictionary<String, String>()
    
    
    
    private var isModelLoaded:Bool = false;
    private var isConfigLoaded:Bool = false
    
    class func getInstance() -> BertClassificationClient
    {
        if (mInstance == nil)
        {
            mInstance = BertClassificationClient()
        }
        return mInstance!
    }
    
    init(){}
    
    func load()-> Bool
    {
        config = BertLoadHelper.getInstance().loadConfigFile(config_name: BertClassificationClient.CLASS_CONFIG_NAME,
                                                             config_type: BertClassificationClient.CLASS_CONFIG_TYPE)
        if let temp = config!["labels"] as? [String]
        { labels = temp }
        else { return false }
        
        if let temp = config!["thresholds"] as? Dictionary<String, NSNumber>
        { thresholds = temp }
        else { return false }
        
        if let temp = config!["tflite"] as? Dictionary<String, String>
        { tflite = temp }
        else { return false }
        
        if let temp = config!["vocab"] as? Dictionary<String, String>
        { vocab = temp }
        else { return false }
        
        if (!loadModel())
        {
            print("Model couldn't be loaded")
            return false
        }
        if let temp = BertLoadHelper.getInstance().loadVocab(vocab: vocab)
        {
            dictionary = temp
            isConfigLoaded = true
        }
        
        let tokenizer = FullTokenizer(input_dic: dictionary, lower_case: false)
        featureConverter = FeatureConverter(_tokenizer: tokenizer, _maxSeqLen: 128)
        print("Model Loaded")
        print(labels)
        return true
    }
    
    
    func loadModel()-> Bool
    {
        do
        {
            if let tflite_arr = tflite["file"]?.components(separatedBy: ".")
            {
                print(tflite_arr)
                let modelPath = Bundle.main.path(forResource: tflite_arr[0], ofType: tflite_arr[1])!
                var options = Interpreter.Options()
                options.threadCount = 4
                try interpreter = Interpreter(modelPath: modelPath, options: options)
                try interpreter?.allocateTensors()
                isModelLoaded = true
                return true
            }
            else
            {
                print(tflite)
                return false
            }
        }
        catch let error
        {
            print(error)
            return false
        }
    }
    
    func close()
    {
        interpreter = nil
        isModelLoaded = false
    }
    
    func isClientLoaded() -> Bool
    {
        return isModelLoaded == true && isConfigLoaded == true
    }
    
    func predict(text:String)-> String?
    {
        do
        {
            let inp = BertHelper.getInstance().getInputFeatures(text: text, converter: featureConverter!)
            let input = inp.inputIds[0].withUnsafeBufferPointer(Data.init)
            
            try interpreter?.copy(input, toInputAt: 0)
            try interpreter?.invoke()
            let res = try interpreter?.output(at: 0)
            let mResult = BertHelper.getInstance().getProbability(res: res!)
            return labels[BertHelper.getInstance().getMaximumIndex(array: mResult)]
        }
        catch let error
        {
            print (error)
            return nil
        }
    }
    
    
}

extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}

