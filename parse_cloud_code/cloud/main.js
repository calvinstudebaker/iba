
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

var jobs = require("cloud/jobs.js");

Parse.Cloud.define("putSweepingData", function(request, response){
	Parse.Cloud.httpRequest({
		url: "http://parq.parseapp.com/sfsweeproutes.json",
		success: function(res){
			var data = res.data;
			var entry = data[0];
			console.log("first entry: " + entry);
			for (var key in entry){
				var attrName = key;
				var attrVal = entry[key];
				// console.log(attrName + ": " + attrVal);
			}
			response.success("word");
		},
		error: function(res){
			console.error("request failed with response code: " + res.status);
			response.error("bad");
		}
	});
});

Parse.Cloud.define("getCrimesNearLocation", function(request, response){

});

Parse.Cloud.job("putMeterData", function(request, response){
	jobs.putMeterDataFromURL("https://data.sfgov.org/resource/7egw-qt89.json", request, response);
});

Parse.Cloud.job("putCrimeData", function(request, response){
	jobs.putCrimeDataFromURL("https://data.sfgov.org/api/views/tmnf-yvry/rows.json", request, resopnse);
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
