/*
push.js
Javascript module that has one function sendPush that sends a custom 
push notification to a given phone installation.

@param params: a javascript object with 4 properties
-pushText -- string of text to display in the notification
-pushType -- custom string to define the type of notification (i.e. “STREET_SWEEPING”)
-installationId -- objectId identifying the phone installation in the Parse Installation table
-optional -- any extra optional data

@return a Parse Promise indicating the push notification will be sent
*/

exports.sendPush = function(params) {
	
	var pushText = params.pushText;
	var pushType = params.pushType;
	var installationId = params.installationId;
	var optional = params.optional;

	var pushQuery = new Parse.Query(Parse.Installation);
	pushQuery.equalTo("objectId", installationId);

	var promise = Parse.Push.send({
		where: pushQuery,
		data: {
			alert: pushText,
			sound: "default",
			custom: pushType,
			"optional": optional
		}
	}, {
		success: function() {
			console.log("Push notification sent: " + pushText);
		},
		error: function(error) {
			console.log("Got an error " + error.code + " : " + error.message);
		}
	}
	);

	return promise;
};
