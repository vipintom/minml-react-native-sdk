import Foundation

public class BasicTokenizer
{
    private static let doLowerCase:Bool = true
    public static let str_whitespace = " "
    
    public class func tokenize(text:String)-> [String]
    {
        let origTokens: [String] = whitespaceTokenize(text: cleanText(text: text))
        
        var res: String = String()
        for token in origTokens
        {
            var temp = token
            if doLowerCase
            { temp = temp.lowercased() }
            let temp2 = runSplitOnPunc(text: temp)
            for t in temp2
            { res += t + String(str_whitespace) }
        }
        
        return whitespaceTokenize(text: res)
    }
    
    private class func cleanText(text: String)-> String
    {
        var res: String = String()
        for ch in text
        {
            if CharChecker.isInvalid(ch: ch) || CharChecker.isControl(ch: ch)
                { continue }
            else if CharChecker.isWhiteSpace(ch: ch)
                { res += str_whitespace }
            else
                { res += String(ch) }
        }
        return res
    }
    
    private class func whitespaceTokenize(text: String)-> [String]
    {
        return text.components(separatedBy: " ")
    }
    
    private class func runSplitOnPunc(text: String)-> [String]
    {
        var res: [String] = [String]()
        var startNewWord: Bool = true
        
        for ch in text
        {
            if CharChecker.isPunctuation(ch: ch)
            {
                res.append(String(ch))
                startNewWord = true
            }
            else
            {
                if startNewWord
                {
                    res.append("")
                    startNewWord = false
                }
                let temp = res.last! + String(ch)
                res[res.count - 1] = temp
            }
        }
        return res
    }
}
