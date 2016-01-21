var VoteForm = (function () {
    var count = 1;
    var data = [];

    var getById = function (id, type) {
        return $("#alt-" + (type ? type + "-" : "") + id).first();
    };

    var setId = function (el, id, type) {
        el.data("alt-id", id);
        el.attr("id", "alt-" + (type ? type + "-" : "") + id);
    };

    var getId = function (el) {
        return $(el).parents("li[data-alt-id]").first().data("alt-id");
    };

    var addEvent = function(event) {
        var form = getById('add');
        if (!form.find('.text').val().trim()) {
            return;
        }

        var alt = getById('new').clone(true);
        id = count++;
        setId(alt, id);
        alt.find(".vote").val(form.find('.vote').val());
        alt.find(".text").text(form.find('.text').val());
        alt.find(".author").html("you");
   
        form.before(alt);
        MotionUI.animateIn(alt, 'slide-in-up ease-out');

        form.find('.vote').val('');
        form.find('.text').val('');
        form.find('.text').focus();
    };

    var deleteEvent = function(event) {
        var id = getId(this);
        var restore = getById('restore').clone(true);
        setId(restore, id, 'restore');
        
        MotionUI.replace(getById(id), restore, 'fade');
    };

    var restoreEvent = function(event) {
        var id = getId(this);
        var restore = getById(id, 'restore');

        MotionUI.replace(restore, getById(id), 'fade', true);
    };

    var editEvent = function(event) {
        var id = getId(this);
        var edit = getById('edit').clone(true);
        var alt = getById(id);
        setId(edit, id, 'edit');

        edit.find(".vote").val(alt.find('.vote').val());
        edit.find(".text").val(alt.find('.text').text());

        MotionUI.replace(getById(id), edit, 'fade');
    };

    var saveEvent = function(event) {
        var id = getId(event.currentTarget);
        var edit = getById(id, 'edit');
        var alt = getById(id);
        
        var text = edit.find('.text').val();
        if (!text.trim()) {
            return ;
        }

        if (text != alt.find(".text").text()) {
            alt.find(".text").text(text);
            alt.find(".author").html("you");
        }
        
        alt.find(".vote").val(edit.find('.vote').val());
        MotionUI.replace(edit, alt, 'fade', true);
    };

    var cancelEvent = function(event) {
        var id = getId(this);
        var edit = getById(id, 'edit');
        var alt = getById(id);

        alt.find(".vote").val(edit.find('.vote').val());

        MotionUI.replace(edit, alt, 'fade', true);
    };

    return {
        init: function() {
            if (!$("#vote-form")) {
                return ;
            }
            
            $("#add-button").click(addEvent);
            $("#alt-add textarea").keypress(function(e){
                var code = e.keyCode ? e.keyCode : e.which;
                if(code == 13)
                {
                    addEvent(e); e.preventDefault();
                }     
                
            });
            $(".delete-button").click(deleteEvent);
            $(".restore-button").click(restoreEvent);
            $(".edit-button").click(editEvent);
            $(".cancel-button").click(cancelEvent);
            $(".save-button").click(saveEvent);
            $("#alt-edit textarea").keypress(function(e){
                var code = e.keyCode ? e.keyCode : e.which;
                if(code == 13)
                {
                    saveEvent(e); e.preventDefault();
                }

            });
            
        },
    };
})();