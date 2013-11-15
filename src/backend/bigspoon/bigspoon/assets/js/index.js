$(document).ready(function() {
    $(".main-scroll").onepage_scroll({
       sectionContainer: "section",
       easing: "ease",
       animationTime: 1000,
       pagination: false,
       updateURL: false,
       beforeMove: function(index) {}, // This option accepts a callback function. The function will be called before the page moves.
       afterMove: function(index) {}, // This option accepts a callback function. The function will be called after the page moves.
       loop: true, // You can have the page loop back to the top/bottom when the user navigates at up/down on the first/last page.
       responsiveFallback: false // You can fallback to normal page scroll by defining the width of the browser in which you want the responsive fallback to be triggered. For example, set this to 600 and whenever the browser's width is less than 600, the fallback will kick in.
    });

    // Uncomment to slide every five seconds

    window.start = function(){
      $(".autoscroll i").addClass("icon-spin");
      autoscroll = setInterval(function(){
        $(".main-scroll").moveDown()
      }, 5000);
    }

});