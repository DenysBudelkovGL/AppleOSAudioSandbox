//
//  AVAudioEngineService.h
//  AudioTest
//
//  Created by Denys Budelkov on 04.08.2021.
//

#import <Foundation/Foundation.h>
#import "AudioEngineService.h"

NS_ASSUME_NONNULL_BEGIN

@interface AVAudioEngineService : NSObject<AudioEngineService>

- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
