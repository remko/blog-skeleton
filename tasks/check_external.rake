CLEAN.include(["linkchecker.out"])

desc "Check external links" \
	"Make sure the local server is running"
task :check_external do
	target="http://localhost:3000"
	sh "linkchecker --no-warnings -F csv/utf-8/linkchecker.out " \
		"--ignore-url='#{target}/postwic' " \
		"--no-follow-url='#{target}/blog/tag' " \
		"--no-follow-url='#{target}/blog/category' " \
		"--ignore-url='#{target}/blog/tag/c\\+\\+' " \
		"--ignore-url='#{target}/blog/tag/tuts\\+' " \
		"--ignore-url=^xmpp: " \
		"--ignore-url='images/wordpress\\.png' " \
		"--ignore-url='https://www.google.com/accounts' " \
		"--ignore-url='http://(blog\\.)?dave.cridland.net' " \
		"--ignore-url='http://jaiku\\.com' " \
		"--ignore-url='http://(.*)\\.?psi-im.org' " \
		"--ignore-url='http://alek\\.silverstone\\.name' " \
		"--ignore-url='http://gislan\\.utumno.pl' " \
		"--ignore-url='http://debaday\\.debian\\.net' " \
		"--ignore-url='http://msn-transport\\.jabberstudio\\.org' " \
		"--ignore-url='http://mailman.jabber.org/pipermail/jdev/2006-February/023173.html' " \
		"#{target}"
end
