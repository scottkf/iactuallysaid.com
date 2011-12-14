$(function() {
  
  $("abbr.timeago").timeago();
  
  var value, _i, _len, _ref;
  _ref = ['div.info', 'div.alert-message', 'div.error'];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    value = _ref[_i];
    $(value).delay(5000).slideUp(300);
  }
  
  $('.vote').bind('ajax:complete', function(xhr, data) {
    data = $.parseJSON(data.responseText);
    if (data.response != "200") {
      return;
    }
    // $('.'+data.id).removeClass('success danger').addClass('disabled default');
    score = parseInt($('.score.' + data.id).html())
    if ($(this).hasClass('hate')) {
      $('.love.'+data.id).remove();
      $(this).addClass('disabled danger');
      score = score - 1;
    } else {
      $('.hate.'+data.id).remove();
      $(this).addClass('disabled success');
      score = score + 1;
    }
    $('.score.' + data.id).html(score);
  });
});