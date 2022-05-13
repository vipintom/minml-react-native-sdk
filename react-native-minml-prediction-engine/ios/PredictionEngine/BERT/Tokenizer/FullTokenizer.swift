import Foundation

public class FullTokenizer
{
    private var dic: Dictionary<String, Int32>
    
    init(input_dic: Dictionary<String, Int32>, lower_case: Bool)
    {
        dic = input_dic
    }
    
    public func tokenize(text:String)-> [String]
    {
        let temp = WordpieceTokenizer(input_dic: dic)
        var res = [String]()
        for t in BasicTokenizer.tokenize(text: text)
        {
            res.append(contentsOf: temp.tokenize(text:t))
            
        }
        return res
    }
    
    public func convertTokensToIds(tokens:[String])-> [Int32]
    {
        var res = [Int32]()
        for token in tokens
        {
            var temp = dic[token]!
            if temp > 1408
            { temp += 3}
            res.append(temp)
        }
        return res
    }
}
