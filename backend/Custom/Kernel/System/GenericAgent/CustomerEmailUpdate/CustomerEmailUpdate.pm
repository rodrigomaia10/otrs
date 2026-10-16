# --
# /opt/Dev/CustomModuleGenericAgent/src/Custom/Kernel/System/GenericAgent/CustomerEmailUpdate/CustomerEmailUpdate.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * msantos@serviceup.com.br
# --

package Kernel::System::GenericAgent::CustomerEmailUpdate::CustomerEmailUpdate;

use strict;
use warnings;
use utf8;

use Kernel::System::VariableCheck (qw(:all));

our @ObjectDependencies = (
    'Kernel::System::Log',
    'Kernel::System::Ticket',
);

sub new {

    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

}

sub Run {
    my ( $Self, %Param ) = @_;

    my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');
    my $CustomerUserObject      = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $DynamicFieldObject       = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $TicketObject             = $Kernel::OM->Get('Kernel::System::Ticket');

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        DynamicFields => 1,
        UserID        => $Self->{UserID},
        Silent        => 1,
    );

    # Get customer user data logged in
    my %User = $CustomerUserObject->CustomerUserDataGet(
        User => $Ticket{CustomerUserID},
    );

    # Get value from dynamic email field
    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => $Param{New}->{DynamicField}
    );

    my $Value = $DynamicFieldValueObject->ValueGet(
        FieldID            => $DynamicField->{ID},
        ObjectID           => $Param{TicketID},
    );

    my $NewEmail = $Value->[0]->{ValueText};

    if ( $NewEmail ) {

        # Return if the registered email is the same as the email entered in the dynamic field
        return if ( $NewEmail eq $User{UserEmail} );

        # Delete keys to prevent data from being overwritten
        foreach my $key (keys %User) {
            delete $User{UserID};
            delete $User{UserEmail};
        }

        # Update the customer user email field
        my $Success = $CustomerUserObject->CustomerUserUpdate(
            ID             => $User{UserLogin},
            UserCustomerID => $User{UserCustomerID},
            UserLogin      => $User{UserLogin},       
            UserFirstname  => $User{UserFirstname},
            UserLastname   => $User{UserLastname},
            UserEmail      => $NewEmail,
            ValidID        => 1,
            UserID         => 1,
            %User,
        );

        if( $Success){

            my $HistoryAdd = $TicketObject->HistoryAdd(
                Name         => "Atualização de e-mail do usuário cliente '$User{UserLogin}' de '$User{UserEmail}' para '$NewEmail' (InBox CustomModuleGenericAgent)",
                HistoryType  => 'AddNote', 
                TicketID     => $Param{TicketID},
                CreateUserID => 1,
            );
        }
    }
}

1;