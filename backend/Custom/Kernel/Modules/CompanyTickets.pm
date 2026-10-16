# --
# Kernel/Modules/CompanyTickets.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * ccresencio@serviceup.com.br
# * jsantos@serviceup.com.br
# * jguedes@serviceup.com.br
# -- 

package Kernel::Modules::CompanyTickets;

use strict;
use warnings;

use utf8;
use Data::Dumper;

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
    
    my $ParamObject                = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ConfigObject               = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject               = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $CustomerUserObject         = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');

    # disable output of customer company tickets
    my $DisableCompanyTickets = $ConfigObject->Get('Ticket::Frontend::CustomerDisableCompanyTicketAccess');

    my $ConfigEnableCompanyTickets = $ConfigObject->Get('CustomerPortal::Core::ShowMenuCompanyTickets');

    if( $ConfigEnableCompanyTickets ){
        my %User = $CustomerUserObject->CustomerUserDataGet(
            User => $Self->{UserLogin},
        );     
      
        if( $User{$ConfigEnableCompanyTickets->{FieldName}} eq $ConfigEnableCompanyTickets->{FieldValue} && !$DisableCompanyTickets){
            
            return $Self->_ShowOverview(
                %Param,                
            );
        }
        else{
 
            $CustomerPortalLayoutObject->CreateNavBar(
                ActionActive => "CompanyTickets",
                %{$Self}
            );

	        my $ActionTitle = $ConfigObject->Get('CustomerPortal::Core::ActionTitle');

            my %Message;

            $Param{Message} = $LayoutObject->{LanguageObject}->Translate("No permissions to view screen.");
            $Param{Comment} = $LayoutObject->{LanguageObject}->Translate("No permissions to view screen. Please contact the responsible team for more information.");

            $LayoutObject->Block(
                Name => 'Error',
                Data => \%Message,
            );

            # build output
            my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{CompanyTickets} );

            $Output .= $LayoutObject->Output(
                TemplateFile => "CustomerPortalError",
                Data         => \%Message,
            );

            $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

            return $Output;
        }
    }
    else{
    
        if( !$DisableCompanyTickets) {

            return $Self->_ShowOverview(
                %Param,
            );
        }
        else{

            $CustomerPortalLayoutObject->CreateNavBar(
                ActionActive => "CompanyTickets",
                %{$Self}
            );

	        my $ActionTitle = $ConfigObject->Get('CustomerPortal::Core::ActionTitle');

            my %Message;

            $Message{Message} = $LayoutObject->{LanguageObject}->Translate("You do not have permission to view this page.");
		    $Message{Comment} = $LayoutObject->{LanguageObject}->Translate("Please contact the responsible team for more information.");

            $LayoutObject->Block(
                Name => 'Error',
                Data => \%Message,
            );

            # build output
            my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{CompanyTickets} );

            $Output .= $LayoutObject->Output(
                TemplateFile => "CustomerPortalError",
                Data         => \%Message,
            );

            $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

            return $Output;
        }
    }

    return $Self->_ShowOverview(
        %Param,
    );
}

