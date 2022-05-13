import Foundation
import TensorFlowLiteC
import TensorFlowLite

class PredictionEngine
{
    
    private static var mInstance: PredictionEngine? = nil
    private var class_client : BertClassificationClient
    private var ner_client : BertNerClient
    
    class func getInstance() -> PredictionEngine
    {
        if (mInstance == nil)
        {
            mInstance = PredictionEngine()
        }
        return mInstance!
    }
    
    init()
    {
        class_client = BertClassificationClient.getInstance()
        var res = class_client.load()
        print(res)
        
        ner_client = BertNerClient.getInstance()
        res = ner_client.load()
        print(res)
    }
    
    func close()
    {
        
    }
    
    func isEngineLoaded()-> Bool
    {
        return (class_client.isClientLoaded()) == true
    }
    
    func classifyText(text:String)-> Dictionary<String, Any>?
    {
        if (!isEngineLoaded()) { return nil }
        if (text == "") { return nil }
        var res = Dictionary<String, Any>()
        do
        {
            res["Text"] = text
            res["Category"] = class_client.predict(text: text)!
            let e = ner_client.predict(text: text)!
            for i in e.keys
            { res[i] = e[i] }
            return res
        }
        catch let error
        {
            print(error)
            return nil
        }
    }
}
