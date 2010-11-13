/**
 * This is where the JS for theStack will go.
 * We can assume Mootools 1.3 (core/more) has been loaded.
 *
 * @author Nat Welch
 */
window.addEvent('domready', function() {

   // Hover text over empty fields
   $$('.post-form').each(function(el) {
      var title = $('title-input');
      var text  = $('text-input');
      var tags  = $('tags-input');

      var ot1 = new OverText(title);
      var ot2 = new OverText(text);
      var ot3 = new OverText(tags);
   });
});
