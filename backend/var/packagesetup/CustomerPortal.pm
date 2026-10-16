# --
# var/packagesetup/CustomerPortal.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package var::packagesetup::CustomerPortal;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);
use List::Util qw(min);

our @ObjectDependencies = (
    'Kernel::System::SysConfig',
	'Kernel::System::Log',
);

=head1 NAME

CustomerPortal.pm - code to excecute during package installation

=head1 SYNOPSIS

All functions of package CustomerPortal

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

=cut

sub new {
    my ( $Type, %Param ) = @_;
    my $Self = {};
    bless( $Self, $Type );

	$Self->{UserID} = 1;

    return $Self;
}

=item CodeInstall()

run the code install part

    my $Result = $Kanban->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;
	
	$Self->_AddCards();
	$Self->_AddLoaderFiles();
    $Self->_AddInternalDynamicFieldsFAQ();
    $Self->CodeUpgrade_6_34_39();
    $Self->CodeUpgrade_6_36_72();
    
    return 1;
}

sub _AddCards {
	my ( $Self, %Param ) = @_;

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # To left custom card add
    $Param{NameLeft} = "Card Lateral Esquerda";
    $Param{BodyLeft} = "<b>Exemplo de mensagem Esquerda<b>";
    $Param{ValidID}  = "1";
    $Param{UserID}   = "1";
   
    # create new db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            INSERT INTO customer_portal_cards (name, body, valid_id, create_time, create_by, change_time, change_by ) 
            VALUES (?, ?, ?, current_timestamp, ?, current_timestamp, ?)',
        Bind => [
            \$Param{NameLeft}, \$Param{BodyLeft}, \$Param{ValidID}, \$Param{UserID}, \$Param{UserID}, 
        ],
    );

    # To right custom card add
    $Param{NameDir} = "Card Lateral Direita";
    $Param{BodyDir} = "<b>Exemplo de mensagem Direita<b>";

    # create new db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            INSERT INTO customer_portal_cards (name, body, valid_id, create_time, create_by, change_time, change_by ) 
            VALUES (?, ?, ?, current_timestamp, ?, current_timestamp, ?)',
        Bind => [
            \$Param{NameDir}, \$Param{BodyDir}, \$Param{ValidID}, \$Param{UserID}, \$Param{UserID}, 
        ],
    );
    
    return 1;
}

sub _AddInternalDynamicFieldsFAQ {
	my ( $Self, %Param ) = @_;
	
	my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
	my $SysConfigObject    = $Kernel::OM->Get('Kernel::System::SysConfig');
	
    #  To DynamicField ButtonText1
	my $DynamicFieldB1 = $DynamicFieldObject->DynamicFieldGet(
        Name => 'ButtonText1',
    );
	
	if ( IsHashRefWithData($DynamicFieldB1) ) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'info',
			Message  => "DynamicField ButtonText1 already exists.",
		);
		return 1;
	}

	# set specific config
    my $FieldConfig = {
        DefaultValue   => '',
		PossibleValues => {},
    };
	
	# create a new field
    my $FieldID = $DynamicFieldObject->DynamicFieldAdd(
		InternalField => 1,
        Name          => 'ButtonText1',
        Label         => 'ButtonText1',
        FieldOrder    => 5,
        FieldType     => 'Text',
        ObjectType    => 'FAQ',
        ValidID       => 1,
		Reorder       => 1,
        UserID        => $Self->{UserID},
		Config        => $FieldConfig,
    );

    if ( !$FieldID ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Could not create the new field ButtonText1.",
		);
    }

    #  To DynamicField ButtonColor1
    my $DynamicFieldC1 = $DynamicFieldObject->DynamicFieldGet(
        Name => 'ButtonColor1',
    );
	
	if ( IsHashRefWithData($DynamicFieldC1) ) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'info',
			Message  => "DynamicField ButtonColor1 already exists.",
		);
		return 1;
	}

	# create a new field
    my $FieldIDC1 = $DynamicFieldObject->DynamicFieldAdd(
		InternalField => 1,
        Name          => 'ButtonColor1',
        Label         => 'ButtonColor1',
        FieldOrder    => 6,
        FieldType     => 'Text',
        ObjectType    => 'FAQ',
        ValidID       => 1,
		Reorder       => 1,
        UserID        => $Self->{UserID},
		Config        => $FieldConfig,
    );

    if ( !$FieldIDC1 ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Could not create the new field ButtonColor1.",
		);
    }

    #  To DynamicField ButtonText2
    my $DynamicFieldB2 = $DynamicFieldObject->DynamicFieldGet(
        Name => 'ButtonText2',
    );
	
	if ( IsHashRefWithData($DynamicFieldB2) ) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'info',
			Message  => "DynamicField ButtonText2 already exists.",
		);
		return 1;
	}

	# create a new field
    my $FieldIDB2 = $DynamicFieldObject->DynamicFieldAdd(
		InternalField => 1,
        Name          => 'ButtonText2',
        Label         => 'ButtonText2',
        FieldOrder    => 7,
        FieldType     => 'Text',
        ObjectType    => 'FAQ',
        ValidID       => 1,
		Reorder       => 1,
        UserID        => $Self->{UserID},
		Config        => $FieldConfig,
    );

    if ( !$FieldIDB2 ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Could not create the new field ButtonText2.",
		);
    }

    #  To DynamicField ButtonColor2
    my $DynamicFieldC2 = $DynamicFieldObject->DynamicFieldGet(
        Name => 'ButtonColor2',
    );
	
	if ( IsHashRefWithData($DynamicFieldC2) ) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'info',
			Message  => "DynamicField ButtonColor2 already exists.",
		);
		return 1;
	}

	# create a new field
    my $FieldIDC2 = $DynamicFieldObject->DynamicFieldAdd(
		InternalField => 1,
        Name          => 'ButtonColor2',
        Label         => 'ButtonColor2',
        FieldOrder    => 8,
        FieldType     => 'Text',
        ObjectType    => 'FAQ',
        ValidID       => 1,
		Reorder       => 1,
        UserID        => $Self->{UserID},
		Config        => $FieldConfig,
    );

    if ( !$FieldIDC2 ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Could not create the new field ButtonColor2.",
		);
    }
	
	return 1;
}

