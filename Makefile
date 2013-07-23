
DESTDIR = /usr/
POCOMPILER = msgfmt -c
POLANGS="$(ls ./po)"

install: installlang
	install -D -m755 ./ai-helper.sh $(DESTDIR)/bin/ai-helper.sh

installlang:
	for lang in $(POLANGS); do mkdir -p $(DESTDIR)/share/locale/${lang} 2> /dev/null; $(POCOMPILER) -o $(DESTDIR)/share/locale/${lang}/archinstall_helper.mo ./po/${lang}/archinstall_helper.po; done

uninstall: uninstalllang
	rm $(DESTDIR)/bin/ai-helper.sh

uninstalllang:
	for lang in $(POLANGS); do mkdir -p $(DESTDIR)/share/locale/${lang} 2> /dev/null; rm $(DESTDIR)/share/locale/${lang}/archinstall_helper.mo; done