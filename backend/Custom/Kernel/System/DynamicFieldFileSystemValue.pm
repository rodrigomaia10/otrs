# --
# Custom/Kernel/System/DynamicFieldFileSystemValue.pm
# Copyright (C) 2019 Service Up, http://serviceup.com.br/
# --
# written/edited by:
# * roliveira@beonup.com.br
# * dsilva@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::System::DynamicFieldFileSystemValue;

use strict;
use warnings;
use MIME::Base64;

use Kernel::System::VariableCheck qw(:all);
use File::Basename;
use Time::HiRes;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Cache',
    'Kernel::System::DB',
    'Kernel::System::Log',
    'Kernel::System::Valid',
    'Kernel::System::YAML',
    'Kernel::System::Time',
    'Kernel::System::Cache',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Encode',
);

=head1 NAME

Kernel::System::DynamicFieldFileSystemValue

=head1 SYNOPSIS

DynamicField values backend

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create a DynamicFieldFileSystemValue object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $DynamicFieldFileSystemValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldFileSystemValue');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{StorageCache} = 0;
    $Self->{StorageCacheTTL} = 60 * 60 * 24;

    return $Self;
}

=item ValueSet()

sets a dynamic field attachment.

    my $Success = $DynamicFieldFileSystemValue->ValueSet(
        FieldID  => $FieldID,                 # ID of the dynamic field
        ObjectID => $ObjectID,                # ID of the current object that the field
        FileContent => $UploadStuff,			 # File upload content
        UserID   => $UserID,
    );

=cut

sub ValueSet {
    my ( $Self, %Param ) = @_;

	# check needed stuff
    for my $Needed (qw(FieldID ObjectID FileContent UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
				Priority => 'error',
				Message => "Need $Needed!"
			);
            return;
        }
    }

	# get path of dynamic field storage
    my $AbsolutePath = $Self->_GetAbsolutePath(
		FieldID  => $Param{FieldID},
		ObjectID => $Param{ObjectID}
	);

	return if !$AbsolutePath;

    # Check fs write permissions.
    # Generate a thread-safe article check directory.
    my ( $Seconds, $Microseconds ) = Time::HiRes::gettimeofday();
    my $PermissionCheckDirectory
        = "check_permissions_${$}_" . ( int rand 1_000_000_000 ) . "_${Seconds}_${Microseconds}";
    my $Path = "$AbsolutePath" . $PermissionCheckDirectory;
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

	my %FileContent = %{$Param{FileContent}};
	
    # strip spaces from filenames
    $FileContent{Filename} =~ s/ /_/g;

    # strip dots from filenames
    $FileContent{Filename} =~ s/^\.//g;

	# strips special characters from filenames
	$FileContent{Filename} =~ s/[^a-zA-Z0-9._]//g;

    # get main object
    my $MainObject = $Kernel::OM->Get('Kernel::System::Main');

    # Perform FilenameCleanup here already to check for
    # conflicting existing attachment files correctly
    $FileContent{Filename} = $MainObject->FilenameCleanUp(
        Filename => $FileContent{Filename},
        Type     => 'Local',
    );

    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime'
    );

	my $SystemTime = $DateTimeObject->ToEpoch();

	$FileContent{Basename} = $SystemTime."_".$FileContent{Filename};

    # write attachment to backend
    if ( !-d $AbsolutePath ) {
        if ( !File::Path::mkpath( [ $AbsolutePath ], 0, 0770 ) ) {    ## no critic
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Can't create $AbsolutePath: $!",
            );
            return;
        }
    }

    # write attachment content type to fs
    my $SuccessContentType = $MainObject->FileWrite(
        Directory  => $AbsolutePath,
        Filename   => "$FileContent{Basename}.content_type",
        Mode       => 'binmode',
        Content    => \$FileContent{ContentType},
        Permission => 660,
    );
    return if !$SuccessContentType;

    # write attachment content to fs

    my $SuccessContent = $MainObject->FileWrite(
        Directory  => $AbsolutePath,
        Filename   => $FileContent{Basename},
        Mode       => 'binmode',
        Content    => \$FileContent{Content},
        Permission => 660,
    );
    return if !$SuccessContent;

	# write attachment id
    my $SuccessFileName = $MainObject->FileWrite(
        Directory  => $AbsolutePath,
        Filename   => "$FileContent{Basename}.file_name",
        Mode       => 'binmode',
        Content    => \$FileContent{Filename},
        Permission => 660,
    );
    return if !$SuccessFileName;

	# write attachment id
    my $SuccessFileID = $MainObject->FileWrite(
        Directory  => $AbsolutePath,
        Filename   => "$FileContent{Basename}.file_id",
        Mode       => 'binmode',
        Content    => \$SystemTime,
        Permission => 660,
    );
    return if !$SuccessFileID;

    # create needed objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # get config public link
    my $OptionPublicLink = $ConfigObject->Get('DynamicFieldFileSystem::Core::PublicLink');

    if ( $OptionPublicLink ) {

        # create a token
        my $SuccessToken = $Self->_CreateToken(
            ObjectID => $Param{ObjectID},
            FieldID  => $Param{FieldID},
            FileName => $FileContent{Filename}
        );
        return if !$SuccessToken;
    }

    return 1;
}

