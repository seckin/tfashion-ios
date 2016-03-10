Parse.Cloud.beforeSave('Activity', function(request, response) {
  var currentUser = request.user;
  var objectUser = request.object.get('fromUser');

  if(!currentUser || !objectUser) {
    response.error('An Activity should have a valid fromUser.');
  } else if (currentUser.id === objectUser.id) {
    if (request.object.get("type") === "follow") {
      var query = new Parse.Query('Activity');
      var toUser = request.object.get("toUser");
      query.equalTo('fromUser', objectUser);
      query.equalTo('toUser', toUser);
      query.equalTo('type', "follow");
      query.count({
        success: function(count) {
          if (count > 0) {
            response.error('User is already followed by current user');
          } else {
            response.success();
          }
        },
        error: function(error) {
          response.error('Cannot find if the user is already followed by current user');
        }
      });
    } else {
      response.success();
    }
  } else {
    response.error('Cannot set fromUser on Activity to a user other than the current user.');
  }
});

Parse.Cloud.afterSave('Activity', function(request) {
  // Only send push notifications for new activities
  if (request.object.existed()) {
    return;
  }

  var toUser = request.object.get("toUser");
  if (!toUser) {
    throw "Undefined toUser. Skipping push for Activity " + request.object.get('type') + " : " + request.object.id;
    return;
  }

  var fromUser = request.object.get("fromUser");
  // Only send push notifications to user if s/he is not fromUser
  // Sender should not recieve notification in the ideal behaviour
  if (toUser.id === fromUser.id) {
    return;
  };

  var query = new Parse.Query('NotificationSetting');
  query.equalTo('user', toUser);
  query.find({
      success: function(notificationSettings) {
        var notificationSetting = notificationSettings[0];
        console.log('Retrieved 1 notificationSetting');
        if (notificationSetting) {
          if (request.object.get("type") === "like") {
            if (notificationSetting.get("likes") === "off") {
              return;
            } else if (notificationSetting.get("likes") === "fromPeopleIFollow") {
              checkToUserIsFollowedByFromUser(request, fromUser, toUser);
            } else if (notificationSetting.get("likes") === "fromEveryone") {
              sendPush(request, toUser);
            }
          } else if (request.object.get("type") === "comment") {
            if (notificationSetting.get("comments") === "off") {
              return;
            } else if (notificationSetting.get("comments") === "fromPeopleIFollow") {
              checkToUserIsFollowedByFromUser(request, fromUser, toUser);
            } else if (notificationSetting.get("comments") === "fromEveryone") {
              sendPush(request, toUser);
            }
          } else if (request.object.get("type") === "follow") {
            if (notificationSetting.get("theNewFollowers") === "off") {
              return;
            } else if (notificationSetting.get("theNewFollowers") === "fromEveryone") {
              sendPush(request, toUser);
            }
          } else if (request.object.get("type") === "mention") {
              sendPush(request, toUser);
          }

        } else {
          console.log('Retrieved 0 notificationSetting');
          sendPush(request, toUser);
        }
      }
    });
});

// todo var checkNotificationSetting = function(user)

var checkToUserIsFollowedByFromUser = function(request, fromUser, toUser) {
  var query = new Parse.Query('Activity');
  query.equalTo('fromUser', fromUser);
  query.equalTo('toUser', toUser);
  query.equalTo('type', "follow");
  query.count({
    success: function(count) {
      if (count > 0) {
        console.log('Count' + count);
        sendPush(request, toUser);
      } else {
        console.log('Count is zero');
        return;
      }
    },
    error: function(error) {
      throw "Push checkToUserIsFollowedByFromUser Error " + error.code + " : " + error.message;
    }
  });
}

var sendPush = function(request, user) {
  var query = new Parse.Query(Parse.Installation);
  query.equalTo('user', user);

  Parse.Push.send({
    where: query, // Set our Installation query.
    data: alertPayload(request)
  }).then(function() {
    // Push was successful
    console.log('Sent push.');
  }, function(error) {
    throw "Push Error " + error.code + " : " + error.message;
  });
}

var alertMessage = function(request) {
  var message = "";

  if (request.object.get("type") === "comment") {
    if (request.user.get('displayName')) {
      message = request.user.get('displayName') + ' commented on one of your clothes: ' + request.object.get('content').trim();
    } else {
      message = "Someone commented on your photo.";
    }
  } else if (request.object.get("type") === "like") {
    if (request.user.get('displayName')) {
      message = request.user.get('displayName') + ' liked one of your clothes.';
    } else {
      message = 'Someone likes your photo.';
    }
  } else if (request.object.get("type") === "follow") {
    if (request.user.get('displayName')) {
      message = request.user.get('displayName') + ' is now following you.';
    } else {
      message = "You have a new follower.";
    }
  } else if (request.object.get("type") === "mention") {
    if (request.user.get('displayName')) {
      message = request.user.get('displayName') + ' mentioned you in a comment.';
    } else {
      message = "Someone mentioned you in a comment.";
    }
  }

  // Trim our message to 140 characters.
  if (message.length > 140) {
    message = message.substring(0, 140);
  }

  return message;
}

var alertPayload = function(request) {
  var payload = {};

  if (request.object.get("type") === "comment") {
    return {
      alert: alertMessage(request), // Set our alert message.
      badge: 'Increment', // Increment the target device's badge count.
      // The following keys help Anypic load the correct photo in response to this push notification.
      p: 'a', // Payload Type: Activity
      t: 'c', // Activity Type: Comment
      fu: request.object.get('fromUser').id, // From User
      // pid: request.object.id // Photo Id
      pid: request.object.get('photo').id // Photo Id
    };
  } else if (request.object.get("type") === "like") {
    return {
      alert: alertMessage(request), // Set our alert message.
      // The following keys help Anypic load the correct photo in response to this push notification.
      p: 'a', // Payload Type: Activity
      t: 'l', // Activity Type: Like
      fu: request.object.get('fromUser').id, // From User
      pid: request.object.get('photo').id // Photo Id
    };
  } else if (request.object.get("type") === "follow") {
    return {
      alert: alertMessage(request), // Set our alert message.
      // The following keys help Anypic load the correct photo in response to this push notification.
      p: 'a', // Payload Type: Activity
      t: 'f', // Activity Type: Follow
      fu: request.object.get('fromUser').id // From User
    };
  } else if (request.object.get("type") === "mention") {
    return {
      alert: alertMessage(request), // Set our alert message.
      badge: 'Increment', // Increment the target device's badge count.
      // The following keys help Anypic load the correct photo in response to this push notification.
      p: 'a', // Payload Type: Activity
      t: 'm', // Activity Type: Mention
      fu: request.object.get('fromUser').id, // From User
      cid: request.object.get('comment').id // Comment Id
    };
  }
}