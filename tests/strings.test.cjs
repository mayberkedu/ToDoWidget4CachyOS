const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');

const strings = vm.createContext({});
vm.runInContext(fs.readFileSync(path.join(__dirname, '../package/contents/code/Strings.js'), 'utf8')
    .replace(/^\.pragma library\s*/, ''), strings);

test('English is the default and fallback; Turkish translations are available', () => {
    for (const source of Object.keys(strings.turkish)) {
        assert.equal(strings.text(undefined, source), source);
        assert.equal(strings.text('en', source), source);
        assert.equal(strings.text('unknown', source), source);
        assert.equal(strings.text('tr', source), strings.turkish[source]);
        assert.ok(strings.text('tr', source).length > 0);
    }
    assert.equal(strings.text('tr', 'New untranslated string'), 'New untranslated string');
    assert.equal(strings.localeName('tr'), 'tr_TR');
    assert.equal(strings.localeName('en'), 'en_US');
    assert.equal(strings.localeName('unknown'), 'en_US');
});

test('placeholders are replaced without changing user text or literal percentages', () => {
    assert.equal(strings.text('en', '%1 tasks remaining', [3]), '3 tasks remaining');
    assert.equal(strings.text('tr', '%1 tasks remaining', [3]), '3 görev kaldı');
    assert.equal(strings.text('tr', 'Task options: %1', ['Do %2']), 'Görev seçenekleri: Do %2');
    assert.equal(strings.text('en', '0% neutral glass, 100% your chosen color.'),
        '0% neutral glass, 100% your chosen color.');
});
