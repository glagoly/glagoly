var VoteForm = (function () {
    //  wired storage
    var count = 1;
    var changes = {};

    var updateAlt = function(id, text) {
        changes[id].author = 'you';
        changes[id].text = text;

        return changes[id];
    };

    var addAlt = function(text) {
        var id = 'new-' + (++count);

        changes[id] = {
            id: id,
            new: true,
            text: text
        };

        return changes[id];
    };

    var deleteAlt = function(id) {
        changes[id].deleted = true;
    };

    var restoreAlt = function(id) {
        changes[id].deleted = false;  
    }

    // dom events
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

        data = addAlt(form.find('.text').val());

        var alt = getById('new').clone(true);
        setId(alt, data.id);
        alt.find(".vote").val(form.find('.vote').val());
        alt.find(".text").text(data.text);
        alt.find(".author").html("you");
   
        $("#alternatives").append(alt);
        MotionUI.animateIn(alt, 'slide-in-up ease-out');

        form.find('.vote').val('');
        form.find('.text').val('');
        form.find('.text').focus();
    };

    var deleteEvent = function(event) {
        var id = getId(this);
        deleteAlt(id);
        var restore = getById('restore').clone(true);
        setId(restore, id, 'restore');
        
        MotionUI.replace(getById(id), restore, 'fade');
    };

    var restoreEvent = function(event) {
        var id = getId(this);
        restoreAlt(id);
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
            var data = updateAlt(id, text);
            alt.find(".text").text(text);
            alt.find(".author").html(data.author);
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

    var getVotes = function() {
        var votes = {};
        $('#alternatives > li').each(function() {
            votes[$(this).data("alt-id")] = $(this).find('.vote').val();
        });
        
        return votes;
    };

    var submitEvent = function(event) {
        create({
            title: $('#title').val().trim(),
            name: $('#name').val().trim(),
            votes: getVotes(),
            changes: changes
        });
        return false;
    };

    var titleChange = function(event) {
        var title = $('#title').val().trim();
        title = (title !== '') ? title : 'poll';
        $('#create').val('Create ' + title.toLowerCase());
    };

    return {
        data: function() {

        },
        init: function() {
            if (!$("#vote-form")) {
                return ;
            }
            $("#main").submit(submitEvent);
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

            $("#title").change(titleChange);
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