# --
# var/packagesetup/FAQInject.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package var::packagesetup::FAQInject;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);
use List::Util qw(min);

our @ObjectDependencies = (
    'Kernel::System::DynamicField',
    'Kernel::System::SysConfig',
	'Kernel::System::Log',
	'Kernel::Config',
);

=head1 NAME

FAQInject.pm - code to excecute during package installation

=head1 SYNOPSIS

All functions of package TicketInvoker

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

    my $Result = $FAQInject->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;
    
    # add dynamic field FAQ answer
	$Self->_AddInternalDynamicField(
        Name => 'FAQAnswer',
        Label         => 'FAQAnswer',
        FieldOrder    => 20,
        FieldType     => 'TextArea',
        ObjectType    => 'Ticket',
        FieldConfig => {
            DefaultValue   => '',
            Rows => '',
            Cols => '',
            RegExList => []
        }
    );    

    # add dynamic field FAQ send answer
    $Self->_AddInternalDynamicField(
        Name => 'FAQSendAnswer',
        Label         => 'FAQSendAnswer',
        FieldOrder    => 21,
        FieldType     => 'Text',
        ObjectType    => 'Ticket',
        FieldConfig => {
            DefaultValue   => '',
            Link => '',
            LinkPreview => '',
            RegExList => []
        }
    );  
    
    # add dynamic field FAQ Minimun Confidence Score
    $Self->_AddInternalDynamicField(
        Name => 'MinConfidenceScore',
        Label         => 'Minimum confidence score',
        FieldOrder    => 22,
        FieldType     => 'Text',
        ObjectType    => 'FAQ',
        FieldConfig => {
            DefaultValue   => '',
            Link => '',
            LinkPreview => '',
            RegExList => []
        }
    );

    # add dynamic field FAQ Minimun Confidence Score in views
    $Self->_AddDynamicFieldConfig(
        FieldName => 'MinConfidenceScore'
    );

    # add dynamic field customer feedback FAQ answer
	$Self->_AddInternalDynamicField(
        Name => 'CustomerFeedbackFAQ',
        Label         => 'Customer return to autoresponder',
        FieldOrder    => 23,
        FieldType     => 'Dropdown',
        ObjectType    => 'Ticket',
        FieldConfig => {
            DefaultValue   => '',
            Link => '',
            LinkPreview => '',
            PossibleNone => 1,
            PossibleValues => {
                1 => 'Satisfactory Answer',
                2 => 'Insufficient answer'
            },
            TranslatableValues => 1,
            TreeView => 0
        }
    );      

    # add web service
    $Self->_AddWebservice();
    
    # add notification
    $Self->_CreateNotification();

    # add email option config
    $Self->_AddEmailOptionConfig(
        FieldName => 'CustomerFeedbackFAQ',
        Values => { 
            '1' => '0',
            '2' => '0'
        },
        Config => 'InBox::EmailOption::DynamicFieldsEnabledValues'
    );

    # add email option config
    $Self->_AddEmailOptionConfig(
        FieldName => 'CustomerFeedbackFAQ',
        Values => { 
            '1' => 'Your ticket will be closed, thanks for contacting us.',
            '2' => 'Your ticket will be forwarded to an agent who will contact you.'
        },
        Config => 'InBox::EmailOption::DynamicFieldsTexts',
    );

    return 1;
}

=item CodeUpgrade_6_3_17()

run the code install part

    my $Result = $FAQInject->CodeUpgrade_6_3_17();

=cut

