import Foundation
public class WordpieceTokenizer
{
    private var dic: Dictionary<String, Int32>
    private let MAX_INPUT_CHARECTERS = 200
    private let UNKNOWN_TOKEN = "[UNK]"
    
    init(input_dic: Dictionary<String, Int32>)
    {
        dic = input_dic
    }
    
    public func tokenize(text:String)-> [String]
    {
        var res = [String]()
        for token in BasicTokenizer.tokenize(text: text)
        {
            if token.count > MAX_INPUT_CHARECTERS
            {
                res.append(UNKNOWN_TOKEN)
                continue
            }
            
            var isBad = false
            var start = 0
            var temp_res = [String]()
            while(start < token.count - 1)
            {
                var temp_str = ""
                var end = token.count - 1
                while start < end
                {
                    var sub_str: String
                    if start == 0
                    {
                        sub_str = String(token[token.startIndex...String.Index(encodedOffset: end)])
                    }
                    else
                    {
                        sub_str = "##" + String(token[String.Index(encodedOffset: start + 1)...String.Index(encodedOffset: end)])
                    }
                    if dic[sub_str] != nil
                    {
                        temp_str = sub_str
                        break
                    }
                    end -= 1
                }
                if temp_str == ""
                {
                    isBad = true
                    break
                }
                
                temp_res.append(temp_str)
                start = end
            }
            if isBad
            { res.append(UNKNOWN_TOKEN) }
            else
            { res.append(contentsOf: temp_res)
            }
        }
        return res
    }
}
