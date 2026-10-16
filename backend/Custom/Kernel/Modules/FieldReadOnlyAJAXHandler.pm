# --
# Kernel/Modules/FieldReadOnlyAJAXHandler.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package Kernel::Modules::FieldReadOnlyAJAXHandler;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get objects
    my $ActivityDialogObject = $Kernel::OM->Get('Kernel::System::ProcessManagement::ActivityDialog');
    my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
    my $DynamicFieldObject   = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $LayoutObject         = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject          = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $JSONObject           = $Kernel::OM->Get('Kernel::System::JSON');

    my $JSON = '';

    # ------------------------------------------------------------ #
    # ajax get customer JSON contract list
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'GetReadOnlyFields' ) {
        # get params
        my $ProcessEntityID        = $ParamObject->GetParam( Param => 'ProcessEntityID' ) || '';
        my $ActivityDialogEntityID = $ParamObject->GetParam( Param => 'ActivityDialogEntityID' ) || '';

        my $ActivityDialog = $ActivityDialogObject->ActivityDialogGet(
            ActivityDialogEntityID => $ActivityDialogEntityID,
            Interface              => 'AgentInterface',
        );

        my @ReadOnlyFields;

        # ["Queue","Article","Lock","PendingTime","State","Priority","CustomerID","Owner","Responsible","SLA","Service","Title"]

        my %FieldMap = (
            'CustomerID'  => {
                Field => 'CustomerAutoComplete',
                Type  => 'Input'
            },
            'Queue'       => {
                Field => 'QueueID',
                Type  => 'Select'
            },
            'Lock' => {
                Field => 'LockID',
                Type  => 'Select'
            },
            'State'       => {
                Field => 'StateID',
                Type  => 'Select'
            },
            'Priority'    => {
                Field => 'PriorityID',
                Type  => 'Select'
            },
            'Owner'       => {
                Field => 'OwnerID',
                Type  => 'Select'
            },
            'Responsible' => {
                Field => 'ResponsibleID',
                Type  => 'Select'
            },
            'SLA'         => {
                Field => 'SLAID',
                Type  => 'Select'
            },
            'Service'     => {
                Field => 'ServiceID',
                Type  => 'Select'
            },
            'Title'     => {
                Field => 'Title',
                Type  => 'Input'
            }
        );

        my $TypeMap = $ConfigObject->Get('ProcessFieldReadOnly::Core::FieldTypes');
        for my $Field ( @{ $ActivityDialog->{FieldOrder} } ) {

            if( $ActivityDialog->{Fields}->{$Field}->{Display} == 3 ) {
      
                
                if ( $Field =~ m{^DynamicField_(.*)}xms ) {
                    my $DynamicFieldName = $1;

                    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
                        Name => $DynamicFieldName
                    );

                    push @ReadOnlyFields, {
                        Field => $Field,
                        Type  => $TypeMap->{ $DynamicField->{FieldType} }
                    };
                }
                elsif( $FieldMap{$Field} ) {

                    push @ReadOnlyFields, $FieldMap{$Field};
                }
            }
        }

        my $JSONString = $JSONObject->Encode(
            Data     => \@ReadOnlyFields,
            SortKeys => 1
        );

        # build JSON output
        $JSON = $LayoutObject->JSONEncode(
            Data => {
                JSONString => $JSONString
            }
        );
    }

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );
}

1;