sub CodeUpgrade_6_3_17 {
    my ( $Self, %Param ) = @_;
    
    # add dynamic field FAQ answer
	$Self->_AddInternalDynamicField(
        Name => 'FAQAnswer',
        Label         => 'FAQAnswer',
        FieldOrder    => 20,
        FieldType     => 'TextArea',
        ObjectType    => 'Ticket',
        FieldConfig => {
            DefaultValue   => '',
            Rows => '',
            Cols => '',
            RegExList => []
        }
    );

    # add dynamic field FAQ send answer
    $Self->_AddInternalDynamicField(
        Name => 'FAQSendAnswer',
        Label         => 'FAQSendAnswer',
        FieldOrder    => 21,
        FieldType     => 'Text',
        ObjectType    => 'Ticket',
        FieldConfig => {
            DefaultValue   => '',
            Link => '',
            LinkPreview => '',
            RegExList => []
        }
    );
    
    # add dynamic field FAQ Minimun Confidence Score
    $Self->_AddInternalDynamicField(
        Name => 'MinConfidenceScore',
        Label         => 'Minimum confidence score',
        FieldOrder    => 22,
        FieldType     => 'Text',
        ObjectType    => 'FAQ',
        FieldConfig => {
            DefaultValue   => '',
            Link => '',
            LinkPreview => '',
            RegExList => []
        }
    );

    # add dynamic field FAQ Minimun Confidence Score in views
    $Self->_AddDynamicFieldConfig(
        FieldName => 'MinConfidenceScore'
    );

    # add dynamic field customer feedback FAQ answer
	$Self->_AddInternalDynamicField(
        Name => 'CustomerFeedbackFAQ',
        Label         => 'Customer return to autoresponder',
        FieldOrder    => 23,
        FieldType     => 'Dropdown',
        ObjectType    => 'Ticket',
        FieldConfig => {
            DefaultValue   => '',
            Link => '',
            LinkPreview => '',
            PossibleNone => 1,
            PossibleValues => {
                1 => 'Satisfactory Answer',
                2 => 'Insufficient answer'
            },
            TranslatableValues => 1,
            TreeView => 0
        }
    ); 

    # add web service
    $Self->_AddWebservice();

    # add notification
    $Self->_CreateNotification();

    # add email option config
    $Self->_AddEmailOptionConfig(
        FieldName => 'CustomerFeedbackFAQ',
        Values => { 
            '1' => '0',
            '2' => '0'
        },
        Config => 'InBox::EmailOption::DynamicFieldsEnabledValues'
    );

    # add email option config
    $Self->_AddEmailOptionConfig(
        FieldName => 'CustomerFeedbackFAQ',
        Values => { 
            '1' => 'Your ticket will be closed, thanks for contacting us.',
            '2' => 'Your ticket will be forwarded to an agent who will contact you.'
        },
        Config => 'InBox::EmailOption::DynamicFieldsTexts',
    );

    return 1;
}

sub _AddInternalDynamicField {
	my ( $Self, %Param ) = @_;

	my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
	my $SysConfigObject    = $Kernel::OM->Get('Kernel::System::SysConfig');
	my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');

	my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => $Param{Name},
    );

	if ( IsHashRefWithData($DynamicField) ) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'info',
			Message  => "DynamicField FAQAnswer already exists.",
		);
		return 1;
	}

    # create a new field
    my $FieldID = $DynamicFieldObject->DynamicFieldAdd(
        InternalField => 0,
        Name          => $Param{Name},
        Label         => $Param{Label},
        FieldOrder    => $Param{FieldOrder},
        FieldType     => $Param{FieldType},
        ObjectType    => $Param{ObjectType},
        Config        => $Param{FieldConfig},
        ValidID       => 1,
        Reorder       => 1,
        UserID        => 1,
    );

    if ( !$FieldID ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Could not create the new field $Param{Name}.",
		);
    }

	return 1;
}

