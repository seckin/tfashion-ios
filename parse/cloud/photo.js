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
	Parse.Cloud.httpRequest({
	  method: 'POST',
	  url: 'http://conceive.io/create_media_from_parse',
	  followRedirects: true,
	  headers: {
	    'Content-Type': 'application/json;charset=utf-8'
	  },
	  body: {
	  	parse_link: "http://cdn.playbuzz.com/cdn/164dc032-b7eb-4e6d-8487-b1d9b2883273/97438fda-c723-449b-8f50-ff1962895ad4.jpg",
	  	parse_object_id: request.object.id
	  }
	}).then(function(httpResponse) {
	  console.log(httpResponse.text);
	}, function(httpResponse) {
	  console.error('Request failed with response code ' + httpResponse.status);
	});
});