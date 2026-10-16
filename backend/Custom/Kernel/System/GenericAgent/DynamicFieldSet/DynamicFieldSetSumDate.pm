# --
# Custom/Kernel/System/GenericAgent/DynamicFieldSet/DynamicFieldSetSumDate.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# --

package Kernel::System::GenericAgent::DynamicFieldSet::DynamicFieldSetSumDate;

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
    my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime'
    );

    my $Success = $DateTimeObject->Add(
        Days          => $Param{New}->{AddDays} || 0,
        AsWorkingTime => $Param{New}->{AsWorkingTime},
    );

    my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
        Name => $Param{New}->{DFDate},
    );

    $Success = $BackendObject->ValueSet(
        DynamicFieldConfig => $DynamicFieldConfig,
        ObjectID           => $Param{TicketID},
        Value              => $DateTimeObject->ToString(),
        UserID             => 1,
    );

    return 1;
}

1;