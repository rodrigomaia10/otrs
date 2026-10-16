# --
# Kernel/Modules/FileSystemAttachment.pm - frontend module
# Copyright (C) 2019 Service Up, http://serviceup.com.br/
#
# written/edited by:
# * roliveira@beonup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::Modules::FileSystemAttachment;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

# Frontend modules are not handled by the ObjectManager.
our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless ($Self, $Type);

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get param object
	my $DynamicFieldFileSystemValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldFileSystemValue');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');

	# get needed params
    my $ObjectID            = $ParamObject->GetParam( Param => 'ObjectID' );
    my $FieldID             = $ParamObject->GetParam( Param => 'FieldID' );
	my $Filename            = $ParamObject->GetParam( Param => 'Filename' );
	my $AllFile             = $ParamObject->GetParam( Param => 'AllFile' );
	my $DistinctDirectories = $ParamObject->GetParam( Param => 'DistinctDirectories' );
	my $FieldPath           = $ParamObject->GetParam( Param => 'FieldPath' );
	my $Token          		= $ParamObject->GetParam( Param => 'Token' );

    # check params 
	if ( $Self->{Subaction} eq 'Delete' ){

		my $BaseAction 	 = $ParamObject->GetParam( Param => 'BaseAction' );
		my $TicketID   	 = $ParamObject->GetParam( Param => 'TicketID' );
        my $Url        	 = $ParamObject->GetParam( Param => 'Url' );
		my $TicketNumber = $ParamObject->GetParam( Param => 'TicketNumber');

		if ( !$BaseAction || ( !$TicketID && !$TicketNumber )) {
			$LogObject->Log(
				Message  => 'BaseAction and TicketID are needed!',
				Priority => 'error',
			);
			return $LayoutObject->ErrorScreen();
		}

		my $FileSystemValue = $DynamicFieldFileSystemValueObject->ValueDelete(
			ObjectID => $ObjectID,
			FieldID  => $FieldID,
			Filename => $Filename,
			UserID   => $Self->{UserID},
		);

		if ( $Token ) {
			
			# delete public key (token) of file_system_token table
			my $DeleteToken = $DynamicFieldFileSystemValueObject->DeleteToken(
				Token => $Token,
			);
		}

        # for process's urls
        if ( $Url eq 'Action=AgentTicketProcess' ) {

        	$LayoutObject->{RequestedURL} =~ /Action=AgentTicketProcess;Subaction=(.*)/;

            return $LayoutObject->Redirect( OP => "Action=$BaseAction;Subaction=".$1 );
        }
		elsif ( $Url eq 'Action=NewTicketProcess' ) {

        	$LayoutObject->{RequestedURL} =~ /Action=NewTicketProcess;Subaction=(.*)/;

            return $LayoutObject->Redirect( OP => "Action=$BaseAction;Subaction=".$1 );
        }
		else {
		
			if ( !$TicketNumber ) {

            	return $LayoutObject->Redirect( OP => "Action=$BaseAction;TicketID=$TicketID" );
			}
			else {
				return $LayoutObject->Redirect( OP => "Action=$BaseAction;TicketNumber=$TicketNumber" );
			}
        }
	}
    elsif ( $Self->{Subaction} eq 'Download' ) {

		my @ObjectIDs = split ',' , $ObjectID;

		# get a attachment
		my %Data;

		if ( $AllFile ) {

			my $MainObject = $Kernel::OM->Get('Kernel::System::Main');

			my $TicketNumber = $TicketObject->TicketNumberLookup(
				TicketID => $ObjectIDs[0],
			);			

			my $TempPath = '';
			my $NameFile = '';

			if( $TicketNumber ) {

				$TempPath = "/opt/znuny/var/tmp/DynamicFieldFileSystem/$FieldID-$TicketNumber/";
				$NameFile = "$FieldID-$TicketNumber.zip";
			}
			else {

				$TempPath = "/opt/znuny/var/tmp/DynamicFieldFileSystem/$FieldID-Article-$ObjectIDs[0]/";
				$NameFile = "$FieldID-Article-$ObjectIDs[0].zip";
			}

			# Check fs write permissions.
			# Generate a thread-safe article check directory.
			my ( $Seconds, $Microseconds ) = Time::HiRes::gettimeofday();
			my $PermissionCheckDirectory
				= "check_permissions_${$}_" . ( int rand 1_000_000_000 ) . "_${Seconds}_${Microseconds}";
			my $Path = "$TempPath" . $PermissionCheckDirectory;
			if ( File::Path::mkpath( $Path, 0, 0770 ) ) {    ## no critic
				rmdir $Path;
			}
			else {
				my $Error = $!;
				$Kernel::OM->Get('Kernel::System::Log')->Log(
					Priority => 'notice',
					Message  => "Can't create $Path: $Error, try: \$OTRS_HOME/bin/otrs.SetPermissions.pl!",
				);
				die "Can't create $Path: $Error, try: \$OTRS_HOME/bin/otrs.SetPermissions.pl!";
			}
			
			my $Content = '';
			
			# write attachment content to fs
			my $FileLocation = $MainObject->FileWrite(
				Directory => $TempPath,
				Filename  => "$NameFile",
				Content   => \$Content,
				Permission => 660
			);

			my $Zip = Archive::Zip->new();

			OBJECT:
			for my $ID ( @ObjectIDs ) {

				my %Ticket = $TicketObject->TicketGet(
					TicketID      => $ID,
					DynamicFields => 1,
					UserID        => $Self->{UserID}
				);

				my $Path = '';

				if ( $DistinctDirectories && $FieldPath  ) {
					
					my @Folders = split /\//, $Ticket{"DynamicField_$FieldPath"};

					$Path =  $Folders[ $#Folders - 1 ] . '/' . $Folders[ $#Folders ];

					$Zip->addDirectory( $Path );
				}

				my $FileData = $DynamicFieldFileSystemValueObject->ValueFileGet(
					ObjectID => $ID,
					FieldID  => $FieldID,
				);
				
				FILE:
				foreach my $File ( @{$FileData} ) {

					my $FileName = $DistinctDirectories && $FieldPath ? "$Path/$File->{Filename}" : $File->{Filename};
					$Zip->addString( $File->{Content}, $FileName );
				}
			}

			unless ( $Zip->writeToFileNamed( $TempPath . "$NameFile" ) == AZ_OK ) {
				die 'write error';
			}

			my $ContentType = 'application/zip';

			# write attachment content type to fs
			my $SuccessContentType = $MainObject->FileWrite(
				Directory  => $TempPath,
				Filename   => "$NameFile.content_type",
				Mode       => 'binmode',
				Content    => \$ContentType,
				Permission => 660,
			);
			return if !$SuccessContentType;

			# write attachment id
			my $SuccessFileName = $MainObject->FileWrite(
				Directory  => $TempPath,
				Filename   => "$NameFile.file_name",
				Mode       => 'binmode',
				Content    => \$NameFile,
				Permission => 660,
			);
			return if !$SuccessFileName;

			my @FileList = $MainObject->DirectoryRead(
				Directory => "$TempPath",
				Filter    => "*",
				Silent    => 1,
			);

			return if ( !IsArrayRefWithData(\@FileList) );

			FILENAME:
			for my $Filename (@FileList) {
				next FILENAME if $Filename =~ /\.content_type$/;
				next FILENAME if $Filename =~ /\.file_name$/;
				next FILENAME if $Filename =~ /\.file_id$/;

				my %FileContent = ();
				if ( -e "$Filename.content_type" ) {

					# read content type
					my $Content = $MainObject->FileRead(
						Location => "$Filename.content_type",
					);
					return if !$Content;
					$FileContent{ContentType} = ${$Content};

					# read file name
					my $Basename = $MainObject->FileRead(
						Location => "$Filename.file_name",
					);
					return if !$Basename;
					$FileContent{Filename} = ${$Basename};

					# read content
					$Content = $MainObject->FileRead(
						Location => $Filename,
						Mode     => 'binmode',
					);
					return if !$Content;
					$FileContent{Content} = ${$Content};

					# all others including attachments with content id that are not images
					# 	should NOT be inline
					$FileContent{Disposition} = 'attachment';
				}
				else {
					$Kernel::OM->Get('Kernel::System::Log')->Log(
						Priority => 'error',
						Message => "No file content_type!"
					);
					return;
				}

				chomp $FileContent{ContentType};

				# delete temporary file
				$Self->_DeleteTemporaryFiles(
					FilePath => $TempPath
				);

				return $LayoutObject->Attachment(%FileContent);
			}

		}
		else {

			my $FileData = $DynamicFieldFileSystemValueObject->ValueFileGet(
				ObjectID => $ObjectID,
				FieldID  => $FieldID,
			);

			FILE:
			foreach my $File ( @{$FileData} ) {

				my $FilenameID = "$File->{FileID}_$File->{Filename}";
				next FILE if $Filename ne $FilenameID;

				$Data{Content}     = $File->{Content};
				$Data{ContentType} = $File->{ContentType};
				$Data{Filename}    = $File->{Filename};
			}

			return $LayoutObject->Attachment(%Data);
		}
	}
}

sub _DeleteTemporaryFiles {
	my ( $Self, %Param ) = @_;

	return if ( !$Param{FilePath} );

	system( 'rm -rf ' . $Param{FilePath} );
}

1;
