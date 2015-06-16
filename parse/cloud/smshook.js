var express = require('express');

// Create an Express web app (more info: http://expressjs.com/)
var app = express();

// Global app configuration section
app.use(express.bodyParser());  // Populate req.body

app.get('/sms',
    function(request, response) {
     express.basicAuth('YOUR_USERNAME', 'YOUR_PASSWORD'),
  var query = new Parse.Query("SignupAttempt");
   query.equalTo("verificationCode", request.body.text);
   query.first({
      success: function(object) {
         object.set("messageArrived", true);
         object.save();
         response.send('Success');
         console.log('Sent messageArrived.');
      },
      error: function(error) {
         response.status(500);
         response.send('Error');
         console.error("Error finding related comments " + error.code + ": " + error.message);
      }
   });
});


// Start the Express app
app.listen();