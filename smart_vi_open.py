#!/usr/bin/env python
"""
triggered from vim, by ,g on a word

We try hard to find a matching file and bring it up in vim

Else we open in browser.
"""

import os
import re
import sys

# http://heise.de
from html import escape
from pathlib import Path

browser = os.environ.get('BROWSER', 'microsoft-edge')
exists = os.path.exists

log = lambda s: open(fn_log, 'a').write('\ncwd: %s; %s\n' % (os.getcwd(), s))

sep = ':-:'


def clean(s):
    for k in '"', "'", '`', '\\':
        s = s.replace(k, '')
    return s


def notify(title, msg=''):
    cmd = '''notify-send -t 10 "%s" "%s\n\n%s\nHelp: ,g on '?' or 'help'" &'''
    os.system(cmd % (clean(title), clean(msg), __file__))


# 'foo/bar'

fn_from_lua = '/tmp/smartopen'
fn_last_from_lua = '/tmp/last_smartopen_expression_from_lua'
fn_log = '/tmp/smartopen.log'
# '/etc/hosts'
os.unlink(fn_log) if exists(fn_log) else 0
exit = lambda *a: sys.exit(0)
pth_join = lambda dir, fn: str(Path(dir).joinpath(Path(fn)))


browse = lambda lnk: os.system('%s "%s" >/dev/null 2>/dev/null &' % (browser, lnk))


def send_exit(fn):
    """vim opens fn now:"""
    log('sending back: %s' % fn)
    with open(fn_from_lua, 'w') as fd:
        fd.write(fn)
    exit()


def validate_and_complete(m):
    if not exists(m['fn']) and not '://' in m['fn']:
        exit(notify('bug: file does not exist: %s' % m['fn']))
    log('parsed: %s' % str(m))
    m['dir'] = os.path.abspath(os.path.dirname(m['fn']))
    for spam in "'", '"':
        m['word'] = m['word'].replace(spam, '')


def try_(f, **m):
    k = '\n'.join(['- %s: %s' % (k, v) for k, v in m.items()])
    k = '\n%s\n' % k
    notify(f.__name__, k)
    try:
        f(**m)
    except Exception as ex:
        notify('Exception', str(ex))


def notify_help():
    notify('Not word selected - showing help')
    # bring up this file itself in vim
    send_exit(__file__)


def touch_new_md_file(fn, title):
    notify('Creating file', fn)
    os.makedirs(os.path.dirname(os.path.abspath(fn)), exist_ok=True)
    with open(fn, 'w') as fd:
        fd.write('# %s' % title)


# ----------------------------------------------------------------------------- checkers
def is_no_word_under_cursor_in_md_file_open_browser_in_ds(word, fn, **kw):
    if word:
        return
    if '/docs/' in fn and '/repos/' in fn and fn.endswith('.md'):
        # starts the mkdocs server and opens browser on the page
        notify('Calling opendocs (mkdocs serve)', msg=fn)
        cmd = '/home/gk/bin/opendocs "%s" --browser >/dev/null 2>/dev/null'
        os.system(cmd % fn)
    else:
        notify_help()
    exit()


def is_help(word, **kw):
    if word == 'help' or word == '?':
        send_exit(__file__)


def is_man_page(word, fn, **kw):
    '''are we viewing a manpage and we ,g over e.g. "touch(5)"'''
    if not fn.startswith('man://'):
        return
    w = word.split(')', 1)[0]
    try:
        i = int(w.split('(', 1)[1])
    except:
        return
    log('here .%s.' % w)
    log('there')
    cmd = "man '%s)'" % w
    log('is man page: %s' % cmd)
    os.system('st -e bash -c "%s" &' % cmd)
    exit()


