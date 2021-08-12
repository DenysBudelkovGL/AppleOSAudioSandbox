//
//  AVAudioEngineService.m
//  AudioTest
//
//  Created by Denys Budelkov on 04.08.2021.
//

#import "AVAudioEngineService.h"

#import <AVFoundation/AVFoundation.h>

#import "EmbeddedAudioUnit.h"

#include <memory>

#define TEST_LATENCY 0.005

@interface AVAudioEngineService() {
}

@property (nonatomic, strong) AVAudioEngine *engine;

@end

@implementation AVAudioEngineService

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Just echo
        //[self tst_SetupSystemBasedPassthrough];
        
        // Echo + system provided effect
        //[self tst_SetupWithSystemEffect];
        
        // Echo + system provided effect, but loaded with Audio Unit infrastructure
        //[self tst_SetupSystemAudioUnit];
        
        // Echo + effect, but loaded with Audio Unit infrastructure
        //[self tst_SetupOurAudioUnit];
        
        // Create AU directly
        [self tst_SetupEmbeddedAudioUnit];
        
        // Manual passthrough
        //[self tst_SetupDumbmemcpyPassthrough];
    }
    return self;
}

- (void)tst_SetupSystemBasedPassthrough {
    self.engine = [[AVAudioEngine alloc] init];
    //AVAudioFormat *inpFormat = [_engine.inputNode inputFormatForBus:0];
    //[_engine connect:_engine.inputNode to:_engine.mainMixerNode format:inpFormat];
    [_engine connect:_engine.inputNode to:_engine.mainMixerNode format:nil];
    
    _engine.mainMixerNode.outputVolume = 0.5;
}

- (void)tst_SetupSystemAudioUnit {
    self.engine = [[AVAudioEngine alloc] init];
    
    AVAudioFormat *inpFormat = [_engine.inputNode inputFormatForBus:0];
    
    AudioComponentDescription auDescription {
        kAudioUnitType_Effect,
        0,
        0,
        0,
        0
    };
    
    NSArray<AVAudioUnitComponent *> * components = [[AVAudioUnitComponentManager sharedAudioUnitComponentManager] componentsMatchingDescription:auDescription];
    AVAudioUnitComponent* component = nullptr;
    for (AVAudioUnitComponent* c in components) {
        NSLog(@"%@", [c name]);
        if ([c.name isEqualToString:@"AUReverb2"]) {
            component = c;
        }
    }
    assert(component);
    NSLog(@">>> %@ selected", [component name]);

    __weak AVAudioEngineService *weakSelf = self;
    // TODO: Do we have to use this for instantiation?
    [AVAudioUnit instantiateWithComponentDescription:component.audioComponentDescription
                                             options:kAudioComponentInstantiation_LoadOutOfProcess
                                   completionHandler:^(__kindof AVAudioUnit * _Nullable audioUnit, NSError * _Nullable error) {
        NSLog(@">>>what? latency: %lf", audioUnit.latency);
        NSLog(@">>>what? outputPresentationLatency: %lf", audioUnit.outputPresentationLatency);
        
        AUParameterTree *params = [audioUnit.AUAudioUnit parameterTree];
        for (AUParameter* param in params.allParameters) {
            NSLog(@"param: %@", param);
            // TODO: id I guess here
            if ([param.displayName isEqualToString:@"dry/wet mix"]) {
                [param setValue:50];
            }
        }
        [audioUnit.AUAudioUnit setParameterTree:params];

        [weakSelf.engine attachNode:audioUnit];
        [weakSelf.engine connect:weakSelf.engine.inputNode to:audioUnit format:inpFormat];
        [weakSelf.engine connect:audioUnit to:weakSelf.engine.mainMixerNode format:inpFormat];
    }];
    
    _engine.mainMixerNode.outputVolume = 0.5;
}

- (void)tst_SetupOurAudioUnit {
    self.engine = [[AVAudioEngine alloc] init];
    
    AVAudioFormat *inpFormat = [_engine.inputNode inputFormatForBus:0];
    
    AudioComponentDescription auDescription {
        kAudioUnitType_Effect,
        0,
        0,
        0,
        0
    };
    
    NSArray<AVAudioUnitComponent *> * components = [[AVAudioUnitComponentManager sharedAudioUnitComponentManager] componentsMatchingDescription:auDescription];
    AVAudioUnitComponent* component = nullptr;
    for (AVAudioUnitComponent* c in components) {
        NSLog(@"%@", [c name]);
        if ([c.name isEqualToString:@"Testv2AudioUnit"]) {
            component = c;
        }
    }
    assert(component);
    NSLog(@">>> %@ selected", [component name]);

    __weak AVAudioEngineService *weakSelf = self;
    // TODO: Do we have to use this for instantiation?
    [AVAudioUnit instantiateWithComponentDescription:component.audioComponentDescription
                                             options:kAudioComponentInstantiation_LoadOutOfProcess
                                   completionHandler:^(__kindof AVAudioUnit * _Nullable audioUnit, NSError * _Nullable error) {
        NSLog(@">>>what? latency: %lf", audioUnit.latency);
        NSLog(@">>>what? outputPresentationLatency: %lf", audioUnit.outputPresentationLatency);
        
        AUParameterTree *params = [audioUnit.AUAudioUnit parameterTree];
        for (AUParameter* param in params.allParameters) {
            NSLog(@"param: %@", param);
            // TODO: id I guess here
            if ([param.displayName isEqualToString:@"dry/wet mix"]) {
                [param setValue:50];
            }
        }
        [audioUnit.AUAudioUnit setParameterTree:params];

        [weakSelf.engine attachNode:audioUnit];
        [weakSelf.engine connect:weakSelf.engine.inputNode to:audioUnit format:inpFormat];
        [weakSelf.engine connect:audioUnit to:weakSelf.engine.mainMixerNode format:inpFormat];
    }];
    
    _engine.mainMixerNode.outputVolume = 0.5;
}

