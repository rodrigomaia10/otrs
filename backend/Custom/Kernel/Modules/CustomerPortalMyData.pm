# --
# Kernel/Modules/CustomerPortalMyData.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# --

package Kernel::Modules::CustomerPortalMyData;

use strict;
use warnings;

use utf8;

use Digest::MD5 qw(md5_hex);
use Encode qw(decode encode);
use File::Basename;

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

    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');

    if( $Self->{Subaction} eq 'Download' ) {

        my $Content = $Self->_GetCustomerUserData(
            CustomerUserID => $Self->{UserLogin},
        );

        return $LayoutObject->Attachment(
			Filename    => $LayoutObject->{LanguageObject}->Translate( "My Data" ).".html",
			ContentType => 'application/octet-stream',
			Content     => $Content,
		);
	}

    if ( $Self->{Subaction} eq 'UpdatePreferences' ){

        # check group param
        my $Group = $ParamObject->GetParam( Param => 'Group' ) || '';

        if ( !$Group ) {
            return $LayoutObject->ErrorScreen(
                Message => Translatable('Param Group is required!'),
            );
        }

        my %User = $CustomerUserObject->CustomerUserDataGet(
            User => $Self->{UserLogin},
        );

        my $Editable = 1;

        # Checks whether the user or client backend is database. This allows you to edit the information. If different from DB the data will only be displayed.
        if ( ( $Group eq "MyData"    && $User{Config}->{Module}        ne "Kernel::System::CustomerUser::DB" ) ||
            (  $Group eq "MyCompany" && $User{CompanyConfig}->{Module} ne "Kernel::System::CustomerCompany::DB" ) ) {

            $Editable = 0;
        }

        my %RequiredFields;

        # Mapping of mandatory fields defined in Default.pm
        for my $Array ( @{ $User{Config}->{Map} }, @{ $User{CompanyConfig}->{Map} } ) {

            $RequiredFields{$Array->[0]} = $Array->[4];
        }

        my @Fields = $Group eq "MyData" ? @{ $ConfigObject->Get('CustomerPortal::Core::UserFieldsMyData') } : @{ $ConfigObject->Get('CustomerPortal::Core::UserFieldsMyCompany') };

        my %Data;
        my %Error;

        my @ArrayFieldEdit;

        FIELD:
        for my $Field ( @Fields ) {

            for my $FieldKey ( keys %{$Field} ) {

                next FIELD if $Field->{$FieldKey} != 1;

                push @ArrayFieldEdit, $FieldKey;

                $Data{$FieldKey} = $ParamObject->GetParam( Param => $FieldKey );

                # If the field is mandatory and is empty
                if ( $RequiredFields{$FieldKey} == 1 && $Data{$FieldKey} eq undef ) {

                    $Error{$FieldKey} = "ServerError";
                }
            }
        }

        my $Message = "";
        my $Color   = "";
        my $Success;

        # If there is an error
        if ( %Error ) {

            return $Self->_MaskNew(
                %Param,
                Error     => \%Error,
                DataParam => \%Data,
            );
        }

        if ( $Group eq "MyData" && $Editable ) {

            # Complete data that the user cannot change to avoid saving empty
            for my $Array ( @{ $User{Config}->{Map} } ) {

                # Verification required if the user wants to update the field with no value
                if ( !($Array->[0] ~~ @ArrayFieldEdit) ) {
                    $Data{$Array->[0]} = $Data{$Array->[0]} || $User{$Array->[0]};
                }

            }

            delete $Data{UserPassword};

            # change the data
            $Success = $CustomerUserObject->CustomerUserUpdate(
                Source         => $User{Source},
                ID             => $Self->{UserLogin},
                UserID         => 1,
                %Data
            );
        }
        elsif ( $Group eq "MyCompany" && $Editable ) {

            my $CustomerCompanyObject = $Kernel::OM->Get('Kernel::System::CustomerCompany');

            # # Complete data that the user cannot change to avoid saving empty
            for my $Array ( @{ $User{CompanyConfig}->{Map} } ) {

                # Verification required if the user wants to update the field with no value
                if ( !($Array->[0] ~~ @ArrayFieldEdit) ) {
                    $Data{$Array->[0]} = $Data{$Array->[0]} || $User{$Array->[0]};
                }
            }

            # change the data
            $Success = $CustomerCompanyObject->CustomerCompanyUpdate(
                CustomerCompanyID       => $User{CustomerID},
                UserID                  => 1,
                %Data
            );
        }

        # If the data cannot be changed
        if ( !$Editable ) {
            $Message = $LayoutObject->{LanguageObject}->Translate( "Information cannot be changed through this panel. Contact your administrator for more information." );
            $Color   = "fcf171";
        }
        elsif ( $Success ) {
            $Message = $LayoutObject->{LanguageObject}->Translate( "Data updated successfully!" );
            $Color   = "71fc82";
        }
        else {
            $Message = $LayoutObject->{LanguageObject}->Translate( "Error while updating data!" );
            $Color   = "fc7e71";
        }
        
        return $Self->_MaskNew(
            Message => $Message,
            Color   => $Color,
            %Param,
        );
    }
    else {

        return $Self->_MaskNew(
            %Param,
        );
    }
}

