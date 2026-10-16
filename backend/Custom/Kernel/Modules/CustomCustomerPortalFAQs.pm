# --
# Kernel/Modules/CustomCustomerPortalFAQs.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# -- 

package Kernel::Modules::CustomCustomerPortalFAQs;

use strict;
use warnings;
use Digest::MD5 qw(md5_hex);

use utf8;
use Kernel::System::VariableCheck qw(:all);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject         = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
    my $ParamObject          = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $FAQObject            = $Kernel::OM->Get('Kernel::System::FAQ');
    my $JSONObject           = $Kernel::OM->Get('Kernel::System::JSON');
    my $CustomerPortalObject = $Kernel::OM->Get('Kernel::System::CustomerPortal');
    my $ServiceObject        = $Kernel::OM->Get('Kernel::System::Service');

    my %GetParam;

    my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');

    if( $Self->{Subaction} eq 'SearchFAQs' ){
        my $JSON =  '{}';

        # Get Params
        my $GetFAQTextSearch   = $ParamObject->GetParam( Param => 'FAQTextSearch' ) || '';
        my $ConfigSearchType   = $ConfigObject->Get("CustomerPortal::CustomCustomerPortalFAQs::SearchType");

        my %SearchData;

        $SearchData{Approved} = 1;
       
        $SearchData{Interface} = {             
            StateID => 1,
            Name    => 'external',    
        };

        if ( $ConfigSearchType eq 'All' ){
            $SearchData{What} = "*$GetFAQTextSearch*";

        }elsif( $ConfigSearchType eq 'Title' ){
            $SearchData{Title} = "*$GetFAQTextSearch*";
        }

        my @IDs = $FAQObject->FAQSearch(
            %SearchData,    
            UserID => $Self->{UserID},
        );

        # To order by top 10 access log
        my $TopAccessIDsRef = $CustomerPortalObject->CustomFAQGetAccessLog(
            ItemIDs => \@IDs,
            UserID  => 1,
        );

        my @FAQsData;

        # my $Services = $ServiceObject->CustomerUserServiceMemberList(
        #     CustomerUserLogin => 'Test',
        #     Result            => 'HASH',
        #     DefaultServices   => 0,
        # );

        FAQ:
        for my $FAQData ( @{$TopAccessIDsRef} ){

            my %FAQ = $FAQObject->FAQGet(
                ItemID     => $FAQData->{ItemID},
                UserID     => 1,
            );

            next FAQ if $FAQ{StateTypeName} eq 'internal';

            push @FAQsData, {
                $FAQData->{ItemID} => $FAQ{Title}
            };
        }

        $JSON = $JSONObject->Encode(
            Data     =>  {
                FAQsData => \@FAQsData,
            },
            Pretty => 1,           
        );

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON || '',
            Type        => 'inline',
            NoCache     => 1,
        );
    }
    elsif( $Self->{Subaction} eq'SearchFAQSolution' ){
        my $JSON =  '{}';

        # Get Params
        my $FAQID = $ParamObject->GetParam( Param => 'FAQID' ) || '';

        my $Interface = $FAQObject->StateTypeGet(
            Name   => 'external',
            UserID => $Self->{UserID},
        );

        # log access to this FAQ item
        $FAQObject->FAQLogAdd(
            ItemID    => $FAQID,
            Interface => $Interface->{Name},
            UserID    => $Self->{UserID},
        );

        my %FAQ = $FAQObject->FAQGet(
            ItemID     => $FAQID,
            ItemFields => 1,        
            UserID     => 1,
        );

        # rewrite handle and action
        $FAQ{Field3}
            =~ s{ index[.]pl [?] Action=AgentFAQZoom }{customer.pl?Action=CustomerFAQZoom}gxms;

        # take care of old style before FAQ 2.0.x
        $FAQ{Field3} =~ s{
            index[.]pl [?] Action=AgentFAQ [&](amp;)? Subaction=Download [&](amp;)?
        }{customer.pl?Action=CustomerFAQZoom;Subaction=DownloadAttachment;}gxms;

        # build base URL for inline images
        my $SessionID = '';
        if ( $Self->{SessionID} && !$Self->{SessionIDCookie} ) {
            $SessionID = ';' . $Self->{SessionName} . '=' . $Self->{SessionID};
            $FAQ{Field3} =~ s{
                (Action=CustomerFAQZoom;Subaction=DownloadAttachment;ItemID=\d+;FileID=\d+)
            }{$1$SessionID}gmsx;
        } 

        # output attachments if any
        my @AttachmentIndex = $FAQObject->AttachmentIndex(
            ItemID     => $FAQID,
            ShowInline => 0,
            UserID     => $Self->{UserID},
        );

        # Faq attachments
        my @AttachmentsOfFAQ;
        if (@AttachmentIndex) {
           
            for my $Attachment (@AttachmentIndex) {

                push @AttachmentsOfFAQ, {
                    Filename => $Attachment->{Filename},
                    FileID => $Attachment->{FileID},
                }
            }
        }

        if(  $FAQ{Field3} ){
            $JSON = $JSONObject->Encode(
                Data   => {
                    FAQResponse => $FAQ{Field3},
                    AttachmentsOfFAQ => \@AttachmentsOfFAQ,
                    ItemID => $FAQID,
                    FieldID => 'Field3',
                    SessionName => $Self->{SessionName},
                    SessionID => $Self->{SessionID},
                    # Baselink
                } ,
                Pretty => 1,           
            );
        }    

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON || '',
            Type        => 'inline',
            NoCache     => 1,
        );
    }
    elsif ( $Self->{Subaction} eq 'SearchFAQCategoryTop10' ){
        my $JSON =  '{}';

        # Get Params
        my $FAQCategoryID = $ParamObject->GetParam( Param => 'FAQCategoryID' ) || '';

        my @CategoryIDArray= $CustomerPortalObject->GetParentFAQCategories(
            CategoryFAQID => $FAQCategoryID,
        );

        push @CategoryIDArray, $FAQCategoryID;

        my $Top10IDsRef = $CustomerPortalObject->CustomFAQTop10Get(
            Interface   => 'external',
            CategoryIDs => \@CategoryIDArray,
            Limit       => 100,          
            UserID      =>  $Self->{UserID},
        );     

        my @FAQCategoryTopDataArray;
	    my @FAQDataTest;
        my %Data;

	    my $CategoriesIcons = $ConfigObject->Get('CustomerPortal::Core::CustomFAQ::CategoriesIcons');

        for my $FAQData (  @{ $Top10IDsRef } ){
            my %FAQCategoryTopData;

            my %FAQ = $FAQObject->FAQGet(
                ItemID     => $FAQData->{ItemID},
                UserID     => $Self->{UserID},
            );
		
            $FAQCategoryTopData{ $FAQData->{ItemID} } = $FAQ{Title};

            push @FAQCategoryTopDataArray, \%FAQCategoryTopData;

            my $SubCategory = 'Outros';

            if ( $FAQ{CategoryName} =~ /::(.+)/ ) {
                $SubCategory = $1;
            }

            my $FAQImageIcon = $Self->_GetPathImage(
                Image => $CategoriesIcons->{$FAQ{CategoryName}}
            );

            push @{ $Data{$SubCategory} }, {
                ItemID        => $FAQData->{ItemID},
                Name          => $FAQ{Title},
                SubCategory   => $SubCategory,
                ImageCategory => $FAQImageIcon
            };

        }

        $JSON = $JSONObject->Encode(

	    Data   => \%Data,
            Pretty => 1,           
        );
          
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON || '',
            Type        => 'inline',
            NoCache     => 1,
        );

    }
    elsif ( $Self->{Subaction} eq 'DownloadAttachment' ){
        # manage parameters
        $GetParam{FileID} = $ParamObject->GetParam( Param => 'FileID' );
        $GetParam{ItemID} = $ParamObject->GetParam( Param => 'ItemID' );

        if ( !defined $GetParam{FileID} ) {
            return $LayoutObject->CustomerFatalError(
                Message => Translatable('Need FileID!'),
            );
        }

        # get attachments
        my %File = $FAQObject->AttachmentGet(
            ItemID => $GetParam{ItemID},
            FileID => $GetParam{FileID},
            UserID => $Self->{UserID},
        );
        if (%File) {
            return $LayoutObject->Attachment(%File);
        }
        else {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Message  => "No such attachment ($GetParam{FileID})! May be an attack!!!",
                Priority => 'error',
            );
            return $LayoutObject->CustomerFatalError();
        }
    }
    else{
        $CustomerPortalLayoutObject->CreateNavBar(
            ActionActive => "FAQs",
            %{$Self}
        );

        # get config of frontend module
        my $Config = $ConfigObject->Get("FAQ::Frontend::CustomerFAQExplorer");
        my $CustomerCategoryGroupHashRef = $FAQObject->GetCustomerCategoriesLongNames(
            CustomerUser =>  $Self->{UserID},
            Type         => 'ro',
            UserID       => 1,
        );

        my $ConfigRelationCategory   = $ConfigObject->Get("CustomerPortal::CustomCustomerPortalFAQs::RelationCategory");
        if( %{$ConfigRelationCategory} ){
            my $Clone;

            my %Services = $ServiceObject->CustomerUserServiceMemberList(
                CustomerUserLogin => $Self->{UserLogin},
                Result            => 'HASH',
                DefaultServices   => 1,
            );

            for my $service ( values %Services ){
                for my $category ( keys %{$ConfigRelationCategory} ){
                    if($service eq $ConfigRelationCategory->{$category}){
                        my ($key) = grep{ $CustomerCategoryGroupHashRef->{$_} eq $category } keys %{$CustomerCategoryGroupHashRef};
                        $Clone->{$key} = $category;
                    }
                }
            }
            $CustomerCategoryGroupHashRef = $Clone;
        }

        my $CategoriesIcons = $ConfigObject->Get('CustomerPortal::Core::CustomFAQ::CategoriesIcons');
        my $CustomFAQLayout = $ConfigObject->Get('CustomerPortal::CustomCustomerPortalFAQs::CustomFAQLayout');
        for my $CustomerCategoryGroup ( keys %{$CustomerCategoryGroupHashRef} ){

            next if $CustomerCategoryGroupHashRef->{$CustomerCategoryGroup} =~ /::/;

            my $FAQImageIcon = $Self->_GetPathImage(
                Image => $CategoriesIcons->{$CustomerCategoryGroupHashRef->{$CustomerCategoryGroup}}
            );
            $LayoutObject->Block(
                Name => 'CustomerCategories',
                Data => {
                    CategoryName  => $CustomerCategoryGroupHashRef->{$CustomerCategoryGroup},
                    FAQCategoryID => $CustomerCategoryGroup,
                    IconCategory  => $FAQImageIcon
                },
            );
        }

        my $ActionTitle = $ConfigObject->Get('CustomerPortal::Core::ActionTitle');
        
        # build output
        my $OutputData = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title =>  $ActionTitle->{CustomerPortalFAQs});
        $OutputData   .= $LayoutObject->Output(
            Data         => {
                %Param,
                ButtonColor   => $CustomFAQLayout->{ButtonColor},
                FontColor     => $CustomFAQLayout->{FontColor},
                Title         => $CustomFAQLayout->{Title},
                Description   => $CustomFAQLayout->{Description},
                SuperiorImage => $Self->_GetPathImage(
                    Image => $CustomFAQLayout->{SuperiorImage}
                )
            },
            TemplateFile => 'CustomCustomerPortalFAQs',
        );
        $OutputData   .= $LayoutObject->CustomerFooter(Type => 'Small');

        return $OutputData;
    }

}

sub _GetPathImage {
    my ( $Self, %Param ) = @_;

    return '' if !$Param{Image};

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    $Param{PathImage} = $ConfigObject->Get('Frontend::WebPath') . $Param{Image};

    if ( index($Param{Image}, 'http') != -1 || index($Param{Image}, 'https') != -1 || index($Param{Image}, 'ftp') != -1 ) {
        $Param{PathImage} = $Param{Image};
    }

    return $Param{PathImage};
}

1;