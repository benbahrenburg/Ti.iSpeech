<h1>Ti.iSpeech</h1>

The Ti.iSpeech module(s) allows you to use the iSpeech.org speech APIs within your Titanium app.

<h2>Before you start</h2>
* This is an iOS anative modules designed to work with Titanium SDK 3.1.3.GA
* Before using this module you first need to install the package. If you need instructions on how to install a 3rd party module please read this installation guide.

<h2>Download the compiled release</h2>

Download the platform you wish to use:

* [iOS Dist](https://github.com/benbahrenburg/Ti.iSpeech/tree/master/iOS/dist)

<h2>Building from source?</h2>

If you are building from source you will need to do the following:

Import the project into Xcode:

* Modify the titanium.xcconfig file with the path to your Titanium installation

<h2>Creating an iSpeech Account</h2>

To use this module, you need an [iSpeech.org](http://www.ispeech.org) account with a developer API key.

Getting started:

* Go to the iSpeech.org developer portal [here](https://www.ispeech.org/developers).
* Register for a developer account
* Create a developer key, you will need this to use the module.

<h2>Setup</h2>

* Download the latest release from the releases folder ( or you can build it yourself )
* Install the ti.ispeech module. If you need help here is a "How To" [guide](https://wiki.appcelerator.org/display/guides/Configuring+Apps+to+Use+Modules). 
* You can now use the module via the commonJS require method, example shown below.


<h2>Installation of supporting files [IMPORTANT]</h2>

Before running your project, you need to copy the platform folder, found {Your Project}/modules/iphone/ti.ispeech/{version}/platform to the {Your Project}/platform folder in your project.  If you don't do this, you will not be able to build your project.

<h2>Importing the module using require</h2>
<pre><code>
var ispeech = require('ti.ispeech');
</code></pre>


<h2>Module Methods</h2>
The following outlines the methods available at the root of the Ti.iSpeech module.

<h3>setAPIKey</h3>

<b>Parameters</b> : String : Required
The setAPIKey takes one parameter, your API key obtained through the iSpeech.org developer portal.

<b>Example</b>
<pre><code>
ispeech.setAPIKey("YOUR_KEY_GOES_HERE");
</code></pre>

<h3>isAvailable</h3>

The isAvailable method, can be used to determine if audio is available on the device.

<b>Parameters</b>
None

<b>Example</b>
<pre><code>
Ti.API.info("Is Audio available? " + ispeech.isAvailable());
</code></pre>

<h3>requestPermission</h3>

Starting with iOS 7, you now need to request permission before using the microphone. To do this call the requestPermission method. This will request the permission and return the results.  If permission has already been granted, true/false will be returned to indicate the status of the request.

<b>Parameters</b>
None

<b>Example</b>
<pre><code>
Ti.API.info("Has Microphone permission? " + ispeech.requestPermission());
</code></pre>



<h2>Module Properties</h2>
The following properties are available from the module. These can be used to config the Recognizer and Dictation proxies.

<b>TYPE_SMS</b> - Optimized for SMS messages.

<b>TYPE_VOICEMAIL</b> Optimized for handling voicemail

<b>TYPE_DICTATION</b> Optimized for dictation

<b>TYPE_MESSAGE</b> - Optimized for message taking

<b>TYPE_INSTANT_MESSAGE</b> - Optimized for instant messages

<b>TYPE_TRANSCRIPT</b> - Optimized for taking transcripts

<b>TYPE_MEMO</b> - Optimized for Memos

<h2>Recognizer Methods</h2>
The following outlines the methods on the Recognizer proxy object.  This proxy allows you to trigger a callback based on key word commands.

<h3>isAvailable</h3>
You can also check if audio is available on each proxy as well as the module.

<b>Parameters</b> 
None

<b>Example</b>
<pre><code>

var recognize = ispeech.createRecognizer();

Ti.API.info("Is Audio available? " + recognize.isAvailable());

</code></pre>

<h3>isRecording</h3>
The isRecording method is used to determine if we are already recording what is being said. This avoids duplication of action.

<b>Parameters</b> 
None

<b>Example</b>
<pre><code>

var recognize = ispeech.createRecognizer();

Ti.API.info("Are you already recording? " + recognize.isRecording());

</code></pre>

<h3>start</h3>
The start method is used to start the command recognization process.  While you are speaking the iSpeech.org APIs will look for the keyword commands provided and trigger an event once matched.  For example you can use this method to listen for a user saying  a voice command such as "call Bob".

<b>Parameters</b> : Dictionary : Require
The start method takes a dictionary with the following elements.

<b>onComplete</b> : Callback : required
The onComplete callback is triggered on finish, error, cancel, or other completion action.

<b>commands</b> : Dictionary : required
The commands dictionary defines the key works and phrases you wish to recognize.

<b>silenceDetection</b> : Boolean : optional
The silenceDetection parameter is true by default. This toggle determines of the recognizer should complete based on silence detection.

<b>locale</b> : String : optional
The locale used to determine the speakers language.

<b>freeformType</b> : Enum : optional
The type of text operation you wish to have performed. By default this is set to TYPE_SMS.

<b>model</b> : String : optional
If you are using a custom model, you can set this value to the model you wish to use.

<b>Example</b>
The following shows how to recognize when someone asks to call one of the individuals listed below.

<pre><code>

var recognize = ispeech.createRecognizer();

function recognizeCompleted(e){
	Ti.API.info(JSON.stringify(e));
};	

recognize.start({
	onComplete:recognizeCompleted,
	commands:[
		{
			alias:"officers",
			command:"call %officers%",
			values:["Mike", "Rocco", "Grant", "Alex","Bob"]
		}
	]
});	
</code></pre>


<h2>Dictation Methods</h2>
The following outlines the methods on the Dictation proxy object.  This proxy allows you record longer messages.

<h3>isAvailable</h3>
You can also check if audio is available on each proxy as well as the module.

<b>Parameters</b> 
None

<b>Example</b>
<pre><code>

var dictate = ispeech.createDictate();

Ti.API.info("Is Audio available? " + dictate.isAvailable());

</code></pre>

<h3>isRecording</h3>
The isRecording method is used to determine if we are already recording what is being said. This avoids duplication of action.

<b>Parameters</b> 
None

<b>Example</b>
<pre><code>

var dictate = ispeech.createDictation();

Ti.API.info("Are you already recording? " + dictate.isRecording());

</code></pre>

<h3>start</h3>
The start method is used to start the dictation process.  While you are speaking the iSpeech.org APIs will be used to convert your voice into text. For example, this method can be used to record a voice note from a user.

<b>Parameters</b> : Dictionary : Require
The start method takes a dictionary with the following elements.

<b>onComplete</b> : Callback : required
The onComplete callback is triggered on finish, error, cancel, or other completion action.

<b>silenceDetection</b> : Boolean : optional
The silenceDetection parameter is true by default. This toggle determines of the recognizer should complete based on silence detection.

<b>locale</b> : String : optional
The locale used to determine the speakers language.

<b>freeformType</b> : Enum : optional
The type of text operation you wish to have performed. By default this is set to TYPE_DICTATION.

<b>model</b> : String : optional
If you are using a custom model, you can set this value to the model you wish to use.

<b>Example</b>
The following shows how to recognize when someone asks to call one of the individuals listed below.

<pre><code>

var dictate = ispeech.createDictate();

function dictateCompleted(e){
	Ti.API.info(JSON.stringify(e));
};	

dictate.start({
	onComplete:dictateCompleted
});	

</code></pre>


<h2>Speak Methods</h2>
The following outlines the methods on the Speak proxy object.  This allows you to speak sentences or phrases.

<h3>isAvailable</h3>
You can also check if audio is available on each proxy as well as the module.

<b>Parameters</b> 
None

<b>Example</b>
<pre><code>

var speak = ispeech.createSpeak();

Ti.API.info("Is Audio available? " + speak.isAvailable());

</code></pre>

<h3>isSpeaking</h3>
The isSpeaking method is used to determine if we are already speaking. This avoids duplication of action.

<b>Parameters</b> 
None

<b>Example</b>
<pre><code>

var speak = ispeech.createSpeak();

Ti.API.info("Are you already speaking? " + speak.isSpeaking());

</code></pre>

<h3>start</h3>
The start method is used to start speaking a phrase using the iSpeech.org API.

<b>Parameters</b> : Dictionary : Require
The start method takes a dictionary with the following elements.

<b>text</b> : String : required
The text which should be spoken.

<b>onComplete</b> : Callback : required
The onComplete callback is triggered on finish, error, cancel, or other completion action.

<b>voice</b> : String : optional
The voice parameter allows you to provide a custom voice.  If this is not provided, the default voice will be used.

<b>speed</b> : Int : optional
The speed parameter allows you to adjust the speed the speech is read.

<b>bitrate</b> : Int : optional
The bitrate parameter allows you to adjust the bitrate used.

<b>resume</b> : Boolean : optional
The resume parameter allows you to indicate if iSpeech should resume after being interrupted. By default this is false.

<b>Example</b>
The following shows how to recognize when someone asks to call one of the individuals listed below.

<pre><code>

var speak = ispeech.createSpeak();

function onSpeakFinished(e){
	Ti.API.info(JSON.stringify(e));
};	

speak.start({
	onComplete:onSpeakFinished,
	text:"Hello world"
});			

</code></pre>

<h2>Learn More</h2>

<h3>Examples</h3>
Please check the module's example folder or 

* [iOS](https://github.com/benbahrenburg/Ti.iSpeech/tree/master/iOS/example) 

for samples on how to use this project.

<h3>Twitter</h3>

Please consider following the [@benCoding Twitter](http://www.twitter.com/benCoding) for updates 
and more about Titanium.

<h3>Blog</h3>

For module updates, Titanium tutorials and more please check out my blog at [benCoding.Com](http://benCoding.com).

<h2>Legal Stuff</h2>
Appcelerator is a registered trademark of Appcelerator, Inc. Appcelerator Titanium is a trademark of Appcelerator, Inc.

iSpeech is a registered trademark of iSpeech, Inc.

<h2>License</h2>
Ti.iSpeech is available under the MIT license.

Copyright 2013 Benjamin Bahrenburg.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