sub _MaskNew {
    my ( $Self, %Param ) = @_;

    my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');
    my $CustomerUserObject         = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $ConfigObject               = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject               = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # Creates the side navigation bar
    $CustomerPortalLayoutObject->CreateNavBar(
        ActionActive => "",
        %{$Self}
    );

    # Displays the top message
    if( $Param{Message} ){

        $LayoutObject->Block(
            Name => 'Head',
            Data => {
                Header => $Param{Message} || "",
                Color  => $Param{Color}   || "",
            },
        );
    }

    $LayoutObject->Block(
        Name => 'Body',
        Data => \%Param,
    );

    # Label mapping
    my %FieldsLabel = (
        UserCity            => "City",
        UserCountry         => "Country",
        UserEmail           => "Email",
        UserFax             => "Fax",
        UserFirstname       => "Firstname",
        UserLastname        => "Lastname",
        UserMobile          => "Mobile",
        UserPhone           => "Phone",
        UserStreet          => "Street",
        UserZip             => "Zip",
        UserTitle           => "Title",
        CustomerCompanyName => "Company Name",
    );

    # takes user information
    my %User = $CustomerUserObject->CustomerUserDataGet(
        User => $Self->{UserLogin},
    );

    my %RequiredFields;

    # Mapping of mandatory fields defined in Default.pm
    for my $Array ( @{ $User{Config}->{Map} }, @{ $User{CompanyConfig}->{Map} } ) {

        $RequiredFields{$Array->[0]} = $Array->[4];
    }

    my @Data        = @{ $ConfigObject->Get('CustomerPortal::Core::ConfigMyData') };
    my @DataUser    = @{ $ConfigObject->Get('CustomerPortal::Core::UserFieldsMyData') };
    my @DataCompany = @{ $ConfigObject->Get('CustomerPortal::Core::UserFieldsMyCompany') };

    my $Count = 0;
    # Displays form cards
    CARD:
    for my $Card ( @Data ) {

        my %GroupData = %{ $Card };

        # Checks whether the card is active
        next CARD if !$GroupData{Active};

        $Count++;

        # show card
        $LayoutObject->Block(
            Name => 'Card',
            Data => {
                Group => $GroupData{Key},
                Label => $GroupData{Label},
                Desc  => $GroupData{Desc}, 
            },
        );



        # show buttons
        $LayoutObject->Block(
            Name => 'ActionButtons',
            Data => {
                Group => $GroupData{Key},
                Label => $GroupData{Label},
                Desc  => $GroupData{Desc}, 
            },
        ) if $GroupData{Key} eq "MyCompany";

        

        # Array of fields to be displayed
        my @Fields = $GroupData{Key} eq "MyData" ? @DataUser : @DataCompany;

        my $Editable = 1;

        # Checks whether the user or client backend is database. This allows you to edit the information. If different from DB the data will only be displayed.
        if ( ( $GroupData{Key} eq "MyData"    && $User{Config}->{Module}        ne "Kernel::System::CustomerUser::DB" ) ||
            (  $GroupData{Key} eq "MyCompany" && $User{CompanyConfig}->{Module} ne "Kernel::System::CustomerCompany::DB" ) ) {

            $Editable = 0;
        }

        FIELD:
        for my $Field ( @Fields ) {

            FIELDKEY:
            for my $FieldKey ( keys %{$Field} ) {

                # Mapping: 
                # 0 does not display.
                # 1 displays for change.
                # 2 only displays without change.
                next FIELD if $Field->{$FieldKey} == 0;

                my $Mandatory = 0;
                my $Readonly  = 0;

                # If the field is configured to be mandatory in Defaults.pm it will be mandatory in the edit screen
                if ( $RequiredFields{$FieldKey} == 1 ) {
                    $Mandatory = 1;
                }

                # If the field is only configured to be displayed or if the data backend is different from the database backend, the field will only be displayed
                if ( $Field->{$FieldKey} == 2 || !$Editable ) {
                    $Readonly = 1;
                }

                # If there is a backend validation error when saving, display the value that was entered by the user
                if ( $Param{Error}->{$FieldKey} ) {
                    $User{$FieldKey} = $Param{DataParam}->{$FieldKey}
                }

                $LayoutObject->Block(
                    Name => "InputKey",
                    Data => {
                        Label      => $LayoutObject->{LanguageObject}->Translate( $FieldsLabel{$FieldKey} || $FieldKey ),
                        Name       => $FieldKey,
                        SelectedID => $User{$FieldKey},
                        Mandatory  => $Mandatory,
                        Readonly   => $Readonly,
                        Class      => $Param{Error}->{$FieldKey} || ''
                    },
                );
            }
        }
    }

    my $ActionTitle = $ConfigObject->Get('CustomerPortal::Core::ActionTitle');

    # build output
    my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{CustomerPortalMyData});

    $Output .= $LayoutObject->Output(
        Data         => \%Param,
        TemplateFile => 'CustomerPortalMyData',
    );

    $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

    return $Output;
}

