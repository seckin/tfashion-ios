var express = require('express');
var app = express();

// Global app configuration section
app.use(express.bodyParser());  // Populate req.body

app.get('/notify_message',
//  express.basicAuth('P5xFUqEkqLlPjLoLPfPlX6GfOFPEqjmsf3ftGWfO', 'omEVJohGXsgfW6n5OrsWEmYlseQnW9inYPz1Pkux'),
         function(request, response) {
  // Use Parse JavaScript SDK to create a new message and save it.
  // var Message = Parse.Object.extend("Message");
  // var message = new Message();
  // message.save({ text: req.body.text }).then(function(message) {
  //   res.send('Success');
  // }, function(error) {
  //   res.status(500);
  //   res.send('Error');
  // });
//console.log(request);

//response.send('text:');
//response.send(request.query.text);


// var TextReceived = Parse.Object.extend("TextReceived");
//   var message = new TextReceived();
//   message.save({
//     query_text: request.query.text,
//     sender_number: request.query.msisdn
//   }).then(function(message) {
//     response.send('Success');
//   }, function(error) {
//     response.status(500);
//     response.send('Error');
//   });

//     Parse.Cloud.define("testUS", function (req, response) {
//     if (req.user) {
//         Parse.Cloud.useMasterKey();
//         req.user.fetch({
//             success: function (user) {
//                 response.success(user._sessionToken);
//             },
//             error: function (user, err) {
//                 response.error(err.message);
//             }
//         });
//     } else {
//         response.error("Not logged in.");
//     }
// });

    var query = new Parse.Query("SignupAttempt");

     query.equalTo("verificationCode", request.query.text);
     query.first({
        success: function(object) {
          object.save({
            messageArrived: true,
            senderNumber: request.query.msisdn
          }).then(function(object) {
            console.log('Sent messageArrived.');
            response.send('Success');
          }, function(error) {
          response.status(500);
          response.send('Error');
          });
        },
        error: function(error) {
           response.status(500);
           response.send('Error');
           console.error("Error finding related comments " + error.code + ": " + error.message);
        }
     });
});

app.listen();