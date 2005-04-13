#!/usr/bin/perl -w

use strict;

print <<'EOF';
<?xml version='1.0' ?>
<!ELEMENT section (title,expl?,compare?,section*)>
<!ELEMENT title (#PCDATA)>
<!ELEMENT expl (#PCDATA)>
EOF

print "<!ELEMENT compare (s+)>\n";
print "<!ELEMENT s (#PCDATA|a)*>\n";
print << 'EOF';
<!ELEMENT a (#PCDATA)>
<!ATTLIST section id ID #REQUIRED>
<!ATTLIST a href CDATA #REQUIRED>
<!ATTLIST s id CDATA #REQUIRED>
EOF

