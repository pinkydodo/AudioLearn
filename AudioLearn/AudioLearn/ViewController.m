//
//  ViewController.m
//  AudioLearn
//
//  Created by pinky on 2021/2/15.
//  Copyright © 2021 pinky. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

/*
需求列表：
 1.录音，并保存pcm文件
 2.录音保存为.wav文件
 3.边录音边播放
 4.
 */

@interface ViewController ()

-(void)handleRouteChange:(NSNotification*) notification;
-(void)handleInterruption:(NSNotification*) notification;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //todopinky:似乎说setActive是个同步操作，可能耗时，不应该放在主线程。先临时放这里了
    [self startAVSession];
    
    [self checkRecordPermission];
    
}

-(void)checkRecordPermission{
    AVAudioSession* session = [AVAudioSession sharedInstance];
    AVAudioSessionRecordPermission recordPermission = [session recordPermission];
    if( recordPermission == AVAudioSessionRecordPermissionUndetermined )
    {
        NSLog(@"record permission:%d", recordPermission );
        if( [session respondsToSelector:@selector( requestRecordPermission:)])
        {
            [session requestRecordPermission:^(BOOL granted) {
                if( granted )
                {
                    NSLog(@"get record permission");
                }
                else{
                    NSLog(@"not permit record");
                }
            }];
        }
    }
    else{
        if( recordPermission == AVAudioSessionRecordPermissionGranted )
        {
            NSLog(@"already get record permission");
        }
        else{
            NSLog(@"already denied record permission ,please set in settings");
        }
    }
    
    
    
}


- (void )startAVSession{
    //1.config session
    AVAudioSession * session = [AVAudioSession sharedInstance ];

    [session setCategory: AVAudioSessionCategoryPlayAndRecord mode:AVAudioSessionModeVoiceChat options:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    //2.start session
    [session setActive:YES error:nil];
    //3.registe notify
    NSNotificationCenter * notifyCenter = [NSNotificationCenter defaultCenter];
    
    [notifyCenter addObserver: self  selector:@selector( handleRouteChange:) name:AVAudioSessionRouteChangeNotification object: session];
    
    [notifyCenter addObserver: self  selector:@selector( handleInterruption:) name:AVAudioSessionInterruptionNotification object: session];
    //imply notify deal
}

-(void)handleRouteChange:(NSNotification*) notification {
    if( [notification.name isEqualToString: AVAudioSessionRouteChangeNotification] )
    {
        NSInteger reason = [[[notification userInfo] objectForKey: AVAudioSessionRouteChangeReasonKey] integerValue];
        
        NSString* preRoute =  [[notification userInfo] objectForKey: AVAudioSessionRouteChangePreviousRouteKey] ;
        
        NSLog(@"Route Changed:%li, pre:%@", (AVAudioSessionRouteChangeReason)reason, preRoute  );
        
    }
}

-(void)handleInterruption:(NSNotification*) notification{
    if( [notification.name isEqualToString: AVAudioSessionInterruptionNotification ])
    {
        NSInteger reason = [[[notification userInfo] objectForKey: AVAudioSessionInterruptionTypeKey] integerValue];
        if( reason == AVAudioSessionInterruptionTypeBegan )
        {
            NSLog(@"Interrupt Begin");
        }
        else if( reason == AVAudioSessionInterruptionTypeEnded )
        {
            NSLog(@"Interrupt End");
            if( [[[notification userInfo] objectForKey: AVAudioSessionInterruptionOptionKey] integerValue] ==
                AVAudioSessionInterruptionOptionShouldResume )
               {
                   NSLog(@" Need Resume ");
            }
        }
    }
}

@end
