//= require jquery
//= require bootstrap
//= require_self

$(function(){
  // Hide flash messages after 30 seconds
  window.setTimeout(function() {
    $('#flash-messages').hide();
  }, 30000);

  $('#one_name').focus();

  var autofillWin = function($el) {
    var score = $el.val();
    if(!score){
      $el.val('11');
    }
  };

  $('#new_match .game').one('focus', '.score', function(e) {
    autofillWin($(e.target));
  });

  $('#add-game').on('click', function(e) {
    var $game = $('#new_match .game:last');
    var $new = $game.clone().find('input').val('').end();
    $new.one('focus', '.score', function(e) {
      autofillWin($(e.target));
    });
    $game.after($new);
  });

});
