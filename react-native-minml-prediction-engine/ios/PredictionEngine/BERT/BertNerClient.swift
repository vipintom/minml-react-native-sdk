import Foundation
import TensorFlowLite

class BertNerClient
{
    
    private static var mInstance: BertNerClient? = nil
    private static var NER_CONFIG_NAME:String = "ner_config"
    private static var NER_CONFIG_TYPE:String = "json"
    
    
    private var interpreter_bert:Interpreter? = nil
    private var interpreter_recog:Interpreter? = nil
    private var config:Dictionary<String,Any>? = nil
    private var featureConverter: FeatureConverter? = nil
    private var labels:[String] = []
    private var dictionary: Dictionary<String, Int32> = Dictionary<String, Int32>()
    
    private var bert_tflite:Dictionary<String, String> = Dictionary<String, String>()
    private var recog_tflite:Dictionary<String, String> = Dictionary<String, String>()
    private var vocab:Dictionary<String, String> = Dictionary<String, String>()
    
    private var isModelLoaded:Bool = false;
    private var isConfigLoaded:Bool = false
    
    class func getInstance() -> BertNerClient
    {
        if (mInstance == nil)
        {
            mInstance = BertNerClient()
        }
        return mInstance!
    }
    
    init(){}
    
    func load()-> Bool
    {
        config = BertLoadHelper.getInstance().loadConfigFile(config_name: BertNerClient.NER_CONFIG_NAME,
                                                             config_type: BertNerClient.NER_CONFIG_TYPE)
        if let temp = config!["labels"] as? [String]
        { labels = temp }
        else { return false }
        
        
        if let temp = config!["bert_tflite"] as? Dictionary<String, String>
        { bert_tflite = temp }
        else { return false }
        
        if let temp = config!["recog_tflite"] as? Dictionary<String, String>
        { recog_tflite = temp }
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
            if let tflite_arr = bert_tflite["file"]?.components(separatedBy: ".")
            {
                print(tflite_arr)
                let modelPath = Bundle.main.path(forResource: tflite_arr[0], ofType: tflite_arr[1])!
                var options = Interpreter.Options()
                options.threadCount = 4
                try interpreter_bert = Interpreter(modelPath: modelPath, options: options)
                try interpreter_bert?.allocateTensors()
                
                if let tflite_arr = recog_tflite["file"]?.components(separatedBy: ".")
                {
                    print(tflite_arr)
                    let modelPath = Bundle.main.path(forResource: tflite_arr[0], ofType: tflite_arr[1])!
                    var options = Interpreter.Options()
                    options.threadCount = 4
                    try interpreter_recog = Interpreter(modelPath: modelPath, options: options)
                    try interpreter_recog?.allocateTensors()
                    isModelLoaded = true
                    return true
                }
                else
                {
                    print(recog_tflite)
                    return false
                }
            }
            else
            {
                print(bert_tflite)
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
        interpreter_bert = nil
        isModelLoaded = false
    }
    
    func isClientLoaded() -> Bool
    {
        return isModelLoaded == true && isConfigLoaded == true
    }
    
    func predict(text:String)-> Dictionary<String, [String]>?
    {
        do
        {
            let inp = BertHelper.getInstance().getInputFeatures(text: text, converter: featureConverter!)
            let input = inp.inputIds[0].withUnsafeBufferPointer(Data.init)
            
            try interpreter_bert?.copy(input, toInputAt: 0)
            try interpreter_bert?.invoke()
            let temp_res = try interpreter_bert?.output(at: 0)
            
            try interpreter_recog?.copy(temp_res!.data, toInputAt: 0)
            try interpreter_recog?.invoke()
            let res = try interpreter_recog?.output(at: 0)
            let r = Array(BertHelper.getInstance().getNEROutput(input: res!, labels: labels)[1...inp.inp_tokens.count])
            return getTokenLabels(inp: inp, model_output: r)
        }
        catch let error
        {
            print (error)
            return nil
        }
    }
    
    func getTokenLabels(inp: BertInputFeature, model_output:[String])-> Dictionary<String, [String]>
    {
        var token_list = [String]()
        var temp = ""
        var temp_map = Dictionary<String, Int>()
        
        var res = Dictionary<String, [String]>()
        var temp_inp = inp.inp_tokens
        temp_inp.append("temp")
        var temp_model_output = model_output
        temp_model_output.append("temp")
        
        for (i,j) in zip(temp_inp, temp_model_output)
        {
            if !i.starts(with: "##")
            {
                if temp != ""
                {
                    token_list.append(temp)
                    
                    var max = 0
                    var count = 0
                    var _label = ""
                    for k in temp_map.keys
                    {
                        count += temp_map[k]!
                        if ["0", "O", "[CLS]", "[SEP]"].contains(k)
                        { continue }
                        if temp_map[k]! > max
                        {
                            max = temp_map[k]!
                            _label = k
                        }
                    }
                    
                    if Float(Float(max)/Float(count)) >= 0.5
                    {
                        if !["0", "O", "[CLS]", "[SEP]"].contains(_label)
                        {
                            if res.keys.contains(_label)
                            { res[_label]?.append(temp) }
                            else
                            { res[_label] = [temp] }
                        }
                    }
                    temp_map = Dictionary<String, Int>()
                }
                temp = i
                if temp_map.keys.contains(j)
                { temp_map[j]! += 1 }
                else
                { temp_map[j] = 1 }
            }
            else
            {
                temp += i.replacingOccurrences(of: "#", with: "")
                if temp_map.keys.contains(j)
                { temp_map[j]! += 1 }
                else
                { temp_map[j] = 1 }
            }
        }
        return res
    }
}

