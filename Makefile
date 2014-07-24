
DESTDIR = /usr
#POCOMPILER = msgfmt -c
#POLANGS=`ls ./po`

all: install

install: installlang
	install -D -m755 ./ai-helper.sh $(DESTDIR)/bin/ai-helper.sh; \
	sed -i -e "s|localfiles=\"\\\$$PWD/\\\$${langfileprefix}\"|localfiles=\"$(DESTDIR)/share/ai-helper\"|" $(DESTDIR)/bin/ai-helper.sh

installlang:
	install -dD -m755 ./lang $(DESTDIR)/share/ai-helper/lang

#	for lang in $(POLANGS); \
	do mkdir -p $(DESTDIR)/share/locale/$$lang/LC_MESSAGES 2> /dev/null; \
	$(POCOMPILER) -o $(DESTDIR)/share/locale/$$lang/LC_MESSAGES/archinstall_helper.mo ./po/$$lang/archinstall_.po; \
	done;


uninstall: uninstalllang
	rm $(DESTDIR)/bin/ai-helper.sh

uninstalllang:
	rm -r $(DESTDIR)/share/ai-helper

#	for lang in $(POLANGS); \
	do rm $(DESTDIR)/share/locale/$$lang/LC_MESSAGES/archinstall_helper.mo; \
	done
