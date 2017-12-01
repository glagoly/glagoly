var VoteForm = (function () {
    var submitEvent = function() {
        vote({
            title: qi('title').value,
            name: qi('name').value,
            votes: $('#alts input[id^="vote"]').map(function() {
                // love jquery for double braces
                return [[this.id.substring(4), $(this).val()]] 
            }).get()
        });

        return false;
    };

    return {
        init: function() {
            if (!$("#vote-form")) {
                return ;
            }
            $("#vote-form").submit(submitEvent);
        },
    };
})();