const assert = require('assert');

describe('homepage', () => {
    it('should have the right title', () => {
        browser.url('/');
        $('.contact .btn').click();
    });
});
