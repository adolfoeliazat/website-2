//= require jquery
//= require_tree .

$(function () {
  'use strict';

  // Mobile navigation
  var $menu = $('#header-menu');
  var $menuToggle = $('#mobile-menu-toggle');
  $menuToggle.on('click', function (event) {
    event.preventDefault();
    $menu.slideToggle(200, function () {
      if($menu.is(':hidden')) {
        $menu.removeAttr('style');
      }
    });
  });

  // var $window = $(window);
  // $('[data-parallax="background"]').each(function () {
  //   var $this = $(this);
  //   var speed = $this.data('parallax-speed');
  //   var offset = $this.data('parallax-offset') || 0;

  //   $window.on('scroll', function () {
  //     var yPos = -($window.scrollTop() / speed);
  //     var coords = '50% ' + (yPos + offset) + 'px';
  //     $this.css('backgroundPosition', coords);
  //   });

  //   $window.scroll()
  // });
});
