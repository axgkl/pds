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
from pathlib import Path

testmode = [0]
user = os.environ.get('USER', 'user')
fn_from_lua = '/tmp/smartopen'  # never change, it's in utils lua!
fn_last_from_lua = '/tmp/smartopen_last_expression_from_lua'
fn_log = f'/tmp/smartopen.{user}.log'
sep = ':-:'
browser = os.environ.get('BROWSER', 'microsoft-edge')
exists = os.path.exists


def log(s):
    msg = '\ncwd: %s; %s\n' % (os.getcwd(), s)
    if sys.stdout and sys.stdout.isatty():
        print(msg)
    open(fn_log, 'a').write(msg)


def clean(s):
    for k in '"', "'", '`', '\\':
        s = s.replace(k, '')
    return s


def notify(title, msg=''):
    cmd = '''notify-send -t 10 "%s" "%s\n\n%s\nHelp: ,g on '?' or 'help'" 2>/dev/null &'''
    os.system(cmd % (clean(title), clean(msg), __file__))


# '/etc/hosts'
os.unlink(fn_log) if exists(fn_log) else 0


def exit(*a):
    send_exit('')  # otherwise line problems in vim


def pth_join(dir, fn): return str(Path(dir).joinpath(Path(fn)))


def browse(lnk):
    while lnk[0] == '*':
        lnk = lnk[1:]
    while lnk[-1] == '*':
        lnk = lnk[:-1]
    return os.system(
        '%s "%s" >/dev/null 2>/dev/null &' % (browser, lnk))


class TestEnd(Exception):
    pass


def send_exit(fn_or_vim_cmd):
    """vim opens fn now if present else run vim.cmd:"""
    log('sending back: %s' % fn_or_vim_cmd)
    with open(fn_from_lua, 'w') as fd:
        fd.write(fn_or_vim_cmd)
    if testmode[0]:
        raise TestEnd
    else:
        sys.exit(0)


def set_dir(m):
    log('got: %s' % str(m))
    if not exists(m['fn']) and "://" not in m["fn"]:
        # may not exist, e.g. in packer plugins overlay, with urls we want to ,g on:
        m['dir'] = os.environ['HOME']
        # exit(notify('bug: file does not exist: %s' % m['fn']))
    else:
        m['dir'] = os.path.abspath(os.path.dirname(m['fn']))


def rm_spam_chars_in_word(m):
    w, l = m['word'], m['line']
    w = ''.join([c for c in w if c not in {"'", '"'}])
    wc = ''.join([c for c in w if c not in ''.join(brkts_and_apos)])

    if w and w[0] == '[' and "]" not in w:
        w = w + l.split(w, 1)[1].split(')', 1)[0] + ')'
    m['word'] = w
    m['clean_word'] = wc
    log('parsed %s' % m)


def tilde_is_home_dir(m):
    m['word'] = m['word'].replace('~', os.environ['HOME'])


def try_(f, **m):
    k = '\n'.join(['- %s: %s' % (k, v) for k, v in m.items()])
    k = '\n%s\n' % k
    # notify(f.__name__, k)
    try:
        f(**m)
    except TestEnd:
        raise
    except Exception:
        pass
        # notify('Exception', str(ex))


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
def is_markdown_dragshot_req(word, fn, dn=os.path.dirname, **_):
    """
    In e.g. a markdown file write "shot:img/foo.png", then `,g` on it. Will:
    - ask you for a screenshot area via scrot
    - creates the file img/foo.png at the right place
    - substitute in vim with a markdown link to it
    """
    if not word.startswith('shot:'):
        return
    tofn = fni = word.split('shot:', 1)[1]
    if not fni.endswith('.png'):
        fni += '.png'
    if not tofn.startswith('/'):
        fni = os.path.abspath(dn(fn) + '/' + fni)
    os.makedirs(dn(fni), exist_ok=True)
    cmd = f'scrot --freeze -s "{fni}"'
    if os.system(cmd):
        notify('drag shot', 'aborted')
        exit(1)
    notify('scrot', f'created {fni}')
    w = tofn.replace('/', '\\/').replace('.', '\\.')
    send_exit(f'%s/shot:{w}/![]({w})/g')


def on_empty_in_md_file_do_mkdocs_serve(word, fn, **_):
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


def is_help(word, **_):
    if word == 'help' or word == '?':
        send_exit(__file__)


def is_man_page(word, fn, **_):
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

    # [foo]: http://... ?
    line = kw['line']
    if word and word[0]+word[-2:] == '[]:' and line.startswith(word + ' '):
        line = line[len(word)+1:]
        if line.startswith('http') and not ' ' in line.strip():
            exit(browse(line.strip()))

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

    pth = pth_join(dir, lnk)
    if exists(pth):
        if pth.rsplit('.', 1)[-1].lower() in {'png', 'svg', 'jpeg', 'gif', 'jpg'}:
            exit(browse(pth))
        send_exit(pth)
    if exists(pth+'.md'):
        send_exit(pth+'.md')

    if not lnk.endswith('.md'):
        exit(browse(title + lnk))

    if not exists(pth):
        touch_new_md_file(pth, title)

    send_exit(pth)


def is_absolute_path(clean_word, word, **kw):
    [send_exit(w) for w in {clean_word, word} if exists(w)]


def is_relative_path(clean_word, dir, fn, first=True, **kw):
    f = pth_join(dir, clean_word)
    if exists(f):
        send_exit(f)
    d = dir + '/docs'
    if clean_word.endswith('.md'):
        k = pth_join(d, clean_word)
        if first and fn.endswith('mkdocs.yml') and not exists(k):
            touch_new_md_file(k, clean_word)

        if exists(d):
            try_(is_relative_path, **dict(dir=d, word=clean_word, fn=fn, first=False))


