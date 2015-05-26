$('#submit_request').click(function(){

var name = $('#first_name').val() + "\u0020" +  $("#last_name").val() + "\u0020";
var email = $("#email_address").val();

  $.ajax({
  type: "POST",
  url: "https://mandrillapp.com/api/1.0/messages/send.json",
  data:{
    'key': 'nSHaF1yr9FL6krekX9ZPWQ',
    'message':{
      'from_email': 'parqtheapp@gmail.com',
      'to':[
        {
          'email': "leighh1@stanford.edu",
          'name': name,
          'type': 'to',
        }
        ],
        'autotext':'true',
        'subject': name + "wants PARQ",
        'html': 'Name: ' + name + '<br> Email: ' + email,
      }
    }
  }).done(function(response) {
   $('#first_name').val('');
   $('#last_name').val('') ;
   $("#email_address").val('');
   $("#request_form").hide();
   $("#thank_you").show();
  });
 });