def is_markdown_link(word, dir, **kw):
    # word = '[foo](bar.md)' ? then find or create it:
    # first [ missing from vim, when its like [**foo**](./bar.md):
    m = re.match(r'.*(.*\])(\(.*\)).*', word)
    if not m:
        return
    title = m.groups()[0][1:-1]
    lnk = m.groups()[1][1:-1]
    if '://' in lnk:
        exit(browse(lnk))

    if not lnk.strip():
        if title.strip():
            exit(browse(title))
        exit()
    # (./parameters.md#section)
    lnk = lnk.split('#', 1)[0]

    if lnk.endswith('/'):
        pth = pth_join(dir, lnk + 'index.md')
        if exists(pth):
            lnk += 'index.md'

    if not lnk.endswith('.md'):
        exit(browse(title + lnk))

    pth = pth_join(dir, lnk)
    if not exists(pth):
        touch_new_md_file(pth, title)

    send_exit(pth)


def is_absolute_path(word, **kw):
    if exists(word):
        send_exit(word)


def is_relative_path(word, dir, fn, first=True, **kw):
    f = pth_join(dir, word)
    if exists(f):
        send_exit(f)
    d = dir + '/docs'
    if word.endswith('.md'):
        k = pth_join(d, word)
        if first and fn.endswith('mkdocs.yml') and not exists(k):
            touch_new_md_file(k, word)

        if exists(d):
            try_(is_relative_path, **dict(dir=d, word=word, fn=fn, first=False))


# check for an lcdoc lp line:
st = lambda l, s: l.startswith(s)
is_lp = lambda l: (st(l, '```') and ' lp ' in l) or (st(l, '`') and ' lp:' in l)


def is_lcdoc_lp_line(word, dir, fn, line, **kw):
    """,g on an lp header opens the current lcdoc folder so that we can search for
    implementation"""
    if not fn.endswith('.md'):
        return
    if not is_lp(line):
        return
    try:
        import lcdoc

        d = os.path.abspath(lcdoc.__file__).rsplit('/', 1)[0]
        os.system('cd "%s" && nohup st 2>/dev/null &' % d)
        exit()
    except ImportError:
        return


# search everything:
# def is_fd(s):
#     if s.startswith('.'):
#         s = s.rsplit('/', 1)[-1]
#     cmd = 'fd --max-results=1 "%s$"' % s
#     log('got cmd: %s' % cmd)
#     fn = os.popen(cmd).read()
#     log('got fn: %s' % fn)
#     if exists(fn.strip()):
#         send_exit(fn)


def remove_brackets_around_word(m):
    word = m['word']
    # remove all brackets:
    # resolves "[title](./file.md)": ( before [:
    for k in "''", '""', '()', '[]', '{}':
        word = word.replace(k, '')
        while k[0] in word:
            # log(k + s)
            word = word.split(k[0], 1)[1]
            word = word.split(k[1], 1)[0]
    m['word'] = word


def main():
    with open(fn_from_lua) as fd:
        expression = fd.read().strip()
    # To debug: copy this to /tmp/smartopen and run __file__ in foreground to debug:
    with open(fn_last_from_lua, 'w') as fd:
        fd.write(expression)
    log('got string from lua:\n' + expression)
    # os.system('bash')
    os.unlink(fn_from_lua)
    m = {'word': '', 'fn': '', 'line': ''}
    for k in m:
        m[k] = expression.split(''.join((sep, k, sep)), 1)[1].split(sep, 1)[0].strip()
    validate_and_complete(m)
    try_(is_no_word_under_cursor_in_md_file_open_browser_in_ds, **m)
    try_(is_man_page, **m)
    try_(is_help, **m)
    try_(is_markdown_link, **m)
    try_(is_absolute_path, **m)
    try_(is_relative_path, **m)
    try_(is_lcdoc_lp_line, **m)

    remove_brackets_around_word(m)

    # search the whole fckng directory tree:
    # try_fd(word)

    word = m['word']

    # Ok, no meaningful file match => look it up in the internet:
    if 'http' in word:
        word = 'http' + word.split('http', 1)[1]
    # special case foo/bar , e.g. in plugins. Then github:
    elif len(word.split('/')) == 2:
        word = 'https://github.com/' + word
    else:
        o = word
        word = 'https://www.google.com/search?client=%s-b-d&q=' + word
        notify('Not found: %s' % o, 'Opening %s' % word)
    exit(browse(word))


if __name__ == '__main__':
    main()
