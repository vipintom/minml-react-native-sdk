import Foundation

@objc(MinmlPredictionEngine)
class MinmlPredictionEngine : NSObject 
{
  @objc
  func constantsToExport() -> [AnyHashable : Any]! {
    return ["count": 1]
  }

  var predictionEngine : PredictionEngine? = nil;

  @objc static func requiresMainQueueSetup() -> Bool {return true}
  
  
  @objc func load(_ api_key : NSString, cb callback: RCTResponseSenderBlock)
  {
      predictionEngine = PredictionEngine.getInstance()
      callback(["yaay"])
  }
  
  @objc func evaluate(_ text : NSString, cb callback: RCTResponseSenderBlock)
  {
  }
  
  @objc func close(cb callback: RCTResponseSenderBlock)
  {
    print("Model Closed")
  }
}
