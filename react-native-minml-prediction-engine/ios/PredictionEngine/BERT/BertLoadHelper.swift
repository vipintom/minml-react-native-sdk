import Foundation
import TensorFlowLiteC
import TensorFlowLite

class BertLoadHelper
{
    private static var mInstance: BertLoadHelper? = nil
    
    class func getInstance() -> BertLoadHelper
    {
        if (mInstance == nil)
        {
            mInstance = BertLoadHelper()
        }
        return mInstance!
    }
    
    init(){}
    
    func loadConfig(config_name:String, config_type:String)-> Dictionary<String,Any>?
    {
        return loadConfigFile(config_name: config_name, config_type: config_type)
    }
    
    func loadConfigFile(config_name:String, config_type:String)-> Dictionary<String,Any>?
    {
        let url = Bundle.main.url(forResource: config_name, withExtension: config_type)!
        do
        {
            let jsonData = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
            return json
        }
        catch
        {
            print(error)
        }
        return nil
    }
    
    func loadVocab(vocab: Dictionary<String, String>)-> Dictionary<String,Int32>?
    {
        do
        {
            if let vocab_arr = vocab["file"]?.components(separatedBy: ".")
            {
                print(vocab_arr)
                let path = Bundle.main.url(forResource: vocab_arr[0], withExtension: vocab_arr[1])!
                let contents = try! String(contentsOf: path)
                let lines = contents.components(separatedBy: "\n")
                var res: Dictionary<String, Int32> = Dictionary<String, Int32>()
                var index : Int32  = 0
                for l in lines
                {
                    res[l] = index
                    index+=1
                }
                return res
            }
            else
            {
                print(vocab)
                return nil
            }
        }
        catch let error
        {
            print(error)
            return nil
        }
        
    }
    
}
