#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"
@interface RCT_EXTERN_MODULE(MinmlPredictionEngine,NSObject)
RCT_EXTERN_METHOD(load:(NSString)api_key cb: (RCTResponseSenderBlock)callback)
RCT_EXTERN_METHOD(evaluate:(NSString)text cb: (RCTResponseSenderBlock)callback)
RCT_EXTERN_METHOD(close)
@end



