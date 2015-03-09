/*
main.js
This file defines all cloud functions that will run on Parse Cloud
These functions can be invoked from the command line using curl with REST API
or from iOS using Parse API
*/

var jobs = require("cloud/jobs.js");
var meterDataURL = "https://data.sfgov.org/resource/7egw-qt89.json";
var crimeDataURL = "https://data.sfgov.org/api/views/tmnf-yvry/rows.json";

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

//given a user location, return a Collection of Crime objects that are within
//1 mile of the given location
Parse.Cloud.define("getCrimesNearLocation", function(request, response){
	
});

//inject initial data into ParkingMeter table from dataSF.org
Parse.Cloud.job("putMeterData", function(request, response){
	jobs.putMeterDataFromURL(meterDataURL, request, response);
});

//inject initial data into Crime table from dataSF.org
Parse.Cloud.job("putCrimeData", function(request, response){
	jobs.putCrimeDataFromURL(crimeDataURL, request, resopnse);
});

//Test function to make sure cloud code is working. Exemplifies using a separate
//javascript module (test.js)
Parse.Cloud.define("test", function(request, response){
	var test = require("cloud/test.js");
	var val = test.isACoolName('Ralph');
	response.success(val);
});
