const assert = require('assert');

describe('podcasts', () => {
    it('should be streamable', () => {
        browser.url('/');
        $('.contact .btn').click();

        browser.url('/team');
        const menu = $('.header.menu .fa-bars');
        menu.waitForDisplayed();
        menu.click();
        $('a=Jobs').click();
        menu.waitForDisplayed();
        menu.click();
        $('a=Podcast').click();
        $('#mep_0 .mejs__controls').waitForDisplayed();
        $('#mep_0 .mejs__play button').click();
        $('span=00:05').waitForDisplayed();
    });
});
