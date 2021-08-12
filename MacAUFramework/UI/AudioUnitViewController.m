//
//  AudioUnitViewController.m
//  TestMacAudioUnit
//
//  Created by Denys Budelkov on 11.08.2021.
//

#import "AudioUnitViewController.h"
#import "TestMacAudioUnitAudioUnit.h"

@interface AudioUnitViewController ()

@end

@implementation AudioUnitViewController {
    AUAudioUnit *audioUnit;
}

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    if (!audioUnit) {
        return;
    }
    
    // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
}

- (AUAudioUnit *)createAudioUnitWithComponentDescription:(AudioComponentDescription)desc error:(NSError **)error {
    audioUnit = [[TestMacAudioUnitAudioUnit alloc] initWithComponentDescription:desc error:error];
    
    return audioUnit;
}

@end
