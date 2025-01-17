$(document).ready(function(){
  // LUA listener
  window.addEventListener('message', function( event ) {
    if (event.data.action == 'open') {
      var type        = event.data.type;
      var slika       = event.data.slika;
      var userData    = event.data.array['user'][0];
      var licenseData = event.data.array['licenses'];
      var sex         = userData.sex;

      if ( type == 'driver' || type == null) {
        $('img').show();
        $('#name').css('color', '#282828');

        if ( sex.toLowerCase() == 'm' ) {
          $('img').attr('src', slika);
          $('#sex').text('musko');
        } else {
          $('img').attr('src', slika);
          $('#sex').text('zensko');
        }

        $('#name').text(userData.firstname + ' ' + userData.lastname);
        $('#dob').text(userData.dateofbirth);
        $('#height').text(188);
        $('#signature').text(userData.firstname + ' ' + userData.lastname);

        if ( type == 'driver' ) {
          if ( licenseData != null ) {
          Object.keys(licenseData).forEach(function(key) {
            var type = licenseData[key].type;

            if ( type == 'drive_bike') {
              type = 'motor';
              $('#licenses').append('<p>'+ type +'</p>');
            } else if ( type == 'drive_truck' ) {
              type = 'kamion';
              $('#licenses').append('<p>'+ type +'</p>');
            } else if ( type == 'drive' ) {
              type = 'auto';
              $('#licenses').append('<p>'+ type +'</p>');
            }
          });
        }
		  $('#sex').css('left', '95px');
		  $('#height').css('left', '162px');
          $('#id-card').css('background', 'url(assets/images/license.png)');
        } else {
		  $('#sex').css('left', '102px');
		  $('#height').css('left', '173px');
          $('#id-card').css('background', 'url(assets/images/idcard.png)');
        }
      } else if ( type == 'weapon' ) {
        $('img').hide();
        $('#name').css('color', '#d9d9d9');
        $('#name').text(userData.firstname + ' ' + userData.lastname);
        $('#dob').text(userData.dateofbirth);
        $('#signature').text(userData.firstname + ' ' + userData.lastname);

        $('#id-card').css('background', 'url(assets/images/firearm.png)');
      }

      $('#id-card').show();
    } else if (event.data.action == 'close') {
      $('#name').text('');
      $('#dob').text('');
      $('#height').text('');
      $('#signature').text('');
      $('#sex').text('');
      $('#id-card').hide();
      $('#licenses').html('');
    }
  });
});
