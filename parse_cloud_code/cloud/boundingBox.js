exports.getBoundingPoints = function(params){
	var nearLeft = params.nearLeft;
	var nearRight = params.nearRight;
	var farLeft = params.farLeft;
	var farRight = params.farRight;

	var minLatitude = Math.min(nearLeft.latitude, nearRight.latitude, farLeft.latitude, farRight.latitude);
	var maxLatitude = Math.max(nearLeft.latitude, nearRight.latitude, farLeft.latitude, farRight.latitude);
	var minLongitude = Math.min(nearLeft.longitude, nearRight.longitude, farLeft.longitude, farRight.longitude);
	var maxLongitude = Math.max(nearLeft.longitude, nearRight.longitude, farLeft.longitude, farRight.longitude);

	var southwestPoint = new Parse.GeoPoint(minLatitude, minLongitude);
	var northeastPoint = new Parse.GeoPoint(maxLatitude, maxLongitude);

	return {
		southwest: southwestPoint,
		northeast: northeastPoint
	};
};