=item ValueGet()

get a dynamic field attachment.

    my $Value = $DynamicFieldFileSystemValue->ValueGet(
        FieldID            => $FieldID,                 # ID of the dynamic field
        ObjectID           => $ObjectID,                # ID of the current object that the field
                                                        #   is linked to, e. g. TicketID
    );

    Returns [
        {
            Link     => 'link attachment',
        },
    ];

=cut

sub ValueGet {
    my ( $Self, %Param ) = @_;;

    # check needed stuff
    for my $Needed (qw(FieldID ObjectID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
				Priority => 'error',
				Message => "Need $Needed!"
			);
            return;
        }
    }

	# get cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    # read cache
    if ( $Self->{StorageCache} ) {

        my $Cache = $CacheObject->Get(
            Type           => 'StorageFS_FileSystem_' . $Param{FieldID},
            Key            => 'ValueGet::' . $Param{FieldID}.'::'.$Param{ObjectID},
            CacheInMemory  => 0,
            CacheInBackend => 1,
        );

        return $Cache if $Cache;
    }

	# get path of dynamic field storage
    my $AbsolutePath = $Self->_GetAbsolutePath(
		FieldID  => $Param{FieldID},
		ObjectID => $Param{ObjectID}
	);

	return if !$AbsolutePath;

	my @Data;

	# get needed objects
    my $MainObject   = $Kernel::OM->Get('Kernel::System::Main');
	my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my @FileList = $MainObject->DirectoryRead(
        Directory => "$AbsolutePath",
        Filter    => "*",
        Silent    => 1,
    );

    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        ID   => $Param{FieldID}
    );

    my $Attachment = $DynamicField->{Config}->{LinkDefault};

    my $Link;

    my $FQDN     = $ConfigObject->Get('FQDN');
    my $HTTPType = $ConfigObject->Get('HttpType');
    my $HTTP     = "$HTTPType://";

    if( $DynamicField->{Config}->{LinkDefault}){
        # Get url of link insert
        my @Values = split('/', $Attachment);
        my $PositionName =  scalar @Values;
        $Link = "<a download href='/znuny-web/$Attachment'>$Values[$PositionName-1]</a>";
        push @Data, $Link;

    }
    else {

        if ( IsArrayRefWithData(\@FileList) ) {

            my $BaseLink   = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->{Baselink};
            my $BaseAction = $ParamObject->GetParam( Param => 'Action' ) || '';
            my $TicketID   = $ParamObject->GetParam( Param => 'TicketID' ) || '';

            FILENAME:
            for my $Filename (@FileList) {

                next FILENAME if $Filename =~ /\.content_type$/;
                next FILENAME if $Filename =~ /\.file_name$/;
                next FILENAME if $Filename =~ /\.file_id$/;

                # get file real name
                $Param{Filename} = basename($Filename);

                # read file name
                my $Basename = $MainObject->FileRead(
                    Location => "$Filename.file_name",
                );

                $Param{Basename} = ${$Basename};                

                my $TruncateName;

                if( length($Param{Basename}) > 16 ){
                    $TruncateName = substr( $Param{Basename}, 0, 17 );
                    $TruncateName .= '...';
                }
                else{
                    $TruncateName = $Param{Basename};
                }
                
                # get public key
                my $Token = $Self->_SearchToken(
                    ObjectID => $Param{ObjectID},
                    FieldID  => $Param{FieldID},
                    FileName => $Param{Basename}
                );

                my $DeleteTitle = $LayoutObject->{LanguageObject}->Translate('Delete');

                my $ViewHTML;

                if ( $Token->{PublicKey} ) {

                    $ViewHTML = "<a href='".$HTTP.$FQDN."/znuny/public.pl?"."Action=PublicAttachment;"
                    ."Token=$Token->{PublicKey}' title='$Param{Basename}'>$TruncateName</a>";

                    $Link = "<a href='".$HTTP.$FQDN."/znuny/public.pl?"."Action=PublicAttachment;"
                    ."Token=$Token->{PublicKey}' title='$Param{Basename}'>$Param{Basename}</a>";

                    if ( $DynamicField->{Config}->{DeleteFile} ) {

                        $ViewHTML .="<a href='".$BaseLink."Action=FileSystemAttachment;Subaction=Delete;BaseAction=$BaseAction;TicketID=$TicketID;"
                        ."FieldID=$Param{FieldID};ObjectID=$Param{ObjectID};Filename=$Param{Filename};Url= $LayoutObject->{RequestedURL};Token=$Token->{PublicKey}' title='$DeleteTitle' class='DeleteFile'>  "
                        ."<i class='fa fa-trash-o'></i></a>";
                    }

                }
                else {

                    $ViewHTML = "<a href='".$BaseLink."Action=FileSystemAttachment;Subaction=Download;"
                    ."FieldID=$Param{FieldID};ObjectID=$Param{ObjectID};Filename=$Param{Filename}' title='$Param{Basename}'>$TruncateName</a>";

                    $Link = "<a href='".$HTTP.$FQDN.$BaseLink."Action=FileSystemAttachment;Subaction=Download;"
                    ."FieldID=$Param{FieldID};ObjectID=$Param{ObjectID};Filename=$Param{Filename}' title='$Param{Basename}'>$Param{Basename}</a>";

                    if ( $DynamicField->{Config}->{DeleteFile} ) {

                        $ViewHTML .="<a href='".$BaseLink."Action=FileSystemAttachment;Subaction=Delete;BaseAction=$BaseAction;TicketID=$TicketID;"
                        ."FieldID=$Param{FieldID};ObjectID=$Param{ObjectID};Filename=$Param{Filename};Url= $LayoutObject->{RequestedURL}' title='$DeleteTitle' class='DeleteFile'>  "
                        ."<i class='fa fa-trash-o'></i></a>";
                    }
                }
               
                push @Data, {
                    Value => $ViewHTML,
                    Link  => $Link
                };
            }

            # add config

            my $DownloadAllFile = $LayoutObject->{LanguageObject}->Translate('Download All File');

            if ( 1 && scalar @Data > 1 ){
                $Data[0]->{AllFile} = "<a href='".$HTTP.$FQDN.$BaseLink."Action=FileSystemAttachment;Subaction=Download;"
                    ."FieldID=$Param{FieldID};ObjectID=$Param{ObjectID};AllFile=1' title='Bulk'>$DownloadAllFile</a>";
            }
        }
    }

    # set cache
    if ( $Self->{StorageCache} ) {

        $CacheObject->Set(
            Type           => 'StorageFS_FileSystem_' . $Param{FieldID},
            TTL            => $Self->{StorageCacheTTL},
            Key            => 'ValueGet::' . $Param{FieldID}.'::'.$Param{ObjectID},
            Value          => \@Data,
            CacheInMemory  => 0,
            CacheInBackend => 1,
        );
    }

	return \@Data;
}

