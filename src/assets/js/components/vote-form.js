var voteForm = {
    init: function() {
        if ($("#vote-form")) {
            voteForm.setup();
        }
    },
 
    setup: function() {
        $("#add-button").click(voteForm.add);
    },
 
    add: function() {
        var form = $("#add-form");
        var alt = $("#alternative-template").clone();
        alt.find(".vote").val(form.find('.vote').val());
        alt.find(".text").html(form.find('.text').val());
        alt.find(".author").html("you");
        form.before(alt);

        MotionUI.animateIn(alt, 'slide-in-up ease-out');
    }
};
