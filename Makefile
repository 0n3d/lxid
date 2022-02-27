install-lib:
	mkdir -p /usr/share/lxid/lib/
	cp -r lib/* /usr/share/lxid/lib/

uninstall-lib:
	rm -r /usr/share/lxid
