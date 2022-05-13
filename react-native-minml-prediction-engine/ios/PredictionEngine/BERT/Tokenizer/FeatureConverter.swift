import Foundation

public class FeatureConverter
{
    private let str_pad = "[PAD]"
    private let str_sep = "[SEP]"
    private let str_cls = "[CLS]"
    
    private var tokenizer: FullTokenizer
    private var maxSeqLen: Int
    
    init(_tokenizer:FullTokenizer, _maxSeqLen:Int)
    {
        tokenizer = _tokenizer
        maxSeqLen = _maxSeqLen
    }
    
    public func convert(text:String)-> BertInputFeature
    {
        var tokenList = tokenizer.tokenize(text: text)
        if (tokenList.count > maxSeqLen)
        { tokenList = Array(tokenList[0...maxSeqLen]) }
        
        let maxContentLength = maxSeqLen - 3
        
        var tokens = [String]()
        tokens.append(str_cls)
        
        if tokenList.count > maxContentLength
        { tokenList = Array(tokenList[0...maxContentLength]) }
        tokens.append(contentsOf: tokenList)
        let var_tokens = Array(tokens[1...tokens.count-1])
        tokens.append(str_sep)
        tokens.append(str_sep)
        
        while tokens.count < maxSeqLen
        { tokens.append(str_pad) }
        
        let inputIds = tokenizer.convertTokensToIds(tokens: tokens)

        return BertInputFeature(_text: text, _tokens: tokens, _ids: inputIds, _inp_tokens: var_tokens)
    }
}
