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
@implementation TiIspeechDictationProxy

-(void)_configure
{
    _isRecording = NO;
    _debug = NO;
	[super _configure];
}

-(void)_destroy
{
    self.outputCallback = nil;
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
    ISSpeechRecognition *recognition = [[ISSpeechRecognition alloc] init];

    recognition.silenceDetectionEnabled = [TiUtils boolValue:@"silenceDetection" properties:args def:YES];
    recognition.freeformType = [TiUtils intValue:@"freeformType" properties:args def:ISFreeFormTypeDictation];
    
    if([args  objectForKey:@"locale"]!=nil){
        [recognition setLocale:[TiUtils stringValue:@"locale" properties:args]];
    }

    if([args  objectForKey:@"model"]!=nil){
        [recognition setModel:[TiUtils stringValue:@"model" properties:args]];
    }
    
	NSError *err;
	
    _isRecording = YES;
    
	[recognition setDelegate:self];
	
	if(![recognition listen:&err]) {
        _isRecording = NO;
		NSLog(@"[ERROR] %@", err);
        NSDictionary *eventErr3 = [NSDictionary dictionaryWithObjectsAndKeys:
                                  NUMBOOL(NO),@"success",
                                  [err localizedDescription],@"message",
                                  nil];
        
        [self _fireEventToListener:@"onComplete"
                        withObject:eventErr3 listener:callback thisObject:nil];
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
