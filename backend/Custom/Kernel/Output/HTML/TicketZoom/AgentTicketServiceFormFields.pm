# --
# Kernel/Output/HTML/TicketZoom/AgentTicketServiceFormFields.pm
# Copyright (C) 2019 Service Up http://www.serviceup.com.br
# --
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package Kernel::Output::HTML::TicketZoom::AgentTicketServiceFormFields;

use strict;
use warnings;
use utf8;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

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

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
	my $LanguageObject            = $Kernel::OM->Get('Kernel::Language');
    my $JSONObject                = $Kernel::OM->Get('Kernel::System::JSON');
	my $TicketObject              = $Kernel::OM->Get('Kernel::System::Ticket');
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $ParamObject               = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $LayoutObject              = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $CustomFormObject          = $Kernel::OM->Get('Kernel::System::CustomServiceForm');
    my $DynamicFieldValueObject   = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    
    my %Ticket = $TicketObject->TicketGet(
		TicketID      => $Self->{TicketID},
		DynamicFields => 1
	);

    if( !$Ticket{ServiceID} ){
        return;
    }

	my $FormID = $CustomFormObject->CustomFormSearch(
		ServiceID => $Ticket{ServiceID}
	);

    if( !$FormID ){
        return;
    }

	my $Fields = $CustomFormObject->CustomFormDynamicFieldList(
		FormID    => $FormID,
    );

    my @FieldNames;

	foreach my $Field ( @{$Fields} ){
		my $Name = $Field->{Name};

		$Name =~ s/DynamicField_//;

		push @FieldNames, $Name;
	}

    DYNAMICFIELD:
    foreach my $Name ( @FieldNames ){

        my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
            Name => $Name,
        );

        my $Label = $LayoutObject->{LanguageObject}->Translate( $DynamicField->{Label} );

        my $Value;
        my $ValueStrg;

        $Value = $DynamicFieldBackendObject->ValueGet(
            DynamicFieldConfig => $DynamicField,     
            ObjectID           => $Self->{TicketID}
        );

        $ValueStrg = $DynamicFieldBackendObject->DisplayValueRender(
            DynamicFieldConfig => $DynamicField,
            Value              => $Ticket{ 'DynamicField_' . $DynamicField->{Name} },
            LayoutObject       => $LayoutObject,
            ValueMaxChars      => $ConfigObject->
                Get('Ticket::Frontend::DynamicFieldsZoomMaxSizeSidebar')
                || 18,    # limit for sidebar display
        );

        if( $Value ){
            if ( $DynamicField->{FieldType} eq 'Table' ) {
                $LayoutObject->Block(
                    Name => 'DynamicFieldLink',
                    Data =>{
                        Label       => $Label,
                        Title       => $ValueStrg->{Title},
                        Value       => $ValueStrg->{Value},
                        Link        => $ValueStrg->{Link},
                        LinkPreview => $ValueStrg->{LinkPreview},
                    }
                );
            }
            else{
                $LayoutObject->Block(
                    Name => 'DynamicField',
                    Data =>{
                        Label => $Label,
                        Title => $ValueStrg->{Title},
                        Value => $ValueStrg->{Value}                       
                    }
                );
            }
        }
    }

    my %CustomDynamicForm = $CustomFormObject->CustomFormGet(
        FormID => $FormID,
        UserID => $Self->{UserID}
    );

    my $Output = $LayoutObject->Output(
        TemplateFile => 'TicketZoomServiceFormFields',
        Data => {},
    );

    return {
        Output => $Output,
    };
}

1;