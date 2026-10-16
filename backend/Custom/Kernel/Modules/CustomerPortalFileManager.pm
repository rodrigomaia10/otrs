# --
# Kernel/Modules/CustomerPortalFileManager.pm
# Copyright (C) 2019 Service UP, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * ghidalgo@serviceup.com.br
# --

package Kernel::Modules::CustomerPortalFileManager;

use strict;
use warnings;

use utf8;

use Encode qw(decode encode);
use Digest::MD5 qw(md5_hex);
use 5.010;

use File::stat;
use File::Basename;

our $ObjectManagerDisabled = 1;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $CustomerPortalObject = $Kernel::OM->Get('Kernel::System::CustomerPortal');
    my $CustomerUserObject   = $Kernel::OM->Get('Kernel::System::CustomerUser');
	my $ServiceObject        = $Kernel::OM->Get('Kernel::System::Service');
    my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject         = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject          = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $JSONObject           = $Kernel::OM->Get('Kernel::System::JSON');
    my $MainObject           = $Kernel::OM->Get('Kernel::System::Main');

    my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');

    $CustomerPortalLayoutObject->CreateNavBar(
        ActionActive => "Outhers",
        %{$Self}
    );

    my $Message  = $ParamObject->GetParam( Param => 'Message' )  || '';
    
    $Param{Title}  = '';
    $Param{Active} = 'CustomerFileManager';    
    
    if ( $Self->{Subaction} eq 'CustomerFileManager' ) {

        my $MainObject = $Kernel::OM->Get('Kernel::System::Main');
	
	    my $AbsolutePath = "/opt/otrs/var/filemanager/$Self->{UserCustomerID}";
	
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

        $Self->_OverviewFileManager( 
			AbsolutePath => $AbsolutePath,
			Folder       => $Self->{CustomerID}
		);	

		my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
        my $ActionTitle = $ConfigObject->Get('CustomerPortal::Core::ActionTitle');

        my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{CustomerPortalFileManager});

		$Output .= $LayoutObject->Output(
			TemplateFile => 'CustomerPortalFileManager',
			Data         => \%Param,
		);

        $Output .= $LayoutObject->CustomerFooter(Type => 'Small');
		
        return $Output;
    }
    # ------------------------------------------------------------ #
    # Download Customer FileManager
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'DownloadCustomerFileManager' ) {

        my $MainObject = $Kernel::OM->Get('Kernel::System::Main');
	
	    my $AbsolutePath = "/opt/otrs/var/filemanager/$Self->{UserCustomerID}";

        my %GetParam = ();

        $GetParam{File} = $ParamObject->GetParam( Param => 'File' ) || ''; 
		
		my $FilePath = "$AbsolutePath/$GetParam{File}";
		
		# read content type
		my $Content = $MainObject->FileRead(
			Location => $FilePath,
		);
		
		return $LayoutObject->Attachment(
			Filename    => $GetParam{File},
			ContentType => 'application/octet-stream',
			Content     => ${ $Content },
		);		
    }
    # ------------------------------------------------------------ #
    #View FileMagener
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ViewFileMagener' ) {

        my $MainObject = $Kernel::OM->Get('Kernel::System::Main');
	
	    my $AbsolutePath = "/opt/otrs/var/filemanager/$Self->{UserCustomerID}";

        my %GetParam = ();

        $GetParam{File} = $ParamObject->GetParam( Param => 'File' ) || ''; 
		
		my $FilePath = "$AbsolutePath/$GetParam{File}";
		
		# read content type
		my $Content = $MainObject->FileRead(
			Location => $FilePath,
		);

		return $LayoutObject->Attachment(
            Name        => $GetParam{File},
            ContentType => 'application/pdf',
            Content     => ${ $Content },
            Type        => 'inline',
        );
    }

	return 1;
}

sub _OverviewFileManager {
    my ( $Self, %Param ) = @_;
	
	#get object
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $MainObject = $Kernel::OM->Get('Kernel::System::Main');
	my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');
	
	$LayoutObject->Block(
        Name => 'Overview',
        Data => \%Param,
    );

    $Param{AbsolutePath} =~ s/([ ])/\\$1/g;
	
	my @FilesInDirectory = $MainObject->DirectoryRead(
        Directory => $Param{AbsolutePath},
		Filter    => '*',
		Silent    => 1
    );
	
	if( IsArrayRefWithData(\@FilesInDirectory) ) {
		
		my $Count = 0;
		
		for my $FilePath (@FilesInDirectory){
			
			my %Data;
		
			# read content type
			my $Content = $MainObject->FileRead(
				Location => $FilePath,
			);

			my $FileStat = stat($FilePath);
			
			my $Size = $FileStat->size;
			
			my ($Sec, $Min, $Hour, $Day, $Month, $Year, $WeekDay) = $TimeObject->SystemTime2Date(
				SystemTime => $FileStat->mtime,
			);
			
			$Data{LastModified} = "$Day/$Month/$Year $Hour:$Min:$Sec";	
			$Data{Name}         = basename( $FilePath );		
			$Data{Content}      = ${ $Content };
			
			if( $Size > ( 1024 * 1024 ) ) {
				$Data{Size} = sprintf "%.1f MBytes", ( $Size / ( 1024 * 1024 ) );
			}
			elsif ( $Size > 1024 ) {
				$Data{Size} = sprintf "%.1f KBytes", ( ( $Size / 1024 ) );
			}
			else {
				$Data{Size} = $Size . ' Bytes';
			}
			
			$LayoutObject->Block(
				Name => 'DataRow',
				Data => \%Data,
			);
			
			$Data{Count} = $Count;
			
			if($Data{Name} =~ /^[^.]*$/i){
				$Data{Class} = "fa fa-folder";
			}			
			elsif($Data{Name} =~ /(.pdf)$/i) {
				$Data{Class} = "fa fa-file-pdf-o";	
				
				$LayoutObject->Block(
					Name => 'ViewPDF',
					Data => \%Data,
				);
			}
			elsif($Data{Name} =~ /(.docx|.doc)$/i){
				$Data{Class} = "fa fa-file-word-o";
			}
			elsif($Data{Name} =~ /(.xlsx|.xlsm|.xls|.xlt|.xls)$/i){
				$Data{Class} = "fa fa-file-excel-o";
			}
			elsif($Data{Name} =~ /(.pptx|.ppt|.ppsx)$/i){
				$Data{Class} = "fa fa-file-powerpoint-o";
			}
			elsif($Data{Name} =~ /(.png|.jpeg)$/i){
				$Data{Class} = "fa fa-file-image-o";
			}
			elsif($Data{Name} =~ /(.rar|.zip|.7z|.tar.gz)$/i){
				$Data{Class} = "fa fa-file-archive-o";
			}
			else{
				$Data{Class} = "fa fa-file-text-o";
			}
			
			if( $Data{Content} ) {
			
				$LayoutObject->Block(
					Name => 'ViewFile',
					Data => \%Data,
				);
				
				$LayoutObject->Block(
					Name => 'DownloadFile',
					Data => \%Data,
				);
			}
			
			$Count++;
		}	
	}
    else {
		$LayoutObject->Block(
			Name => 'NoDataFoundMsg',
			Data => {},
		);
	}
	
	return 1;
}

1;