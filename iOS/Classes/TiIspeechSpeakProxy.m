/**
 * Copyright (c) 2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the MIT License
 * Please see the LICENSE included with this distribution for details.
 *
 * Available at https://github.com/benbahrenburg/Ti.iSpeech
 *
 */
#import "TiIspeechSpeakProxy.h"
#import "ISpeechSDK.h"
#import "TiUtils.h"
@implementation TiIspeechSpeakProxy

-(void)_configure
{
    _isSpeaking = NO;
	[super _configure];
}

-(NSNumber*)isSpeaking:(id)unused
{
    return NUMBOOL(_isSpeaking);
}

-(BOOL)findAvailable
{
    return ISSpeechRecognition.audioInputAvailable;
}

-(NSNumber*)isAvailable:(id)unused
{
    return NUMBOOL([self findAvailable]);
}

-(void)start:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    KrollCallback *callback = [args  objectForKey:@"onComplete"];
	ENSURE_TYPE(callback,KrollCallback);

    if([self findAvailable] == NO){
        NSLog(@"[ERROR] audio not available");
        NSDictionary *eventErr = [NSDictionary dictionaryWithObjectsAndKeys:
                                  NUMBOOL(NO),@"success",
                                  @"audio not available",@"message",
                                  nil];
        
        [self _fireEventToListener:@"onComplete"
                        withObject:eventErr listener:callback thisObject:nil];
        return;
    }
    
    if(_isSpeaking){
		NSLog(@"[ERROR] Already speaking");
        NSDictionary *eventErr2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   NUMBOOL(NO),@"success",
                                   @"already speaking",@"message",
                                   nil];
        
        [self _fireEventToListener:@"onComplete"
                        withObject:eventErr2 listener:callback thisObject:nil];
        return;
    }
    _debug = [TiUtils boolValue:@"debug" properties:args def:NO];
    NSString *text = [TiUtils stringValue:@"text" properties:args];
    ISSpeechSynthesis *synthesis = [[ISSpeechSynthesis alloc] initWithText:text];
    
    if([args objectForKey:@"voice"]!=nil){
        synthesis.voice = [TiUtils stringValue:@"voice" properties:args];
    }
    
    if([args objectForKey:@"speed"]!=nil){
        synthesis.speed = [TiUtils intValue:@"speed" properties:args];
    }

    if([args objectForKey:@"bitrate"]!=nil){
        synthesis.bitrate = [TiUtils intValue:@"bitrate" properties:args];
    }
    
    synthesis.resumesAfterInterruption = [TiUtils boolValue:@"resume" properties:args def:NO];
    
    NSError *err;
    _isSpeaking = YES;
    
    if(![synthesis speak:&err]) {
        _isSpeaking = NO;
		NSLog(@"[ERROR] %@", err);
        NSDictionary *eventErr3 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   NUMBOOL(NO),@"success",
                                   [err localizedDescription],@"message",
                                   nil];
        
        [self _fireEventToListener:@"onComplete"
                        withObject:eventErr3 listener:callback thisObject:nil];
    }else{
        _isSpeaking = NO;
        NSDictionary *eventOk = [NSDictionary dictionaryWithObjectsAndKeys:
                                   NUMBOOL(YES),@"success",
                                    text,@"text",
                                   nil];
        
        [self _fireEventToListener:@"onComplete"
                        withObject:eventOk listener:callback thisObject:nil];
    }
}

@end
