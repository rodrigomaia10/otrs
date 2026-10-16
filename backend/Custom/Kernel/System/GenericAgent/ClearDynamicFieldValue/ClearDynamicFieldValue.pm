# --
# Kernel/System/ClearDynamicFieldValue/ClearDynamicFieldValue.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by: 
# * nfreitas@serviceup.com.br
# --

package Kernel::System::GenericAgent::ClearDynamicFieldValue::ClearDynamicFieldValue;

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::Log',
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

    # get object
    my $LayoutObject              = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');

    my $FieldName = $Param{New}->{DynamicField};

    my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
        Name => $FieldName,
    );

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => 'DELETE FROM dynamic_field_value WHERE field_id = ? AND object_id = ?',
        Bind  => [ \$DynamicFieldConfig->{ID}, \$Param{TicketID} ],
    );

    # clears the cache so that the field appears clear on the screen
    # get cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    # delete cache
    $CacheObject->CleanUp(
        Type => 'DynamicFieldValue',
    );

    return 1;
}

1;