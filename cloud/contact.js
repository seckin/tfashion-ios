Parse.Cloud.beforeSave('Contact', function(request, response) {
  var currentUser = request.user;
  var objectUser = request.object.get('fromUser');

  if(!currentUser || !objectUser) {
    response.error('A Contact should have a valid fromUser.');
  } else if (currentUser.id === objectUser.id) {

    var objectId = request.object.id;
    // if objectId of request object is defined, it is unnecessary to query object
    if (objectId) {
      response.success();
    } else {
      var query = new Parse.Query("Contact");
      var phoneNumbers = request.object.get("phoneNumbers");
      var emails = request.object.get("emails");
      if (phoneNumbers[0]) {
        query.containedIn("phoneNumbers", phoneNumbers);
      } else {
        query.containedIn("emails", emails);
      }
      query.equalTo("fromUser", objectUser);
      query.first({
        success: function(object) {
          if (object) {
             object.save({
              phoneNumbers: request.object.get('phoneNumbers'),
              emails: request.object.get('emails'),
              firstName: request.object.get('firstName'),
              lastName: request.object.get('lastName'),
              fullName: request.object.get('fullName')
            }).then(function(object) {
              response.error("A Contact already exists for fromUser, but updated");
            }, function(error) {
              response.error("A Contact already exists for fromUser with error: " + error.message);
            });
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
    response.error('Cannot set fromUser on Contact to a user other than the current user.');
  }
});


Parse.Cloud.define("sendContacts", function(request, response) {
  var list = request.params.contacts;

  var contacts = new Array();
  for (var i = 0; i < list.length; i++) {
    var contactExtend = Parse.Object.extend("Contact");
    var contact = new contactExtend();
    contact.set('firstName', list[i].firstName);
    contact.set('lastName', list[i].lastName);
    contact.set('fullName', list[i].fullName);
    contact.set('emails', list[i].emails);
    contact.set('phoneNumbers', list[i].phoneNumbers);
    contact.set('addressBookRecordId', list[i].addressBookRecordId);
    contact.set('fromUser', request.user);
    contact.set('ACL', list[i].ACL);

    contacts[i] = contact;
  }

  Parse.Object.saveAll(contacts,{
    success: function(list) {
      // All the objects were saved.
      response.success();
    },
    error: function(error) {
      // An error occurred while saving one of the objects.
      // It may probably updated
      response.error(error.message);
    },
  });
});