=item ValueFileGet()

get a dynamic field file system.

    my $Value = $DynamicFieldFileSystemValue->ValueFileGet(
        FieldID            => $FieldID,                 # ID of the dynamic field
        ObjectID           => $ObjectID,                # ID of the current object that the field
    );

    Returns [
        {
            Disposition   => 'attachment',
            Content       => 'content',
            Filename      => 'file1.txt',
            ContentType   => 'plain/text',
            FileID        => '123456',
        },
		{
            Disposition   => 'attachment',
            Content       => 'content',
            Filename      => 'file2.txt',
            ContentType   => 'plain/text',
            FileID        => '123456',
        },
    ];

=cut

sub ValueFileGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(FieldID ObjectID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
				Priority => 'error',
				Message => "Need $Needed!"
			);
            return;
        }
    }

    # get cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    # read cache
    if ( $Self->{StorageCache} ) {

        my $Cache = $CacheObject->Get(
            Type           => 'StorageFS_FileSystem_' . $Param{FieldID},
            Key            => 'ValueFileGet::' . $Param{FieldID}.'::'.$Param{ObjectID},
            CacheInMemory  => 0,
            CacheInBackend => 1,
        );

        return $Cache if $Cache;
    }

	# get path of dynamic field storage
    my $AbsolutePath = $Self->_GetAbsolutePath(
		FieldID  => $Param{FieldID},
		ObjectID => $Param{ObjectID},
        Silent   => 1,
	);
	return if !$AbsolutePath;

	my @Data;

	# get main object
    my $MainObject = $Kernel::OM->Get('Kernel::System::Main');

    my @FileList = $MainObject->DirectoryRead(
        Directory => "$AbsolutePath",
        Filter    => "*",
        Silent    => 1,
    );

    return if ( !IsArrayRefWithData(\@FileList) );

	if ( IsArrayRefWithData(\@FileList) ) {

        # get encode object
        my $EncodeObject = $Kernel::OM->Get('Kernel::System::Encode');

        FILENAME:
        for my $Filename (@FileList) {
            next FILENAME if $Filename =~ /\.content_type$/;
            next FILENAME if $Filename =~ /\.file_name$/;
            next FILENAME if $Filename =~ /\.file_id$/;

			my %FileData = ();
            if ( -e "$Filename.content_type" ) {

				# read content type
                my $Content = $MainObject->FileRead(
                    Location => "$Filename.content_type",
                );
                return if !$Content;
                $FileData{ContentType} = ${$Content};

                # read file id
                my $FileID = $MainObject->FileRead(
                    Location => "$Filename.file_id",
                );
                return if !$FileID;
                $FileData{FileID} = ${$FileID};

				# read file name
                my $Basename = $MainObject->FileRead(
                    Location => "$Filename.file_name",
                );
                return if !$Basename;
                $FileData{Filename} = ${$Basename};

                # read content
                $Content = $MainObject->FileRead(
                    Location => $Filename,
                    Mode     => 'binmode',
                );
                return if !$Content;
                $FileData{Content} = ${$Content};

                # all others including attachments with content id that are not images
                # 	should NOT be inline
                $FileData{Disposition} = 'attachment';
            }
            else {
				$Kernel::OM->Get('Kernel::System::Log')->Log(
					Priority => 'error',
					Message => "No file content_type!"
				);
				return;
            }

            if (
                $FileData{ContentType} =~ /plain\/text/i
                && $FileData{ContentType} =~ /(utf\-8|utf8)/i
                )
            {
                $EncodeObject->EncodeInput( \$FileData{Content} );
            }

            chomp $FileData{ContentType};

            push @Data, \%FileData;
        }
    }

    # set cache
    if ( $Self->{StorageCache} ) {

        $CacheObject->Set(
            Type           => 'StorageFS_FileSystem_' . $Param{FieldID},
            TTL            => $Self->{StorageCacheTTL},
            Key            => 'ValueFileGet::' . $Param{FieldID}.'::'.$Param{ObjectID},
            Value          => \@Data,
            CacheInMemory  => 0,
            CacheInBackend => 1,
        );
    }

	return \@Data;
}