- (void)tst_SetupWithSystemEffect {
    self.engine = [[AVAudioEngine alloc] init];
    
    AVAudioFormat *inpFormat = [_engine.inputNode inputFormatForBus:0];
    
    AVAudioUnitReverb *effect = [[AVAudioUnitReverb alloc] init];
    [effect loadFactoryPreset:AVAudioUnitReverbPresetPlate];
    [effect setWetDryMix:50];
    [_engine attachNode:effect];
    
    [_engine connect:_engine.inputNode to:effect format:inpFormat];
    [_engine connect:effect to:_engine.mainMixerNode format:inpFormat];
    
    _engine.mainMixerNode.outputVolume = 0.5;
}

- (void)tst_SetupEmbeddedAudioUnit {
    /*self.engine = [[AVAudioEngine alloc] init];
    
    AVAudioFormat *inpFormat = [_engine.inputNode inputFormatForBus:0];
    
    EmbeddedAudioUnit *effect = [[EmbeddedAudioUnit alloc] init];
    //[effect loadFactoryPreset:AVAudioUnitReverbPresetPlate];

    //[effect setWetDryMix:50];
    AVAudioNode
    
    [_engine attachNode:effect.kernelAdapter.];
    
    [_engine connect:_engine.inputNode to:effect format:inpFormat];
    [_engine connect:effect to:_engine.mainMixerNode format:inpFormat];
    
    _engine.mainMixerNode.outputVolume = 0.5;*/
}

- (void)tst_SetupDumbmemcpyPassthrough {
    self.engine = [[AVAudioEngine alloc] init];
    
    // "Don't care for now" buffer
    static std::unique_ptr<Float32[]> tmp_buf = std::make_unique<Float32[]>(10000);
    
    ///Input
    AVAudioSinkNode *inpNode = [[AVAudioSinkNode alloc] initWithReceiverBlock:^OSStatus(const AudioTimeStamp * _Nonnull timestamp, AVAudioFrameCount frameCount, const AudioBufferList * _Nonnull inputData) {
        memcpy(tmp_buf.get(), inputData->mBuffers[0].mData, inputData->mBuffers[0].mDataByteSize);
        NSLog(@"Received %i frames", frameCount);
        return noErr;
    }];
    [_engine attachNode:inpNode];
    AVAudioFormat *inpFormat = [_engine.inputNode inputFormatForBus:0];
    [_engine connect:_engine.inputNode to:inpNode format:inpFormat];
    
    ///

    AVAudioSourceNode *outNode = [[AVAudioSourceNode alloc] initWithRenderBlock:^OSStatus(BOOL * _Nonnull isSilence, const AudioTimeStamp * _Nonnull timestamp, AVAudioFrameCount frameCount, AudioBufferList * _Nonnull outputData) {
        NSLog(@"Requested %i frames", frameCount);
        NSLog(@"source render block called mSampleTime:%f mHostTime:%llu mRateScalar:%f mWordClockTime:%llu mSMPTETime:%hd ",
              timestamp->mSampleTime,
              timestamp->mHostTime,
              timestamp->mRateScalar,
              timestamp->mWordClockTime,
              timestamp->mSMPTETime.mSubframes);

        Float32 *outPtr = (Float32*)(outputData->mBuffers[0].mData);
        for (size_t i = 0; i < frameCount; ++i) {
            static double tst_sinTime = 0;
            static double tst_mp = -1;
            tst_sinTime += 0.01f * tst_mp;
            if (tst_sinTime > 0.99f || tst_sinTime < -0.99f) tst_mp *= -1;
            
            Float32 sample = tst_sinTime;
            outPtr[i] = (sample + tmp_buf[i])/2.0f;
        }
        
        return noErr;
    }];
    [_engine attachNode:outNode];
    //[_engine connect:srcNode to:_engine.mainMixerNode format:nil];
    [_engine connect:outNode to:_engine.mainMixerNode format:inpFormat];
    //[_engine connect:_engine.inputNode to:_engine.mainMixerNode format:inpFormat];
    _engine.mainMixerNode.outputVolume = 0.5;
}

- (void)start
{
    NSLog(@"AVAudioEngineService start");
    NSError *err = nullptr;
    [_engine startAndReturnError:&err];
    if (err) {
        NSLog(@"error: %@", err.localizedDescription);
    }
}

- (void)stop
{
    NSLog(@"AVAudioEngineService stop");
    [_engine stop];
}

@end
