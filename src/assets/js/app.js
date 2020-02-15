protos = [$client,$bert]; N2O_start();

function closeHelp() {
    qi('help-callout').style.display = 'none';
};

function clearAltForm() {
    qi('alt_text').value = '';

    slider = qi('alt_vote');
    slider.value = 0;
    onSliderChange(slider);
};

function onSliderChange(slider) {
    slider.classList.remove('positive');
    slider.classList.remove('negative');
    var text =  qi(slider.id + 'text');

    if (slider.value > 0) {
        slider.classList.add('positive');
        text.innerHTML = "&#65291;" + slider.value;
    }
    
    if (slider.value < 0) {
        slider.classList.add('negative');
        text.innerHTML = "&mdash;"  + (-slider.value);
    }
    
    if (slider.value == 0) {
        text.innerHTML = "&empty;";
    }
}

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

function showResults() {
    view_results();
};

// This is called with the results from from FB.getLoginStatus().
function statusChangeCallback(response) {
    console.log('statusChangeCallback');
    if (response.status === 'connected') {
        // Logged into your app and Facebook.
        fb_login(response.authResponse.accessToken);
    } else if (response.status === 'not_authorized') {
        alert('Please log into this app.');
    } else {
        alert('Please log into Facebook.');
    }
}

function onLoginClick() {
    FB.login(function(response) {
        statusChangeCallback(response);
    }, {scope: 'public_profile'});
};
