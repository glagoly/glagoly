protos = [$client,$bert]; N2O_start();

function closeHelp() {
    qi('help-callout').style.display = 'none';
};

function clearAltForm() {
    qi('alt_text').value = '';
    qi('alt_vote').value = '';
};

function voteSubmit() {
    var x = document.querySelectorAll("#alts input[id^=\"vote\"]");
    var votes = [];
    for (var i = 0; i < x.length; i++) {
        votes.push([x[i].id.substring(4), x[i].value]);
    };

    vote({
        title:  qi('title') ? qi('title').value : '',
        name: qi('name').value,
        votes: votes
    });
    console.log(votes);
    return false;
};


