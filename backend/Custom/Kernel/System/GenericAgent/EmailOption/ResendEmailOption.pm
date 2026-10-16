# --
# Custom/Kernel/System/GenericAgent/EmailOption/ResendEmailOption.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# --

package Kernel::System::GenericAgent::EmailOption::ResendEmailOption;

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

    # get objects
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');
    my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        DynamicFields => 1
    );

    if ( $Param{New}->{Subaction} eq 'Resend' ) {

        $TicketObject->EventHandler(
            Event => 'CustomResendEmailOption',
            Data  => {
                TicketID => $Param{TicketID},
            },
            UserID => 1,
        );
    }
    elsif ( $Param{New}->{Subaction} eq 'RemoveEmail' ) {

        my $EmailOptionObject = $Kernel::OM->Get('Kernel::System::EmailOption');

        my $FieldEmails      = $Param{New}->{FieldEmails};
        my $FieldRemoveEmail = $Param{New}->{FieldRemoveEmail};
        my $FieldResponse    = $Param{New}->{FieldResponse};

        my $Emails      = $Ticket{"DynamicField_$FieldEmails"};
        my $RemoveEmail = $Ticket{"DynamicField_$FieldRemoveEmail"};


        # ---- Remove email from mailing list
        my @EmailList = split(',', $Emails);

        @EmailList = grep { $_ ne $RemoveEmail } @EmailList;

        $Emails = join(',', @EmailList);

        if (!@EmailList) {
            $Emails = '';
        }

        my $DynamicFieldEmails = $DynamicFieldObject->DynamicFieldGet(
            Name => $FieldEmails,
        );

        my $Success = $DynamicFieldValueObject->ValueSet(
            FieldID  => $DynamicFieldEmails->{ID},
            ObjectID => $Param{TicketID},
            Value    => [
                {
                    ValueText => $Emails,
                },
            ],
            UserID   => 1,
        );

        # ---- Remove the value of the dynamic field and change the validity 
        # ---- of the EmailOption to be able to receive a new vote
        my $DynamicFieldResponse = $DynamicFieldObject->DynamicFieldGet(
            Name => $FieldResponse,
        );

        my $Success1 = $DynamicFieldValueObject->ValueDelete(
            FieldID  => $DynamicFieldResponse->{ID},
            ObjectID => $Param{TicketID},
            UserID   => 1,
        );

        my $Success2 = $EmailOptionObject->ValidRequest(
            TicketID   => $Param{TicketID},
            FieldID    => $DynamicFieldResponse->{ID},
        );
    }

    return 1;
}

1;