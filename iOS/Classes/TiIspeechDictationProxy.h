/**
 * Copyright (c) 2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the MIT License
 * Please see the LICENSE included with this distribution for details.
 *
 * Available at https://github.com/benbahrenburg/Ti.iSpeech
 *
 */

#import "TiProxy.h"
#import "ISpeechSDK.h"

@interface TiIspeechDictationProxy : TiProxy<ISSpeechRecognitionDelegate> {
@private
    BOOL _isRecording;
    BOOL _debug;
    BOOL _isAllowed;
}
@property (nonatomic, strong) KrollCallback *outputCallback;
@end
