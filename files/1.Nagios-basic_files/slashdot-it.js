





(
  function() {
    var url_attr   = 'url='   + encodeURIComponent(window.slashdot_url         || window.location.href);
    var style_attr = 'style=' + encodeURIComponent(window.slashdot_badge_style || 'h0');
    var title_attr = 'title=' + encodeURIComponent(window.slashdot_title       || document.title);
    var src_query  = '?' + [style_attr, url_attr, title_attr].join('&');

    var dx=130, dy=25;
    if ( /^style=v/.test(style_attr) ) {
      dx=52;
      dy=80;
    }
    
    var iframe = '<iframe src="https://slashdot.org/slashdot-it.pl'+src_query+'"' +
                  ' height="' + dy + '" width="' + dx + '" scrolling="no" frameborder="0"></iframe>'
    document.write(iframe);
  }
)()
