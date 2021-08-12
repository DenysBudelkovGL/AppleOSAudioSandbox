//
//  ViewController.m
//  MacosTest
//
//  Created by Denys Budelkov on 10.08.2021.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AVFAudio/AVFAudio.h>
#import <MacAUFramework/MacAUFramework.h>
#import <CoreAudio/CoreAudio.h>

@interface ViewController() {
}

@property (nonatomic, strong) AVAudioEngine *engine;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    // Do any additional setup after loading the view.
    
    NSLog(@"./path: %@", [[NSFileManager defaultManager] currentDirectoryPath]);
    [self prepareAudioUnit];
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)prepareAudioUnit {
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
        //if ([c.name isEqualToString:@"Testv2AudioUnit"]) {
        //if ([c.name isEqualToString:@"AUReverb2"]) {
        if ([c.name isEqualToString:@"TestMacAudioUnit"]) {
            component = c;
        }
    }
    assert(component);
    NSLog(@">>> %@ selected", [component name]);
    [AUAudioUnit registerSubclass:TestMacAudioUnitAudioUnit.class asComponentDescription:component.audioComponentDescription name:@"test plugin" version:UINT32_MAX];
}

- (IBAction)testBtnPressed:(NSButton *)sender {
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] != AVAuthorizationStatusAuthorized) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            NSLog(@"audioaccess: %@", granted ? @"yes" : @"no");
            if (granted) {
                sender.enabled = false;
                [self tst_SetupWithSystemEffect];
            }
        }];
    } else {
        sender.enabled = false;
        [self tst_SetupWithSystemEffect];
    }
}

- (void)tst_SetupWithSystemEffect {
    self.engine = [[AVAudioEngine alloc] init];

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
        if ([c.name isEqualToString:@"TestMacAudioUnit"]) {
            component = c;
        }
    }
    assert(component);
    NSLog(@">>> %@ selected", [component name]);
    
    
    AudioUnitGetProperty(_engine.inputNode.audioUnit, kAudioDevicePropertyStreamConfiguration, 0, <#AudioUnitElement inElement#>, <#void * _Nonnull outData#>, <#UInt32 * _Nonnull ioDataSize#>)
    
    UInt32 bufSize = 8;
    AudioUnitSetProperty(_engine.inputNode.audioUnit, kAudioDevicePropertyBufferFrameSize, kAudioUnitScope_Global, 0, &bufSize, sizeof(UInt32));
    AVAudioInputNode *inp = _engine.inputNode;
    AVAudioFormat *inpFormat = [inp inputFormatForBus:0];
    
    __weak ViewController *weakSelf = self;
    [AVAudioUnit instantiateWithComponentDescription:component.audioComponentDescription
                                             options:kAudioComponentInstantiation_LoadInProcess
                                   completionHandler:^(__kindof AVAudioUnit * _Nullable audioUnit, NSError * _Nullable error) {
        
        //weakSelf.ourUnitAV = audioUnit;
        //weakSelf.ourUnitAU = audioUnit.AUAudioUnit;
        NSLog(@">>>what? latency: %lf", audioUnit.latency);
        NSLog(@">>>what? outputPresentationLatency: %lf", audioUnit.outputPresentationLatency);
        
        AUParameterTree *params = [audioUnit.AUAudioUnit parameterTree];
        for (AUParameter* param in params.allParameters) {
            NSLog(@"param: %@", param);
            // TODO: id I guess here
            if ([param.displayName.lowercaseString isEqualToString:@"dry/wet mix"]) {
                [param setValue:50];
            }
        }
        [audioUnit.AUAudioUnit setParameterTree:params];

        [weakSelf.engine attachNode:audioUnit];
        [weakSelf.engine connect:weakSelf.engine.inputNode to:audioUnit format:inpFormat];
        [weakSelf.engine connect:audioUnit to:weakSelf.engine.mainMixerNode format:inpFormat];
        
        NSError *err = nil;
        [weakSelf.engine startAndReturnError:&err];
        if (err) {
            NSLog(@"[_engine startAndReturnError] error:%@", err.debugDescription);
        }
    }];
}

@end
