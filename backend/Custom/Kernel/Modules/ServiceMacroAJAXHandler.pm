# --
# Kernel/Modules/ServiceMacroAJAXHandler.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# --

package Kernel::Modules::ServiceMacroAJAXHandler;

use strict;
use warnings;
use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

use utf8;
use Encode qw(decode encode);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # get the dynamic fields for contract object
    $Self->{DynamicField} = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid      => 1,
        ObjectType => ['Contract'],
    );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject      = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject      = $Kernel::OM->Get('Kernel::Config');
    my $ParamObject       = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LogObject         = $Kernel::OM->Get('Kernel::System::Log');
    my $MacroObject       = $Kernel::OM->Get('Kernel::System::Macro');



    if ( $Self->{Subaction} eq 'AddDynamicField' ) {

        my $DynamicFieldID = $ParamObject->GetParam( Param => 'DynamicFieldID' );
        my $SelectedValue  = $ParamObject->GetParam( Param => 'SelectedValue' );
        my $Widget         = $ParamObject->GetParam( Param => 'Widget' );
        my $Type           = $ParamObject->GetParam( Param => 'Type' )       || '';
        my $ValueDF        = $ParamObject->GetParam( Param => 'ValueDF' )    || '';
        my $ValueMacro     = $ParamObject->GetParam( Param => 'ValueMacro' ) || '';

        my $DynamicFieldConfig = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldGet(
            ID => $DynamicFieldID,
        );

        my %DynamicFieldContract;

        $DynamicFieldContract{Profile}   = $Self->{Profile};
        $DynamicFieldContract{Subaction} = $Self->{Subaction};

        my $DynamicFieldHTML;
        my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

        # Get field HTML.
        if ( $Widget eq 'Select' ) {
            $DynamicFieldHTML = $DynamicFieldBackendObject->SearchFieldRender(
                DynamicFieldConfig     => $DynamicFieldConfig,
                Profile                => \%DynamicFieldContract,
                LayoutObject           => $LayoutObject,
                ConfirmationCheckboxes => 1,
                Type                   => $Type,
            );
        }
        elsif ( $Widget eq 'Update' ) {

            my $PossibleValuesFilter;

            my $IsACLReducible = $DynamicFieldBackendObject->HasBehavior(
                DynamicFieldConfig => $DynamicFieldConfig,
                Behavior           => 'IsACLReducible',
            );

            if ($IsACLReducible) {

                # Get PossibleValues.
                my $PossibleValues = $DynamicFieldBackendObject->PossibleValuesGet(
                    DynamicFieldConfig => $DynamicFieldConfig,
                );

                # Check if field has PossibleValues property in its configuration.
                if ( IsHashRefWithData($PossibleValues) ) {

                    # Convert possible values key => value to key => key for ACLs using a Hash slice.
                    my %AclData = %{$PossibleValues};
                    @AclData{ keys %AclData } = keys %AclData;

                    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

                    # Set possible values filter from ACLs.
                    my $ACL = $TicketObject->TicketAcl(
                        Action        => $Self->{Action},
                        Type          => 'DynamicField_' . $DynamicFieldConfig->{Name},
                        ReturnType    => 'Ticket',
                        ReturnSubType => 'DynamicField_' . $DynamicFieldConfig->{Name},
                        Data          => \%AclData,
                        UserID        => $Self->{UserID},
                    );
                    if ($ACL) {
                        my %Filter = $TicketObject->TicketAclData();

                        # Convert Filer key => key back to key => value using map.
                        %{$PossibleValuesFilter} = map { $_ => $PossibleValues->{$_} } keys %Filter;
                    }
                }
            }

            $DynamicFieldHTML = $DynamicFieldBackendObject->EditFieldRender(
                DynamicFieldConfig   => $DynamicFieldConfig,
                PossibleValuesFilter => $PossibleValuesFilter,
                LayoutObject         => $LayoutObject,
                ParamObject          => $ParamObject,
                UseDefaultValue      => 0,
                OverridePossibleNone => 1,
                ConfirmationNeeded   => 1,
                NoIgnoreField        => 1,
                Template             => \%DynamicFieldContract,
                MaxLength            => 200,
                Value                => $ValueDF
            );
        }

        $DynamicFieldHTML->{ID} = $SelectedValue;
        $DynamicFieldHTML->{DynamicFieldName} = $DynamicFieldConfig->{Name};

        my %Macros = $MacroObject->MacroList();

        $DynamicFieldHTML->{FieldMacro} = $LayoutObject->BuildSelection(
            Data        => \%Macros,
            Name        => 'MacroName',
            Size        => 5,
            Multiple    => 0,
            Translation => 0,
            SelectedID  => $ValueMacro,
            Class       => 'Modernize',
        );

        my $Output = $LayoutObject->JSONEncode(
            Data => $DynamicFieldHTML,
        );

        # Send JSON response.
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $Output,
            Type        => 'inline',
            NoCache     => 1,
        );
    }
}

1;