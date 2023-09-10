/**
 * Event helpers
 */
function onVoteClick(button) {
    var newValue = button.dataset.value;
    var input = button.parentNode.querySelector('input');
    if (input.value == newValue) {
      newValue = 0;
    }
    input.value = newValue;
    
    button.parentNode.querySelectorAll("button").forEach((btn) => {
        if (btn.dataset.value == newValue) {
          btn.classList.add('active');
        } else {
          btn.classList.remove('active');
        }   
    });
};

function voteSubmit(event) {
    event.preventDefault();

    if (!event.target.checkValidity()) {
        event.target.classList.add('was-validated');
        return false;
    }


    var sliders = qa("input[type=hidden]");
    var votes = [];
    sliders.forEach((slider) => {
        console.log(slider.dataset);
        if (slider.dataset.altId) {
            votes.push([slider.dataset.altId, slider.value]);
        }
    });

    var accessEl = qs('input[name="access"]:checked');

    document.vote({
        title: qi('title') ? qi('title').value : '',
        access: accessEl ? accessEl.value: '',
        name: qi('name').value,
        votes: votes
    });
};

function text_alert(input, value) {
    var text = input.value;
    input.value = value;
    setTimeout(function() {
        input.value = text;

        input.focus();
        input.select();
    }, 1000);
}

function copy_share() {
    var share_url = qi('share_url');
    navigator.clipboard.writeText(share_url.value).then(function() {
        text_alert(share_url, share_url.dataset.text);
    }, function(err) {
        text_alert(share_url, "ERROR");
    });
};

function update_title_input(link) {
    qi('title').value = link.innerHTML;
};

/**
 * Facebook sdk
 */

function fb_init() {
    if (window.FB) {
        return FB.XFBML.parse();
    }
    (function(d, s, id) {
        var js, fjs = d.getElementsByTagName(s)[0];
        if (d.getElementById(id)) {
            return;
        }
        js = d.createElement(s);
        js.id = id;
        js.src = "https://connect.facebook.net/en_US/sdk.js";
        fjs.parentNode.insertBefore(js, fjs);
    }(document, 'script', 'facebook-jssdk'));
}

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
 * counter.dev
 */
if (document.location.hostname !== 'localhost') {
    const script = document.createElement('script');
    script.async = true;
    script.dataset.id = "a3bfb50d-6a82-4c40-aab9-9a2527614c81";
    script.dataset.utcoffset = "3";
    script.src = "https://cdn.counter.dev/script.js";
    document.body.appendChild(script);
}