sub _ShowOverview {
    my ( $Self, %Param ) = @_;

    my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');
    my $LayoutObject               = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject               = $Kernel::OM->Get('Kernel::Config');
    my $ParamObject                = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $TicketObject               = $Kernel::OM->Get('Kernel::System::Ticket');
    my $BackendObject              = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $DynamicFieldObject         = $Kernel::OM->Get('Kernel::System::DynamicField');

    # disable output of customer company tickets
    my $DisableCompanyTickets = $ConfigObject->Get('Ticket::Frontend::CustomerDisableCompanyTicketAccess');
    my $ServicesNotAllowed    = $ConfigObject->Get('CustomerPortal::Core::ServicesNotAllowed');
    my $HiddeQueues           = $ConfigObject->Get("CustomerPortal::Core::HiddeTicketsByQueue");
    my $EnableCopyTickets     = $ConfigObject->Get('CustomerPortal::CompanyTickets::ToEnableTicketsWithUserInCopy');

    my $BulkFeature = 1;

    # check subaction
    if ( !$Self->{Subaction} ) {
        return $LayoutObject->Redirect(
            OP => 'Action=CompanyTickets;Subaction=CompanyTickets',
        );
    }
    elsif ( $Self->{Subaction} eq 'CompanyTickets' && $DisableCompanyTickets ) {
        return $LayoutObject->CustomerNoPermission( WithHeader => 'yes' );
    }

    # check needed CustomerID
    if ( !$Self->{UserCustomerID} ) {
        my $Output = $LayoutObject->CustomerHeader(
            Title => Translatable('Error'),
        );
        $Output .= $LayoutObject->CustomerError(
            Message => Translatable('Need CustomerID!'),
        );
        $Output .= $LayoutObject->CustomerFooter();
        return $Output;
    }

    $Kernel::OM->Get('Kernel::System::AuthSession')->UpdateSessionID(
        SessionID => $Self->{SessionID},
        Key       => 'LastScreenOverview',
        Value     => $Self->{RequestedURL},
    );

    # my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');

    $CustomerPortalLayoutObject->CreateNavBar(
        ActionActive => "CompanyTickets",
        %{$Self}
    );

    $LayoutObject->Block( Name => 'ShowMyCompanyTickets' );

    $Param{Title}  = '';
    $Param{Active} = 'CompanyTickets';

    my $ActionTitle = $ConfigObject->Get('CustomerPortal::Core::ActionTitle');

    my $StateFilter     = $ConfigObject->Get('CustomerPortal::Core::StateFilter');

    my $SortBy         = $ParamObject->GetParam( Param => 'SortBy' )  || 'Age';
    my $OrderByCurrent = $ParamObject->GetParam( Param => 'OrderBy' ) || 'Down';
    my $Search         = $ParamObject->GetParam( Param => 'Search' ) || '';

    if ( $Self->{Subaction} eq 'SetVoteStar' ){
               
        $Param{Classification}  = $ParamObject->GetParam( Param => 'Classification' ) || '';
        $Param{TicketNumber}    = $ParamObject->GetParam( Param => 'TN' ) || '';
        $Param{Comment}         = $ParamObject->GetParam( Param => 'Comment' ) || '';

        my $TicketID = $TicketObject->TicketCheckNumber(
            Tn => $Param{TicketNumber},
        );

        my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
            Name => 'TicketStarAvaliation',
        );

        my $SuccessSetStarAvalition = $BackendObject->ValueSet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ObjectID           => $TicketID,
            Value              => $Param{Classification},                   
            UserID             => $ConfigObject->Get('CustomerPanelUserID'),
        );

        my $DynamicFieldConfigNote = $DynamicFieldObject->DynamicFieldGet(
            Name => 'TicketNoteAvalition',
        );

        if ( $SuccessSetStarAvalition ){
           
            my $VoteToNoteRequired =  $ConfigObject->Get('CustomerPortal::Core::TicketStarAvaliation::VoteToNoteRequired');

            my $ConfigNameStar = 'Star';

            if ( $Param{Classification} > 1 ){
                $ConfigNameStar = 'Stars';
            }

            my $NameStarClassification = "$Param{Classification}" . " " .  "$ConfigNameStar";

            if ( $VoteToNoteRequired->{$NameStarClassification} eq '1' ){
                if( $Param{Comment} ){
                    my $SuccessSetNoteAvalition = $BackendObject->ValueSet(
                        DynamicFieldConfig => $DynamicFieldConfigNote,
                        ObjectID           => $TicketID,
                        Value              => $Param{Comment},                   
                        UserID             => $ConfigObject->Get('CustomerPanelUserID'),
                    );
                }
            }

            if( ! $Param{Comment} ){
                my $SuccessDeleteNoteAvalition = $BackendObject->ValueDelete(
                    DynamicFieldConfig => $DynamicFieldConfigNote,    
                    ObjectID           => $TicketID,                                                               
                    UserID             => $ConfigObject->Get('CustomerPanelUserID'),
                );
            }

            my $SuccessSetHistory = $TicketObject->HistoryAdd(
                Name         =>  $LayoutObject->{LanguageObject}
                        ->Translate( 'Vote added by "%s"', $Self->{UserLogin} ),
                HistoryType  => 'Misc', 
                TicketID     => $TicketID,
                CreateUserID => $ConfigObject->Get('CustomerPanelUserID'),
            );

        }

        # send JSON response
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     =>  1,
            Type        => 'inline',
            NoCache     => 1,
        );

    }
    else{
        # filter definition
        my %Filters = (
            MyTickets => {
                All => {
                    Name   => 'All',
                    Prio   => 1000,
                    Search => {
                        CustomerUserLoginRaw => $Self->{UserID},
                        # States                => $StateFilter->{all},
                        OrderBy              => $OrderByCurrent,
                        SortBy               => $SortBy,
                        CustomerUserID       => $Self->{UserID},
                        Permission           => 'ro',
                    },
                },
                Open => {
                    Name   => 'Open',
                    Prio   => 1100,
                    Search => {
                        CustomerUserLoginRaw => $Self->{UserID},
                        States                => $StateFilter->{open},
                        OrderBy              => $OrderByCurrent,
                        SortBy               => $SortBy,
                        CustomerUserID       => $Self->{UserID},
                        Permission           => 'ro',
                    },
                },
                Closed => {
                    Name   => 'Closed',
                    Prio   => 1200,
                    Search => {
                        CustomerUserLoginRaw => $Self->{UserID},
                        States                => $StateFilter->{closed},
                        OrderBy              => $OrderByCurrent,
                        SortBy               => $SortBy,
                        CustomerUserID       => $Self->{UserID},
                        Permission           => 'ro',
                    },
                },
                Pending => {
                    Name   => 'Pending',
                    Prio   => 1300,
                    Search => {
                        CustomerUserLoginRaw => $Self->{UserID},
                        States                => $StateFilter->{pending},
                        OrderBy              => $OrderByCurrent,
                        SortBy               => $SortBy,
                        CustomerUserID       => $Self->{UserID},
                        Permission           => 'ro',
                    },
                },
                 Pending1 => {
                    Name   => 'Pending1',
                    Prio   => 1301,
                    Search => {
                        CustomerUserLoginRaw => $Self->{UserID},
                        States                => $StateFilter->{pending},
                        OrderBy              => $OrderByCurrent,
                        SortBy               => $SortBy,
                        CustomerUserID       => $Self->{UserID},
                        Permission           => 'ro',
                    },
                },
            },
        );

        if ( scalar @{ $StateFilter->{all} } > 0 ) {
            $Filters{MyTickets}->{All}->{Search}{States} = $StateFilter->{all};
        }

        if ( $Search ) {

            $Filters{MyTickets}->{All}->{Search}{Fulltext}     = $Search;
            $Filters{MyTickets}->{Open}->{Search}{Fulltext}    = $Search;
            $Filters{MyTickets}->{Closed}->{Search}{Fulltext}  = $Search;
            $Filters{MyTickets}->{Pending}->{Search}{Fulltext} = $Search;
        }


        my $UserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');

        my %User = $UserObject->CustomerUserDataGet(
            User => $Self->{UserLogin},
        );
        my $UserEmail = $User{UserEmail};

        my @CustomerIDs;

        # Add filter for customer company if the company tickets are not disabled.
        if ( !$DisableCompanyTickets ) {
            my %AccessibleCustomers = $Kernel::OM->Get('Kernel::System::CustomerGroup')->GroupContextCustomers(
                CustomerUserID => $Self->{UserID},
            );

            # Show customer companies as additional filter selection.
            if ( $Self->{Subaction} eq 'CompanyTickets' && scalar keys %AccessibleCustomers > 1 ) {

                @CustomerIDs = $ParamObject->GetArray( Param => 'CustomerIDs' );

                # Prevent array item duplication.
                my %CustomerIDsHash = map { $_ => 1 } @CustomerIDs;
                @CustomerIDs = sort keys %CustomerIDsHash;

                $Param{CustomerIDStrg} = $LayoutObject->BuildSelection(
                    Data       => \%AccessibleCustomers,
                    Name       => 'CustomerIDs',
                    Multiple   => 1,
                    Size       => 1,
                    SelectedID => \@CustomerIDs,
                    Class      => 'Modernize',
                );

                # Remember the active customer ID filter.
                $Param{CustomerIDs} = '';
                for my $CustomerID (@CustomerIDs) {
                    $Param{CustomerIDs} .= ';CustomerIDs=' . $LayoutObject->LinkEncode($CustomerID);
                }
            }
            else {

                # Default behavior - use all available customer IDs.
                @CustomerIDs = sort keys %AccessibleCustomers;
            }

            $Filters{CompanyTickets} = {
                All => {
                    Name   => 'All',
                    Prio   => 1000,
                    Search => {
                        CustomerIDRaw  => \@CustomerIDs,
                        OrderBy        => $OrderByCurrent,
                        SortBy         => $SortBy,
                        CustomerUserID => $Self->{UserID},
                        Permission     => 'ro',
                    },
                },
                Open => {
                    Name   => 'Open',
                    Prio   => 1100,
                    Search => {
                        CustomerIDRaw  => \@CustomerIDs,
                        States         => $StateFilter->{open},
                        OrderBy        => $OrderByCurrent,
                        SortBy         => $SortBy,
                        CustomerUserID => $Self->{UserID},
                        Permission     => 'ro',
                    },
                },
                Closed => {
                    Name   => 'Closed',
                    Prio   => 1200,
                    Search => {
                        CustomerIDRaw  => \@CustomerIDs,
                        States         => $StateFilter->{closed},
                        OrderBy        => $OrderByCurrent,
                        SortBy         => $SortBy,
                        CustomerUserID => $Self->{UserID},
                        Permission     => 'ro',
                    },
                },
                Pending => {
                    Name   => 'Pending',
                    Prio   => 1300,
                    Search => {
                        States         => $StateFilter->{pending},
                        CustomerIDRaw  => \@CustomerIDs,
                        OrderBy        => $OrderByCurrent,
                        SortBy         => $SortBy,
                        CustomerUserID => $Self->{UserID},
                        Permission     => 'ro',
                    },
                }               
            };

            if ( scalar @{ $StateFilter->{all} } > 0 ) {
                $Filters{CompanyTickets}->{All}->{Search}{States} = $StateFilter->{all};
            }

            if ( $Search ) {

                $Filters{CompanyTickets}->{All}->{Search}{Fulltext}     = $Search;
                $Filters{CompanyTickets}->{Open}->{Search}{Fulltext}    = $Search;
                $Filters{CompanyTickets}->{Closed}->{Search}{Fulltext}  = $Search;
                $Filters{CompanyTickets}->{Pending}->{Search}{Fulltext} = $Search;
            }
        }

        my %CustomFilter;

        my $ConfigCustomFilter = $ConfigObject->Get('CustomerPortal::Core::CustomFilterCompanyTickets');

        if ( $ConfigCustomFilter ) {

            for my $NameFilter ( keys %{ $ConfigCustomFilter }) {
                $CustomFilter{$NameFilter} = $ConfigCustomFilter->{$NameFilter};
            }
        }

        my $FilterCurrent = $ParamObject->GetParam( Param => 'Filter' ) || 'Open';

        my $SearchParam   = $ParamObject->GetParam( Param => 'SearchParam' );

        if ( $Search && !$SearchParam ) {

            $FilterCurrent = 'All';
        }

        # check if filter is valid
        if ( !$Filters{ $Self->{Subaction} }->{$FilterCurrent} ) {
            my $Output = $LayoutObject->CustomerHeader(
                Title => Translatable('Error'),
            );
            $Output .= $LayoutObject->CustomerError(
                Message => $LayoutObject->{LanguageObject}->Translate( 'Invalid Filter: %s!', $FilterCurrent ),
            );
            $Output .= $LayoutObject->CustomerFooter();
            return $Output;
        }

        # check if archive search is allowed, otherwise search for all tickets
        my %SearchInArchive;
        if (
            $ConfigObject->Get('Ticket::ArchiveSystem')
            && !$ConfigObject->Get('Ticket::CustomerArchiveSystem')
            )
        {
            $SearchInArchive{ArchiveFlags} = [ 'y', 'n' ];
        }

        my %NavBarFilter;
        my $Counter         = 0;
        my $AllTickets      = 0;
        my $AllTicketsTotal = 0;
        my $TicketObject    = $Kernel::OM->Get('Kernel::System::Ticket');

        if ( $Search ) {

            my $TicketID = $TicketObject->TicketIDLookup(
                TicketNumber => $Search,
                UserID       => $Self->{UserID},
            );
            
            if ($TicketID) {
                return $LayoutObject->Redirect(
                    OP => "Action=CustomerPortalTicketZoom;TicketNumber=$Search",
                );
            }
        }

        for my $Filter ( sort keys %{ $Filters{ $Self->{Subaction} } } ) {

            my $Count = 0;
            $Counter++;
            my @AllTickets;

            if ( $ServicesNotAllowed || $HiddeQueues ) {

                if( $EnableCopyTickets eq 'Yes' ){
                    
                    @AllTickets = $TicketObject->TicketSearch(
                        %{ $Filters{ $Self->{Subaction} }->{$Filter}->{Search} },
                        %SearchInArchive,
                        %CustomFilter,
                        Result              => 'ARRAY',
                        ContentSearchPrefix => '*',
                        ContentSearchSuffix => '*',
                    );

                    my %SearchParams = %{ $Filters{ $Self->{Subaction} }->{$Filter}->{Search} };
                    delete @SearchParams{qw(CustomerUserID CustomerUserLoginRaw CustomerIDRaw)};

                    my @CcTickets = $TicketObject->TicketSearch(
                        %SearchParams,
                        %SearchInArchive,
                        %CustomFilter,
                        MIMEBase_Cc         => '%' . $UserEmail . '%',
                        Result              => 'ARRAY',
                        ContentSearchPrefix => '*',
                        ContentSearchSuffix => '*',
                        UserID              => 1,
                    );  

                    my @DynamicFieldCcTickets = $TicketObject->TicketSearch(
                        %SearchParams,
                        %SearchInArchive,
                        %CustomFilter,
                        DynamicField_CustomerCC => {
                            Like => '%' . $UserEmail . '%'
                        },
                        Result              => 'ARRAY',
                        ContentSearchPrefix => '*',
                        ContentSearchSuffix => '*',
                        UserID              => 1,
                    );

                    my %Seen;
                    @AllTickets = grep { !$Seen{$_}++ } ( @AllTickets, @CcTickets, @DynamicFieldCcTickets );

                } else {

                    @AllTickets = $TicketObject->TicketSearch(
                        %{ $Filters{ $Self->{Subaction} }->{$Filter}->{Search} },
                        %SearchInArchive,
                        %CustomFilter,
                        Result              => 'ARRAY',
                        ContentSearchPrefix => '*',
                        ContentSearchSuffix => '*',
                        FullTextIndex       => 1,
                    );

                }

                TICKET:
                foreach my $TicketID ( @AllTickets ){
                    
                    my %Ticket = $TicketObject->TicketGet(
                        TicketID => $TicketID,
                        UserID   => 1,
                    );
    
                    if ( $Ticket{ServiceID} ) {

                        if ( grep( $Ticket{ServiceID} eq $_, @{ $ServicesNotAllowed } ) && $Ticket{CustomerUserID} ne $Self->{UserID} ){
                            next TICKET;
                        }
                    }

                    if ( grep { $_ eq $Ticket{Queue} } @{ $HiddeQueues } ) {
                        next TICKET;
                    }

                    $Count++;
                }
            }
            else {
                
                if( $EnableCopyTickets eq 'Yes' ){

                    my @CustomerTicketIDs = $TicketObject->TicketSearch(
                        %{ $Filters{ $Self->{Subaction} }->{$Filter}->{Search} },
                        %SearchInArchive,
                        %CustomFilter,
                        Result              => 'ARRAY',
                        ContentSearchPrefix => '*',
                        ContentSearchSuffix => '*',
                    );

                    my %SearchParams = %{ $Filters{ $Self->{Subaction} }->{$Filter}->{Search} };
                    delete @SearchParams{qw(CustomerUserID CustomerUserLoginRaw CustomerIDRaw)};

                    my @CcTicketIDs = $TicketObject->TicketSearch(
                        %SearchParams,
                        %SearchInArchive, 
                        %CustomFilter,
                        MIMEBase_Cc         => '%' . $UserEmail . '%',
                        Result              => 'ARRAY',
                        ContentSearchPrefix => '*',
                        ContentSearchSuffix => '*',
                        UserID              => 1,
                    );

                    my @DynamicFieldCcTicketIDs = $TicketObject->TicketSearch(
                        %SearchParams,
                        %SearchInArchive,
                        %CustomFilter,
                        DynamicField_CustomerCC => {
                            Like => '%' . $UserEmail . '%'
                        },
                        Result              => 'ARRAY',
                        ContentSearchPrefix => '*',
                        ContentSearchSuffix => '*',
                        UserID              => 1,
                    );

                    my %Seen;
                    my @AllUniqueTicketIDs = grep { !$Seen{$_}++ } ( @CustomerTicketIDs, @CcTicketIDs, @DynamicFieldCcTicketIDs );

                    $Count = scalar @AllUniqueTicketIDs;

                } else {

                    $Count = $TicketObject->TicketSearch(
                        %{ $Filters{ $Self->{Subaction} }->{$Filter}->{Search} },
                        %SearchInArchive,
                        %CustomFilter,
                        Result              => 'COUNT',
                        ContentSearchPrefix => '*',
                        ContentSearchSuffix => '*',
                        FullTextIndex       => 1,
                    ) || 0;

                }
            }

            my $ClassA = '';
            if ( $Filter eq $FilterCurrent ) {
                $ClassA     = 'Selected';
                $AllTickets = $Count;
            }
            if ( $Filter eq 'All' ) {
                $AllTicketsTotal = $Count;
            }
            $NavBarFilter{ $Filters{ $Self->{Subaction} }->{$Filter}->{Prio} } = {
                %{ $Filters{ $Self->{Subaction} }->{$Filter} },
                Count  => $Count,
                Filter => $Filter,
                ClassA => $ClassA,
            };
        }

        my $StartHit  = int( $ParamObject->GetParam( Param => 'StartHit' ) || 1 );
        my $PageShown = $Self->{UserShowTickets} || 25;


        # create & return output
        my $Link = 'SortBy=' . $LayoutObject->Ascii2Html( Text => $SortBy )
            . ';OrderBy=' . $LayoutObject->Ascii2Html( Text => $OrderByCurrent )
            . ';Filter=' . $LayoutObject->Ascii2Html( Text => $FilterCurrent )
            . ';Subaction=' . $LayoutObject->Ascii2Html( Text => $Self->{Subaction} )
            . ';';

        if ( $Search ) {
            $Link .= "Search=$Search;";
            $Param{SearchText} = "Search=$Search;SearchParam=1;";
        }

        # Add CustomerIDs parameter if needed.
        if ( IsArrayRefWithData( \@CustomerIDs ) ) {
            for my $CustomerID (@CustomerIDs) {
                $Link .= "CustomerIDs=$CustomerID;";
            }
        }

        my %PageNav = $LayoutObject->PageNavBar(
            Limit     => 10000,
            StartHit  => $StartHit,
            PageShown => $PageShown,
            AllHits   => $AllTickets,
            Action    => 'Action=CompanyTickets',
            Link      => $Link,
            IDPrefix  => 'CompanyTickets',
        );

        my $OrderBy = 'Down';

        if ( $OrderByCurrent eq 'Down' ) {
            $OrderBy = 'Up';
        }

        my $Sort         = '';
        my $StateSort    = 'SortClick';
        my $TicketSort   = 'SortClick';
        my $TitleSort    = 'SortClick';
        my $AgeSort      = 'SortClick';
        my $QueueSort    = 'SortClick';
        my $OwnerSort    = 'SortClick';
        my $ServiceSort  = 'SortClick';
        my $TypeSort     = 'SortClick';
        my $SLASort      = 'SortClick';
        my $PrioritySort = 'SortClick';

        # this sets the opposite to the $OrderBy
        if ( $OrderBy eq 'Down' ) {
            $Sort = 'SortAscending';
        }

        if ( $OrderBy eq 'Up' ) {
            $Sort = 'SortDescending';
        }

        if ( $SortBy eq 'State' ) {
            $StateSort = $Sort;
        }
        elsif ( $SortBy eq 'Ticket' ) {
            $TicketSort = $Sort;
        }
        elsif ( $SortBy eq 'Title' ) {
            $TitleSort = $Sort;
        }
        elsif ( $SortBy eq 'Age' ) {
            $AgeSort = $Sort;
        }
        elsif ( $SortBy eq 'Queue' ) {
            $QueueSort = $Sort;
        }
        elsif ( $SortBy eq 'Owner' ) {
            $OwnerSort = $Sort;
        }
        elsif ( $SortBy eq 'Service' ) {
            $ServiceSort = $Sort;
        }
        elsif ( $SortBy eq 'Type' ) {
            $TypeSort = $Sort;
        }
        elsif ( $SortBy eq 'SLA' ) {
            $SLASort = $Sort;
        }
        elsif ( $SortBy eq 'Priority' ) {
            $PrioritySort = $Sort;
        }

        my %SortClassHeader = (
            TicketNumber  => $TicketSort,
            Service       => $ServiceSort,
            Type          => $TypeSort,
            Title         => $TitleSort,
            State         => $StateSort,
            Age           => $AgeSort,
            SLA           => $SLASort,
            Priority      => $PrioritySort,
            PriorityColor => $PrioritySort,
        );

        $LayoutObject->Block(
            Name => 'Filled',
            Data => {
                %Param,
                %PageNav,
                # OrderBy    => $OrderBy,
                # StateSort  => $StateSort,
                # TicketSort => $TicketSort,
                # TitleSort  => $TitleSort,
                # AgeSort    => $AgeSort,
                # Filter     => $FilterCurrent,
            },
        );

        my %SortHeader = (
            TicketNumber  => 'Ticket',
            Service       => 'Service',
            Title         => 'Title',
            State         => 'State',
            Age           => 'Age',
            Type          => 'Type',
            SLA           => 'SLA',
            Priority      => 'Priority',
            PriorityColor => 'Priority',
        );

        my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
        my $Columns = $ConfigObject->Get('CustomerPortal::CompanyTickets::Settings');

        my @VisibleColumns = @{ $Columns->{VisibleColumns} };

        my $Total = 0;

        for my $ColumnName ( @VisibleColumns ) {

            $Total++;

            my $ClassSort = 'SortClick';

            my $CheckClass = $SortHeader{$ColumnName} || $ColumnName;

            if ( $CheckClass eq $SortBy ) {
                $ClassSort = $Sort;
            }

            if ( $ColumnName =~ /DynamicField_/ ) {

                my @ColumnDFName = split /DynamicField_/, $ColumnName;
                
                my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
                    Name => $ColumnDFName[1],
                );

                $ColumnName = $DynamicField->{Label};

                $SortHeader{$ColumnName} = 'DynamicField_' . $ColumnDFName[1];
            }

            if ( $ColumnName eq 'PriorityColor' ) {

                $LayoutObject->Block(
                    Name => 'TableHeader',
                    Data => { 
                        LabelHeader => $LayoutObject->{LanguageObject}->Translate("   "),
                        HeaderSort  => $SortHeader{$ColumnName} || $ColumnName,
                        ClassSort   => $ClassSort,
                        OrderBy     => $OrderBy,
                        Filter      => $FilterCurrent,
                        Search      => $Search
                    }
                );
            }
            else {

                $LayoutObject->Block(
                    Name => 'TableHeader',
                    Data => { 
                        LabelHeader => $LayoutObject->{LanguageObject}->Translate("$ColumnName"),
                        HeaderSort  => $SortHeader{$ColumnName} || $ColumnName,,
                        ClassSort   => $ClassSort,
                        OrderBy     => $OrderBy,
                        Filter      => $FilterCurrent,
                        Search      => $Search
                    }
                );
                
            
            }
            
        }

        if ($BulkFeature) {
            $LayoutObject->Block(
                Name => 'BulkNavBar',
                Data => \%Param,
            );
        }

        if ( $ConfigObject->Get('CustomerPortal::Core::TicketStarAvaliation::ToEnableTicketStarAvaliation') eq 'Yes' ) {
            my $DynamicFieldStarConfig = $DynamicFieldObject->DynamicFieldGet(
                Name => 'TicketStarAvaliation',
            );

            $LayoutObject->Block(
                Name => 'TableHeader',
                Data => { 
                    LabelHeader => $DynamicFieldStarConfig->{Label},                  
                }
            );

            my $DynamicFieldNoteConfig = $DynamicFieldObject->DynamicFieldGet(
                Name => 'TicketNoteAvalition',
            );

            $LayoutObject->Block(
                Name => 'ModalCommentStarVote',
                Data => {               
                    TicketNoteAvalitionLabel => $DynamicFieldNoteConfig->{Label},     
                },
            );
        }

        my $Owner = $ConfigObject->Get('Ticket::Frontend::CustomerTicketOverview')->{Owner};
        my $Queue = $ConfigObject->Get('Ticket::Frontend::CustomerTicketOverview')->{Queue};

        if ($Owner) {

            $Total++;

            $LayoutObject->Block(
                Name => 'OverviewNavBarPageOwner',
                Data => {
                    OrderBy   => $OrderBy,
                    OwnerSort => $OwnerSort,
                    Filter    => $FilterCurrent,
                },
            );
        }

        if ($Queue) {

            $Total++;

            $LayoutObject->Block(
                Name => 'OverviewNavBarPageQueue',
                Data => {
                    OrderBy   => $OrderBy,
                    QueueSort => $QueueSort,
                    Filter    => $FilterCurrent,
                },
            );
        }

        $LayoutObject->Block(
            Name => 'FilterPriorities',
            Data => {
                ValueSearch => $Search || ''
            },
        );

        # show header filter
        for my $Key ( sort keys %NavBarFilter ) {
            $LayoutObject->Block(
                Name => 'FilterHeader',
                Data => {
                    %Param,
                    %{ $NavBarFilter{$Key} },
                },
            );
        }

        # show footer filter - show only if more the one page is available
        if ( $AllTickets > $PageShown ) {
            $LayoutObject->Block(
                Name => 'FilterFooter',
                Data => {
                    %Param,
                    %PageNav,
                },
            );
        }
        for my $Key ( sort keys %NavBarFilter ) {
            if ( $AllTickets > $PageShown ) {
                $LayoutObject->Block(
                    Name => 'FilterFooterItem',
                    Data => {
                        %Param,
                        %PageNav,
                        %{ $NavBarFilter{$Key} },

                    },
                );
            }
        }

        # get the dynamic fields for this screen
        # my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
        # my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

        # get dynamic field config for frontend module
        my $DynamicFieldFilter = $ConfigObject->Get("Ticket::Frontend::CustomerTicketOverview")->{DynamicField};
        my $DynamicField       = $DynamicFieldObject->DynamicFieldListGet(
            Valid       => 1,
            ObjectType  => ['Ticket'],
            FieldFilter => $DynamicFieldFilter || {},
        );

        # reduce the dynamic fields to only the ones that are desinged for customer interface
        my @CustomerDynamicFields;
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{$DynamicField} ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

            my $IsCustomerInterfaceCapable = $BackendObject->HasBehavior(
                DynamicFieldConfig => $DynamicFieldConfig,
                Behavior           => 'IsCustomerInterfaceCapable',
            );
            next DYNAMICFIELD if !$IsCustomerInterfaceCapable;

            push @CustomerDynamicFields, $DynamicFieldConfig;
        }
        $DynamicField = \@CustomerDynamicFields;

        # Dynamic fields
        # cycle trough the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{$DynamicField} ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

            my $Label = $DynamicFieldConfig->{Label};

            # get field sortable condition
            my $IsSortable = $BackendObject->HasBehavior(
                DynamicFieldConfig => $DynamicFieldConfig,
                Behavior           => 'IsSortable',
            );

            if ($IsSortable) {
                my $CSS = 'SortClick';
                if (
                    $SortBy
                    && ( $SortBy eq ( 'DynamicField_' . $DynamicFieldConfig->{Name} ) )
                    )
                {
                    if ( $OrderByCurrent && ( $OrderByCurrent eq 'Up' ) ) {
                        $OrderBy = 'Down';
                        $CSS .= ' SortDescending';
                    }
                    else {
                        $OrderBy = 'Up';
                        $CSS .= ' SortAscending';
                    }
                }

                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageDynamicField',
                    Data => {
                        %Param,
                        CSS => $CSS,
                    },
                );

                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageDynamicFieldSortable',
                    Data => {
                        %Param,
                        OrderBy          => $OrderBy,
                        Label            => $Label,
                        DynamicFieldName => $DynamicFieldConfig->{Name},
                        Filter           => $FilterCurrent,
                    },
                );

                # example of dynamic fields order customization
                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageDynamicField_' . $DynamicFieldConfig->{Name},
                    Data => {
                        %Param,
                        CSS => $CSS,
                    },
                );

                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageDynamicField_'
                        . $DynamicFieldConfig->{Name}
                        . '_Sortable',
                    Data => {
                        %Param,
                        OrderBy          => $OrderBy,
                        Label            => $Label,
                        DynamicFieldName => $DynamicFieldConfig->{Name},
                        Filter           => $FilterCurrent,
                    },
                );

                $Total++;
            }
            else {

                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageDynamicField',
                    Data => {
                        %Param,
                    },
                );

                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageDynamicFieldNotSortable',
                    Data => {
                        %Param,
                        Label => $Label,
                    },
                );

                # example of dynamic fields order customization
                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageDynamicField_' . $DynamicFieldConfig->{Name},
                    Data => {
                        %Param,
                    },
                );

                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageDynamicField_'
                        . $DynamicFieldConfig->{Name}
                        . '_NotSortable',
                    Data => {
                        %Param,
                        Label => $Label,
                    },
                );

                $Total++;
            }
        }

        if ( !$AllTicketsTotal ) {

            $LayoutObject->Block(
                Name => 'NoDataFoundMsg',
                Data => {
                    Total => $Total
                },
            );

            # build output
            my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{CompanyTickets} );

            $Output .= $LayoutObject->Output(
                TemplateFile => 'CompanyTickets',
                Data         => \%Param,
            );

            # get page footer
            $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

            # return page
            return $Output;
        }

        my @ViewableTickets = $TicketObject->TicketSearch(
            %{ $Filters{ $Self->{Subaction} }->{$FilterCurrent}->{Search} },
            %SearchInArchive,
            %CustomFilter,
            Result              => 'ARRAY',
            ContentSearchPrefix => '*',
            ContentSearchSuffix => '*',
            FullTextIndex       => 1,
        );

        if( $EnableCopyTickets eq 'Yes' ){

            my %SearchParams = %{ $Filters{ $Self->{Subaction} }->{$FilterCurrent}->{Search} };
            delete @SearchParams{ qw(CustomerUserID CustomerIDRaw) };

            my @CcTickets = $TicketObject->TicketSearch(
                %SearchParams,
                Result              => 'ARRAY',
                MIMEBase_Cc         => '%' . $UserEmail . '%',
                UserID              => 1,
            );

            my @DynamicFieldCcTickets = $TicketObject->TicketSearch(
                %SearchParams,
                Result              => 'ARRAY',
                DynamicField_CustomerCC => {
                    Like => '%' . $UserEmail . '%'
                },
                UserID              => 1,
            );

            my %SeenTicket;
            my @Union = grep { !$SeenTicket{$_}++ } ( @ViewableTickets, @CcTickets, @DynamicFieldCcTickets );

            if( @Union ){
                @ViewableTickets = $TicketObject->TicketSearch(
                    TicketID => \@Union,                    
                    Result   => 'ARRAY',
                    SortBy   => $SearchParams{SortBy},      
                    OrderBy  => $SearchParams{OrderBy},
                    UserID   => 1,
                );
            }
        }

        if ( $ServicesNotAllowed || $HiddeQueues ) {

            my @AuxViewableTickets;

            TICKET:
            foreach my $TicketID ( @ViewableTickets ){
                
                my %Ticket = $TicketObject->TicketGet(
                    TicketID => $TicketID,
                    UserID   => 1,
                );

                if ( $Ticket{ServiceID} ) {

                    if ( grep( $Ticket{ServiceID} eq $_, @{ $ServicesNotAllowed } ) && $Ticket{CustomerUserID} ne $Self->{UserID} ){
                        next TICKET;
                    }
                }

                if ( grep { $_ eq $Ticket{Queue} } @{ $HiddeQueues } ) {
                    next TICKET;
                }

                push @AuxViewableTickets, $TicketID;
            }

            @ViewableTickets = @AuxViewableTickets;
        }

        my $TicketBulkByState = $ConfigObject->Get("CustomerPortal::Core::TicketBulkByState");

        my %TicketBulkByStateMap = map { $_ => 1 } @{ $TicketBulkByState };

        # show tickets
        $Counter = 0;
        for my $TicketID (@ViewableTickets) {
            $Counter++;
            if (
                $Counter >= $StartHit
                && $Counter < ( $PageShown + $StartHit )
                )
            {
                $Self->ShowTicketStatus( 
                    TicketID             => $TicketID,
                    BulkFeature          => $BulkFeature,
                    TicketBulkByStateMap => \%TicketBulkByStateMap,
                );
            }
        }

        # create & return output
        my $Title = $Self->{Subaction};
        if ( $Title eq 'MyTickets' ) {
            $Title = Translatable('My Tickets');
        }
        elsif ( $Title eq 'CompanyTickets' ) {
            $Title = Translatable('Company Tickets');
        }
        my $Refresh = '';
        if ( $Self->{UserRefreshTime} ) {
            $Refresh = 60 * $Self->{UserRefreshTime};
        }
        my $Output = $CustomerPortalLayoutObject->CustomerHeader(
            Title   => $Title,
            Refresh => $Refresh,
            Type    => 'Small',
            Title   => $ActionTitle->{CompanyTickets}
        );

        $Output .= $LayoutObject->Output(
            TemplateFile => 'CompanyTickets',
            Data         => \%Param,
        );

        # get page footer
        $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

        # return page
        return $Output;
    }

}

