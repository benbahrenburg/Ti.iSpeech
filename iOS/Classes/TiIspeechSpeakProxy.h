/**
 * Copyright (c) 2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the MIT License
 * Please see the LICENSE included with this distribution for details.
 *
 * Available at https://github.com/benbahrenburg/Ti.iSpeech
 *
 */

#import "TiProxy.h"

@interface TiIspeechSpeakProxy : TiProxy {
@private
    BOOL _isSpeaking;
    BOOL _debug;
}

@end
