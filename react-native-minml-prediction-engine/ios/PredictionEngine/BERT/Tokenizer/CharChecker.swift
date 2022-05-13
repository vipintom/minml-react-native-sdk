import Foundation

public class CharChecker
{
    public class func isInvalid(ch : Character)-> Bool
    {
        return CharacterSet.illegalCharacters.contains(ch.unicodeScalars.first!)
    }
    
    public class func isControl(ch: Character)-> Bool
    {
        let temp = ch.unicodeScalars.first!
        if ch.isWhitespace { return false }
        return CharacterSet.controlCharacters.contains(temp)
    }
    
    public class func isWhiteSpace(ch: Character)-> Bool
    {
        let temp = ch.unicodeScalars.first!
        return CharacterSet.whitespacesAndNewlines.contains(temp)
    }
    
    public class func isPunctuation(ch: Character)-> Bool
    {
        let temp = ch.unicodeScalars.first!
        return CharacterSet.punctuationCharacters.contains(temp)
    }
    
}
