Parse.Cloud.beforeSave('InviteRequest', function(request, response) {
  var objectId = request.object.id;
  // if objectId of request object is defined, it is unnecessary to query object
  if (objectId) {
    response.success();
  } else {
    var objectUser = request.object.get('fromUser');
    var contact = request.object.get("contact");

    var query = new Parse.Query("InviteRequest");
    query.equalTo("contact", contact);
    query.equalTo("fromUser", objectUser);
    query.first({
      success: function(object) {
        if (object) {
          response.error("An InviteRequest already exists for fromUser");
        } else {
          response.success();
        }
      },
      error: function(error) {
        response.error("Could not validate uniqueness for this InviteRequest object.");
      }
    });
  }

});

Parse.Cloud.job("consumeInviteRequests", function(request, status) {

  Parse.Cloud.useMasterKey();

  var Mailgun = require('mailgun');
  Mailgun.initialize('sandbox4249.mailgun.org', 'key-9ul0a2y1gkepa73596xlpv7-136y6-v6');

  var nexmo = require('cloud/nexmo.js');
  nexmo.initialize('396872b7', '4b3d53f8');

  var counter = 0;
  // Query for unsent invite requests
  var query = new Parse.Query("InviteRequest");
  query.equalTo("invitationSent", false);
  query.each(function(inviteRequest) {

    var contact = inviteRequest.get("contact");
    var fromUser = inviteRequest.get("fromUser");

    counter += 1;
    console.log(counter + " inviteRequest processed.");

    return contact.fetch().then(function(fetchedContact){
      fromUser.fetch().then(function(fetchedUser) {
        var inviteText = fetchedUser.get("displayName") + ", has invited you to join TFashion.";
        if (fetchedContact.get("emails")[0]) {
          Mailgun.sendEmail({
            to: fetchedContact.get("emails")[0],
            from: "team@pera.io",
            subject: "Join me on TFashion!",
            text: inviteText
          }, {
            success: function(httpResponse) {
              console.log(httpResponse);
              response.success("Email sent!");
            },
            error: function(httpResponse) {
              console.error(httpResponse);
              response.error("Uh oh, something went wrong");
            }
          });
          inviteRequest.set("invitationSent", true);
          inviteRequest.save();
        } else if (fetchedContact.get("phoneNumbers")[0]) {
          nexmo.sendTextMessage('TFashion', fetchedContact.get("phoneNumbers")[0], inviteText,{}, sendTextMessageCallback);
          inviteRequest.set("invitationSent", true);
          inviteRequest.save();
        }
      });
    });
  }).then(function() {
    // Set the job's success status
    status.success("Consuming InviteRequests completed successfully.");
  }, function(error) {
    // Set the job's error status
    status.error("Uh oh, something went wrong.");
  });
});

var sendTextMessageCallback = function (err, messageResponse) {
  if (err) {
    return err;
  } else {
    return messageResponse;
  }
}