# check for an lcdoc lp line:
def st(l, s): return l.startswith(s)


def is_lp(l):
    return (st(l, '```') and ' lp ' in l) or (st(l, '`') and ' lp:' in l)


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
    # see [doc1]
    for k in brkts_and_apos:
        word = word.replace(k, '')
        while k[0] in word:
            # log(k + s)
            word = word.split(k[0], 1)[1]
            word = word.split(k[1], 1)[0]
    m['word'] = word


def read_file(fn):
    if exists(fn):
        with open(fn) as fd:
            return fd.read()
    return ''


def url_github(word):
    return 'https://github.com/' + word


def url_search(word):
    return 'https://www.google.com/search?client=%s-b-d&q=' + word


def main():
    '''If an execution from vi did not work,
    simply call me w/o arguments in foreground, with breakpoints.
    We'll be running the last expression'''
    expression = read_file(fn_from_lua)
    if not sep in expression:
        expression = read_file(fn_last_from_lua)
    assert sep in expression
    with open(fn_last_from_lua, 'w') as fd:
        fd.write(expression)
    log('got string from lua:\n' + expression)
    os.unlink(fn_from_lua) if exists(fn_from_lua) else 0
    m = {'word': '', 'fn': '', 'line': ''}
    for k in m:
        m[k] = expression.split(''.join((sep, k, sep)), 1)[
            1].split(sep, 1)[0].strip()
    tilde_is_home_dir(m)
    set_dir(m)
    rm_spam_chars_in_word(m)
    try_(is_markdown_dragshot_req, **m)
    try_(on_empty_in_md_file_do_mkdocs_serve, **m)
    try_(is_man_page, **m)
    try_(is_help, **m)
    try_(is_markdown_link, **m)
    remove_brackets_around_word(m)
    try_(is_absolute_path, **m)
    try_(is_relative_path, **m)
    try_(is_lcdoc_lp_line, **m)

    # search the whole fckng directory tree:
    # try_fd(word)

    word = m['word']

    # Ok, no meaningful file match => look it up in the internet:
    if 'http' in word:
        word = 'http' + word.split('http', 1)[1]
    # special case foo/bar , e.g. in plugins. Then github:
    elif len(word.split('/')) == 2:
        word = url_github(word)
    else:
        o = word
        word = url_search(word)
        notify('Not found: %s' % o, 'Opening %s' % word)
    exit(browse(word))


def run_tests():
    testmode[0] = 1
    ossys, se = [], []
    sysexit = sys.exit
    os.system = lambda cmd: ossys.append(cmd)
    sys.exit = lambda ec=0: se.append(ec) or 1/0

    def write_fn(word, fn='/etc/hosts', line=None):
        if line is None:
            line = f'xx {word} xx'
        P = f':-:word:-:{word}:-:fn:-:{fn}:-:line:-:{line}:-:end:-:'
        print(P)
        with open(fn_from_lua, 'w') as fd:
            fd.write(P)
    nr = 0
    for ErrMsg, tests in Tests.items():
        for t in tests:
            err_msg = t[2] if len(t) == 3 else ErrMsg
            nr += 1
            print(f'[{nr}] {X1B}1;30;43m {t}{X1B}0m')
            ossys.clear() or se.clear()
            write_fn(*t[0])
            try:
                print('{X1B}2;37m')
                main()
            except TestEnd:
                print(f'{X1B}0m')
                if len(t[1]) > 1:
                    browse(t[1][1])
                    o = ossys
                    if o[-2] == o[-1] and browser in o[-1] and browser in o[-2]:
                        pass
                    else:
                        print('browser exception')
                        breakpoint()  # FIXME BREAKPOINT
                fn = t[1][0]
                if fn:
                    r = read_file(fn_from_lua)
                    if r != fn:
                        raise Exception(f'{err_msg}: {t}. Got: "{r}". Wanted "{fn}"')
                print(f'✔️ {t}')
                continue
            raise Exception(f'Did not exit {err_msg} {t}')

    sys.exit = sysexit


H = os.environ['HOME']
Tests = {
    # string: sets a new error message
    # [[word, optional fn, opt line], [fn_content, opt browse content]]
    'File path must be extracted': [
        [['/etc/hosts'], ['/etc/hosts']],
        [['some_func("/etc/hosts")'], ['/etc/hosts']],
        [["some_func('/etc/hosts')"], ['/etc/hosts']],
        [["some_func('''/etc/hosts''')"], ['/etc/hosts']],
        [['"~/.bashrc"'], [H + '/.bashrc']],
        [[f'"{H}/.bashrc"'], [H + '/.bashrc']]
    ],
    'Browser must open on word': [
        [['http://foo.bar'], ['', 'http://foo.bar']],
        [['foo'], ['', url_search('foo')]],
        [['/x/y/z'], ['', url_search('/x/y/z')], 'url open on non existing file'],
    ],
}


# because of a f*ck*ng treesitter bug with brackets, this breaks all indent:
# => keep them all at the end, incl. the comments(!) below, e.g. doc1
brkts_and_apos = "''", '""', '()', '[]', '{}'
X1B = '\x1b['


if __name__ == '__main__':
    if sys.argv[-1] == 'test':
        sys.exit(run_tests())
    try:
        main()
    except Exception as ex:
        log(f'exception: {ex}')
        send_exit(str(ex))

# doc1:     # resolves "[title](./file.md)": ( before [:
