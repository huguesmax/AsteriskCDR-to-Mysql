#!/usr/bin/env perl

# Programme qui permet de recupérer les CDR perdus pour des problèmes de bases de données
# et de les ré insérer dans la table CDR
# Pour chaque appel asterisk crée un iniqueid, je check si cet uniqueid est présent ou pas
# avant d'inserer l'appel ajouter un index
# Il faut penser a indexer la table cdr

# ALTER TABLE `asterisk`.`cdr` ADD INDEX `idx_uniqid` (`uniqueid`); 
# installer le module  cpanm Text::CSV_XS ou yum -y install perl-Text-CSV_XS
#
use strict;
use DBI;                        # Connexion a Mysql
use Text::CSV_XS;               # Module d'import du CSV

my $host          = "127.0.0.1";  
my $login         = "asterisk";
my $dbname        = "asterisk";
my $password      = "xxxx";
my $MasterFile    = "/var/log/asterisk/cdr-csv/Master.csv";
my $total         = 0;
my $ok            = 0;
my $perdu         = 0;


my $conn          = DBI->connect("DBI:mysql:dbname=$dbname;host=$host", $login, $password) || die $DBI::errstr;
print "# Connected to: localhost -->base : $dbname\n";

#une ligne du fichier CSV Master.csv
#0          '',
#1          '0033332538293',
#2          '0492943333',
#3          'tx11',
#4         '"Moi" <0033332538298>',
#5           'SIP/tx11-00000011',
#6          'SIP/ovh-00000012',
#7          'Dial',
#8           'sip/0433944480@ovh,90,HCT',
#9           '2016-01-06 11:05:31',
#10           '',
#11           '2016-01-06 11:06:00',
#12           '29',
#13           '0',
#14          'BUSY',
#15           'DOCUMENTATION',
#16           '1452078331.26',
#17           ''

my @rows;
my $csv = Text::CSV_XS->new ({ binary => 1, auto_diag => 1 });
open my $fh, "<:encoding(utf8)", $MasterFile or die "$MasterFile: $!";

	while (my $row = $csv->getline ($fh)) {
		push @rows, $row;
		$total++;
	}
close $fh;

#je parcours le tableau

	foreach my $line (@rows) {

		#check si uniquid est présent
		if ( check($line->[16]) ) {

			$ok++;

		} else {
			print "Appel perdu ou absent: $line->[9]\t $line->[16] absent de la base de donnees\n";
			$perdu++;
			print "calldate   = $line->[9]\n";
			print "clid       = $line->[4]\n";
			print "src        = $line->[1]\n";
			print "dst        = $line->[2]\n";
			print "dcontext   = $line->[3]\n";
			print "channel    = $line->[5]\n";
			print "dstchannel = $line->[6]\n";
			print "lastapp    = $line->[7]\n";
			print "lastdata   = $line->[8]\n";
			print "duration   = $line->[12]\n";
			print "billesec   = $line->[13]\n";
			print "disposition= $line->[14]\n";
			print "uniqueid   = $line->[16]\n";
			print "#############################\n";
			print "\n";

		my $sql="INSERT INTO cdr ( calldate,clid,src,dst,dcontext,channel,dstchannel,lastapp,lastdata,duration,billsec,disposition,uniqueid ) 
		 		   values ( ?,?,?,?,?,?,?,?,?,?,?,?,?)";

        	my $result = $conn->prepare($sql) || die "# Can't prepare mysql request $\n";
	           $result->execute( $line->[9],$line->[4],$line->[1],$line->[2],$line->[3],$line->[5],$line->[6],$line->[7],$line->[8],$line->[12],
				     $line->[13],$line->[14],$line->[16] ) || die("# Erreur I Can't execute mysql request on $result\n");

		$perdu++;

		}

	
	}

print "############## Fin Analyse #################\n\n";

print "CDR total: $total\n";
print "CDR ok   : $ok\n";
print "CDR lost: $perdu\n";




################################ sub ######################################################
sub check {
	my $uniqueid = shift;
	my $sql="SELECT uniqueid  FROM cdr WHERE uniqueid = '$uniqueid' limit 1";
    	my $result = $conn->prepare($sql)  || die "# Can't prepare mysql request $\n";
           $result->execute()            || die "# Can't execute mysql request on $result\n";
	my %line;
	$result->bind_columns( \( @line{ @{ $result->{NAME_lc} } } ) );
	my $present;

	while ( $result->fetch ) {

	        $present           = $line{'uniqueid'};

        }

	return $present
}
