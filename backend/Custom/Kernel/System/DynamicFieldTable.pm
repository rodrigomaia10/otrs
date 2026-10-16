# --
# Kernel/System/DynamicFieldTable.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package Kernel::System::DynamicFieldTable;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

Kernel::System::DynamicFieldTable - dynamic field table management

=head1 SYNOPSIS

Global module to manage DynamicFieldTable.

=head1 PUBLIC INTERFACE

=head2 new()

create an object. Do not use it directly, instead use:

    my $DynamicFieldTableObject = $Kernel::OM->Get('Kernel::System::DynamicFieldTable');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=head2 TempSet()

insert temp data table in database.

    my $Sucess = $DynamicFieldTableObject->TempSet(
        FieldID => 100,
        FormID  => 1000000,
        JSON    => '{}',
    );

=cut

sub TempSet {
    my ( $Self, %Param ) = @_;

    # check needed params
    for my $Needed (qw(FieldID FormID JSON)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # clean up old data
    $Self->_ValueTempCleanup(
        FieldID => $Param{FieldID},
        FormID  => $Param{FormID}
    );

    # create new db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            INSERT INTO df_table_temp (field_id, form_id, content)
            VALUES (?, ?, ?)',
        Bind => [
            \$Param{FieldID}, \$Param{FormID}, \$Param{JSON},
        ],
    );

    return 1;
}

=head2 ValueGet()

get JSON data table from db.

    my $JSONData = $DynamicFieldTableObject->ValueGet(
        FormID  => 1000000,   # optional
        ObjectID => 100,   # optional
    );

=cut

sub ValueGet {
    my ( $Self, %Param ) = @_;

    # get needed params
    if ( !$Param{FormID} && !$Param{ObjectID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need FormID or ObjectID!"
        );
        return;
    }
	
	# get needed params
    if ( !$Param{FieldID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need FieldID!"
        );
        return;
    }

    my $JSON;

    if ( $Param{FormID} ) {

        # get db record based on form id
        return if !$Kernel::OM->Get('Kernel::System::DB')->Prepare(
            SQL => '
                SELECT content FROM df_table_temp WHERE form_id = ? and field_id = ?',
            Bind  => [ \$Param{FormID}, \$Param{FieldID} ],
            Limit => 1,
        );
    }
    elsif ( $Param{ObjectID} ) {

        # get db record based on object id
        return if !$Kernel::OM->Get('Kernel::System::DB')->Prepare(
            SQL => '
                SELECT content FROM df_table_value WHERE object_id = ? and field_id = ?',
            Bind  => [ \$Param{ObjectID}, \$Param{FieldID} ],
            Limit => 1,
        );
    }
	
    while ( my @Row = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray() ) {
        $JSON = $Row[0];
    }

    return $JSON;
}

=head2 ValueGetTag()

get JSON data table from db.

    my $JSONData = $DynamicFieldTableObject->ValueGetTag(
        ObjectID => 100,   # optional
    );

=cut

sub ValueGetTag {
    my ( $Self, %Param ) = @_;

    # get needed params
    if ( !$Param{FormID} && !$Param{ObjectID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need FormID or ObjectID!"
        );
        return;
    }	

    my $JSON;
	
	if ( $Param{ObjectID} && $Param{FieldID}) {

        # get db record based on object id
        return if !$Kernel::OM->Get('Kernel::System::DB')->Prepare(
            SQL => '
                SELECT content FROM df_table_value WHERE object_id = ? and field_id = ?',
            Bind  => [ \$Param{ObjectID}, \$Param{FieldID}],
            Limit => 1,
        );
    }elsif ( $Param{ObjectID} ) {

        # get db record based on object id
        return if !$Kernel::OM->Get('Kernel::System::DB')->Prepare(
            SQL => '
                SELECT content FROM df_table_value WHERE object_id = ?',
            Bind  => [ \$Param{ObjectID}],
            Limit => 1,
        );
    }
	
    while ( my @Row = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray() ) {
        $JSON = $Row[0];
    }

    return $JSON;
}

=head2 ValueSet()

set JSON data table to db.

    my $Sucess = $DynamicFieldTableObject->ValueSet(
        FieldID  => 1000000,
        ObjectID => 100,
        JSON => '{}',
    );

=cut

sub ValueSet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(FieldID ObjectID FormID JSON)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    $Self->_ValueTempCleanup( 
        FieldID  => $Param{FieldID},
        FormID   => $Param{FormID}
    );
    $Self->_ValueCleanup(
        FieldID  => $Param{FieldID},
        ObjectID => $Param{ObjectID}
    );

    # create db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            INSERT INTO df_table_value (field_id, object_id, content)
            VALUES (?, ?, ?)',
        Bind => [
            \$Param{FieldID}, \$Param{ObjectID}, \$Param{JSON},
        ],
    );

    return 1;
}

=begin Internal:

=head2 _ValueTempCleanup()

remove temp data from db.

    $DynamicFieldTableObject->_ValueTempCleanup(
        FieldID => 10,
        FormID  => 100
    );

=cut

sub _ValueTempCleanup {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(FieldID FormID)) {
        if ( !$Param{$_} ) {

            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => 'DELETE FROM df_table_temp WHERE field_id = ? AND form_id = ?',
        Bind  => [ \$Param{FieldID}, \$Param{FormID} ],
        Limit => 1,
    );

    return 1;
}

=head2 _ValueCleanup()

remove value of data table from db.

    $DynamicFieldTableObject->_ValueCleanup(
        FieldID => 10,
        ObjectID => 100
    );

=cut

sub _ValueCleanup {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(FieldID ObjectID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            DELETE FROM df_table_value WHERE field_id = ? AND object_id = ?',
        Bind  => [ \$Param{FieldID}, \$Param{ObjectID} ],
        Limit => 1,
    );

    return 1;
}

=head2 _TruncateTable()

remove all data from table temp.

    $DynamicFieldTableObject->_TruncateTable();

=cut

sub _TruncateTempTable {
    my ( $Self, %Param ) = @_;

    # truncate temp table
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => 'TRUNCATE TABLE df_table_temp',
    );

    return 1;
}

1;