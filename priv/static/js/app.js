/**
* Event helpers
*/

function onSliderChange(slider) {
    // fix scroll bug
    // see: https://stackoverflow.com/questions/70914750/prevent-scroll-jump-on-range-input-on-android
    slider.focus({preventScroll: true});

    var text = qi(slider.id.replace('slider', 'badge'));
    text.classList.remove('bg-success');
    text.classList.remove('bg-danger');

    if (slider.value > 0) {
        text.classList.add('bg-success');
        text.innerHTML = "+" + slider.value;
    }
    
    if (slider.value < 0) {
        text.classList.add('bg-danger');
        text.innerHTML = "&minus;" + (-slider.value);
    }
    
    if (slider.value == 0) {
        text.innerHTML = "&empty;";
    }
}

function voteSubmit(event) {
    event.preventDefault();

    if (!event.target.checkValidity()) {
        event.target.classList.add('was-validated');
        return false;
    }

    var sliders = qa("input[type=range]");
    var votes = [];
    for (var i = 0; i < sliders.length; i++) {
        votes.push([sliders[i].id.replace(/\D/g, ''), sliders[i].value]);
    };

    document.vote({
        title: qi('title') ? qi('title').value : '',
        name: qi('name').value,
        votes: votes
    });
};

function update_title_input(link) {
    qi('title').value = link.innerHTML;
};

/**
* Facebook sdk
*/

window.fbAsyncInit = function() {
    FB.init({
        appId: (debug ? '1159337948166597' : '543950855954497'),
        cookie: false,
        xfbml: true,
        version: 'v13.0'
    });
};

function statusChangeCallback(response) {
    if (response.status === 'connected') {
        // Logged into your app and Facebook.
        document.fb_login(response.authResponse.accessToken);
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

/**
* Google Analytics
*/

(function(e,t,n,i,s,a,c){e[n]=e[n]||function(){(e[n].q=e[n].q||[]).push(arguments)}
;a=t.createElement(i);c=t.getElementsByTagName(i)[0];a.async=true;a.src=s
;c.parentNode.insertBefore(a,c)
})(window,document,"galite","script","https://cdn.jsdelivr.net/npm/ga-lite@2/dist/ga-lite.min.js");

if (document.location.hostname !== 'localhost') {
    galite('create', 'UA-111273395-1', 'auto');
    galite('send', 'pageview');
}
