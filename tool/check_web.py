"""Drive the packaged release in real Chrome, using only a disposable profile."""

from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from os import environ
from pathlib import Path
from shutil import which
from tempfile import TemporaryDirectory
from threading import Thread

from playwright.sync_api import expect, sync_playwright


class QuietHandler(SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass


def enable_screen_reader(page):
    page.locator('flt-semantics-placeholder, flt-semantics').first.wait_for(state='attached')
    placeholder = page.locator('flt-semantics-placeholder')
    if placeholder.count():
        placeholder.first.dispatch_event('click')


def semantic(page, name):
    return page.get_by_label(name, exact=True).or_(page.get_by_text(name, exact=True)).first


def activate(page, name):
    semantic(page, name).click(force=True)


def enter(page, label, text):
    field = page.get_by_role('textbox', name=label, exact=True)
    field.click(force=True)
    expect(field).to_be_focused()
    field.fill(text)


def browser_store(page):
    return page.evaluate('''async () => {
      if ((await indexedDB.databases()).some(db => db.name === 'strata')) return 'IndexedDB: strata';
      const root = await navigator.storage.getDirectory();
      const drift = await root.getDirectoryHandle('drift_db');
      const db = await drift.getDirectoryHandle('strata');
      await db.getFileHandle('database');
      return 'OPFS: drift_db/strata/database';
    }''')


def passed(message):
    print('PASS: ' + message, flush=True)
    if environ.get('GITHUB_ACTIONS'):
        print('::notice title=Release browser check::' + message, flush=True)


def check_preferences(page, origin):
    page.goto(origin + '/#/settings')
    enable_screen_reader(page)
    activate(page, 'العربية')
    expect(page).to_have_title('ستراتا')
    activate(page, 'داكن')
    page.wait_for_function('''() => {
        const raw = localStorage.getItem('strata.preferences.v1');
        if (!raw) return false;
        const value = JSON.parse(raw), prefs = typeof value === 'string' ? JSON.parse(value) : value;
        return prefs.locale === 'ar' && prefs.theme === 'dark';
    }''')
    page.reload()
    expect(page).to_have_title('ستراتا')
    enable_screen_reader(page)
    activate(page, 'English')
    expect(page).to_have_title('Strata')
    assert page.url.endswith('/#/settings'), page.url
    passed('Settings deep link, live locale/theme, stored preferences and reload.')


def check_directory(page, origin):
    page.goto(origin + '/#/outlets')
    enable_screen_reader(page)
    expect(semantic(page, 'No outlets yet')).to_be_visible(timeout=30000)
    activate(page, 'Add outlet')
    enter(page, 'Outlet code', 'QA-17')
    enter(page, 'Outlet name', 'Browser persistence check')
    activate(page, 'Save outlet')
    expect(semantic(page, 'QA-17')).to_be_visible()
    stored = browser_store(page)
    page.reload()
    enable_screen_reader(page)
    expect(semantic(page, 'QA-17')).to_be_visible(timeout=30000)
    expect(semantic(page, 'Browser persistence check')).to_be_visible()
    page.wait_for_function('navigator.serviceWorker.controller?.scriptURL.endsWith("/strata-sw.js")', timeout=60000)
    passed('UI write, real ' + stored + ', refresh and reopened row.')


def main():
    root = Path(__file__).resolve().parents[1] / 'build' / 'web'
    if not (root / 'strata-sw.js').is_file():
        raise SystemExit('Build the web release and run tool/prepare_offline_web.py first.')
    chrome = which('google-chrome') or which('chromium')
    if not chrome:
        raise SystemExit('Install Chrome or Chromium first.')
    with ThreadingHTTPServer(('127.0.0.1', 0), partial(QuietHandler, directory=root)) as server, TemporaryDirectory(prefix='strata-chrome-') as profile:
        Thread(target=server.serve_forever, daemon=True).start()
        origin = f'http://127.0.0.1:{server.server_port}'
        try:
            with sync_playwright() as playwright:
                def launch():
                    return playwright.chromium.launch_persistent_context(profile, executable_path=chrome,
                        args=['--enable-unsafe-swiftshader'], locale='en-US', viewport={'width': 1320, 'height': 880})
                for restart in (False, True):
                    context = launch()
                    page = context.new_page()
                    page.set_default_timeout(25000)
                    try:
                        if not restart:
                            check_preferences(page, origin)
                            check_directory(page, origin)
                        else:
                            # No running app/worker from the first process, and no network.
                            context.set_offline(True)
                            page.goto(origin + '/#/outlets')
                            enable_screen_reader(page)
                            expect(semantic(page, 'Browser persistence check')).to_be_visible(timeout=30000)
                            activate(page, 'Edit outlet')
                            enter(page, 'Outlet name', 'Saved while offline')
                            activate(page, 'Save outlet')
                            expect(semantic(page, 'Saved while offline')).to_be_visible()
                            page.reload()
                            enable_screen_reader(page)
                            expect(semantic(page, 'Saved while offline')).to_be_visible(timeout=30000)
                            passed('Chrome process restart, offline launch, offline edit and offline reload.')
                    except Exception:
                        print(page.locator('body').aria_snapshot()[:4500], flush=True)
                        raise
                    finally:
                        context.close()
        finally:
            server.shutdown()


if __name__ == '__main__':
    main()
