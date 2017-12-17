try { module.exports = {dec:dec,enc:enc}; } catch (e) { }

// BERT Encoder

function uc(u1,u2) { if (u1.byteLength == 0) return u2; if (u2.byteLength == 0) return u1;
                     var a = new Uint8Array(u1.byteLength + u2.byteLength);
                     a.set(u1, 0); a.set(u2, u1.byteLength); return a; };
function ar(o)     { return o.v instanceof ArrayBuffer ? new Uint8Array(o.v) : o.v instanceof Uint8Array ? o.v :
                     Array.isArray(o.v) ? new Uint8Array(o.v) : new Uint8Array(utf8_toByteArray(o.v).v);}
function fl(a)     { return a.reduce(function(f,t){ return uc(f, t instanceof Uint8Array ? t :
                     Array.isArray(t) ? fl(t) : new Uint8Array([t]) ); }, new Uint8Array()); }
function atom(o)   { return {t:100,v:utf8_toByteArray(o).v}; }
function bin(o)    { return {t:109,v:o instanceof ArrayBuffer ? new Uint8Array(o) : o instanceof Uint8Array ? o : utf8_toByteArray(o).v}; }
function tuple()   { return {t:104,v:Array.apply(null,arguments)}; }
function list()    { return {t:108,v:Array.apply(null,arguments)}; }
function number(o) { return {t:98,v:o}; }
function enc(o)    { return fl([131,ein(o)]); }
function ein(o)    { return Array.isArray(o)?en_108({t:108,v:o}):eval('en_'+o.t)(o); }
function en_undefined(o) { return [106]; }
function en_98(o)  { return [98,o.v>>>24,(o.v>>>16)&255,(o.v>>>8)&255,o.v&255]; }
function en_97(o)  { return [97,o.v];}
function en_106(o) { return [106];}
function en_100(o) { return [100,o.v.length>>>8,o.v.length&255,ar(o)]; }
function en_107(o) { return [107,o.v.length>>>8,o.v.length&255,ar(o)];}
function en_104(o) { var l=o.v.length,r=[]; for(var i=0;i<l;i++)r[i]=ein(o.v[i]); return [104,l,r]; }
function en_109(o) { var l=o.v instanceof ArrayBuffer ? o.v.byteLength : o.v.length;
                     return[109,l>>>24,(l>>>16)&255,(l>>>8)&255,l&255,ar(o)]; }
function en_108(o) { var l=o.v.length,r=[]; for(var i=0;i<l;i++)r.push(ein(o.v[i]));
                     return o.v.length==0?[106]:[108,l>>>24,(l>>>16)&255,(l>>>8)&255,l&255,r,106]; }

// BERT Decoder

function nop(b) { return []; };
function big(b) { var sk=b==1?sx.getUint8(ix++):sx.getInt32((a=ix,ix+=4,a));
                  var ret=0, sig=sx.getUint8(ix++), count=sk;
                  while (count-->0) {
                    ret = 256 * ret + sx.getUint8(ix+count)
                  }
                  ix += sk;
                  return ret*(sig==0?1:-1);
                }
function int(b) { return b==1?sx.getUint8(ix++):sx.getInt32((a=ix,ix+=4,a)); };
function dec(d) { sx=new DataView(d);ix=0; if(sx.getUint8(ix++)!==131)throw("BERT?"); return din(); };
function str(b) { var dv,sz=(b==2?sx.getUint16(ix):sx.getInt32(ix));ix+=b;
                  var r=sx.buffer.slice(ix,ix+=sz); return b==2?utf8_dec(r):r; };
function run(b) { var sz=(b==1?sx.getUint8(ix):sx.getUint32(ix)),r=[]; ix+=b;
                  for(var i=0;i<sz;i++) r.push(din()); if(b==4)ix++; return r; };
function din()  { var c=sx.getUint8(ix++),x; switch(c) { case 97: x=[int,1];break;
                  case 98:  x=[int,4]; break; case 100: x=[str,2]; break;
                  case 110: x=[big,1]; break; case 111: x=[big,4]; break;
                  case 104: x=[run,1]; break; case 107: x=[str,2]; break;
                  case 108: x=[run,4]; break; case 109: x=[str,4]; break;
                  default:  x=[nop,0]; } return {t:c,v:x[0](x[1])};};


// JSON formatter

var $client = {};
$client.on = function onclient(evt, callback) {
    try {  msg = JSON.parse(evt.data);
           if (debug) console.log(JSON.stringify(msg));
           if (typeof callback == 'function' && msg) callback(msg);
           for (var i=0;i<$bert.protos.length;i++) {
                p = $bert.protos[i]; if (p.on(msg, p.do).status == "ok") return { status: "ok"}; }
    } catch (ex) { return { status: "error" }; }
    return { status: "ok" }; };

// Nitrogen Compatibility Layer

function querySourceRaw(Id) {
    var val, el = document.getElementById(Id);
    if (!el) return "";
    switch (el.tagName) {
        case 'FIELDSET': val = document.querySelector('[id="' + Id + '"] :checked');
                         val = val ? val.value : ""; break;
        case 'INPUT':
            switch (el.getAttribute("type")) {
                case 'radio': case 'checkbox': val = el.checked ? el.value : ""; break;
                case  'date': val = new Date(Date.parse(el.value)) || ""; break;
                case  'calendar': val = pickers[el.id]._d || ""; break;  //only 4 nitro #calendar{}
                default:     var edit = el.contentEditable;
                    if (edit && edit === 'true') val = el.innerHTML;
                    else val = el.value; }
            break;
        default: var edit = el.contentEditable;
            if (edit && edit === 'true') val = el.innerHTML;
            else val = el.value; }
    return val; }

function querySource(Id) {
    var qs = querySourceRaw(Id);
    if(qs instanceof Date) { return tuple(number(qs.getFullYear()),number(qs.getMonth()+1),number(qs.getDate())); }
    else { return utf8_toByteArray(qs); } }

(function() {
    window.requestAnimationFrame = window.requestAnimationFrame || window.mozRequestAnimationFrame ||
        window.webkitRequestAnimationFrame || window.msRequestAnimationFrame; })();


// WebSocket Transport

$ws = { heart: true, interval: 4000,
        creator: function(url) { return window.WebSocket ? new window.WebSocket(url) : false; },
        onheartbeat: function() { this.channel.send('PING'); } };

// N2O Reliable Connection

$conn = { onopen: nop, onmessage: nop, onclose: nop, onconnect: nop,
          send:  function(data)   { if (this.port.channel) this.port.channel.send(data); },
          close: function()       { if (this.port.channel) this.port.channel.close(); } };

