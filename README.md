# Asterisk-Master.csv-To-Mysql
Perl script to read Asterisk CDR from Master.csv and push to Mysql

yum -y install perl-Text-CSV_XS perl-DBI

1) Créer une base asterisk

2) Créer un table cdr ( login asterisk / pwd asterisk )

mysql asterisk -u asterisk -pasterisk < cdr.sql

CREATE TABLE `cdr` (
  `calldate` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `clid` varchar(80) NOT NULL DEFAULT '',
  `src` varchar(80) NOT NULL DEFAULT '',
  `dst` varchar(80) NOT NULL DEFAULT '',
  `dcontext` varchar(80) NOT NULL DEFAULT '',
  `channel` varchar(80) NOT NULL DEFAULT '',
  `dstchannel` varchar(80) NOT NULL DEFAULT '',
  `lastapp` varchar(80) NOT NULL DEFAULT '',
  `lastdata` varchar(80) NOT NULL DEFAULT '',
  `duration` int(11) NOT NULL DEFAULT '0',
  `billsec` int(11) NOT NULL DEFAULT '0',
  `disposition` varchar(45) NOT NULL DEFAULT '',
  `amaflags` int(11) NOT NULL DEFAULT '0',
  `accountcode` varchar(20) NOT NULL DEFAULT '',
  `uniqueid` varchar(32) NOT NULL DEFAULT '',
  `userfield` varchar(255) NOT NULL DEFAULT '',
  KEY `calldate` (`calldate`),
  KEY `dst` (`dst`),
  KEY `accountcode` (`accountcode`),
  KEY `lastdata` (`lastdata`),
  KEY `idx_uniqid` (`uniqueid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8


3) Editer le programme import_Master_to_Mysql.pl pour mettre le login/pwd de votre choix

4) ./import_Master_to_Mysql.pl


