exports.sendPush = function(params) {
	
	var pushText = params.pushText;
	var pushType = params.pushType;
	var installationId = params.installationId;

	var pushQuery = new Parse.Query(Parse.Installation);
	pushQuery.equalTo("objectId", installationId);

	Parse.Push.send({
		where: pushQuery,
		data: {
			alert: pushText,
		}
	}, {
		success: function() {
			console.log("Push notification sent!");
			return("Push notification sent!");
		},
		error: function(error) {
			return("Got an error " + error.code + " : " + error.message);
		}
	}
	);
}
