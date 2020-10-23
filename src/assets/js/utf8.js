try { module.exports = {dec:utf8_dec,enc:utf8_toByteArray}; } catch (e) { }

// N2O UTF-8 Support

function utf8_toByteArray(str) {
    var byteArray = [];
    if (str !== undefined && str !== null)
        byteArray = (new TextEncoder("utf-8")).encode(str);

    return {t:107,v:byteArray}; };

function utf8_dec(ab) { return (new TextDecoder()).decode(ab); }
