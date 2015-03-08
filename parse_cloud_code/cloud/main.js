
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});




Parse.Cloud.define("putMeterData", function(request, response){

	var data = [];
	var http = 

	Parse.Cloud.httpRequest({
		url: "https://data.sfgov.org/resource/7egw-qt89.json",
		success: function(res){
			data = res.data;
			console.log("success");
			response.success(data);
		},
		error: function(res){
			console.error("request failed with response code: " + res.status);
			response.error("bad");
		}
	});

	
});

Parse.Cloud.define("test", function(request, response){
	var test = require("cloud/test.js");
	var val = test.isACoolName('Ralph');
	response.success(val);
});


//from http://stackoverflow.com/questions/247483/http-get-request-in-javascript
// function httpGet(theUrl)
// {
//     var xmlHttp = null;

//     xmlHttp = new XMLHttpRequest();
//     xmlHttp.open( "GET", theUrl, false );
//     xmlHttp.send( null );
//     return xmlHttp.responseText;
// }