=item CodeUpgrade_6_15_17()

run the code code upgrade on version 6_15_17

    my $Result = $CustomerPortal->CodeUpgrade_6_15_17();

=cut

sub CodeUpgrade_6_15_17 {
    my ( $Self, %Param ) = @_;

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # To left custom card add
    $Param{NameLeft} = "Card Lateral Esquerda";
    $Param{BodyLeft} = "<b>Exemplo de mensagem Esquerda<b>";
    $Param{ValidID}  = "1";
    $Param{UserID}   = "1";
   
    # create new db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            INSERT INTO customer_portal_cards (name, body, valid_id, create_time, create_by, change_time, change_by ) 
            VALUES (?, ?, ?, current_timestamp, ?, current_timestamp, ?)',
        Bind => [
            \$Param{NameLeft}, \$Param{BodyLeft}, \$Param{ValidID}, \$Param{UserID}, \$Param{UserID}, 
        ],
    );

    # To right custom card add
    $Param{NameDir} = "Card Lateral Direita";
    $Param{BodyDir} = "<b>Exemplo de mensagem Direita<b>";

    # create new db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            INSERT INTO customer_portal_cards (name, body, valid_id, create_time, create_by, change_time, change_by ) 
            VALUES (?, ?, ?, current_timestamp, ?, current_timestamp, ?)',
        Bind => [
            \$Param{NameDir}, \$Param{BodyDir}, \$Param{ValidID}, \$Param{UserID}, \$Param{UserID}, 
        ],
    );
    
    return 1;
}

=item CodeUpgrade_6_23_27()

run the code code upgrade on version 6_23_27

    my $Result = $CustomerPortal->CodeUpgrade_6_23_27();

=cut

sub CodeUpgrade_6_23_27 {
    my ( $Self, %Param ) = @_;

    my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

	my %Setting = $SysConfigObject->SettingGet(
		Name => "Loader::Module::AdminService###002-Ticket",
	);

	my @LoaderCSS = @{$Setting{EffectiveValue}{CSS}};
	my @LoaderJS = @{$Setting{EffectiveValue}{JavaScript}};
	
	# add JS if not exists
	if (grep $_ ne 'Core.Agent.Admin.CustomerPortalService.js', @LoaderJS) {
		push @LoaderJS, 'Core.Agent.Admin.CustomerPortalService.js';
	}
	
	my $Success = $SysConfigObject->SettingsSet(
		UserID   => $Self->{UserID},                                    
		Comments => 'Added JS to module CustomerPortal',                 
		Settings => [                                     
			{
				Name                   => 'Loader::Module::AdminService###002-Ticket',
				EffectiveValue         => { CSS => \@LoaderCSS, JavaScript => \@LoaderJS },
				IsValid                => 1,              
				UserModificationActive => 0,              
			},
		],
	);

	return $Success;
}