=item ValueDelete()

delete a Dynamic field value entry. All associated rows will be deleted.

    my $Success = $DynamicFieldFileSystemValue->ValueDelete(
        FieldID            => $FieldID,                 # ID of the dynamic field
        ObjectID           => $ObjectID,                # ID of the current object that the field
                                                        #   is linked to, e. g. TicketID
		Filename => 'file.txt',
        UserID  => 123,
    );

    Returns 1.

=cut

sub ValueDelete {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(FieldID ObjectID Filename UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
				Priority => 'error',
				Message => "Need $Needed!"
			);
            return;
        }
    }

	# get path of dynamic field storage
    my $AbsolutePath = $Self->_GetAbsolutePath(
		FieldID  => $Param{FieldID},
		ObjectID => $Param{ObjectID}
	);

	return if !$AbsolutePath;

    if ( -e $AbsolutePath ) {

        my @List = $Kernel::OM->Get('Kernel::System::Main')->DirectoryRead(
            Directory => $AbsolutePath,
            Filter    => "*",
        );

		FILE:
        for my $File (@List) {

			my $Basename = basename($File);
			next FILE if $Basename !~ m/$Param{Filename}/;

            if ( $File !~ /(\/|\\)plain.txt$/ ) {

                if ( !unlink "$File" ) {

                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'error',
                        Message  => "Can't remove: $File: $!!",
                    );
                }
            }
        }
    }

    return 1;
}

