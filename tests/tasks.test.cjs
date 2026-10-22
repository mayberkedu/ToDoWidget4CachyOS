const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');

const tasks = vm.createContext({ Date, Math });
const source = fs.readFileSync(path.join(__dirname, '../package/contents/code/Tasks.js'), 'utf8');
vm.runInContext(source.replace(/^\.pragma library\s*/, ''), tasks);
const plain = value => JSON.parse(JSON.stringify(value));

test('create, edit, complete, reopen and delete without mutating saved tasks', () => {
    const original = [];
    const added = tasks.save(original, '', '  Bir görev  ', '2026-10-22');
    assert.equal(original.length, 0);
    assert.equal(added[0].title, 'Bir görev');
    const id = added[0].id;
    const done = tasks.toggle(added, id);
    assert.equal(done[0].completed, true);
    assert.equal(added[0].completed, false);
    const edited = tasks.save(done, id, 'Yeni başlık', '');
    assert.deepEqual(plain(edited), [{ id, title: 'Yeni başlık', deadline: '', completed: true, priority: 'low' }]);
    assert.equal(tasks.toggle(edited, id)[0].completed, false);
    assert.equal(tasks.remove(edited, id).length, 0);
});

test('independent completion, filtering and clearing completed tasks', () => {
    let list = tasks.save([], '', 'Birinci', '');
    list = tasks.save(list, '', 'İkinci', '');
    assert.notEqual(list[0].id, list[1].id);
    list = tasks.toggle(list, list[0].id);
    assert.equal(list[1].completed, false);
    assert.equal(tasks.filtered(list, 'all').length, 2);
    assert.equal(tasks.filtered(list, 'active')[0].title, 'İkinci');
    assert.equal(tasks.filtered(list, 'done')[0].title, 'Birinci');
    assert.equal(tasks.clearCompleted(list)[0].title, 'İkinci');
});

test('task validation blocks blank titles, excessive length and invalid dates', () => {
    for (const title of ['', '   ', 'x'.repeat(241)])
        assert.throws(() => tasks.save([], '', title, ''));
    assert.throws(() => tasks.save([], '', 'Görev', '2026-02-29'));
    assert.throws(() => tasks.save([], '', 'Görev', undefined));
    assert.equal(tasks.save([], '', '<b>Plain text</b>', '')[0].title, '<b>Plain text</b>');
});

test('JSON round trip preserves Unicode, newlines and optional dates', () => {
    const list = tasks.save([], '', 'İşler: çığ, "kahve"\nikinci satır', '2028-02-29');
    const decoded = tasks.decode(JSON.stringify(list));
    assert.equal(decoded.error, '');
    assert.deepEqual(plain(decoded.tasks), plain(list));
    assert.equal(tasks.decode('[]').tasks.length, 0);
});

test('corrupt data and duplicate IDs block writes instead of silently resetting', () => {
    const valid = { id: 'a', title: 'Görev', deadline: '', completed: false };
    for (const raw of ['{', '{}', 'null', '[null]', JSON.stringify([valid, valid]),
        JSON.stringify([{ ...valid, completed: 'false' }]),
        JSON.stringify([{ ...valid, deadline: '2026-13-01' }])]) {
        const decoded = tasks.decode(raw);
        assert.equal(decoded.tasks.length, 0);
        assert.ok(decoded.error.length > 0);
    }
});

test('date-only comparisons handle leap days and local calendar boundaries', () => {
    assert.ok(tasks.parseDate('2028-02-29'));
    for (const value of ['2026-02-29', '2026-02-30', '2026-00-01', '2026-13-01', '2026-1-01', '0099-01-01'])
        assert.equal(tasks.parseDate(value), null);
    const now = new Date(2026, 11, 31, 23, 59);
    assert.equal(tasks.dateKey(now), '2026-12-31');
    assert.equal(tasks.deadlineLabel('2026-12-31', now), 'Today');
    assert.equal(tasks.deadlineLabel('2026-12-31', now, 'tr'), 'Bugün');
    assert.equal(tasks.deadlineLabel('2027-01-01', now), 'Tomorrow');
    assert.equal(tasks.deadlineLabel('2027-01-01', now, 'tr'), 'Yarın');
    assert.equal(tasks.deadlineLabel('2027-01-02', now), '2 Jan 2027');
    assert.equal(tasks.deadlineLabel('2027-01-02', now, 'tr'), '2 Oca 2027');
    assert.equal(tasks.priorityLabel('high'), 'High');
    assert.equal(tasks.priorityLabel('medium', 'tr'), 'Orta');
    assert.equal(tasks.priorityLabel('low', 'unknown'), 'Low');
    assert.equal(tasks.deadlineLabel('', now), '');
});


test('legacy tasks gain low priority without losing content or order', () => {
    const old = [{ id: 'a', title: 'Eski görev', deadline: '', completed: false }];
    const decoded = tasks.decode(JSON.stringify(old));
    assert.equal(decoded.error, '');
    assert.equal(decoded.tasks[0].priority, 'low');
    assert.equal(decoded.tasks[0].id, 'a');
});

test('priorities survive edits, completion and serialization', () => {
    let list = tasks.save([], '', 'Öncelikli', '', 'high');
    const id = list[0].id;
    list = tasks.toggle(list, id);
    list = tasks.save(list, id, 'Düzenlendi', '');
    assert.equal(list[0].priority, 'high');
    list = tasks.setPriority(list, id, 'medium');
    assert.equal(tasks.decode(JSON.stringify(list)).tasks[0].priority, 'medium');
    assert.throws(() => tasks.setPriority(list, id, 'invalid'));
    assert.throws(() => tasks.save([], '', 'Görev', '', 'invalid'));
});

test('moving tasks supports both directions and keeps all properties', () => {
    const list = ['a', 'b', 'c', 'd'].map((id, index) => ({
        id, title: id, deadline: '', completed: index === 1, priority: 'high'
    }));
    const moved = tasks.move(list, 'a', 'd');
    assert.deepEqual(plain(moved.map(task => task.id)), ['b', 'c', 'd', 'a']);
    assert.deepEqual(plain(tasks.move(moved, 'a', 'b')), list);
    assert.deepEqual(list.map(task => task.id), ['a', 'b', 'c', 'd']);
    assert.equal(tasks.move(list, 'missing', 'a'), list);
    assert.equal(tasks.move(list, 'a', 'a'), list);
    const filtered = tasks.filtered(list, 'active');
    const reordered = tasks.move(list, filtered[2].id, filtered[0].id);
    assert.deepEqual(plain(reordered.map(task => task.id)), ['d', 'a', 'b', 'c']);
    assert.equal(reordered.find(task => task.id === 'b').completed, true);
});