sub _AddLoaderFiles {
	my ( $Self, %Param ) = @_;

	my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

    my %Setting = $SysConfigObject->SettingGet(
        Name => "Loader::Module::AdminService###002-Ticket",
    );

    my %EffectiveValue;
    my @LoaderCSS;
    my @LoaderJS;

    if ( $Setting{EffectiveValue}{CSS} ) {
        @LoaderCSS = @{$Setting{EffectiveValue}{CSS}};
    }

    if ( $Setting{EffectiveValue}{JavaScript} ) {
        @LoaderJS = @{$Setting{EffectiveValue}{JavaScript}};
    }

    # add JS if not exists
    if ( !( 'Core.Agent.Admin.CustomerPortalService.js' ~~ @LoaderJS ) ) {
        push @LoaderJS, 'Core.Agent.Admin.CustomerPortalService.js';
    }

    if ( @LoaderCSS ) {

        $EffectiveValue{CSS} = \@LoaderCSS;
    }

    if ( @LoaderJS ) {

        $EffectiveValue{JavaScript} = \@LoaderJS;
    }

    my $Success = $SysConfigObject->SettingsSet(
        UserID   => 1,
        Name     => 'Loader::Module::AdminService###002-Ticket',                                
        Comments => 'Added JS to module CustomerPortal',                 
        Settings => [                                     
            {
                Name                   => 'Loader::Module::AdminService###002-Ticket',
                EffectiveValue         => \%EffectiveValue,
                IsValid                => 1,              
                UserModificationActive => 0,              
            },
        ],
    );

	return $Success;
}

=item CodeUpgrade_6_26_31()

run the code code upgrade on version 6_26_31

    my $Result = $CustomerPortal->CodeUpgrade_6_26_31();

=cut

sub CodeUpgrade_6_26_31 {
    my ( $Self, %Param ) = @_;
	
	my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
	my $SysConfigObject    = $Kernel::OM->Get('Kernel::System::SysConfig');
	
    #  To DynamicField ButtonText1
	my $DynamicFieldB1 = $DynamicFieldObject->DynamicFieldGet(
        Name => 'ButtonText1',
    );
	
	if ( IsHashRefWithData($DynamicFieldB1) ) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'info',
			Message  => "DynamicField ButtonText1 already exists.",
		);
		return 1;
	}

	# set specific config
    my $FieldConfig = {
        DefaultValue   => '',
		PossibleValues => {},
    };
	
	# create a new field
    my $FieldID = $DynamicFieldObject->DynamicFieldAdd(
		InternalField => 1,
        Name          => 'ButtonText1',
        Label         => 'ButtonText1',
        FieldOrder    => 5,
        FieldType     => 'Text',
        ObjectType    => 'FAQ',
        ValidID       => 1,
		Reorder       => 1,
        UserID        => $Self->{UserID},
		Config        => $FieldConfig,
    );

    if ( !$FieldID ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Could not create the new field ButtonText1.",
		);
    }

    #  To DynamicField ButtonColor1
    my $DynamicFieldC1 = $DynamicFieldObject->DynamicFieldGet(
        Name => 'ButtonColor1',
    );
	
	if ( IsHashRefWithData($DynamicFieldC1) ) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'info',
			Message  => "DynamicField ButtonColor1 already exists.",
		);
		return 1;
	}

	# create a new field
    my $FieldIDC1 = $DynamicFieldObject->DynamicFieldAdd(
		InternalField => 1,
        Name          => 'ButtonColor1',
        Label         => 'ButtonColor1',
        FieldOrder    => 6,
        FieldType     => 'Text',
        ObjectType    => 'FAQ',
        ValidID       => 1,
		Reorder       => 1,
        UserID        => $Self->{UserID},
		Config        => $FieldConfig,
    );

    if ( !$FieldIDC1 ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Could not create the new field ButtonColor1.",
		);
    }

    #  To DynamicField ButtonText2
    my $DynamicFieldB2 = $DynamicFieldObject->DynamicFieldGet(
        Name => 'ButtonText2',
    );
	
	if ( IsHashRefWithData($DynamicFieldB2) ) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'info',
			Message  => "DynamicField ButtonText2 already exists.",
		);
		return 1;
	}

	# create a new field
    my $FieldIDB2 = $DynamicFieldObject->DynamicFieldAdd(
		InternalField => 1,
        Name          => 'ButtonText2',
        Label         => 'ButtonText2',
        FieldOrder    => 7,
        FieldType     => 'Text',
        ObjectType    => 'FAQ',
        ValidID       => 1,
		Reorder       => 1,
        UserID        => $Self->{UserID},
		Config        => $FieldConfig,
    );

    if ( !$FieldIDB2 ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Could not create the new field ButtonText2.",
		);
    }

    #  To DynamicField ButtonColor2
    my $DynamicFieldC2 = $DynamicFieldObject->DynamicFieldGet(
        Name => 'ButtonColor2',
    );
	
	if ( IsHashRefWithData($DynamicFieldC2) ) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'info',
			Message  => "DynamicField ButtonColor2 already exists.",
		);
		return 1;
	}

	# create a new field
    my $FieldIDC2 = $DynamicFieldObject->DynamicFieldAdd(
		InternalField => 1,
        Name          => 'ButtonColor2',
        Label         => 'ButtonColor2',
        FieldOrder    => 8,
        FieldType     => 'Text',
        ObjectType    => 'FAQ',
        ValidID       => 1,
		Reorder       => 1,
        UserID        => $Self->{UserID},
		Config        => $FieldConfig,
    );

    if ( !$FieldIDC2 ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Could not create the new field ButtonColor2.",
		);
    }
	
	return 1;
}