=item AllValuesDelete()

delete all entries of a dynamic field .

    my $Success = $DynamicFieldFileSystemValue->AllValuesDelete(
        FieldID            => $FieldID,                 # ID of the dynamic field
        UserID  => 123,
    );

    Returns 1.

=cut

sub AllValuesDelete {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(FieldID ObjectID Filename UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log( Priority => 'error', Message => "Need $Needed!" );
            return;
        }
    }

	# get path of dynamic field storage
    my $AbsolutePath = $Self->_GetAbsolutePath(
		FieldID  => $Param{FieldID},
		ObjectID => $Param{ObjectID}
	);

	return if !$AbsolutePath;

	if ( -e $AbsolutePath ) {

        my @List = $Kernel::OM->Get('Kernel::System::Main')->DirectoryRead(
            Directory => $AbsolutePath,
            Filter    => "*",
        );

        for my $File (@List) {

            if ( $File !~ /(\/|\\)plain.txt$/ ) {

                if ( !unlink "$File" ) {

                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'error',
                        Message  => "Can't remove: $File: $!!",
                    );
                }
            }
        }
    }

    return 1;
}

=item Internal Function()

=cut


sub _GetAbsolutePath {
    my ( $Self, %Param ) = @_;

    # DataDir
    my $DataDir = $Kernel::OM->Get('Kernel::Config')->Get('DynamicFieldFileSystemDir')
        || die 'Got no dynamic field dir!';

    # get needed objects
	my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
	my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

	my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        ID   => $Param{FieldID},
    );

	return if !IsHashRefWithData($DynamicField);

	my $CreateTime;
	if ( $DynamicField->{ObjectType} eq 'Article' ){

        # get database object
        my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

        return if !$DBObject->Prepare(
            SQL => '
                SELECT create_time
                FROM article
                WHERE id = ?
                ORDER BY id ASC',
            Bind => [ \$Param{ObjectID} ],
            Limit => 1,
        );

        my $Time;
        while ( my @Row = $DBObject->FetchrowArray() ) {
            $Time = $Row[0];
        }

		$CreateTime = $Time;
	}
	elsif ( $DynamicField->{ObjectType} eq 'Ticket' ){
		my %Ticket = $TicketObject->TicketGet(
			TicketID     => $Param{ObjectID},
			UserID       => $Param{UserID},
		);

		$CreateTime = $Ticket{Created};
	}

    return if !$CreateTime;

    my ($Data, $Hours) = split / /, $CreateTime;

    my ($Year, $Month, $Day) = split /-/, $Data;

    my $ContentPath =
		$Year . '/' . $Month . '/' . $Day. '/' . $DynamicField->{ObjectType} . '/' .$Param{ObjectID}. '/' .$Param{FieldID} ;

    return "$DataDir/$ContentPath/";
}


