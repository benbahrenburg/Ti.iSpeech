'use strict';

var ispeech = require('ti.ispeech');
Ti.API.info("module is => " + ispeech);

ispeech.setAPIKey("YOUR_KEY_GOES_HERE");
var dictate = ispeech.createDictation(),
	recognize = ispeech.createRecognizer(),
	speak = ispeech.createSpeak();
	
var win = Ti.UI.createWindow({
    backgroundColor: 'white',
});

//Create a container for our buttons
var vwTop = Ti.UI.createView({
	height:50, layout:"horizontal", width:Ti.UI.FILL, top:0
});
win.add(vwTop);

var inputText = Ti.UI.createTextArea({
	backgroundColor:"#999",
	top:60, bottom:0, width:Ti.UI.FILL,
	borderStyle: Ti.UI.INPUT_BORDERSTYLE_ROUNDED,
});
win.add(inputText);

var dictateButton = Ti.UI.createButton({
	title:"Dictate", width:50, height:50, left:10
});
vwTop.add(dictateButton);

var recognizeButton = Ti.UI.createButton({
	title:"Recognize Commands", width:170, height:50, left:10
});
vwTop.add(recognizeButton);

var speakButton = Ti.UI.createButton({
	title:"Speak", width:50, height:50, left:10
});
vwTop.add(speakButton);

function dictateCompleted(e){
	Ti.API.info(JSON.stringify(e));
	if(e.success){
		inputText.value = "Dictation Results:\n" + e.text;
	}else{
		alert(e.message);
	}
};

dictateButton.addEventListener('click',function(){
	if(!ispeech.isAvailable()){
		alert("Audio is not available");
		return;
	}
	
	if(dictate.isRecording()){
		alert("You are already recording");
		return;
	}
	inputText.value = "";
	var dialog = Ti.UI.createAlertDialog({
		title:"How it works", buttonNames:["Cancel","Ok"],
		message:"Speak into your device, the words will be added to the textArea"
	});
	dialog.addEventListener("click",function(f){
		if(f.index === 1){
			dictate.start({
				onComplete:dictateCompleted
			});				
		}	
	});
	dialog.show();
});

function recognizeCompleted(e){
	Ti.API.info(JSON.stringify(e));
	if(e.success){
		inputText.value = "Recognizer Results:\n" + e.text;
	}else{
		alert(e.message);
	}
};
recognizeButton.addEventListener('click',function(){
	if(!ispeech.isAvailable()){
		alert("Audio is not available");
		return;
	}

	if(recognize.isRecording()){
		alert("You are already recording");
		return;
	}
	inputText.value = "";
	
	var dialog = Ti.UI.createAlertDialog({
		title:"How it works", buttonNames:["Cancel","Ok"],
		message:"Say a command such as call Bob or call Alex"
	});
	
	dialog.addEventListener("click",function(f){
		if(f.index ===1){
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
		}
	});
	dialog.show();	
});

function onSpeakFinished(e){
	Ti.API.info(JSON.stringify(e));
};
speakButton.addEventListener('click',function(){
	if(!ispeech.isAvailable()){
		alert("Audio is not available");
		return;
	}

	if(speak.isSpeaking()){
		alert("You are already Speaking");
		return;
	}
	if((inputText.value+'').length == 0 ){
		alert("Enter text to speak in the textarea first");
		return;
	}
	var dialog = Ti.UI.createAlertDialog({
		title:"How it works", buttonNames:["Cancel","Ok"],
		message:"This will speak the text you entered into the textarea"
	});
	
	dialog.addEventListener("click",function(f){
		if(f.index===1){
			speak.start({
				onComplete:onSpeakFinished,
				text:inputText.value
			});			
		}
	});
	dialog.show();		
});

win.addEventListener('open',function(){
	Ti.API.info("Has Microphone permission? " + ispeech.requestPermission());
});

win.open();