ct = 0;
transports = [ $ws ];
heartbeat = null;
reconnectDelay = 1000;
maxReconnects = 100;

function nop() { }
function bullet(url) { $conn.url = url; return $conn; }
function xport() { return maxReconnects <= ct ? false : transports[ct++ % transports.length]; }
function reconnect() { setTimeout(function() { connect(); }, reconnectDelay); }
function next() { $conn.port = xport(); return $conn.port ? connect() : false; }
function connect() {
    $conn.port.channel = $conn.port.creator($conn.url);
    if (!$conn.port.channel) return next();
    $conn.port.channel.onmessage = function(e) { $conn.onmessage(e); };
    $conn.port.channel.onopen = function() {
        if ($conn.port.heart) heartbeat = setInterval(function(){$conn.port.onheartbeat();}, $conn.port.interval);
        $conn.onopen();
        $conn.onconnect(); };
    $conn.port.channel.onclose = function() { $conn.onclose(); clearInterval(heartbeat); reconnect(); };
    return $conn; }


// N2O CORE

var active      = false,
    debug       = false,
    session     = "site-sid",
    protocol    = window.location.protocol == 'https:' ? "wss://" : "ws://",
    querystring = window.location.pathname + window.location.search,
    host        = null == transition.host ? window.location.hostname : transition.host,
    port        = null == transition.port ? window.location.port : transition.port;

function N2O_start() {
    ws = new bullet(protocol + host + (port==""?"":":"+port) + "/ws" + querystring);
    ws.onmessage = function (evt) { // formatters loop
    for (var i=0;i<protos.length;i++) { p = protos[i]; if (p.on(evt, p.do).status == "ok") return; } };
    ws.onopen = function() { if (!active) { console.log('Connect'); ws.send('N2O,'+transition.pid); active=true; } };
    ws.onclose = function() { active = false; console.log('Disconnect'); }; next(); }

function qi(name) { return document.getElementById(name); }
function qs(name) { return document.querySelector(name);  }
function qn(name) { return document.createElement(name);  }
function is(x,num,name) { return x.t==106?false:(x.v.length === num && x.v[0].v === name); }
function co(name) { match=document.cookie.match(new RegExp(name+'=([^;]+)')); return match?match[1]:undefined; }

/// N2O Protocols

var $io = {}; $io.on = function onio(r, cb) { if (is(r,3,'io')) {
    try { eval(utf8_dec(r.v[1].v)); if (typeof cb == 'function') cb(r); return { status: "ok" }; }
    catch (e) { console.log(e); return { status: '' }; } } else return { status: '' }; }

var $file = {}; $file.on = function onfile(r, cb) { if (is(r,10,'ftp')) {
    if (typeof cb == 'function') cb(r); return { status: "ok" }; } else return { status: ''}; }

var $bin = {}; $bin.on = function onbin(r, cb) { if (is(r,2,'bin')) {
    if (typeof cb == 'function') cb(r); return { status: "ok" }; } else return { status: '' }; }

// BERT Formatter

var $bert = {}; $bert.protos = [$io,$bin,$file]; $bert.on = function onbert(evt, cb) {
    if (Blob.prototype.isPrototypeOf(evt.data) && (evt.data.length > 0 || evt.data.size > 0)) {
        var r = new FileReader();
        r.addEventListener("loadend", function() {
            try { erlang = dec(r.result);
                  if (debug) console.log(JSON.stringify(erlang));
                  if (typeof cb  == 'function') cb(erlang);
                  for (var i=0;i<$bert.protos.length;i++) {
                    p = $bert.protos[i]; if (p.on(erlang, p.do).status == "ok") return; }
            } catch (e) { console.log(e); } });
        r.readAsArrayBuffer(evt.data);
        return { status: "ok" }; } else return { status: "error", desc: "data" }; }

var  protos = [ $bert ];

try { module.exports = {dec:utf8_dec,enc:utf8_toByteArray}; } catch (e) { }

// N2O UTF-8 Support

function utf8_toByteArray(str) {
    var byteArray = [];
    if (str !== undefined && str !== null)
    for (var i = 0; i < str.length; i++)
        if (str.charCodeAt(i) <= 0x7F) byteArray.push(str.charCodeAt(i));
        else {
            var h = encodeURIComponent(str.charAt(i)).substr(1).split('%');
            for (var j = 0; j < h.length; j++) byteArray.push(parseInt(h[j], 16)); }
    return {t:107,v:byteArray}; };

function utf8_dec(ab) {
    if (!(ab instanceof ArrayBuffer)) ab = new Uint8Array(utf8_toByteArray(ab).v).buffer;
    var t=new DataView(ab),i=c=c1=c2=0,itoa=String.fromCharCode,s=[]; while (i<t.byteLength ) {
    c=t.getUint8(i); if (c<128) { s+=itoa(c); i++; } else
    if ((c>191) && (c<224)) { c2=t.getUint8(i+1); s+=itoa(((c&31)<<6)|(c2&63)); i+=2; }
    else { c2=t.getUint8(i+1); c3=t.getUint8(i+2); s+=itoa(((c&15)<<12)|((c2&63)<<6)|(c3&63));
    i+=3; } } return s; }


// N2O Validation

function validateSources(list) {
    return list.reduce(function(acc,x) {
        var event = new CustomEvent('validation');
            event.initCustomEvent('validation',true,true,querySourceRaw(x));
        var el = qi(x),
            listener = el && el.validation,
            res = !listener || listener && el.dispatchEvent(event);
        console.log(res);
        if (el) el.style.background = res ? '' : 'pink';
        return res && acc; },true); }

