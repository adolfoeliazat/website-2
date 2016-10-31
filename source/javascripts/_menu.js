$(function () {
  'use strict';

  // Mobile navigation
  var $menu = $('#js-header-menu');
  var $menuToggle = $('#js-header-menu-toggle');

  $menuToggle.on('click', function (event) {
    event.preventDefault();
    $menu.slideToggle(200, function () {
      if($menu.is(':hidden')) {
        $menu.removeAttr('style');
      }
    });
  });
});
