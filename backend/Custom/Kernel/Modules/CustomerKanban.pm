# --
#
# Kernel/Modules/Kanban.pm
# Copyright (C) 2019 Service UP, http://www.serviceup.com.br
#
# written/edited by:
# * ccresencio@serviceup.com.br
# * nfreitas@serviceup.com.br
# --

package Kernel::Modules::CustomerKanban;

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

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $CustomerPortalObject = $Kernel::OM->Get('Kernel::System::CustomerPortal');
	my $ServiceObject        = $Kernel::OM->Get('Kernel::System::Service');
    my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject         = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject          = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $JSONObject           = $Kernel::OM->Get('Kernel::System::JSON');
    my $TicketObject         = $Kernel::OM->Get('Kernel::System::Ticket');
    my $UserObject           = $Kernel::OM->Get('Kernel::System::User');


    my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');
    my $CardHomeSearch             = $ConfigObject->Get('CustomerPortal::Core::CardHomeSearch');

    $CustomerPortalLayoutObject->CreateNavBar(
        ActionActive => "Kanban",
        %{$Self},
        HideSearch => $CardHomeSearch->{Search}
    );

    my $ActionTitle = $ConfigObject->Get('CustomerPortal::Core::ActionTitle');

    # build output
    my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{CustomerKanban} );

    my @ColumnsInformations;
    my @ColumnsBoard;

    my $ServicesNotAllowed = $ConfigObject->Get('CustomerPortal::Core::ServicesNotAllowed');
    my $HiddeQueues        = $ConfigObject->Get("CustomerPortal::Core::HiddeTicketsByQueue");
    my $ConfigFilters      = $ConfigObject->Get('CustomerPortal::Core::CustomerKanbanFilters');

    my $Count = 1;

    for my $Board ( sort keys %{ $ConfigFilters } ){
        my %BoardData;

        #Get filters separete ; and format to array object
        my %FilterBoard;
        for my $Filter ( keys %{ $ConfigFilters->{$Board}{Filter} } ){
            
            if ( $ConfigFilters->{$Board}{Filter}{$Filter} =~ m/;/ ){

                my @ArrayData = split /;/, $ConfigFilters->{$Board}{Filter}{$Filter};
                $FilterBoard{$Filter} = \@ArrayData;
            }
            else {
                $FilterBoard{$Filter} = $ConfigFilters->{$Board}{Filter}{$Filter}
            }
        }

        # User tickets only
        $FilterBoard{CustomerUserLoginRaw} = $Self->{UserID};

        if ( $FilterBoard{CompanyTickets} ) {
            delete $FilterBoard{CustomerUserLoginRaw};
        }
        
        my @TicketIDs = $TicketObject->TicketSearch(
            Result         => 'ARRAY',
            CustomerUserID => $Self->{UserID},
            %FilterBoard,
        );

        my @DataBoardItems;
        my %DataOfticketColumn;
   
        TICKET:
        for my $TicketID ( @TicketIDs ){

            my %ItemBoard;

            my %Ticket = $TicketObject->TicketGet(
                TicketID      => $TicketID,
                DynamicFields => 0,         
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

            my %User = $UserObject->GetUserData(
                UserID => $Ticket{OwnerID},
            ); 

            $Ticket{OwnerName} = "$User{UserFirstname} $User{UserLastname}";

            $ItemBoard{id}    = $TicketID;

            my %FieldsCard;

            for my $ItemCard ( $ConfigFilters->{$Board}{Fields}  ){

                for my $ItemField ( keys %$ItemCard ){

                    $FieldsCard{ $ItemField } = $Ticket{  $ItemCard->{$ItemField} };

                    $LayoutObject->Block(
                        Name => 'Field',
                        Data => {
                            FieldNumber => $ItemField,
                            Field =>  $Ticket{  $ItemCard->{$ItemField} }
                        },
                    );
                }
            }

            $ItemBoard{title} = $LayoutObject->Output(
                TemplateFile => 'CustomerKanbanCardBoard',
                Data         => { 
                    %Ticket,
                    %FieldsCard
                }
            );
            
            push ( @DataBoardItems, \%ItemBoard);
        }
     
        $DataOfticketColumn{id}    = $Count;
        $DataOfticketColumn{item}  = \@DataBoardItems;
        $DataOfticketColumn{title} =  "$ConfigFilters->{$Board}{Title} - (". (scalar @DataBoardItems).")"; 
     
        push (@ColumnsInformations, \%DataOfticketColumn);
    }

    my $JSONString = $JSONObject->Encode(
        Pretty => 1,           
        Data   =>  {
            ColumnData  => \@ColumnsInformations,         
        }
    );

    $Output   .= $LayoutObject->AddJSData(
        Key   => "BoardsColumnData",
        Value => $JSONString
    );

    $Output   .= $LayoutObject->Output(
        Data         => \%Param,
        TemplateFile => 'CustomerKanban',
    );

    $Output   .= $LayoutObject->CustomerFooter(Type => 'Small');

    return $Output;
}

1;