sub CodeUpgrade_6_34_39 {
	my ( $Self, %Param ) = @_;

	my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
	my $SysConfigObject    = $Kernel::OM->Get('Kernel::System::SysConfig');
	my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');

	my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => 'ImpactOperation',
    );

	if ( IsHashRefWithData($DynamicField) ) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'info',
			Message  => "DynamicField ImpactOperation already exists.",
		);
		return 1;
	}

	# set specific config
    my $FieldConfig = {
        DefaultValue   => '',
		PossibleValues => {},
    };

    # create a new field
    my $FieldID = $DynamicFieldObject->DynamicFieldAdd(
        InternalField => 1,
        Name          => 'ImpactOperation',
        Label         => 'Esse incidente impacta diretamente na operação?',
        FieldOrder    => 4,
        FieldType     => 'Checkbox',
        ObjectType    => 'Ticket',
        Config        => $FieldConfig,
        ValidID       => 1,
        Reorder       => 1,
        UserID        => 1,
    );

    if ( !$FieldID ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Could not create the new field ImpactOperation.",
		);
    }

	return 1;
}

=item CodeUpgrade_6_36_72()

run the code code upgrade on version CodeUpgrade_6_36_72

    my $Result = $CustomerPortal->CodeUpgrade_6_36_72();

=cut

sub CodeUpgrade_6_36_72 {
	my ( $Self, %Param ) = @_;

	my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
	my $SysConfigObject    = $Kernel::OM->Get('Kernel::System::SysConfig');
	my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');

	my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => 'TicketStarAvaliation',
    );

	if ( IsHashRefWithData($DynamicField) ) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'info',
			Message  => "DynamicField TicketStarAvaliation already exists.",
		);
		return 1;
	}

	# set specific config
    my %FieldConfig = (
        PossibleValues => {
                            1 => '1 Star',
                            2 => "2 Stars",
                            3 => "3 Stars",
                            4 => "4 Stars",
                            5 => "5 Stars",
                           },
        DefaultValue => '',
    ); 

    # create a new field
    my $FieldID = $DynamicFieldObject->DynamicFieldAdd(
        InternalField => 0,
        Name          => 'TicketStarAvaliation',
        Label         => 'Avaliação',
        FieldOrder    => 4,
        FieldType     => 'Dropdown',
        ObjectType    => 'Ticket',
        Config        => \%FieldConfig,
        ValidID       => 1,
        Reorder       => 1,
        UserID        => 1,
    );

    if ( !$FieldID ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Could not create the new field TicketStarAvaliation.",
		);
    }

    my $DynamicFieldTicketNoteAvalition = $DynamicFieldObject->DynamicFieldGet(
        Name => 'TicketNoteAvalition',
    );

	if ( IsHashRefWithData($DynamicFieldTicketNoteAvalition) ) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'info',
			Message  => "DynamicField TicketNoteAvalition already exists.",
		);
		return 1;
	}

	# set specific config
    my $FieldConfigTicketNoteAvalition = {
        # DefaultValue   => '',
		# PossibleValues => {},
    };


    # create a new field
    my $FieldIDTicketNoteAvalition = $DynamicFieldObject->DynamicFieldAdd(
        InternalField => 0,
        Name          => 'TicketNoteAvalition',
        Label         => 'Informe um comentário para a avaliação',
        FieldOrder    => 5,
        FieldType     => 'TextArea',
        ObjectType    => 'Ticket',
        Config        => $FieldConfigTicketNoteAvalition,
        ValidID       => 1,
        Reorder       => 1,
        UserID        => 1,
    );

    if ( !$FieldIDTicketNoteAvalition ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Could not create the new field TicketNoteAvalition.",
		);
    }
    
	return 1;
}

1;