# ShowTicket
sub ShowTicketStatus {
    my ( $Self, %Param ) = @_;

    my $LayoutObject               = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject               = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ArticleObject              = $Kernel::OM->Get('Kernel::System::Ticket::Article');
    my $CommunicationChannelObject = $Kernel::OM->Get('Kernel::System::CommunicationChannel');
    my $UserObject                 = $Kernel::OM->Get('Kernel::System::User');
    my $DynamicFieldObject         = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $BackendObject              = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my $TicketID                   = $Param{TicketID} || return;

    # Get last customer article.
    my @ArticleList = $ArticleObject->ArticleList(
        TicketID             => $Param{TicketID},
        IsVisibleForCustomer => 1,
        OnlyLast             => 1,
    );

    my %Article;
    if ( $ArticleList[0] && IsHashRefWithData( $ArticleList[0] ) ) {
        my $ArticleBackendObject = $ArticleObject->BackendForArticle( %{ $ArticleList[0] } );
        %Article = $ArticleBackendObject->ArticleGet(
            TicketID  => $Param{TicketID},
            ArticleID => $ArticleList[0]->{ArticleID},
        );
    }

    # get ticket info
    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $TicketID,
        DynamicFields => 1,
    );

    my $Subject;
    my $ConfigObject          = $Kernel::OM->Get('Kernel::Config');
    my $SmallViewColumnHeader = $ConfigObject->Get('Ticket::Frontend::CustomerTicketOverview')->{ColumnHeader};

    # Check if the last customer subject or ticket title should be shown.
    # If ticket title should be shown, check if there are articles, because ticket title
    # could be related with a subject of an article which does not visible for customer (see bug#13614).
    # If there is no subject, set to 'Untitled'.
    if ( $SmallViewColumnHeader eq 'LastCustomerSubject' ) {
        $Subject = $Article{Subject} || '';
    }
    elsif ( $SmallViewColumnHeader eq 'TicketTitle' && $ArticleList[0] ) {
        $Subject = $Ticket{Title};
    }
    else {
        $Subject = Translatable('Untitled!');
    }

    # Condense down the subject.
    $Subject = $TicketObject->TicketSubjectClean(
        TicketNumber => $Ticket{TicketNumber},
        Subject      => $Subject,
    );

    # Age design.
    $Ticket{CustomerAge} = $LayoutObject->CustomerAge(
        Age   => $Ticket{Age},
        Space => ' '
    ) || 0;

    # return ticket information if there is no article
    if ( !IsHashRefWithData( \%Article ) ) {
        $Article{State}        = $Ticket{State};
        $Article{TicketNumber} = $Ticket{TicketNumber};
        $Article{Body}         = $LayoutObject->{LanguageObject}->Translate('This item has no articles yet.');
    }

    # customer info (customer name)
    if ( $Article{CustomerUserID} ) {
        $Param{CustomerName} = $Kernel::OM->Get('Kernel::System::CustomerUser')->CustomerName(
            UserLogin => $Article{CustomerUserID},
        );
        $Param{CustomerName} = '(' . $Param{CustomerName} . ')' if ( $Param{CustomerName} );
    }

    my $Columns = $ConfigObject->Get('CustomerPortal::CompanyTickets::Settings');

    my @VisibleColumns = @{ $Columns->{VisibleColumns} };

    # add block
    $LayoutObject->Block(
        Name => 'Record',
        Data => {
            # %Article,
            # %Ticket,
            # Subject => $Subject,
            # %Param,
        },
    );

    if ($Param{BulkFeature}) {

        my $Disable = '';
        my $Title   = 'Select this ticket';

        if ( $Param{TicketBulkByStateMap} && %{ $Param{TicketBulkByStateMap} } ) {
            if ( !$Param{TicketBulkByStateMap}->{ $Ticket{State} } ) {
                $Disable = 'disabled';
                $Title   = 'It is not possible to perform mass action for this ticket';
            }
        }

        $LayoutObject->Block(
            Name => 'Bulk',
            Data => { %Ticket, %Article, Disabled => $Disable, Title => $Title},
        );
    }

    for my $ColumnName ( @VisibleColumns ) {

        if ( $ColumnName eq 'PriorityColor' ) {
            $ColumnName = 'Flags'
        }

        if ( $ColumnName eq 'CustomerUser' ) {

            my %User = $UserObject->GetUserData(
                User => $Ticket{CustomerUserID}
            );

            $Ticket{$ColumnName} = "$User{UserFirstname} $User{UserLastname}";
        }
        elsif ( $ColumnName eq 'Process' ){

            my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
            my $ProcessObject      = $Kernel::OM->Get('Kernel::System::ProcessManagement::Process');
            my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

            my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
                Name => 'ProcessManagementProcessID',
            );

            # get field value
            my $Value = $BackendObject->ValueGet(
                DynamicFieldConfig => $DynamicField,
                ObjectID           => $Ticket{TicketID},
            );

            if ( $Value ) {

                my $Process = $ProcessObject->ProcessGet(
                    ProcessEntityID => $Value,
                );

                $Ticket{$ColumnName} = $Process->{Name};
            }
        }
        elsif ( $ColumnName eq 'Time Units'){

            $Ticket{TicketTimeUnits} = $TicketObject->TicketAccountedTimeGet(
                TicketID => $Ticket{TicketID},
            );

            $Ticket{$ColumnName} = _ConvertSecondsToHHMMSS($Ticket{TicketTimeUnits}*60);
        }
        elsif( $ColumnName =~ /DynamicField_/ ) {

            my @ColumnDFName = split /DynamicField_/, $ColumnName;

            my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
                Name => $ColumnDFName[1],
            );
            
            my $Value = $BackendObject->ValueGet(
                DynamicFieldConfig => $DynamicField,
                ObjectID           => $Ticket{TicketID},
            );

            my $ValueStrg = $BackendObject->DisplayValueRender(
                DynamicFieldConfig => $DynamicField,
                Value              => $Value,
                ValueMaxChars      => 20,
                LayoutObject       => $LayoutObject,
            );

            $Ticket{$ColumnName} = $ValueStrg->{Value};
                
        }
        elsif ( $ColumnName eq 'Service L1' ) {

            my ($FirstLevel) = split /::/, $Ticket{Service};

            $Ticket{$ColumnName} = $FirstLevel;
        }

        $LayoutObject->Block(
            Name => 'RecordRow',
            Data => {
                %Ticket,
                %Article,
                Subject => $Subject,
                Value   => $Ticket{$ColumnName} || '--',
                Class   => $ColumnName
            }
        );
    }

    my $Owner = $ConfigObject->Get('Ticket::Frontend::CustomerTicketOverview')->{Owner};
    my $Queue = $ConfigObject->Get('Ticket::Frontend::CustomerTicketOverview')->{Queue};

    if ($Owner) {
        my $OwnerName = $Kernel::OM->Get('Kernel::System::User')->UserName( UserID => $Ticket{OwnerID} );
        $LayoutObject->Block(
            Name => 'RecordOwner',
            Data => {
                OwnerName => $OwnerName,
            },
        );
    }
    if ($Queue) {
        $LayoutObject->Block(
            Name => 'RecordQueue',
            Data => {
                %Ticket,
            },
        );
    }

    # get the dynamic fields for this screen
    # my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    # my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # get dynamic field config for frontend module
    my $DynamicFieldFilter = $ConfigObject->Get("Ticket::Frontend::CustomerTicketOverview")->{DynamicField};
    my $DynamicField       = $DynamicFieldObject->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => ['Ticket'],
        FieldFilter => $DynamicFieldFilter || {},
    );

    # reduce the dynamic fields to only the ones that are desinged for customer interface
    my @CustomerDynamicFields;
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicField} ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        my $IsCustomerInterfaceCapable = $BackendObject->HasBehavior(
            DynamicFieldConfig => $DynamicFieldConfig,
            Behavior           => 'IsCustomerInterfaceCapable',
        );
        next DYNAMICFIELD if !$IsCustomerInterfaceCapable;

        push @CustomerDynamicFields, $DynamicFieldConfig;
    }
    $DynamicField = \@CustomerDynamicFields;

    # Dynamic fields
    # cycle trough the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicField} ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        # get field value
        my $Value = $BackendObject->ValueGet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ObjectID           => $Ticket{TicketID},
        );

        my $ValueStrg = $BackendObject->DisplayValueRender(
            DynamicFieldConfig => $DynamicFieldConfig,
            Value              => $Value,
            ValueMaxChars      => 20,
            LayoutObject       => $LayoutObject,
        );

        $LayoutObject->Block(
            Name => 'RecordDynamicField',
            Data => {
                Value => $ValueStrg->{Value},
                Title => $ValueStrg->{Title},
            },
        );

        if ( $ValueStrg->{Link} ) {
            $LayoutObject->Block(
                Name => 'RecordDynamicFieldLink',
                Data => {
                    Value                       => $ValueStrg->{Value},
                    Title                       => $ValueStrg->{Title},
                    Link                        => $ValueStrg->{Link},
                    $DynamicFieldConfig->{Name} => $ValueStrg->{Title},
                },
            );
        }
        else {
            $LayoutObject->Block(
                Name => 'RecordDynamicFieldPlain',
                Data => {
                    Value => $ValueStrg->{Value},
                    Title => $ValueStrg->{Title},
                },
            );
        }

        # example of dynamic fields order customization
        $LayoutObject->Block(
            Name => 'RecordDynamicField' . $DynamicFieldConfig->{Name},
            Data => {
                Value => $ValueStrg->{Value},
                Title => $ValueStrg->{Title},
            },
        );

        if ( $ValueStrg->{Link} ) {
            $LayoutObject->Block(
                Name => 'RecordDynamicField' . $DynamicFieldConfig->{Name} . 'Link',
                Data => {
                    Value                       => $ValueStrg->{Value},
                    Title                       => $ValueStrg->{Title},
                    Link                        => $ValueStrg->{Link},
                    $DynamicFieldConfig->{Name} => $ValueStrg->{Title},
                },
            );
        }
        else {
            $LayoutObject->Block(
                Name => 'RecordDynamicField' . $DynamicFieldConfig->{Name} . 'Plain',
                Data => {
                    Value => $ValueStrg->{Value},
                    Title => $ValueStrg->{Title},
                },
            );
        }
    }

    if ( $ConfigObject->Get('CustomerPortal::Core::TicketStarAvaliation::ToEnableTicketStarAvaliation') eq 'Yes' ) {

        my $StatesToShowAvaliation = $ConfigObject->Get('CustomerPortal::Core::TicketStarAvaliation::StatesToShow');

        $LayoutObject->Block(
            Name => 'RecordAvalition',
            Data => {},
        );

        if ( my ($MatchedState) = grep $_ eq $Ticket{State}, @{$StatesToShowAvaliation} ) {            

            my $DynamicFieldStarAvaliation = $DynamicFieldObject->DynamicFieldGet(
                Name => 'TicketStarAvaliation',
            );

            my $ValueStarVote = $BackendObject->ValueGet(
                DynamicFieldConfig => $DynamicFieldStarAvaliation,
                ObjectID           => $Ticket{TicketID},
            );

            my $StarLimit = scalar keys %{ $DynamicFieldStarAvaliation->{Config}{PossibleValues} };

            for my $StarNumber ( reverse sort keys %{ $DynamicFieldStarAvaliation->{Config}{PossibleValues} } ){

                my $VoteWhenStart = '';

                if( $Ticket{DynamicField_TicketStarAvaliation} ){
                    if( $StarNumber <= $Ticket{DynamicField_TicketStarAvaliation} ){
                        $VoteWhenStart = 'CheckStarTicketVote';  
                    }
                }

                $LayoutObject->Block(
                    Name => 'RecordAvalitionLine',
                    Data => {
                        TicketNumber => $Ticket{TicketNumber},
                        StarTitle => $DynamicFieldStarAvaliation->{Config}{PossibleValues}{$StarNumber},                   
                        StarValue => $StarNumber,     
                        ClassStar => $VoteWhenStart          
                    },
                );

            }
        
        }
       
    }

    return;
}

sub _ConvertSecondsToHHMMSS {

	my $Time = $_[0];

    if($_[0] < 0){
        $_[0] = $_[0] *-1;
    }

    my $hourz=int($_[0]/3600);

    my $leftover=$_[0] % 3600;

    my $minz=int($leftover/60);

    my $secz=int($leftover % 60);

    if ( $Time < 0 ){
		return sprintf ("-%02d:%02d:%02d", $hourz,$minz,$secz)
	}
	else{
		return sprintf ("%02d:%02d:%02d", $hourz,$minz,$secz)
	}
}

1;
