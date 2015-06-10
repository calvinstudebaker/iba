/*
push.js
Javascript module 
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
