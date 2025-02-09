#import <Foundation/Foundation.h>
#import "HpsHpaDevice.h"

@interface HpsHpaGiftVoidBuilder : NSObject
{
	HpsHpaDevice *device;
}

@property (nonatomic, strong) NSString *transactionId;
@property (nonatomic, readwrite) int referenceNumber;

- (void) execute:(void(^)(id<IHPSDeviceResponse>, NSError*))responseBlock;
- (id)initWithDevice: (HpsHpaDevice*)HpaDevice;

@end
