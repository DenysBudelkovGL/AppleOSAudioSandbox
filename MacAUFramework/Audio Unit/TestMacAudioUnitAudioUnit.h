//
//  TestMacAudioUnitAudioUnit.h
//  TestMacAudioUnit
//
//  Created by Denys Budelkov on 11.08.2021.
//

#import <AudioToolbox/AudioToolbox.h>
#import "TestMacAudioUnitDSPKernelAdapter.h"

// Define parameter addresses.
extern const AudioUnitParameterID myParam1;

@interface TestMacAudioUnitAudioUnit : AUAudioUnit

@property (nonatomic, readonly) TestMacAudioUnitDSPKernelAdapter *kernelAdapter;
- (void)setupAudioBuses;
- (void)setupParameterTree;
- (void)setupParameterCallbacks;
@end
