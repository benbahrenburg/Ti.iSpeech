/**
 * Copyright (c) 2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the MIT License
 * Please see the LICENSE included with this distribution for details.
 *
 * Available at https://github.com/benbahrenburg/Ti.iSpeech
 *
 */

#import "TiIspeechModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "iSpeechSDK.h"
#import <AVFoundation/AVAudioSession.h>
@implementation TiIspeechModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"2d7a53f1-30a6-4cef-bba7-968c89530de7";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"ti.ispeech";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
}

-(void)shutdown:(id)sender
{
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}


#pragma Public APIs

-(void)setAPIKey:(id)value
{
    ENSURE_SINGLE_ARG(value,NSString);
    [[iSpeechSDK sharedSDK] setAPIKey:value];
}

-(NSNumber*)isAvailable:(id)unused
{
    return NUMBOOL(ISSpeechRecognition.audioInputAvailable);
}

-(NSNumber*)requestPermission:(id)unused
{
    BOOL _isAllowed = YES;
    __block BOOL isAllowed = YES;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_0
    if([[AVAudioSession sharedInstance]
        respondsToSelector:@selector(requestRecordPermission)])
    {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL allowed){
            NSLog(@"Allow microphone use? %d", allowed);
            isAllowed = allowed;
        }];
    }
#endif
    _isAllowed= isAllowed;
    
    return NUMBOOL(_isAllowed);
}

MAKE_SYSTEM_PROP(TYPE_SMS,ISFreeFormTypeSMS);
MAKE_SYSTEM_PROP(TYPE_VOICEMAIL,ISFreeFormTypeVoicemail);
MAKE_SYSTEM_PROP(TYPE_DICTATION,ISFreeFormTypeDictation);
MAKE_SYSTEM_PROP(TYPE_MESSAGE,ISFreeFormTypeMessage);
MAKE_SYSTEM_PROP(TYPE_INSTANT_MESSAGE,ISFreeFormTypeInstantMessage);
MAKE_SYSTEM_PROP(TYPE_TRANSCRIPT,ISFreeFormTypeTranscript);
MAKE_SYSTEM_PROP(TYPE_MEMO,ISFreeFormTypeMemo);

@end