sub _GetCustomerUserData {
    my ( $Self, %Param ) = @_;

    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');

    # Get the HTML template
    my $CustomerUserTemplate = $ConfigObject->Get('CustomerPortal::Core::GenerateCustomerUserTemplate');
    my $CompanyDataTemplate  = $ConfigObject->Get('CustomerPortal::Core::GenerateCompanyDataTemplate');
    my %TicketTemplate       = %{ $ConfigObject->Get('CustomerPortal::Core::GenerateTicketDataTemplate') };

    my $HiddeQueues = $ConfigObject->Get("CustomerPortal::Core::HiddeTicketsByQueue");

    my %User = $CustomerUserObject->CustomerUserDataGet(
        User => $Param{CustomerUserID}
    );

    # Assemble the HTML with the data
    my $HTMLUser = $LayoutObject->Output(
        Template => $CustomerUserTemplate,
        Data     => {
            UserData => \%User
        },
    );

    $LayoutObject->Block(
        Name => "CustomerUserTemplate",
        Data => {
            CustomerUserTemplate => $HTMLUser
        }
    );

    # Assemble the HTML with the data
    my $HTMLCompany = $LayoutObject->Output(
        Template => $CompanyDataTemplate,
        Data     => {
            CompanyData => \%User
        },
    );

    $LayoutObject->Block(
        Name => "CompanyDataTemplate",
        Data => {
            CompanyDataTemplate => $HTMLCompany,
        }
    );

    my $HTMLTicketHead = $LayoutObject->Output(
        Template => $TicketTemplate{TicketListHeadTemplate},
    );

    $LayoutObject->Block(
        Name => "TicketListHeadTemplate",
        Data => {
            TicketListHeadTemplate => $HTMLTicketHead
        }
    );

    #all user tickets 
    my @TicketList = $TicketObject->TicketSearch(
        Result            =>  'ARRAY',
        CustomerUserLogin => $Param{CustomerUserID},
        UserID            => 1
    );

    TICKET:
    foreach my $TicketID ( @TicketList ) {

        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $TicketID,
            # DynamicFields => 1,
            # Extended      => 1,
            UserID        => 1,
        );

        if ( grep { $_ eq $Ticket{Queue} } @{ $HiddeQueues } ) {
            next TICKET;
        }

        my $HTMLTicketBody = $LayoutObject->Output(
            Template => $TicketTemplate{TicketListBodyTemplate},
            Data     => \%Ticket
        );

        $LayoutObject->Block(
            Name => "TicketRow",
            Data => {
                TicketListBodyTemplate => $HTMLTicketBody
            }
        );
    }

    my $DisableCompanyTickets = $ConfigObject->Get('Ticket::Frontend::CustomerDisableCompanyTicketAccess');

    if( !$DisableCompanyTickets) {

        my $ServicesNotAllowed = $ConfigObject->Get('CustomerPortal::Core::ServicesNotAllowed');

        $LayoutObject->Block(
            Name => "CompanyTickets",
        );

        $LayoutObject->Block(
            Name => "CompanyTicketListHeadTemplate",
            Data => {
                TicketListHeadTemplate => $HTMLTicketHead
            }
        );

        my %UserTickets = map { $_ => 1 } @TicketList;

        my @CompanyTicketList = $TicketObject->TicketSearch(
            Result          =>  'ARRAY',
            UserID          => 1,
            CustomerUserID  => $Param{CustomerUserID},
        );

        COMPANYTICKET:
        foreach my $TicketID ( @CompanyTicketList ) {

            next COMPANYTICKET if $UserTickets{$TicketID};

            my %Ticket = $TicketObject->TicketGet(
                TicketID      => $TicketID,
                UserID        => 1,
            );

            if ( grep { $_ eq $Ticket{Queue} } @{ $HiddeQueues } ) {
                next COMPANYTICKET;
            }

            if ( $ServicesNotAllowed ) {

                if ( $Ticket{ServiceID} ) {

                    if ( grep( $Ticket{ServiceID} eq $_, @{ $ServicesNotAllowed } ) && $Ticket{CustomerUserID} ne $Self->{UserID} ){
                        next COMPANYTICKET;
                    }
                }
            }

            my $HTMLTicketBody = $LayoutObject->Output(
                Template => $TicketTemplate{TicketListBodyTemplate},
                Data     => \%Ticket
            );

            $LayoutObject->Block(
                Name => "CompanyTicketRow",
                Data => {
                    TicketListBodyTemplate => $HTMLTicketBody
                }
            );
        }
    }

    my $HtmlContent = $LayoutObject->Output(
        TemplateFile => 'CustomerPortalUserDataExport',
        Data         => {
            Logo => $ConfigObject->Get('CustomerPortal::Core::CustomerLogoDefault') || "",
        }
    );
    
    return $HtmlContent;
}

1;