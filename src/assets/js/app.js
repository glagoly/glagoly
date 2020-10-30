protos = [$client,$bert]; N2O_start();

function closeHelp(e) {
    e.preventDefault();
    qi('help-callout').style.display = 'none';
};

function clearAltForm() {
    qi('alt_text').value = '';
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

    data = {
        title:  qi('title') ? qi('title').value : '',
        name: qi('name').value,
        votes: votes,
        // add alternative
        alt_text: qi('alt_text').value
    };
    vote(data);
    
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

function checkLoginState() {
    FB.getLoginStatus(function(response) {
      statusChangeCallback(response);
    });
}
