var voteForm = {
    init: function() {
        if ($("#vote-form")) {
            voteForm.setup();
        }
    },
 
    setup: function() {
        $("#add-button").click(voteForm.add);
        $(".delete-button").click(voteForm.delete);
    },
 
    delete: function() {
        var alt = $(this).parents("li[data-alternative-id]").first();
        var deleted = $("#delete-alternative").clone();
        MotionUI.animateOut(alt, 'fade-out ease-out', function () {
            alt.after(deleted);
            MotionUI.animateIn(deleted, 'fade-in ease-out');    
        });
    },

    add: function() {
        var form = $("#add-form");
        var text = form.find('.text');
        if (!text.val().trim()) {

            return;
        }

        var alt = $("#alternative-template").clone();
        alt.find(".vote").val(form.find('.vote').val());
        alt.find(".text").html(form.find('.text').val());
        alt.find(".author").html("you");
        form.before(alt);

        MotionUI.animateIn(alt, 'slide-in-up ease-out');
    }
};
