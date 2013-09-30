/**
 * Copyright (c) 2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the MIT License
 * Please see the LICENSE included with this distribution for details.
 *
 * Available at https://github.com/benbahrenburg/Ti.iSpeech
 *
 */

#import "TiIspeechDictationProxy.h"
#import "TiUtils.h"
#import <AVFoundation/AVAudioSession.h>
@implementation TiIspeechDictationProxy

-(void)_configure
{
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
    _isRecording = NO;
    _debug = NO;
	[super _configure];
}

-(void)_destroy
{
    [self removeRecognizer];
	[super _destroy];
}

-(void) doCallListener:(NSString*)name
{
    if ([self _hasListeners:name]) {
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               NUMBOOL(YES),@"success",
                               nil
                               ];
        
        [self fireEvent:name withObject:event];
    }
}
-(NSNumber*)isPermitted:(id)unused
{
    return NUMBOOL(_isAllowed);
}
-(NSNumber*)isRecording:(id)unused
{
    return NUMBOOL(_isRecording);
}

-(BOOL)findAvailable
{
    return ISSpeechRecognition.audioInputAvailable;
}

-(NSNumber*)isAvailable:(id)unused
{
    return NUMBOOL([self findAvailable]);
}

-(void)removeRecognizer
{
    if(self.recognition!=nil){
        [[self recognition] setDelegate:nil];
        self.recognition = nil;
    }
}

-(void)start:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    KrollCallback *callback = [args  objectForKey:@"onComplete"];
	ENSURE_TYPE(callback,KrollCallback);

    if(_isAllowed == NO){
        NSLog(@"[ERROR] No Microphone Access");
        NSDictionary *eventErrA = [NSDictionary dictionaryWithObjectsAndKeys:
                                  NUMBOOL(NO),@"success",
                                  @"No Microphone access",@"message",
                                  nil];
        
        [self _fireEventToListener:@"onComplete"
                        withObject:eventErrA listener:callback thisObject:nil];
        return;
    }
    
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
    
    if(_isRecording){
        NSLog(@"[ERROR] already recording");
        NSDictionary *eventErr2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                  NUMBOOL(NO),@"success",
                                  @"already recording",@"message",
                                  nil];
        
        [self _fireEventToListener:@"onComplete"
                        withObject:eventErr2 listener:callback thisObject:nil];
        return;
         
    }

    _debug = [TiUtils boolValue:@"debug" properties:args def:NO];
    self.outputCallback = callback;
    if(self.recognition!=nil){
        [self removeRecognizer];
    }
    self.recognition = [[ISSpeechRecognition alloc] init];

    [self recognition].silenceDetectionEnabled = [TiUtils boolValue:@"silenceDetection" properties:args def:YES];
    [self recognition].freeformType = [TiUtils intValue:@"freeformType" properties:args def:ISFreeFormTypeDictation];
    
    if([args  objectForKey:@"locale"]!=nil){
        [[self recognition] setLocale:[TiUtils stringValue:@"locale" properties:args]];
    }

    if([args  objectForKey:@"model"]!=nil){
        [[self recognition] setModel:[TiUtils stringValue:@"model" properties:args]];
    }
    
	NSError *err;
	
    _isRecording = YES;
    
	[[self recognition] setDelegate:self];
	
	if(![[self recognition] listen:&err]) {
        _isRecording = NO;
		NSLog(@"[ERROR] %@", err);
        NSDictionary *eventErr3 = [NSDictionary dictionaryWithObjectsAndKeys:
                                  NUMBOOL(NO),@"success",
                                  [err localizedDescription],@"message",
                                  nil];
        
        [self _fireEventToListener:@"onComplete"
                        withObject:eventErr3 listener:callback thisObject:nil];
        [self removeRecognizer];
	}
}

- (void)recognition:(ISSpeechRecognition *)speechRecognition didGetRecognitionResult:(ISSpeechRecognitionResult *)result {
	
    _isRecording = NO;
    if(_debug){
        NSLog(@"[DEBUG] Method: %@", NSStringFromSelector(_cmd));
        NSLog(@"[DEBUG] Result: %@", result.text);
    }
    
    if(self.outputCallback!=nil){
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               NUMBOOL(YES),@"success",
                               @"completed",@"action",
                               result.text,@"text",
                               NUMFLOAT(result.confidence),@"confidence",
                               nil];
        
        [self _fireEventToListener:@"onComplete"
                        withObject:event listener:self.outputCallback thisObject:nil];
    }
    [self removeRecognizer];
    
}

- (void)recognition:(ISSpeechRecognition *)speechRecognition didFailWithError:(NSError *)error {
    
    _isRecording = NO;
    if(_debug){
        NSLog(@"[DEBUG] Method: %@", NSStringFromSelector(_cmd));
        NSLog(@"[DEBUG] Error: %@", error);
    }
    
    if(self.outputCallback!=nil){
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               NUMBOOL(NO),@"success",
                               [error localizedDescription],@"message",
                               @"errored",@"action",
                               nil];
        
        [self _fireEventToListener:@"onComplete"
                        withObject:event listener:self.outputCallback thisObject:nil];
    }
    [self removeRecognizer];
}

- (void)recognitionCancelledByUser:(ISSpeechRecognition *)speechRecognition {
    
     _isRecording = NO;
    if(_debug){
        NSLog(@"[DEBUG] Method: %@", NSStringFromSelector(_cmd));
    }
    
    if(self.outputCallback!=nil){
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               NUMBOOL(NO),@"success",
                               @"canceled",@"action",
                               nil];
        
        [self _fireEventToListener:@"onComplete"
                        withObject:event listener:self.outputCallback thisObject:nil];
    }
    [self removeRecognizer];
}

- (void)recognitionDidBeginRecording:(ISSpeechRecognition *)speechRecognition {
	if(_debug){
        NSLog(@"[DEBUG] Method: %@", NSStringFromSelector(_cmd));
    }
    [self doCallListener:@"startedRecording"];
}

- (void)recognitionDidFinishRecording:(ISSpeechRecognition *)speechRecognition {
    if(_debug){
        NSLog(@"[DEBUG] Method: %@", NSStringFromSelector(_cmd));
    }
    [self doCallListener:@"finishedRecording"];
}


@end
