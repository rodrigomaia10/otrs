# --
# bin/otrs.FileDBToFS.pl
# Copyright (C) 2019 Service Up, http://serviceup.com.br/
#

use strict;
use warnings;
use utf8;

use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin);
use lib dirname($RealBin) . '/Kernel/cpan-lib';
use lib dirname($RealBin) . '/Custom';

use File::Path qw();
use Kernel::System::ObjectManager;

local $Kernel::OM = Kernel::System::ObjectManager->new(
    'Kernel::System::Log' => {
        LogPrefix => 'OTRS-otrs.FileDBToFS.pl',
    },
);

# needed variables
my $TableAttachment = 'df_attachment';
my $FieldID = 0; # FieldID FileSystem dynamic field REQUERID!

# get needed objects
my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
my $DynamicFieldFileSystemValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldFileSystemValue');
my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

# try database
return if !$DBObject->Prepare(
    SQL => "SELECT article_id, filename, content, content_type FROM $TableAttachment WHERE deleted = 0",
);

my @Data;
while ( my @Row = $DBObject->FetchrowArray() ) {
	my %FileData = ();

	$FileData{ObjectID} 	= $Row[0];
	$FileData{Filename} 	= $Row[1];
	$FileData{Content}  	= $Row[2];
	$FileData{ContentType}  = $Row[3];
	
	push @Data, \%FileData;
}

for my $File ( @Data ){
	my $TicketNumber = $TicketObject->TicketNumberLookup(
        TicketID => $File->{ObjectID},
    );
	
	if($TicketNumber && $FieldID){
		my %FileContent = (
			Content 	=> $File->{Content},
			ContentType => $File->{ContentType},
			Filename 	=> $File->{Filename},
		);

		# write attachment content to fs
		my $Success = $DynamicFieldFileSystemValueObject->ValueSet(
			FieldID  	=> $FieldID,
			ObjectID 	=> $File->{ObjectID},
			FileContent => \%FileContent,
			UserID   	=> 1,
		);
		
		my $ObjectID = $File->{ObjectID};
		
		if($Success){
			return if !$DBObject->Do(
				SQL => "UPDATE $TableAttachment SET deleted = 1 WHERE article_id = ?",
				Bind => [\$ObjectID],
			);
			print "FileSystem add to $File->{ObjectID} \n";
		}		
	}
	else{
		print "ObjectID or FieldID invalid! \n";
	}
}