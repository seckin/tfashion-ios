Parse.Cloud.beforeSave('NotificationSetting', function(request, response) {
  var currentUser = request.user;
  var objectUser = request.object.get('user');

  if(!currentUser || !objectUser) {
    response.error('A NotificationSetting should have a valid user.');
  } else if (currentUser.id === objectUser.id) {

    var objectId = request.object.id;
    // if objectId of request object is defined, it is unnecessary to query object
    if (objectId) {
        response.success();
    } else {
        var query = new Parse.Query("NotificationSetting");
        query.equalTo("user", objectUser);
        query.first({
            success: function(object) {
              if (object) {
                response.error("A NotificationSetting for this user already exists.");
              } else {
                response.success();
              }
            },
            error: function(error) {
              response.error("Could not validate uniqueness for this Contact object.");
            }
        });
    }
  } else {
    response.error('Cannot set user on NotificationSetting to a user other than the current user.');
  }
});