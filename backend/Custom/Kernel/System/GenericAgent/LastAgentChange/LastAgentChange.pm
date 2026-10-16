# --
# Custom/Kernel/System/GenericAgent/LastAgentChange/LastAgentChange.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::System::GenericAgent::LastAgentChange::LastAgentChange;

use strict;
use warnings;
use Encode;
use URI;
use MIME::Base64;
use utf8;
use parent qw(Kernel::System::Ticket::Article::Backend::Base);

use LWP::UserAgent;
use Kernel::System::VariableCheck (qw(:all));

our @ObjectDependencies = (
'Kernel::System::DateTime',
'Kernel::System::Log',
'Kernel::System::Priority',
'Kernel::System::Ticket',
);

sub new {

    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # 0=off; 1=on;
    $Self->{Debug} = $Param{Debug} || 0;
    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $UserObject         = $Kernel::OM->Get('Kernel::System::User');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # get ticket data
    my %Ticket = $TicketObject->TicketGet(
        DynamicFields => 1,
        %Param,
    );

    return if $Ticket{ChangeBy} == 1;

    my %User = $UserObject->GetUserData(
        UserID => $Ticket{ChangeBy},
    );

    my @DinamicFields = qw(DFNameAgent DFDateAgent AgentLogin);
    my $Overwrite = $Param{New}->{Overwrite} && lc $Param{New}->{Overwrite} eq 'não' ? 0 : 1;

    for my $DinamicField (@DinamicFields) {

        my $FieldName = $Param{New}->{$DinamicField};
        my $DFName = 'DynamicField_' . $FieldName;

        next unless $FieldName;

        my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
            Name => $FieldName,
        );

        if ($Overwrite || !$Ticket{$DFName}) {

            my $Value = '';

            if ( $DinamicField eq 'DFDateAgent' ) {

                my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');

                $Value = $DateTimeObject->Format( Format => '%d/%m/%Y %H:%M' );
            }
            elsif ( $DinamicField eq 'DFNameAgent' ) {

                $Value = "$User{UserFirstname} $User{UserLastname}";
            }
            elsif ( $DinamicField eq 'AgentLogin' ) {

                $Value = $User{UserLogin};
            }

            my $Success = $BackendObject->ValueSet(
	            DynamicFieldConfig => $DynamicFieldConfig,
	            ObjectID           => $Param{TicketID},
	            Value              => $Value,
	            UserID             => 1,
	        ); 
        }
    }

    return 1;
}

1;