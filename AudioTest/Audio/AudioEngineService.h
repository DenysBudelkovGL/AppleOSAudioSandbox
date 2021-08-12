//
//  AudioEngineService.h
//  AudioTest
//
//  Created by Denys Budelkov on 04.08.2021.
//

#ifndef AudioEngineService_h
#define AudioEngineService_h

@protocol AudioEngineService <NSObject>

- (void)start;
- (void)stop;

@end


#endif /* AudioEngineService_h */
