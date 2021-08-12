//
//  sandbox.m
//  AudioTest
//
//  Created by Denys Budelkov on 03.08.2021.
//

#import "sandbox.h"

#import <AVFAudio/AVFAudio.h>

class CPPSandbox {
public:
    //
    CPPSandbox() {
        printf("test\n");
    }
    ~CPPSandbox() {
        printf("destructor\n");
    }
};

@interface AudioSandbox() {
    CPPSandbox _sanbox;
}

@property (nonatomic, strong) AVAudioSession *session;

@end

@implementation AudioSandbox

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
        [self setupSession];
    }
    return self;
}

- (void)setupSession {
    NSError *err = nullptr;
    
    self.session = [AVAudioSession sharedInstance];
    [_session setCategory:AVAudioSessionCategoryPlayAndRecord
                    mode:AVAudioSessionModeMeasurement
      routeSharingPolicy:AVAudioSessionRouteSharingPolicyDefault
                 options:AVAudioSessionCategoryOptionDuckOthers
                   error:nil];
    
    [_session setPreferredIOBufferDuration:0.005 error:&err];
    
    // Inp
    AVAudioSessionPortDescription *input = nullptr;
    NSArray<AVAudioSessionPortDescription *> *inputs = _session.availableInputs;
    for (int i = 0; i < inputs.count; ++i) {
        if (inputs[i].portType == AVAudioSessionPortUSBAudio) {
            input = inputs[i];
        }
    }
    if (!input) {
        [_session setPreferredInput:input error:&err];
    } else {
        NSLog(@"Input not found: %@", err.localizedDescription);
    }
    
    err = nullptr;
    [_session setActive:true error:&err];
    if (err) {
        NSLog(@"Can't activate session: %@", err.localizedDescription);
    } else {
        NSLog(@"AVAudioSession active");
    }
    
    for (AVAudioSessionPortDescription* port in _session.currentRoute.inputs) {
        NSLog(@"Port: %s", port.portType.UTF8String);
        if (port.selectedDataSource) {
            NSLog(@"Name: %@", port.selectedDataSource.dataSourceName);
        }
    }
}

- (void)dealloc
{
    
}

@end
