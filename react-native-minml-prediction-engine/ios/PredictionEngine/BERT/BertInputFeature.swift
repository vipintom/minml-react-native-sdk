import Foundation

public class BertInputFeature
{
    public var text: String
    public var tokens: [String]
    public var inp_tokens: [String]
    public var inputIds = [[Int32]](repeating: [Int32](repeating: 0, count: 128), count: 1)
    
    init(_text:String, _tokens:[String], _ids:[Int32], _inp_tokens:[String])
    {
        inputIds[0] = _ids
        text = _text
        tokens = _tokens
        inp_tokens = _inp_tokens
    }
}
