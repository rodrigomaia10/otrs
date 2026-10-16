# --
# Kernel/Modules/CustomerPortalSearch.pm
# Copyright (C) 2019 Service UP, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package Kernel::Modules::CustomerPortalSearch;

use strict;
use warnings;

use utf8;

use Encode qw(decode encode);
use File::Basename;

use Digest::MD5 qw(md5_hex);

our $ObjectManagerDisabled = 1;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # get form id
    $Self->{FormID} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'FormID' );

    # create form id
    if ( !$Self->{FormID} ) {
        $Self->{FormID} = $Kernel::OM->Get('Kernel::System::Web::UploadCache')->FormIDCreate();
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

	my $ServiceObject = $Kernel::OM->Get('Kernel::System::Service');
    my $TicketObject  = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject   = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $FAQObject     = $Kernel::OM->Get('Kernel::System::FAQ');
    my $Config        = $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::CustomerTicketMessage");

    my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');

    $CustomerPortalLayoutObject->CreateNavBar(
        ActionActive => "",
        %{$Self}
    );

    my $CustomerUser = $Self->{UserID};

    $Param{SearchValue} = $ParamObject->GetParam( Param => 'SearchValue' );
    $Param{OpenBy}      = $ParamObject->GetParam( Param => 'OpenBy' );
   
    $LayoutObject->Block( 
        Name => 'SearchResults',
        Data => {
            Fulltext => $Param{SearchValue},
        },
    );

    my $SelectedDefault = $ConfigObject->Get('CustomerPortal::Core::DefaultValueForSearch'); 
    my $CurrentOrder    = $ConfigObject->Get('Ticket::CustomerTicketSearch::Order::Default')  || 'Down';
    my $SearchLimit     = $ConfigObject->Get('Ticket::CustomerTicketSearch::SearchLimit')     || 200;
    my $SortBy          = $ConfigObject->Get('Ticket::CustomerTicketSearch::SortBy::Default') || 'Age';
    
    if ( $SelectedDefault == 1 ) {
        # Search FAQ
        if ( $Param{OpenBy} eq 'CustomerPortalFAQs' || $Param{OpenBy} eq 'CustomerPortalFAQZoom' ) {

            $Self->_SearchFAQs(
            Search => $Param{SearchValue}
            );
        }
        # Search Services
        elsif ( $Param{OpenBy} eq 'Services' ) {

            $Self->_SearchService(
            Search => $Param{SearchValue}
            );
        }
        # Search Tickets
        elsif ( $Param{OpenBy} eq 'MyTickets' || $Param{OpenBy} eq 'CustomerPortalTicketZoom' || $Param{OpenBy} eq 'CompanyTickets' ) {

            $Self->_SearchMyTikets(
            Search => $Param{SearchValue}
            );
        }
        # Search All
        else {

            $Self->_SearchService(
            Search => $Param{SearchValue}
            );

            $Self->_SearchMyTikets(
            Search => $Param{SearchValue}
            );

            $Self->_SearchFAQs(
            Search => $Param{SearchValue}
            );
        }
    }
    elsif ( $SelectedDefault == 2 ) {
        
        $Self->_SearchService(
            Search => $Param{SearchValue}
        );
    }
    elsif ( $SelectedDefault == 3 ) {
        
        $Self->_SearchMyTikets(
            Search => $Param{SearchValue}
        );
    }
    elsif ( $SelectedDefault == 4 ) {
        
        $Self->_SearchFAQs(
            Search => $Param{SearchValue}
        );
    }
    else {
        $Self->_SearchService(
            Search => $Param{SearchValue}
        );

        $Self->_SearchMyTikets(
            Search => $Param{SearchValue}
        );

        $Self->_SearchFAQs(
            Search => $Param{SearchValue}
        );
    }

    my $ActionTitle = $ConfigObject->Get('CustomerPortal::Core::ActionTitle');

    # build output
    my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{CustomerPortalSearch});

    $Output .= $LayoutObject->Output(
        TemplateFile => 'CustomerPortalSearch',
        Data         => {
            SearchValue => $Param{SearchValue},
        },
    );

    $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

    return $Output;
}
sub _SearchService {
    my ( $Self, %Param ) = @_;

    my $ServiceObject = $Kernel::OM->Get('Kernel::System::Service');
    my $TicketObject  = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # To service 
    my %ServiceHash;
    my $CustomerUser = $Self->{UserID};

    my @ServiceList = $ServiceObject->ServiceSearch(
        Name   => "$Param{Search}",
        UserID => '1',
    );

    my %AllServices = $ServiceObject->ServiceList(
        UserID => 1,
        KeepChildren => $ConfigObject->Get('Ticket::Service::KeepChildren'),
    );

    my $ACL = $TicketObject->TicketAcl(
        Action         => $Self->{Action}, 
        CustomerUserID => $Self->{UserID},
        ReturnType     => 'Ticket',
        ReturnSubType  => 'Service',
        Data           => \%AllServices,
    );
    
    # Check ACL
    if($ACL){
        %AllServices = $TicketObject->TicketAclData();
    }

    # Return all Services in relation with CustomerUser.
    my %CustomerServices = $ServiceObject->CustomerUserServiceMemberList(
        Result            => 'HASH',
        CustomerUserLogin => $Self->{UserID},
        UserID            => 1,
    );

    # Filter Services based on relation with CustomerUser and KeepChildren config.
    my %ServiceListHash;

    for my $FilterServiceID ( sort keys %AllServices ) {
        if($CustomerServices{$FilterServiceID}){
            $ServiceListHash{$FilterServiceID} = $CustomerServices{$FilterServiceID};
        }
    }

    my @ServicesIDs;

    my %Data;

    for my $SourceID (@ServiceList){

        my $Counter = 0;

        for my $ServiceID (sort keys %ServiceListHash){

            my %SubServiceData = $ServiceObject->ServiceGet(
                ServiceID      => $ServiceID,
                CustomerUserID => $CustomerUser,
                UserID         => 1,
            );

            if ($SourceID eq $SubServiceData{ServiceID}) {

                $Data{$SubServiceData{ServiceID}} = {
                    Name      => $SubServiceData{Name},
                    NameShort => $SubServiceData{NameShort},
                };

                push @ServicesIDs, $SubServiceData{ServiceID};
            }

            if ($SubServiceData{ParentID} ~~ @ServicesIDs){
                delete $Data{$SubServiceData{ParentID}};
            }
        }
    }

    for my $ServiceDataID ( keys %Data) {

        $LayoutObject->Block(
            Name => 'RecordService',
            Data => {
                TypeObject  => $LayoutObject->{LanguageObject}->Translate('Service'),
                Description => $LayoutObject->{LanguageObject}->Translate('Open ticket'),
                Name        => $Data{$ServiceDataID}->{Name},
                NameShort   => $Data{$ServiceDataID}->{NameShort},
                URLToAcess  => "Action=NewTicketService;ServiceID=$ServiceDataID",
            },
        );
    }

}
sub _SearchMyTikets {
    my ( $Self, %Param ) = @_;

    my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject  = $Kernel::OM->Get('Kernel::System::Ticket');
    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $Config        = $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::CustomerTicketMessage");

    my $ServicesNotAllowed = $ConfigObject->Get('CustomerPortal::Core::ServicesNotAllowed');
    my $HiddeQueues        = $ConfigObject->Get("CustomerPortal::Core::HiddeTicketsByQueue");

    my $SortBy             = $ConfigObject->Get('Ticket::CustomerTicketSearch::SortBy::Default') || 'Age';
    my $CurrentOrder       = $ConfigObject->Get('Ticket::CustomerTicketSearch::Order::Default')  || 'Down';
    my $SearchLimit        = $ConfigObject->Get('Ticket::CustomerTicketSearch::SearchLimit')     || 200;

    my $TicketIDLookup = $TicketObject->TicketIDLookup(
        TicketNumber => $Param{Search},
    );

    my @ViewableTicketIDs;

    if ( $TicketIDLookup ) {
        @ViewableTicketIDs = ( $TicketIDLookup );
    }
    else {

        # perform ticket search
        @ViewableTicketIDs = $TicketObject->TicketSearch(
            Result              => 'ARRAY',
            CustomerUserID      => $Self->{UserID},
            SortBy              => $SortBy,
            OrderBy             => $CurrentOrder,
            Limit               => $SearchLimit,
            CustomerUserID      => $Self->{UserID},
            ConditionInline     => $Config->{ExtendedSearchCondition},
            ContentSearchPrefix => '*',
            ContentSearchSuffix => '*',
            FullTextIndex       => 1,
            Fulltext            => $Param{Search},
            Permission          => 'ro',
        );
    }

    # if there are results to show
    if (@ViewableTicketIDs) {

        TICKET:
        for my $TicketID (@ViewableTicketIDs) {

            # Get ticket data.
            my %Ticket = $TicketObject->TicketGet(
                TicketID      => $TicketID,
                DynamicFields => 0,
                # Extended      => 1,
                UserID        => $Self->{UserID},
            );

            if ( grep { $_ eq $Ticket{Queue} } @{ $HiddeQueues } ) {
                next TICKET;
            }

            if ( $ServicesNotAllowed ) {

                if ( $Ticket{ServiceID} ) {

                    if ( grep( $Ticket{ServiceID} eq $_, @{ $ServicesNotAllowed } ) && $Ticket{CustomerUserID} ne $Self->{UserID} ){
                        next TICKET;
                    }
                }
            }

            # add blocks to template
            $LayoutObject->Block(
                Name => 'Record',
                Data => {
                    TypeObject  => $LayoutObject->{LanguageObject}->Translate('Ticket'),
                    Description => $LayoutObject->{LanguageObject}->Translate('To view'),
                    Name        => $Ticket{Title},
                    URLToAcess  => "Action=CustomerPortalTicketZoom;TicketNumber=$Ticket{TicketNumber}"
                },
            );
        }
    }

}
sub _SearchFAQs {
    my ( $Self, %Param ) = @_;

    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $FAQObject     = $Kernel::OM->Get('Kernel::System::FAQ');


    my @IDs = $FAQObject->FAQSearch(
            Valid  => 0,
            UserID => 1,
            What   => "$Param{Search}",           
        );

        for my $ItemID (@IDs){

            my %FAQ = $FAQObject->FAQGet(
                ItemID     => $ItemID,
                ItemFields => 1,
                UserID     => 1,
            );

            if($FAQ{State} ne 'internal (agent)'){

                # add blocks to template
                $LayoutObject->Block(
                    Name => 'Record',
                    Data => {
                        TypeObject  => $LayoutObject->{LanguageObject}->Translate('FAQ'),
                        Description => $LayoutObject->{LanguageObject}->Translate('To view'),
                        Name        =>  $FAQ{Title},
                        URLToAcess  => "Action=CustomerPortalFAQZoom;ItemID=$FAQ{ID}",

                    },
                );
            }            
        }
}
1;