sub _AddDynamicFieldConfig {
	my ( $Self, %Param ) = @_;

	my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

    # set frontend modules
    my @Frontend = qw(AgentFAQAdd AgentFAQEdit AgentFAQZoom);

    # add dynamic field customer contract in the sysconfig of modules
    foreach my $ItemUpdate ( @Frontend ){

        my %Setting = $SysConfigObject->SettingGet(
            Name => "FAQ::Frontend::$ItemUpdate###DynamicField",
        );

        my %DynamicFilds = %{ $Setting{EffectiveValue} };

        my $IsDynamicField = 0;

        for my $Item (keys %DynamicFilds){
            if ( $Item eq $Param{FieldName} ) {
                $IsDynamicField = 1;
            }
        }

        if(!$IsDynamicField){
            $DynamicFilds{$Param{FieldName}} = '1';
        }

        # Deploy the new settings.
        my $SettingsDeployed = $SysConfigObject->SettingsSet(
            UserID   => 1,
            Comments => "Add dynamic field $Param{FieldName}",
            Settings => [ 
                {
                    Name           => "FAQ::Frontend::$ItemUpdate###DynamicField",
                    EffectiveValue => \%DynamicFilds,
                    IsValid        => 1,
                    UserModificationActive => 0
                }
            ],
        );

        if ( !$SettingsDeployed ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Message  => "Error while deploying the migrated permissions!",
                Priority => 'error',
            );
        }
    }	

    return 1;
}

sub _AddEmailOptionConfig {
	my ( $Self, %Param ) = @_;

	my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');
   
    my %Setting = $SysConfigObject->SettingGet(
        Name => $Param{Config},
    );

    my %EmailOption = %{ $Setting{EffectiveValue} };

    my $IsDynamicField = 0;

    for my $Item (keys %EmailOption){
        if ( $Item eq $Param{FieldName} ) {
            $IsDynamicField = 1;
        }
    }

    if(!$IsDynamicField){
        $EmailOption{$Param{FieldName}} = $Param{Values};
    }

    # Deploy the new settings.
    my $SettingsDeployed = $SysConfigObject->SettingsSet(
        UserID   => 1,
        Comments => "Add dynamic field $Param{FieldName}",
        Settings => [ 
            {
                Name           => $Param{Config},
                EffectiveValue => \%EmailOption,
                IsValid        => 1,
                UserModificationActive => 0
            }
        ],
    );

    if ( !$SettingsDeployed ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Message  => "Error while deploying the migrated permissions!",
            Priority => 'error',
        );
    }

    return 1;
}

sub _AddWebservice {
	my ( $Self, %Param ) = @_;

    my $WebserviceObject = $Kernel::OM->Get('Kernel::System::GenericInterface::Webservice');
    my $YAMLObject       = $Kernel::OM->Get('Kernel::System::YAML');

    my $Home = $Kernel::OM->Get('Kernel::Config')->Get('Home');

    for my $File ( qw(AzureLanguageIA) ) {
        
        my $Content = $Kernel::OM->Get('Kernel::System::Main')->FileRead(
            Location => "$Home/var/webservices/TicketInvoker/$File.yml",
            Mode     => 'utf8',
        );

        $Content = ${ $Content || \'' };

        my $ImportedConfig = $YAMLObject->Load( Data => $Content );

        my $Success = $WebserviceObject->WebserviceAdd(
            Name    => $File,
            Config  => $ImportedConfig,
            ValidID => 1,
            UserID  => $Self->{UserID},
        );

        if( !$Success ){
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Could not add webservice.",
            );

            return 0;
        }
    }   

    return 1;
}

sub _CreateNotification {
    my ( $Self, %Param ) = @_;

    my $NotificationEventObject = $Kernel::OM->Get('Kernel::System::NotificationEvent');

    my $Home = $Kernel::OM->Get('Kernel::Config')->Get('Home');
            
    my $Content = $Kernel::OM->Get('Kernel::System::Main')->FileRead(
        Location => "$Home/var/notification/FAQ_Create_automatic_answer.yml",
        Mode     => 'utf8',
    );

    $Content = ${ $Content || \'' };

    my $NotificationImport = $NotificationEventObject->NotificationImport(
        Content                        => $Content,
        OverwriteExistingNotifications => 0,
        UserID                         => 1,
    );

    if ( !$NotificationImport->{Success} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Could not add notification.",
        );

        return 0;
    }

    return 1;
}

1;