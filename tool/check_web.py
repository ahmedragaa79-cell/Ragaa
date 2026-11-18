"""Smoke-test the compiled release and real browser preferences (no seeded data).

Requires Python 3, Playwright, Chrome, and `flutter build web` output.
The HTTP server and browser profile are temporary and local to the test.
"""

from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from shutil import which
from threading import Thread

from playwright.sync_api import expect, sync_playwright


class QuietHandler(SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass


def enable_screen_reader(page):
    # Flutter deliberately keeps this accessibility control just off screen.
    page.locator("flt-semantics-placeholder").first.dispatch_event("click")


def activate_choice(page, name):
    choice = page.get_by_label(name, exact=True).or_(page.get_by_text(name, exact=True)).first
    choice.click(force=True)


def main():
    root = Path(__file__).resolve().parents[1] / "build" / "web"
    if not (root / "main.dart.js").is_file():
        raise SystemExit("Build the Flutter web release first.")
    chrome = which("google-chrome") or which("chromium")
    if not chrome:
        raise SystemExit("Install Chrome or Chromium first.")
    with ThreadingHTTPServer(("127.0.0.1", 0), partial(QuietHandler, directory=root)) as server:
        Thread(target=server.serve_forever, daemon=True).start()
        try:
            with sync_playwright() as playwright:
                browser = playwright.chromium.launch(executable_path=chrome, args=["--enable-unsafe-swiftshader"])
                page = browser.new_page(locale="en-US", viewport={"width": 1320, "height": 880})
                page.set_default_timeout(25000)
                page.goto(f"http://127.0.0.1:{server.server_port}/#/settings")
                try:
                    enable_screen_reader(page)
                    activate_choice(page, "العربية")
                    expect(page).to_have_title("ستراتا")
                    activate_choice(page, "داكن")
                    # Wait for the plugin write, not just the optimistic repaint.
                    page.wait_for_function("""() => {
                        const value = localStorage.getItem('strata.preferences.v1');
                        if (!value) return false;
                        const decoded = JSON.parse(value);
                        const prefs = typeof decoded === 'string' ? JSON.parse(decoded) : decoded;
                        return prefs.locale === 'ar' && prefs.theme === 'dark';
                    }""")
                    page.reload()
                    expect(page).to_have_title("ستراتا")
                    enable_screen_reader(page)
                    activate_choice(page, "English")
                    expect(page).to_have_title("Strata")
                    assert page.url.endswith("/#/settings"), page.url
                    print("PASS: settings deep link, live language switch, real theme/locale storage, reload and switch back.")
                except Exception:
                    print(page.locator("body").aria_snapshot()[:4000])
                    raise
                finally:
                    browser.close()
        finally:
            server.shutdown()


if __name__ == "__main__":
    main()
