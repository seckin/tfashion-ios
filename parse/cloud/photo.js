// Validate Photos have a valid owner in the "user" pointer.
Parse.Cloud.beforeSave('Photo', function(request, response) {
  var currentUser = request.user;
  var objectUser = request.object.get('user');

  if(!currentUser || !objectUser) {
    response.error('A Photo should have a valid user.');
  } else if (currentUser.id === objectUser.id) {
    response.success();
  } else {
    response.error('Cannot set user on Photo to a user other than the current user.');
  }
});

 
Parse.Cloud.afterSave("Photo", function(request) {
	if (request.object.existed()) { 
		// it existed before 
		console.log('it existed before');
	} else {
	// it is new 
		console.log('it is new');
	}
	var obj = request.object.toJSON();
	console.log("obj.image");
	console.log(obj.image);
	console.log("obj.image.url:");
	console.log(obj.image.url);
	console.log("obj.objectId");
	console.log(obj.objectId);


	Parse.Cloud.httpRequest({
	  method: 'POST',
	  url: 'http://conceive.io/create_media_from_parse',
	  followRedirects: true,
	  headers: {
	    'Content-Type': 'application/json;charset=utf-8'
	  },
	  body: {
	  	parse_link: obj.image.url,
	  	parse_object_id: obj.objectId
	  }
	}).then(function(httpResponse) {
	  console.log(httpResponse.text);

	  query = new Parse.Query("_User");
	  query.get(request.object.get("user").id, {
	    success: function(user) {
	      user.increment("numPhotos");
	      user.save();
	    },
	    error: function(error) {
	      console.error("Got an error " + error.code + " : " + error.message);
	    }
	  });

	}, function(httpResponse) {
	  console.error('Request failed with response code ' + httpResponse.status);
	});
});