(function () {
   function CustomEvent ( event, params ) {
       params = params || { bubbles: false, cancelable: false, detail: undefined };
       var evt = document.createEvent( 'CustomEvent' );
       evt.initCustomEvent( event, params.bubbles, params.cancelable, params.detail );
       return evt;  };
  CustomEvent.prototype = window.Event.prototype;
  window.CustomEvent = CustomEvent; })();

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

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbImJlcnQuanMiLCJjbGllbnQuanMiLCJuaXRyb2dlbi5qcyIsImJ1bGxldC5qcyIsIm4yby5qcyIsInV0ZjguanMiLCJ2YWxpZGF0aW9uLmpzIiwiYXBwLmpzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiJBQUFBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQ3JEQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQ1pBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FDOUJBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUNsQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQ3BEQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQ3JCQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FDdEJBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBIiwiZmlsZSI6ImFwcC5qcyIsInNvdXJjZXNDb250ZW50IjpbInRyeSB7IG1vZHVsZS5leHBvcnRzID0ge2RlYzpkZWMsZW5jOmVuY307IH0gY2F0Y2ggKGUpIHsgfVxuXG4vLyBCRVJUIEVuY29kZXJcblxuZnVuY3Rpb24gdWModTEsdTIpIHsgaWYgKHUxLmJ5dGVMZW5ndGggPT0gMCkgcmV0dXJuIHUyOyBpZiAodTIuYnl0ZUxlbmd0aCA9PSAwKSByZXR1cm4gdTE7XG4gICAgICAgICAgICAgICAgICAgICB2YXIgYSA9IG5ldyBVaW50OEFycmF5KHUxLmJ5dGVMZW5ndGggKyB1Mi5ieXRlTGVuZ3RoKTtcbiAgICAgICAgICAgICAgICAgICAgIGEuc2V0KHUxLCAwKTsgYS5zZXQodTIsIHUxLmJ5dGVMZW5ndGgpOyByZXR1cm4gYTsgfTtcbmZ1bmN0aW9uIGFyKG8pICAgICB7IHJldHVybiBvLnYgaW5zdGFuY2VvZiBBcnJheUJ1ZmZlciA/IG5ldyBVaW50OEFycmF5KG8udikgOiBvLnYgaW5zdGFuY2VvZiBVaW50OEFycmF5ID8gby52IDpcbiAgICAgICAgICAgICAgICAgICAgIEFycmF5LmlzQXJyYXkoby52KSA/IG5ldyBVaW50OEFycmF5KG8udikgOiBuZXcgVWludDhBcnJheSh1dGY4X3RvQnl0ZUFycmF5KG8udikudik7fVxuZnVuY3Rpb24gZmwoYSkgICAgIHsgcmV0dXJuIGEucmVkdWNlKGZ1bmN0aW9uKGYsdCl7IHJldHVybiB1YyhmLCB0IGluc3RhbmNlb2YgVWludDhBcnJheSA/IHQgOlxuICAgICAgICAgICAgICAgICAgICAgQXJyYXkuaXNBcnJheSh0KSA/IGZsKHQpIDogbmV3IFVpbnQ4QXJyYXkoW3RdKSApOyB9LCBuZXcgVWludDhBcnJheSgpKTsgfVxuZnVuY3Rpb24gYXRvbShvKSAgIHsgcmV0dXJuIHt0OjEwMCx2OnV0ZjhfdG9CeXRlQXJyYXkobykudn07IH1cbmZ1bmN0aW9uIGJpbihvKSAgICB7IHJldHVybiB7dDoxMDksdjpvIGluc3RhbmNlb2YgQXJyYXlCdWZmZXIgPyBuZXcgVWludDhBcnJheShvKSA6IG8gaW5zdGFuY2VvZiBVaW50OEFycmF5ID8gbyA6IHV0ZjhfdG9CeXRlQXJyYXkobykudn07IH1cbmZ1bmN0aW9uIHR1cGxlKCkgICB7IHJldHVybiB7dDoxMDQsdjpBcnJheS5hcHBseShudWxsLGFyZ3VtZW50cyl9OyB9XG5mdW5jdGlvbiBsaXN0KCkgICAgeyByZXR1cm4ge3Q6MTA4LHY6QXJyYXkuYXBwbHkobnVsbCxhcmd1bWVudHMpfTsgfVxuZnVuY3Rpb24gbnVtYmVyKG8pIHsgcmV0dXJuIHt0Ojk4LHY6b307IH1cbmZ1bmN0aW9uIGVuYyhvKSAgICB7IHJldHVybiBmbChbMTMxLGVpbihvKV0pOyB9XG5mdW5jdGlvbiBlaW4obykgICAgeyByZXR1cm4gQXJyYXkuaXNBcnJheShvKT9lbl8xMDgoe3Q6MTA4LHY6b30pOmV2YWwoJ2VuXycrby50KShvKTsgfVxuZnVuY3Rpb24gZW5fdW5kZWZpbmVkKG8pIHsgcmV0dXJuIFsxMDZdOyB9XG5mdW5jdGlvbiBlbl85OChvKSAgeyByZXR1cm4gWzk4LG8udj4+PjI0LChvLnY+Pj4xNikmMjU1LChvLnY+Pj44KSYyNTUsby52JjI1NV07IH1cbmZ1bmN0aW9uIGVuXzk3KG8pICB7IHJldHVybiBbOTcsby52XTt9XG5mdW5jdGlvbiBlbl8xMDYobykgeyByZXR1cm4gWzEwNl07fVxuZnVuY3Rpb24gZW5fMTAwKG8pIHsgcmV0dXJuIFsxMDAsby52Lmxlbmd0aD4+Pjgsby52Lmxlbmd0aCYyNTUsYXIobyldOyB9XG5mdW5jdGlvbiBlbl8xMDcobykgeyByZXR1cm4gWzEwNyxvLnYubGVuZ3RoPj4+OCxvLnYubGVuZ3RoJjI1NSxhcihvKV07fVxuZnVuY3Rpb24gZW5fMTA0KG8pIHsgdmFyIGw9by52Lmxlbmd0aCxyPVtdOyBmb3IodmFyIGk9MDtpPGw7aSsrKXJbaV09ZWluKG8udltpXSk7IHJldHVybiBbMTA0LGwscl07IH1cbmZ1bmN0aW9uIGVuXzEwOShvKSB7IHZhciBsPW8udiBpbnN0YW5jZW9mIEFycmF5QnVmZmVyID8gby52LmJ5dGVMZW5ndGggOiBvLnYubGVuZ3RoO1xuICAgICAgICAgICAgICAgICAgICAgcmV0dXJuWzEwOSxsPj4+MjQsKGw+Pj4xNikmMjU1LChsPj4+OCkmMjU1LGwmMjU1LGFyKG8pXTsgfVxuZnVuY3Rpb24gZW5fMTA4KG8pIHsgdmFyIGw9by52Lmxlbmd0aCxyPVtdOyBmb3IodmFyIGk9MDtpPGw7aSsrKXIucHVzaChlaW4oby52W2ldKSk7XG4gICAgICAgICAgICAgICAgICAgICByZXR1cm4gby52Lmxlbmd0aD09MD9bMTA2XTpbMTA4LGw+Pj4yNCwobD4+PjE2KSYyNTUsKGw+Pj44KSYyNTUsbCYyNTUsciwxMDZdOyB9XG5cbi8vIEJFUlQgRGVjb2RlclxuXG5mdW5jdGlvbiBub3AoYikgeyByZXR1cm4gW107IH07XG5mdW5jdGlvbiBiaWcoYikgeyB2YXIgc2s9Yj09MT9zeC5nZXRVaW50OChpeCsrKTpzeC5nZXRJbnQzMigoYT1peCxpeCs9NCxhKSk7XG4gICAgICAgICAgICAgICAgICB2YXIgcmV0PTAsIHNpZz1zeC5nZXRVaW50OChpeCsrKSwgY291bnQ9c2s7XG4gICAgICAgICAgICAgICAgICB3aGlsZSAoY291bnQtLT4wKSB7XG4gICAgICAgICAgICAgICAgICAgIHJldCA9IDI1NiAqIHJldCArIHN4LmdldFVpbnQ4KGl4K2NvdW50KVxuICAgICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICAgICAgaXggKz0gc2s7XG4gICAgICAgICAgICAgICAgICByZXR1cm4gcmV0KihzaWc9PTA/MTotMSk7XG4gICAgICAgICAgICAgICAgfVxuZnVuY3Rpb24gaW50KGIpIHsgcmV0dXJuIGI9PTE/c3guZ2V0VWludDgoaXgrKyk6c3guZ2V0SW50MzIoKGE9aXgsaXgrPTQsYSkpOyB9O1xuZnVuY3Rpb24gZGVjKGQpIHsgc3g9bmV3IERhdGFWaWV3KGQpO2l4PTA7IGlmKHN4LmdldFVpbnQ4KGl4KyspIT09MTMxKXRocm93KFwiQkVSVD9cIik7IHJldHVybiBkaW4oKTsgfTtcbmZ1bmN0aW9uIHN0cihiKSB7IHZhciBkdixzej0oYj09Mj9zeC5nZXRVaW50MTYoaXgpOnN4LmdldEludDMyKGl4KSk7aXgrPWI7XG4gICAgICAgICAgICAgICAgICB2YXIgcj1zeC5idWZmZXIuc2xpY2UoaXgsaXgrPXN6KTsgcmV0dXJuIGI9PTI/dXRmOF9kZWMocik6cjsgfTtcbmZ1bmN0aW9uIHJ1bihiKSB7IHZhciBzej0oYj09MT9zeC5nZXRVaW50OChpeCk6c3guZ2V0VWludDMyKGl4KSkscj1bXTsgaXgrPWI7XG4gICAgICAgICAgICAgICAgICBmb3IodmFyIGk9MDtpPHN6O2krKykgci5wdXNoKGRpbigpKTsgaWYoYj09NClpeCsrOyByZXR1cm4gcjsgfTtcbmZ1bmN0aW9uIGRpbigpICB7IHZhciBjPXN4LmdldFVpbnQ4KGl4KyspLHg7IHN3aXRjaChjKSB7IGNhc2UgOTc6IHg9W2ludCwxXTticmVhaztcbiAgICAgICAgICAgICAgICAgIGNhc2UgOTg6ICB4PVtpbnQsNF07IGJyZWFrOyBjYXNlIDEwMDogeD1bc3RyLDJdOyBicmVhaztcbiAgICAgICAgICAgICAgICAgIGNhc2UgMTEwOiB4PVtiaWcsMV07IGJyZWFrOyBjYXNlIDExMTogeD1bYmlnLDRdOyBicmVhaztcbiAgICAgICAgICAgICAgICAgIGNhc2UgMTA0OiB4PVtydW4sMV07IGJyZWFrOyBjYXNlIDEwNzogeD1bc3RyLDJdOyBicmVhaztcbiAgICAgICAgICAgICAgICAgIGNhc2UgMTA4OiB4PVtydW4sNF07IGJyZWFrOyBjYXNlIDEwOTogeD1bc3RyLDRdOyBicmVhaztcbiAgICAgICAgICAgICAgICAgIGRlZmF1bHQ6ICB4PVtub3AsMF07IH0gcmV0dXJuIHt0OmMsdjp4WzBdKHhbMV0pfTt9O1xuIiwiXG4vLyBKU09OIGZvcm1hdHRlclxuXG52YXIgJGNsaWVudCA9IHt9O1xuJGNsaWVudC5vbiA9IGZ1bmN0aW9uIG9uY2xpZW50KGV2dCwgY2FsbGJhY2spIHtcbiAgICB0cnkgeyAgbXNnID0gSlNPTi5wYXJzZShldnQuZGF0YSk7XG4gICAgICAgICAgIGlmIChkZWJ1ZykgY29uc29sZS5sb2coSlNPTi5zdHJpbmdpZnkobXNnKSk7XG4gICAgICAgICAgIGlmICh0eXBlb2YgY2FsbGJhY2sgPT0gJ2Z1bmN0aW9uJyAmJiBtc2cpIGNhbGxiYWNrKG1zZyk7XG4gICAgICAgICAgIGZvciAodmFyIGk9MDtpPCRiZXJ0LnByb3Rvcy5sZW5ndGg7aSsrKSB7XG4gICAgICAgICAgICAgICAgcCA9ICRiZXJ0LnByb3Rvc1tpXTsgaWYgKHAub24obXNnLCBwLmRvKS5zdGF0dXMgPT0gXCJva1wiKSByZXR1cm4geyBzdGF0dXM6IFwib2tcIn07IH1cbiAgICB9IGNhdGNoIChleCkgeyByZXR1cm4geyBzdGF0dXM6IFwiZXJyb3JcIiB9OyB9XG4gICAgcmV0dXJuIHsgc3RhdHVzOiBcIm9rXCIgfTsgfTtcbiIsIi8vIE5pdHJvZ2VuIENvbXBhdGliaWxpdHkgTGF5ZXJcblxuZnVuY3Rpb24gcXVlcnlTb3VyY2VSYXcoSWQpIHtcbiAgICB2YXIgdmFsLCBlbCA9IGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKElkKTtcbiAgICBpZiAoIWVsKSByZXR1cm4gXCJcIjtcbiAgICBzd2l0Y2ggKGVsLnRhZ05hbWUpIHtcbiAgICAgICAgY2FzZSAnRklFTERTRVQnOiB2YWwgPSBkb2N1bWVudC5xdWVyeVNlbGVjdG9yKCdbaWQ9XCInICsgSWQgKyAnXCJdIDpjaGVja2VkJyk7XG4gICAgICAgICAgICAgICAgICAgICAgICAgdmFsID0gdmFsID8gdmFsLnZhbHVlIDogXCJcIjsgYnJlYWs7XG4gICAgICAgIGNhc2UgJ0lOUFVUJzpcbiAgICAgICAgICAgIHN3aXRjaCAoZWwuZ2V0QXR0cmlidXRlKFwidHlwZVwiKSkge1xuICAgICAgICAgICAgICAgIGNhc2UgJ3JhZGlvJzogY2FzZSAnY2hlY2tib3gnOiB2YWwgPSBlbC5jaGVja2VkID8gZWwudmFsdWUgOiBcIlwiOyBicmVhaztcbiAgICAgICAgICAgICAgICBjYXNlICAnZGF0ZSc6IHZhbCA9IG5ldyBEYXRlKERhdGUucGFyc2UoZWwudmFsdWUpKSB8fCBcIlwiOyBicmVhaztcbiAgICAgICAgICAgICAgICBjYXNlICAnY2FsZW5kYXInOiB2YWwgPSBwaWNrZXJzW2VsLmlkXS5fZCB8fCBcIlwiOyBicmVhazsgIC8vb25seSA0IG5pdHJvICNjYWxlbmRhcnt9XG4gICAgICAgICAgICAgICAgZGVmYXVsdDogICAgIHZhciBlZGl0ID0gZWwuY29udGVudEVkaXRhYmxlO1xuICAgICAgICAgICAgICAgICAgICBpZiAoZWRpdCAmJiBlZGl0ID09PSAndHJ1ZScpIHZhbCA9IGVsLmlubmVySFRNTDtcbiAgICAgICAgICAgICAgICAgICAgZWxzZSB2YWwgPSBlbC52YWx1ZTsgfVxuICAgICAgICAgICAgYnJlYWs7XG4gICAgICAgIGRlZmF1bHQ6IHZhciBlZGl0ID0gZWwuY29udGVudEVkaXRhYmxlO1xuICAgICAgICAgICAgaWYgKGVkaXQgJiYgZWRpdCA9PT0gJ3RydWUnKSB2YWwgPSBlbC5pbm5lckhUTUw7XG4gICAgICAgICAgICBlbHNlIHZhbCA9IGVsLnZhbHVlOyB9XG4gICAgcmV0dXJuIHZhbDsgfVxuXG5mdW5jdGlvbiBxdWVyeVNvdXJjZShJZCkge1xuICAgIHZhciBxcyA9IHF1ZXJ5U291cmNlUmF3KElkKTtcbiAgICBpZihxcyBpbnN0YW5jZW9mIERhdGUpIHsgcmV0dXJuIHR1cGxlKG51bWJlcihxcy5nZXRGdWxsWWVhcigpKSxudW1iZXIocXMuZ2V0TW9udGgoKSsxKSxudW1iZXIocXMuZ2V0RGF0ZSgpKSk7IH1cbiAgICBlbHNlIHsgcmV0dXJuIHV0ZjhfdG9CeXRlQXJyYXkocXMpOyB9IH1cblxuKGZ1bmN0aW9uKCkge1xuICAgIHdpbmRvdy5yZXF1ZXN0QW5pbWF0aW9uRnJhbWUgPSB3aW5kb3cucmVxdWVzdEFuaW1hdGlvbkZyYW1lIHx8IHdpbmRvdy5tb3pSZXF1ZXN0QW5pbWF0aW9uRnJhbWUgfHxcbiAgICAgICAgd2luZG93LndlYmtpdFJlcXVlc3RBbmltYXRpb25GcmFtZSB8fCB3aW5kb3cubXNSZXF1ZXN0QW5pbWF0aW9uRnJhbWU7IH0pKCk7XG4iLCJcbi8vIFdlYlNvY2tldCBUcmFuc3BvcnRcblxuJHdzID0geyBoZWFydDogdHJ1ZSwgaW50ZXJ2YWw6IDQwMDAsXG4gICAgICAgIGNyZWF0b3I6IGZ1bmN0aW9uKHVybCkgeyByZXR1cm4gd2luZG93LldlYlNvY2tldCA/IG5ldyB3aW5kb3cuV2ViU29ja2V0KHVybCkgOiBmYWxzZTsgfSxcbiAgICAgICAgb25oZWFydGJlYXQ6IGZ1bmN0aW9uKCkgeyB0aGlzLmNoYW5uZWwuc2VuZCgnUElORycpOyB9IH07XG5cbi8vIE4yTyBSZWxpYWJsZSBDb25uZWN0aW9uXG5cbiRjb25uID0geyBvbm9wZW46IG5vcCwgb25tZXNzYWdlOiBub3AsIG9uY2xvc2U6IG5vcCwgb25jb25uZWN0OiBub3AsXG4gICAgICAgICAgc2VuZDogIGZ1bmN0aW9uKGRhdGEpICAgeyBpZiAodGhpcy5wb3J0LmNoYW5uZWwpIHRoaXMucG9ydC5jaGFubmVsLnNlbmQoZGF0YSk7IH0sXG4gICAgICAgICAgY2xvc2U6IGZ1bmN0aW9uKCkgICAgICAgeyBpZiAodGhpcy5wb3J0LmNoYW5uZWwpIHRoaXMucG9ydC5jaGFubmVsLmNsb3NlKCk7IH0gfTtcblxuY3QgPSAwO1xudHJhbnNwb3J0cyA9IFsgJHdzIF07XG5oZWFydGJlYXQgPSBudWxsO1xucmVjb25uZWN0RGVsYXkgPSAxMDAwO1xubWF4UmVjb25uZWN0cyA9IDEwMDtcblxuZnVuY3Rpb24gbm9wKCkgeyB9XG5mdW5jdGlvbiBidWxsZXQodXJsKSB7ICRjb25uLnVybCA9IHVybDsgcmV0dXJuICRjb25uOyB9XG5mdW5jdGlvbiB4cG9ydCgpIHsgcmV0dXJuIG1heFJlY29ubmVjdHMgPD0gY3QgPyBmYWxzZSA6IHRyYW5zcG9ydHNbY3QrKyAlIHRyYW5zcG9ydHMubGVuZ3RoXTsgfVxuZnVuY3Rpb24gcmVjb25uZWN0KCkgeyBzZXRUaW1lb3V0KGZ1bmN0aW9uKCkgeyBjb25uZWN0KCk7IH0sIHJlY29ubmVjdERlbGF5KTsgfVxuZnVuY3Rpb24gbmV4dCgpIHsgJGNvbm4ucG9ydCA9IHhwb3J0KCk7IHJldHVybiAkY29ubi5wb3J0ID8gY29ubmVjdCgpIDogZmFsc2U7IH1cbmZ1bmN0aW9uIGNvbm5lY3QoKSB7XG4gICAgJGNvbm4ucG9ydC5jaGFubmVsID0gJGNvbm4ucG9ydC5jcmVhdG9yKCRjb25uLnVybCk7XG4gICAgaWYgKCEkY29ubi5wb3J0LmNoYW5uZWwpIHJldHVybiBuZXh0KCk7XG4gICAgJGNvbm4ucG9ydC5jaGFubmVsLm9ubWVzc2FnZSA9IGZ1bmN0aW9uKGUpIHsgJGNvbm4ub25tZXNzYWdlKGUpOyB9O1xuICAgICRjb25uLnBvcnQuY2hhbm5lbC5vbm9wZW4gPSBmdW5jdGlvbigpIHtcbiAgICAgICAgaWYgKCRjb25uLnBvcnQuaGVhcnQpIGhlYXJ0YmVhdCA9IHNldEludGVydmFsKGZ1bmN0aW9uKCl7JGNvbm4ucG9ydC5vbmhlYXJ0YmVhdCgpO30sICRjb25uLnBvcnQuaW50ZXJ2YWwpO1xuICAgICAgICAkY29ubi5vbm9wZW4oKTtcbiAgICAgICAgJGNvbm4ub25jb25uZWN0KCk7IH07XG4gICAgJGNvbm4ucG9ydC5jaGFubmVsLm9uY2xvc2UgPSBmdW5jdGlvbigpIHsgJGNvbm4ub25jbG9zZSgpOyBjbGVhckludGVydmFsKGhlYXJ0YmVhdCk7IHJlY29ubmVjdCgpOyB9O1xuICAgIHJldHVybiAkY29ubjsgfVxuIiwiXG4vLyBOMk8gQ09SRVxuXG52YXIgYWN0aXZlICAgICAgPSBmYWxzZSxcbiAgICBkZWJ1ZyAgICAgICA9IGZhbHNlLFxuICAgIHNlc3Npb24gICAgID0gXCJzaXRlLXNpZFwiLFxuICAgIHByb3RvY29sICAgID0gd2luZG93LmxvY2F0aW9uLnByb3RvY29sID09ICdodHRwczonID8gXCJ3c3M6Ly9cIiA6IFwid3M6Ly9cIixcbiAgICBxdWVyeXN0cmluZyA9IHdpbmRvdy5sb2NhdGlvbi5wYXRobmFtZSArIHdpbmRvdy5sb2NhdGlvbi5zZWFyY2gsXG4gICAgaG9zdCAgICAgICAgPSBudWxsID09IHRyYW5zaXRpb24uaG9zdCA/IHdpbmRvdy5sb2NhdGlvbi5ob3N0bmFtZSA6IHRyYW5zaXRpb24uaG9zdCxcbiAgICBwb3J0ICAgICAgICA9IG51bGwgPT0gdHJhbnNpdGlvbi5wb3J0ID8gd2luZG93LmxvY2F0aW9uLnBvcnQgOiB0cmFuc2l0aW9uLnBvcnQ7XG5cbmZ1bmN0aW9uIE4yT19zdGFydCgpIHtcbiAgICB3cyA9IG5ldyBidWxsZXQocHJvdG9jb2wgKyBob3N0ICsgKHBvcnQ9PVwiXCI/XCJcIjpcIjpcIitwb3J0KSArIFwiL3dzXCIgKyBxdWVyeXN0cmluZyk7XG4gICAgd3Mub25tZXNzYWdlID0gZnVuY3Rpb24gKGV2dCkgeyAvLyBmb3JtYXR0ZXJzIGxvb3BcbiAgICBmb3IgKHZhciBpPTA7aTxwcm90b3MubGVuZ3RoO2krKykgeyBwID0gcHJvdG9zW2ldOyBpZiAocC5vbihldnQsIHAuZG8pLnN0YXR1cyA9PSBcIm9rXCIpIHJldHVybjsgfSB9O1xuICAgIHdzLm9ub3BlbiA9IGZ1bmN0aW9uKCkgeyBpZiAoIWFjdGl2ZSkgeyBjb25zb2xlLmxvZygnQ29ubmVjdCcpOyB3cy5zZW5kKCdOMk8sJyt0cmFuc2l0aW9uLnBpZCk7IGFjdGl2ZT10cnVlOyB9IH07XG4gICAgd3Mub25jbG9zZSA9IGZ1bmN0aW9uKCkgeyBhY3RpdmUgPSBmYWxzZTsgY29uc29sZS5sb2coJ0Rpc2Nvbm5lY3QnKTsgfTsgbmV4dCgpOyB9XG5cbmZ1bmN0aW9uIHFpKG5hbWUpIHsgcmV0dXJuIGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKG5hbWUpOyB9XG5mdW5jdGlvbiBxcyhuYW1lKSB7IHJldHVybiBkb2N1bWVudC5xdWVyeVNlbGVjdG9yKG5hbWUpOyAgfVxuZnVuY3Rpb24gcW4obmFtZSkgeyByZXR1cm4gZG9jdW1lbnQuY3JlYXRlRWxlbWVudChuYW1lKTsgIH1cbmZ1bmN0aW9uIGlzKHgsbnVtLG5hbWUpIHsgcmV0dXJuIHgudD09MTA2P2ZhbHNlOih4LnYubGVuZ3RoID09PSBudW0gJiYgeC52WzBdLnYgPT09IG5hbWUpOyB9XG5mdW5jdGlvbiBjbyhuYW1lKSB7IG1hdGNoPWRvY3VtZW50LmNvb2tpZS5tYXRjaChuZXcgUmVnRXhwKG5hbWUrJz0oW147XSspJykpOyByZXR1cm4gbWF0Y2g/bWF0Y2hbMV06dW5kZWZpbmVkOyB9XG5cbi8vLyBOMk8gUHJvdG9jb2xzXG5cbnZhciAkaW8gPSB7fTsgJGlvLm9uID0gZnVuY3Rpb24gb25pbyhyLCBjYikgeyBpZiAoaXMociwzLCdpbycpKSB7XG4gICAgdHJ5IHsgZXZhbCh1dGY4X2RlYyhyLnZbMV0udikpOyBpZiAodHlwZW9mIGNiID09ICdmdW5jdGlvbicpIGNiKHIpOyByZXR1cm4geyBzdGF0dXM6IFwib2tcIiB9OyB9XG4gICAgY2F0Y2ggKGUpIHsgY29uc29sZS5sb2coZSk7IHJldHVybiB7IHN0YXR1czogJycgfTsgfSB9IGVsc2UgcmV0dXJuIHsgc3RhdHVzOiAnJyB9OyB9XG5cbnZhciAkZmlsZSA9IHt9OyAkZmlsZS5vbiA9IGZ1bmN0aW9uIG9uZmlsZShyLCBjYikgeyBpZiAoaXMociwxMCwnZnRwJykpIHtcbiAgICBpZiAodHlwZW9mIGNiID09ICdmdW5jdGlvbicpIGNiKHIpOyByZXR1cm4geyBzdGF0dXM6IFwib2tcIiB9OyB9IGVsc2UgcmV0dXJuIHsgc3RhdHVzOiAnJ307IH1cblxudmFyICRiaW4gPSB7fTsgJGJpbi5vbiA9IGZ1bmN0aW9uIG9uYmluKHIsIGNiKSB7IGlmIChpcyhyLDIsJ2JpbicpKSB7XG4gICAgaWYgKHR5cGVvZiBjYiA9PSAnZnVuY3Rpb24nKSBjYihyKTsgcmV0dXJuIHsgc3RhdHVzOiBcIm9rXCIgfTsgfSBlbHNlIHJldHVybiB7IHN0YXR1czogJycgfTsgfVxuXG4vLyBCRVJUIEZvcm1hdHRlclxuXG52YXIgJGJlcnQgPSB7fTsgJGJlcnQucHJvdG9zID0gWyRpbywkYmluLCRmaWxlXTsgJGJlcnQub24gPSBmdW5jdGlvbiBvbmJlcnQoZXZ0LCBjYikge1xuICAgIGlmIChCbG9iLnByb3RvdHlwZS5pc1Byb3RvdHlwZU9mKGV2dC5kYXRhKSAmJiAoZXZ0LmRhdGEubGVuZ3RoID4gMCB8fCBldnQuZGF0YS5zaXplID4gMCkpIHtcbiAgICAgICAgdmFyIHIgPSBuZXcgRmlsZVJlYWRlcigpO1xuICAgICAgICByLmFkZEV2ZW50TGlzdGVuZXIoXCJsb2FkZW5kXCIsIGZ1bmN0aW9uKCkge1xuICAgICAgICAgICAgdHJ5IHsgZXJsYW5nID0gZGVjKHIucmVzdWx0KTtcbiAgICAgICAgICAgICAgICAgIGlmIChkZWJ1ZykgY29uc29sZS5sb2coSlNPTi5zdHJpbmdpZnkoZXJsYW5nKSk7XG4gICAgICAgICAgICAgICAgICBpZiAodHlwZW9mIGNiICA9PSAnZnVuY3Rpb24nKSBjYihlcmxhbmcpO1xuICAgICAgICAgICAgICAgICAgZm9yICh2YXIgaT0wO2k8JGJlcnQucHJvdG9zLmxlbmd0aDtpKyspIHtcbiAgICAgICAgICAgICAgICAgICAgcCA9ICRiZXJ0LnByb3Rvc1tpXTsgaWYgKHAub24oZXJsYW5nLCBwLmRvKS5zdGF0dXMgPT0gXCJva1wiKSByZXR1cm47IH1cbiAgICAgICAgICAgIH0gY2F0Y2ggKGUpIHsgY29uc29sZS5sb2coZSk7IH0gfSk7XG4gICAgICAgIHIucmVhZEFzQXJyYXlCdWZmZXIoZXZ0LmRhdGEpO1xuICAgICAgICByZXR1cm4geyBzdGF0dXM6IFwib2tcIiB9OyB9IGVsc2UgcmV0dXJuIHsgc3RhdHVzOiBcImVycm9yXCIsIGRlc2M6IFwiZGF0YVwiIH07IH1cblxudmFyICBwcm90b3MgPSBbICRiZXJ0IF07XG4iLCJ0cnkgeyBtb2R1bGUuZXhwb3J0cyA9IHtkZWM6dXRmOF9kZWMsZW5jOnV0ZjhfdG9CeXRlQXJyYXl9OyB9IGNhdGNoIChlKSB7IH1cblxuLy8gTjJPIFVURi04IFN1cHBvcnRcblxuZnVuY3Rpb24gdXRmOF90b0J5dGVBcnJheShzdHIpIHtcbiAgICB2YXIgYnl0ZUFycmF5ID0gW107XG4gICAgaWYgKHN0ciAhPT0gdW5kZWZpbmVkICYmIHN0ciAhPT0gbnVsbClcbiAgICBmb3IgKHZhciBpID0gMDsgaSA8IHN0ci5sZW5ndGg7IGkrKylcbiAgICAgICAgaWYgKHN0ci5jaGFyQ29kZUF0KGkpIDw9IDB4N0YpIGJ5dGVBcnJheS5wdXNoKHN0ci5jaGFyQ29kZUF0KGkpKTtcbiAgICAgICAgZWxzZSB7XG4gICAgICAgICAgICB2YXIgaCA9IGVuY29kZVVSSUNvbXBvbmVudChzdHIuY2hhckF0KGkpKS5zdWJzdHIoMSkuc3BsaXQoJyUnKTtcbiAgICAgICAgICAgIGZvciAodmFyIGogPSAwOyBqIDwgaC5sZW5ndGg7IGorKykgYnl0ZUFycmF5LnB1c2gocGFyc2VJbnQoaFtqXSwgMTYpKTsgfVxuICAgIHJldHVybiB7dDoxMDcsdjpieXRlQXJyYXl9OyB9O1xuXG5mdW5jdGlvbiB1dGY4X2RlYyhhYikge1xuICAgIGlmICghKGFiIGluc3RhbmNlb2YgQXJyYXlCdWZmZXIpKSBhYiA9IG5ldyBVaW50OEFycmF5KHV0ZjhfdG9CeXRlQXJyYXkoYWIpLnYpLmJ1ZmZlcjtcbiAgICB2YXIgdD1uZXcgRGF0YVZpZXcoYWIpLGk9Yz1jMT1jMj0wLGl0b2E9U3RyaW5nLmZyb21DaGFyQ29kZSxzPVtdOyB3aGlsZSAoaTx0LmJ5dGVMZW5ndGggKSB7XG4gICAgYz10LmdldFVpbnQ4KGkpOyBpZiAoYzwxMjgpIHsgcys9aXRvYShjKTsgaSsrOyB9IGVsc2VcbiAgICBpZiAoKGM+MTkxKSAmJiAoYzwyMjQpKSB7IGMyPXQuZ2V0VWludDgoaSsxKTsgcys9aXRvYSgoKGMmMzEpPDw2KXwoYzImNjMpKTsgaSs9MjsgfVxuICAgIGVsc2UgeyBjMj10LmdldFVpbnQ4KGkrMSk7IGMzPXQuZ2V0VWludDgoaSsyKTsgcys9aXRvYSgoKGMmMTUpPDwxMil8KChjMiY2Myk8PDYpfChjMyY2MykpO1xuICAgIGkrPTM7IH0gfSByZXR1cm4gczsgfVxuIiwiXG4vLyBOMk8gVmFsaWRhdGlvblxuXG5mdW5jdGlvbiB2YWxpZGF0ZVNvdXJjZXMobGlzdCkge1xuICAgIHJldHVybiBsaXN0LnJlZHVjZShmdW5jdGlvbihhY2MseCkge1xuICAgICAgICB2YXIgZXZlbnQgPSBuZXcgQ3VzdG9tRXZlbnQoJ3ZhbGlkYXRpb24nKTtcbiAgICAgICAgICAgIGV2ZW50LmluaXRDdXN0b21FdmVudCgndmFsaWRhdGlvbicsdHJ1ZSx0cnVlLHF1ZXJ5U291cmNlUmF3KHgpKTtcbiAgICAgICAgdmFyIGVsID0gcWkoeCksXG4gICAgICAgICAgICBsaXN0ZW5lciA9IGVsICYmIGVsLnZhbGlkYXRpb24sXG4gICAgICAgICAgICByZXMgPSAhbGlzdGVuZXIgfHwgbGlzdGVuZXIgJiYgZWwuZGlzcGF0Y2hFdmVudChldmVudCk7XG4gICAgICAgIGNvbnNvbGUubG9nKHJlcyk7XG4gICAgICAgIGlmIChlbCkgZWwuc3R5bGUuYmFja2dyb3VuZCA9IHJlcyA/ICcnIDogJ3BpbmsnO1xuICAgICAgICByZXR1cm4gcmVzICYmIGFjYzsgfSx0cnVlKTsgfVxuXG4oZnVuY3Rpb24gKCkge1xuICAgZnVuY3Rpb24gQ3VzdG9tRXZlbnQgKCBldmVudCwgcGFyYW1zICkge1xuICAgICAgIHBhcmFtcyA9IHBhcmFtcyB8fCB7IGJ1YmJsZXM6IGZhbHNlLCBjYW5jZWxhYmxlOiBmYWxzZSwgZGV0YWlsOiB1bmRlZmluZWQgfTtcbiAgICAgICB2YXIgZXZ0ID0gZG9jdW1lbnQuY3JlYXRlRXZlbnQoICdDdXN0b21FdmVudCcgKTtcbiAgICAgICBldnQuaW5pdEN1c3RvbUV2ZW50KCBldmVudCwgcGFyYW1zLmJ1YmJsZXMsIHBhcmFtcy5jYW5jZWxhYmxlLCBwYXJhbXMuZGV0YWlsICk7XG4gICAgICAgcmV0dXJuIGV2dDsgIH07XG4gIEN1c3RvbUV2ZW50LnByb3RvdHlwZSA9IHdpbmRvdy5FdmVudC5wcm90b3R5cGU7XG4gIHdpbmRvdy5DdXN0b21FdmVudCA9IEN1c3RvbUV2ZW50OyB9KSgpO1xuIiwicHJvdG9zID0gWyRjbGllbnQsJGJlcnRdOyBOMk9fc3RhcnQoKTtcblxuZnVuY3Rpb24gY2xvc2VIZWxwKCkge1xuICAgIHFpKCdoZWxwLWNhbGxvdXQnKS5zdHlsZS5kaXNwbGF5ID0gJ25vbmUnO1xufTtcblxuZnVuY3Rpb24gY2xlYXJBbHRGb3JtKCkge1xuICAgIHFpKCdhbHRfdGV4dCcpLnZhbHVlID0gJyc7XG4gICAgcWkoJ2FsdF92b3RlJykudmFsdWUgPSAnJztcbn07XG5cbmZ1bmN0aW9uIHZvdGVTdWJtaXQoKSB7XG4gICAgdmFyIHggPSBkb2N1bWVudC5xdWVyeVNlbGVjdG9yQWxsKFwiI2FsdHMgaW5wdXRbaWRePVxcXCJ2b3RlXFxcIl1cIik7XG4gICAgdmFyIHZvdGVzID0gW107XG4gICAgZm9yICh2YXIgaSA9IDA7IGkgPCB4Lmxlbmd0aDsgaSsrKSB7XG4gICAgICAgIHZvdGVzLnB1c2goW3hbaV0uaWQuc3Vic3RyaW5nKDQpLCB4W2ldLnZhbHVlXSk7XG4gICAgfTtcblxuICAgIHZvdGUoe1xuICAgICAgICB0aXRsZTogIHFpKCd0aXRsZScpID8gcWkoJ3RpdGxlJykudmFsdWUgOiAnJyxcbiAgICAgICAgbmFtZTogcWkoJ25hbWUnKS52YWx1ZSxcbiAgICAgICAgdm90ZXM6IHZvdGVzXG4gICAgfSk7XG4gICAgY29uc29sZS5sb2codm90ZXMpO1xuICAgIHJldHVybiBmYWxzZTtcbn07XG5cbi8vIFRoaXMgaXMgY2FsbGVkIHdpdGggdGhlIHJlc3VsdHMgZnJvbSBmcm9tIEZCLmdldExvZ2luU3RhdHVzKCkuXG5mdW5jdGlvbiBzdGF0dXNDaGFuZ2VDYWxsYmFjayhyZXNwb25zZSkge1xuICAgIGNvbnNvbGUubG9nKCdzdGF0dXNDaGFuZ2VDYWxsYmFjaycpO1xuICAgIGlmIChyZXNwb25zZS5zdGF0dXMgPT09ICdjb25uZWN0ZWQnKSB7XG4gICAgICAgIC8vIExvZ2dlZCBpbnRvIHlvdXIgYXBwIGFuZCBGYWNlYm9vay5cbiAgICAgICAgZmJfbG9naW4ocmVzcG9uc2UuYXV0aFJlc3BvbnNlLmFjY2Vzc1Rva2VuKTtcbiAgICB9IGVsc2UgaWYgKHJlc3BvbnNlLnN0YXR1cyA9PT0gJ25vdF9hdXRob3JpemVkJykge1xuICAgICAgICBhbGVydCgnUGxlYXNlIGxvZyBpbnRvIHRoaXMgYXBwLicpO1xuICAgIH0gZWxzZSB7XG4gICAgICAgIGFsZXJ0KCdQbGVhc2UgbG9nIGludG8gRmFjZWJvb2suJyk7XG4gICAgfVxufVxuXG5mdW5jdGlvbiBvbkxvZ2luQ2xpY2soKSB7XG4gICAgRkIubG9naW4oZnVuY3Rpb24ocmVzcG9uc2UpIHtcbiAgICAgICAgc3RhdHVzQ2hhbmdlQ2FsbGJhY2socmVzcG9uc2UpO1xuICAgIH0sIHtzY29wZTogJ3B1YmxpY19wcm9maWxlJ30pO1xufTtcbiJdLCJzb3VyY2VSb290IjoiL3NvdXJjZS8ifQ==