=item DfFileSystemAttachmentAdd()

returns 1 if attachment was added with success

    my $Success = $SystemAttachmentObject->DfFileSystemAttachmentAdd(
        ID          => 123,
        Filename    => 'file.txt',
        ContentType => 'text/file',
        Content     => $EncodedContent,
    );

=cut

sub DfFileSystemAttachmentAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(ID ContentType Content Filename)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Do(
        SQL => 'INSERT INTO df_attachment_default(field_id, content, content_type, file_name) VALUES '
            . '(?, ?, ?, ?)',
        Bind => [
            \$Param{ID}, \$Param{Content}, \$Param{ContentType}, \$Param{Filename},
        ],
    );

    # delete cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => $Self->{CacheType},
    );

    return 1;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut


=head2 _CreateToken()

set request data to DynamicFieldFileSystemValue.

    my $PublicKey = $DynamicFieldFileSystemValueObject->_CreateToken(
        TicketID   => 1,
        ArticleID  => 1, # optional
        FieldID    => 1,
        FieldValue => 'Valor 1',
        SendTo     => 'example@serviceup.com'
    );

=cut

sub _CreateToken {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed ( qw(ObjectID FieldID FileName ) ) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # get system time
    my $SystemTime = $Kernel::OM->Create('Kernel::System::DateTime')->ToEpoch();

    # create PublicSurveyKey
    my $MD5 = Digest::MD5->new();
    $MD5->add( $SystemTime . int( rand(999999999) ) );
    my $PublicKey = $MD5->hexdigest();

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # insert token data
    return if !$DBObject->Do(
        SQL => 'INSERT INTO file_system_token (object_id, field_id, file_name, valid_id, public_key, create_time ) 
                VALUES ( ?, ?, ?, 1, ?, current_timestamp )',
        Bind => [ \$Param{ObjectID}, \$Param{FieldID}, \$Param{FileName}, \$PublicKey, ],
    );

    return $PublicKey;
}

=head2 _SearchToken()

returns the public key with respect to the given parameters..

    my $Token = $Self->_SearchToken(
        ObjectID => 1,
        FieldID  => 1,
        FileName => 'teste.txt'
    );

=cut

sub _SearchToken {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed ( qw(ObjectID FieldID FileName ) ) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # request public key
    return if !$DBObject->Prepare(
        SQL => 'SELECT public_key FROM file_system_token WHERE object_id = ? AND field_id = ? AND file_name = ?',
        Bind => [ \$Param{ObjectID}, \$Param{FieldID}, \$Param{FileName} ],
    );

    # fetch the result
    my %RequestData;

    while ( my @Row = $DBObject->FetchrowArray() ) {
        $RequestData{PublicKey} = $Row[0];
    }

    return \%RequestData;
}

=head2 GetDataAttachment()

returns data against the given public key.

    my $DataAttachment = $Kernel::OM->Get('Kernel::System::DynamicFieldFileSystemValue')->GetDataAttachment(
        Token => $Token,
    );

=cut

sub GetDataAttachment {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{Token} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need Token!"
            );
            return;
    }    

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # request attachment data
    return if !$DBObject->Prepare(
        SQL => 'SELECT object_id, field_id, file_name FROM file_system_token WHERE public_key = ?',
        Bind => [ \$Param{Token} ],
    );

    # fetch the result
    my %RequestData;

    while ( my @Row = $DBObject->FetchrowArray() ) {
        $RequestData{ObjectID} = $Row[0];
        $RequestData{FieldID}  = $Row[1];
        $RequestData{FileName} = $Row[2];
    }

    return \%RequestData;

}

sub DeleteToken {
    my ( $Self, %Param ) = @_;

    # check needed stuff
        if ( !$Param{Token} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need Token!"
            );
            return;
        }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # request attachment data
    return if !$DBObject->Do(
        SQL => 'DELETE FROM file_system_token WHERE public_key = ?',
        Bind => [ \$Param{Token} ],
    );

    return 1;
}