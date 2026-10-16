# --
# Kernel/Modules/CustomerPortalAddCustomerUser.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package Kernel::Modules::CustomerPortalAddCustomerUser;

use strict;
use warnings;
 
use utf8;

use Digest::MD5 qw(md5_hex);
use Encode qw(decode encode);
use File::Basename;

our $ObjectManagerDisabled = 1;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # get form id
    $Self->{FormID} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'FormID' );

    # create form id
    if ( !$Self->{FormID} ) {
        $Self->{FormID} = $Kernel::OM->Get('Kernel::System::Web::UploadCache')->FormIDCreate();
    }

    my $DynamicFieldConfigs = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        ObjectType => 'CustomerUser',
    );

    $Self->{DynamicFieldLookup} = { map { $_->{Name} => $_ } @{$DynamicFieldConfigs} };

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject         = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject          = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $CustomerUserObject   = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $CustomerPortalObject = $Kernel::OM->Get('Kernel::System::CustomerPortal');
    my $JSONObject           = $Kernel::OM->Get('Kernel::System::JSON');
	my $ServiceObject        = $Kernel::OM->Get('Kernel::System::Service');

    my $Message  = $ParamObject->GetParam( Param => 'Message' )  || '';

    my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');

    $CustomerPortalLayoutObject->CreateNavBar(
        ActionActive => "",
        %{$Self}
    );

    if( $Self->{Subaction} eq 'AddCustomerUser' ){

        my $Note = '';
        my $Message = '';
        my $Source = 'CustomerUser';
        my ( %GetParam, %Errors );

        my $AutoLoginCreation = $ConfigObject->Get($Source)->{AutoLoginCreation};
        my $CheckItemObject = $Kernel::OM->Get('Kernel::System::CheckItem');
        my $MainObject         = $Kernel::OM->Get('Kernel::System::Main');

        # Get dynamic field backend object.
        my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

        ENTRY:
        for my $Entry ( @{ $ConfigObject->Get($Source)->{Map} } ) {

            # don't validate UserLogin if AutoLoginCreation is configured
            next ENTRY if ( $AutoLoginCreation && $Entry->[0] eq 'UserLogin' );

            # check dynamic fields
            if ( $Entry->[5] eq 'dynamic_field' ) {

                my $DynamicFieldConfig = $Self->{DynamicFieldLookup}->{ $Entry->[2] };

                if ( !IsHashRefWithData($DynamicFieldConfig) ) {
                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'error',
                        Message  => "DynamicField $Entry->[2] not found!",
                    );
                    next ENTRY;
                }

                my $ValidationResult = $DynamicFieldBackendObject->EditFieldValueValidate(
                    DynamicFieldConfig => $DynamicFieldConfig,
                    ParamObject        => $ParamObject,
                    Mandatory          => $Entry->[4],
                );

                if ( $ValidationResult->{ServerError} ) {
                    $Errors{ $Entry->[0] } = $ValidationResult;
                }
                else {

                    # generate storable value of dynamic field edit field
                    $GetParam{ $Entry->[0] } = $DynamicFieldBackendObject->EditFieldValueGet(
                        DynamicFieldConfig => $DynamicFieldConfig,
                        ParamObject        => $ParamObject,
                        LayoutObject       => $LayoutObject,
                    );
                }
            }

            # check remaining non-dynamic-field mandatory fields
            else {
                $GetParam{ $Entry->[0] } = $ParamObject->GetParam( Param => $Entry->[0] ) || '';
            }
        }

        # check email address
        if (
            $GetParam{UserEmail}
            && !$CheckItemObject->CheckEmail( Address => $GetParam{UserEmail} )
            )
        {
            $Errors{UserEmailInvalid} = 'ServerError';
            $Errors{ErrorType}        = $CheckItemObject->CheckErrorType() . 'ServerErrorMsg';
        }

        $GetParam{ValidID} = '1';
        $GetParam{UserCustomerID} = $Self->{UserCustomerID};

        # if no errors occurred
        if ( !%Errors ) {

            # add user
            my $User = $CustomerUserObject->CustomerUserAdd(
                %GetParam,
                UserID => '1',
                Source => $Source
            );

            if ($User) {

                # set dynamic field values
                my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

                ENTRY:
                for my $Entry ( @{ $ConfigObject->Get($Source)->{Map} } ) {
                    next ENTRY if $Entry->[5] ne 'dynamic_field';

                    my $DynamicFieldConfig = $Self->{DynamicFieldLookup}->{ $Entry->[2] };

                    if ( !IsHashRefWithData($DynamicFieldConfig) ) {
                        $Note .= $LayoutObject->Notify(
                            Info => $LayoutObject->{LanguageObject}->Translate(
                                'Dynamic field %s not found!',
                                $Entry->[2],
                            ),
                        );
                        next ENTRY;
                    }

                    my $ValueSet = $DynamicFieldBackendObject->ValueSet(
                        DynamicFieldConfig => $DynamicFieldConfig,
                        ObjectName         => $User,
                        Value              => $GetParam{ $Entry->[0] },
                        UserID             => '1',
                    );

                    if ( !$ValueSet ) {
                        $Note .= $LayoutObject->Notify(
                            Info => $LayoutObject->{LanguageObject}->Translate(
                                'Unable to set value for dynamic field %s!',
                                $Entry->[2],
                            ),
                        );
                        next ENTRY;
                    }
                }

                # update preferences
                my %Preferences = %{ $ConfigObject->Get('CustomerPreferencesGroups') };
                GROUP:
                for my $Group ( sort keys %Preferences ) {
                    next GROUP if $Group eq 'Password';

                    # get user data
                    my %UserData = $CustomerUserObject->CustomerUserDataGet(
                        User => $User,
                    );
                    my $Module = $Preferences{$Group}->{Module};
                    if ( !$MainObject->Require($Module) ) {
                        return $LayoutObject->FatalError();
                    }
                    my $Object = $Module->new(
                        %{$Self},
                        ConfigItem => $Preferences{$Group},
                        UserObject => $CustomerUserObject,
                        Debug      => $Self->{Debug},
                    );
                    my @Params = $Object->Param( %{ $Preferences{$Group} }, UserData => \%UserData );
                    if (@Params) {
                        my %GetParam;
                        for my $ParamItem (@Params) {
                            my @Array = $ParamObject->GetArray( Param => $ParamItem->{Name} );
                            $GetParam{ $ParamItem->{Name} } = \@Array;
                        }
                        if (
                            !$Object->Run(
                                GetParam => \%GetParam,
                                UserData => \%UserData
                            )
                            )
                        {
                            $Note .= $LayoutObject->Notify( Info => $Object->Error() );
                        }
                    }
                }

                # get user data and show screen again
                if ( !$Note ) {
                    # $Note = $LayoutObject->{LanguageObject}->Translate('User %s added successfully!', $GetParam{UserLogin} );
                    $Note = $LayoutObject->Notify( Info => $LayoutObject->{LanguageObject}->Translate('User %s added successfully!', $GetParam{UserLogin} ) );
                }
                
                # redirect
                return $LayoutObject->Redirect(
                    OP => "Action=CustomerPortalAddCustomerUser;Message=$Note",
                );
            }
            else {
                $Note .= $LayoutObject->Notify( Priority => 'Error' );
            }
        }

        # redirect
        return $LayoutObject->Redirect(
            OP => "Action=CustomerPortalAddCustomerUser;Message=$Note",
        );
    }
    else{

        if($Message){
            $LayoutObject->Block(
                Name => 'Head',
                Data => {
                    Header => $Message
                },
            );
        }
        
        $LayoutObject->Block(
            Name => 'Body',
            Data => \%Param,
        );

        # To show item to Add CustomerUser
        my $LoginsToAddedCustomerUser = $ConfigObject->Get('CustomerPortal::Core::LoginsToAddedCustomerUser');

        my %HashOfUserConfig = map {$_ => $Self->{UserLogin}} @{$LoginsToAddedCustomerUser};

        if ( defined $HashOfUserConfig{ $Self->{UserLogin} } ) {

            $LayoutObject->Block(
                Name => 'ItemAddUser',
                Data => {},
            );

            my $Source = 'CustomerUser';

            # update only the preferences and dynamic fields, if the source is readonly or a ldap backend
            my $UpdateOnlyPreferences;

            if ( $ConfigObject->Get($Source)->{ReadOnly} || $ConfigObject->Get($Source)->{Module} =~ /LDAP/i ) {
                $UpdateOnlyPreferences = 1;
            }

            my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
            
            ENTRY:
            for my $Entry ( @{ $ConfigObject->Get( $Source )->{Map} } ) {

                next ENTRY if !$Entry->[0];
                next ENTRY if $Entry->[0] eq 'UserComment';
                next ENTRY if $Entry->[0] eq 'UserCountry';
                next ENTRY if $Entry->[0] eq 'UserZip';
                next ENTRY if $Entry->[0] eq 'UserStreet';
                next ENTRY if $Entry->[0] eq 'UserFax';
                next ENTRY if $Entry->[0] eq 'UserCity';
                next ENTRY if $Entry->[0] eq 'UserTitle';

                # Handle dynamic fields
                if ( $Entry->[5] eq 'dynamic_field' ) {

                    my $DynamicFieldConfig = $Self->{DynamicFieldLookup}->{ $Entry->[2] };

                    next ENTRY if !IsHashRefWithData($DynamicFieldConfig);

                    # Get HTML for dynamic field
                    my $DynamicFieldHTML = $DynamicFieldBackendObject->EditFieldRender(
                        DynamicFieldConfig => $DynamicFieldConfig,
                        Value              => $Param{ $Entry->[0] } ? $Param{ $Entry->[0] } : undef,
                        Mandatory          => $Entry->[4],
                        LayoutObject       => $LayoutObject,
                        ParamObject        => $ParamObject,

                        # Server error, if any
                        %{ $Param{Errors}->{ $Entry->[0] } },
                    );

                    # skip fields for which HTML could not be retrieved
                    next ENTRY if !IsHashRefWithData($DynamicFieldHTML);

                    $LayoutObject->Block(
                        Name => 'DynamicField',
                        Data => {
                            Name  => $DynamicFieldConfig->{Name},
                            Label => $DynamicFieldHTML->{Label},
                            Field => $DynamicFieldHTML->{Field},
                        },
                    );

                    next ENTRY;
                }

                my $Block = 'Input';

                # check input type
                if ( $Entry->[0] =~ /^UserPasswor/i ) {
                    $Block = 'Password';
                }

                # check if login auto creation
                if ( $ConfigObject->Get( $Source )->{AutoLoginCreation} && $Entry->[0] eq 'UserLogin' ) {
                    $Block = 'InputHidden';
                }

                if ( $Entry->[7] || $UpdateOnlyPreferences ) {
                    $Param{ReadOnly} = 1;
                }
                else {
                    $Param{ReadOnly} = 0;
                }

                # show required flag
                if ( $Entry->[4] ) {
                    $Param{RequiredClass}          = 'Validate_Required';
                    $Param{RequiredLabelClass}     = 'Mandatory';
                    $Param{RequiredLabelCharacter} = '*';
                }
                else {
                    $Param{RequiredClass}          = '';
                    $Param{RequiredLabelClass}     = '';
                    $Param{RequiredLabelCharacter} = '';
                }

                # set empty string
                $Param{Errors}->{ $Entry->[0] . 'Invalid' } ||= '';

                # add class to validate emails
                if ( $Entry->[0] eq 'UserEmail' ) {
                    $Param{RequiredClass} .= ' Validate_Email';
                }

                # build selections or input fields
                if ( $ConfigObject->Get( $Source )->{Selections}->{ $Entry->[0] } ) {
                    $Block = 'Option';

                    # Change the validation class
                    if ( $Param{RequiredClass} ) {
                        $Param{RequiredClass} = 'Validate_Required';
                    }

                    # get the data of the current selection
                    my $SelectionsData = $ConfigObject->Get( $Source )->{Selections}->{ $Entry->[0] };

                    # make sure the encoding stamp is set
                    for my $Key ( sort keys %{$SelectionsData} ) {
                        $SelectionsData->{$Key}
                            = $Kernel::OM->Get('Kernel::System::Encode')->EncodeInput( $SelectionsData->{$Key} );
                    }

                    # build option string
                    $Param{Option} = $LayoutObject->BuildSelection(
                        Data        => $SelectionsData,
                        Name        => $Entry->[0],
                        Translation => 1,
                        SelectedID  => $Param{ $Entry->[0] },
                        Class       => "$Param{RequiredClass} Modernize " . $Param{Errors}->{ $Entry->[0] . 'Invalid' },
                        Disabled    => $UpdateOnlyPreferences ? 1 : 0,
                    );
                }
                elsif ( $Entry->[0] =~ /^ValidID/i ) {

                    # Change the validation class
                    if ( $Param{RequiredClass} ) {
                        $Param{RequiredClass} = 'Validate_Required';
                    }

                    # build ValidID string
                    $Block = 'Option';
                    $Param{Option} = $LayoutObject->BuildSelection(
                        Data       => { $Kernel::OM->Get('Kernel::System::Valid')->ValidList(), },
                        Name       => $Entry->[0],
                        SelectedID => defined( $Param{ $Entry->[0] } ) ? $Param{ $Entry->[0] } : 1,
                        Class      => "$Param{RequiredClass} Modernize " . $Param{Errors}->{ $Entry->[0] . 'Invalid' },
                        Disabled   => $UpdateOnlyPreferences ? 1 : 0,
                    );
                }
                elsif (
                    $Entry->[0] =~ /^UserCustomerID$/i
                    && $ConfigObject->Get( $Source )->{CustomerCompanySupport}
                    )
                {
                    my $CustomerCompanyObject = $Kernel::OM->Get('Kernel::System::CustomerCompany');
                    my %CompanyList           = (
                        $CustomerCompanyObject->CustomerCompanyList( Limit => 0 ),
                        '' => '-',
                    );
                    if ( $Param{ $Entry->[0] } ) {
                        my %Company = $CustomerCompanyObject->CustomerCompanyGet(
                            CustomerID => $Param{ $Entry->[0] },
                        );
                        if ( !%Company ) {
                            $CompanyList{ $Param{ $Entry->[0] } } = $Param{ $Entry->[0] } . ' (-)';
                        }
                    }
                    $Block = 'Option';

                    # Change the validation class
                    if ( $Param{RequiredClass} ) {
                        $Param{RequiredClass} = 'Validate_Required';
                    }

                    my $UseAutoComplete = $Kernel::OM->Get('Kernel::Config')->Get('AdminCustomerUser::UseAutoComplete');

                    if ($UseAutoComplete) {

                        my $Value = $Param{ $Entry->[0] } || $Param{CustomerID};
                        $Param{Option} = '<input type="text" id="UserCustomerID" name="UserCustomerID" value="' . $Value . '"
                            class="W50pc CustomerAutoCompleteSimple '
                            . $Param{RequiredClass} . ' '
                            . $Param{Errors}->{ $Entry->[0] . 'Invalid' }
                            . '" data-customer-search-type="CustomerID" />';
                    }
                    else {
                        $Param{Option} = $LayoutObject->BuildSelection(
                            Data       => \%CompanyList,
                            Name       => $Entry->[0],
                            Max        => 80,
                            SelectedID => $Param{ $Entry->[0] } || $Param{CustomerID},
                            Class      => "$Param{RequiredClass} Modernize " . $Param{Errors}->{ $Entry->[0] . 'Invalid' },
                            Disabled   => $UpdateOnlyPreferences ? 1 : 0,
                        );
                    }
                }
                elsif ( $Param{Action} eq 'Add' && $Entry->[0] =~ /^UserCustomerID$/i ) {

                    # Use CustomerID param if called from CIC.
                    $Param{Value} = $Param{ $Entry->[0] } || $Param{CustomerID} || '';
                }
                else {
                    $Param{Value} = $Param{ $Entry->[0] } || '';
                }

                # add form option
                if ( $Param{Type} && $Param{Type} eq 'hidden' ) {
                    $Param{Preferences} .= $Param{Value};
                }
                else {
                    $LayoutObject->Block(
                        Name => 'PreferencesGeneric',
                        Data => {
                            Item => $Entry->[1],
                            %Param
                        },
                    );
                    $LayoutObject->Block(
                        Name => "PreferencesGeneric$Block",
                        Data => {
                            Item         => $Entry->[1],
                            Name         => $Entry->[0],
                            InvalidField => $Param{Errors}->{ $Entry->[0] . 'Invalid' } || '',
                            %Param,
                        },
                    );

                    # add the correct client side error msg
                    if ( $Block eq 'Input' && $Entry->[0] eq 'UserEmail' ) {
                        $LayoutObject->Block(
                            Name => 'PreferencesUserEmailErrorMsg',
                            Data => { Name => $Entry->[0] },
                        );
                    }
                    else {
                        $LayoutObject->Block(
                            Name => "PreferencesGenericErrorMsg",
                            Data => { Name => $Entry->[0] },
                        );
                    }

                    # add the correct server error msg
                    if ( $Block eq 'Input' && $Param{UserEmail} && $Entry->[0] eq 'UserEmail' ) {

                        # display server error msg according with the occurred email error type
                        $LayoutObject->Block(
                            Name => 'PreferencesUserEmail' . ( $Param{Errors}->{ErrorType} || '' ),
                            Data => { Name => $Entry->[0] },
                        );
                    }
                    else {
                        $LayoutObject->Block(
                            Name => "PreferencesGenericServerErrorMsg",
                            Data => { Name => $Entry->[0] },
                        );
                    }
                }
            }


            my $PreferencesUsed = $ConfigObject->Get( $Source )->{AdminSetPreferences};
            if ( ( defined $PreferencesUsed && $PreferencesUsed != 0 ) || !defined $PreferencesUsed ) {

                my %Data;
                my %Preferences = %{ $ConfigObject->Get('CustomerPreferencesGroups') };

                GROUP:
                for my $Group ( sort keys %Preferences ) {

                    next GROUP if !$Group;
                    next GROUP if $Group ne 'Language' && $Group ne 'TimeZone' ;

                    my $PreferencesGroup = $Preferences{$Group};

                    next GROUP if !$PreferencesGroup;
                    next GROUP if ref $PreferencesGroup ne 'HASH';

                    if ( $Data{ $PreferencesGroup->{Prio} } ) {

                        COUNT:
                        for my $Count ( 1 .. 151 ) {

                            $PreferencesGroup->{Prio}++;

                            if ( !$Data{ $PreferencesGroup->{Prio} } ) {
                                $Data{ $PreferencesGroup->{Prio} } = $Group;
                                last COUNT;
                            }
                        }
                    }

                    $Data{ $PreferencesGroup->{Prio} } = $Group;
                }

                # sort
                for my $Key ( sort keys %Data ) {
                    $Data{ sprintf "%07d", $Key } = $Data{$Key};
                    delete $Data{$Key};
                }

                # show each preferences setting
                PRIO:
                for my $Prio ( sort keys %Data ) {

                    my $Group = $Data{$Prio};
                    if ( !$ConfigObject->{CustomerPreferencesGroups}->{$Group} ) {
                        next PRIO;
                    }

                    my %Preference = %{ $ConfigObject->{CustomerPreferencesGroups}->{$Group} };
                    if ( $Group eq 'Password' ) {
                        next PRIO;
                    }

                    my $Module = $Preference{Module}
                        || 'Kernel::Output::HTML::CustomerPreferencesGeneric';

                    # load module
                    if ( $Kernel::OM->Get('Kernel::System::Main')->Require($Module) ) {
                        my $Object = $Module->new(
                            %{$Self},
                            ConfigItem => \%Preference,
                            UserObject => $Kernel::OM->Get('Kernel::System::CustomerUser'),
                            Debug      => $Self->{Debug},
                        );
                        my @Params = $Object->Param( UserData => \%Param );
                        if (@Params) {
                            for my $ParamItem (@Params) {
                               
                                if (
                                    ref $ParamItem->{Data} eq 'HASH'
                                    || ref $Preference{Data} eq 'HASH'
                                    )
                                {
                                    my %BuildSelectionParams = (
                                        %Preference,
                                        %{$ParamItem},
                                    );
                                    $BuildSelectionParams{Class} = join( ' ', $BuildSelectionParams{Class} // '', 'Modernize' );

                                    $ParamItem->{Option} = $LayoutObject->BuildSelection(
                                        %BuildSelectionParams,
                                    );
                                }

                                $LayoutObject->Block(
                                    Name => 'AddCustomerOption',
                                    Data => {
                                        Group => $Group,
                                        %Param,
                                        %Data,
                                        %Preference,
                                        %{$ParamItem},
                                    },
                                );
                            }
                        }
                    }
                    else {
                        return $LayoutObject->FatalError();
                    }
                }
            }
        }else{
            $CustomerPortalLayoutObject->CreateNavBar(
                ActionActive => "CustomerPortalAddCustomerUser",
                %{$Self}
            );

	        my $ActionTitle = $ConfigObject->Get('CustomerPortal::Core::ActionTitle');

            $Param{Message} = $LayoutObject->{LanguageObject}->Translate("No permissions to view screen.");
            $Param{Comment} = $LayoutObject->{LanguageObject}->Translate("No permissions to view screen. Please contact the responsible team for more information.");

            $LayoutObject->Block(
                Name => 'Error',
                Data => \%Param,
            );

            # build output
            my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{CompanyTickets} );

            $Output .= $LayoutObject->Output(
                TemplateFile => "CustomerPortalError",
                Data         => \%Param,
            );

            $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

            return $Output;
        }

        my $ActionTitle = $ConfigObject->Get('CustomerPortal::Core::ActionTitle');

        # build output
        my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{CustomerPortalAddCustomerUser});

        $Output   .= $LayoutObject->Output(
            Data         => \%Param,
            TemplateFile => 'CustomerPortalAddCustomerUser',
        );
        $Output   .= $LayoutObject->CustomerFooter(Type => 'Small');

        return $Output;
    }
}

1;