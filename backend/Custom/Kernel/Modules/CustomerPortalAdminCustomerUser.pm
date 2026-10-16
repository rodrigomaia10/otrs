# --
# Kernel/Modules/CustomerPortalAdminCustomerUser.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package Kernel::Modules::CustomerPortalAdminCustomerUser;

use strict;
use warnings;

use utf8;

use Digest::MD5 qw(md5_hex);
use Encode qw(decode encode);

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
    my $CheckItemObject      = $Kernel::OM->Get('Kernel::System::CheckItem');
    my $MainObject           = $Kernel::OM->Get('Kernel::System::Main');

    my $Message  = $ParamObject->GetParam( Param => 'Message' )  || '';

    my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');

    $CustomerPortalLayoutObject->CreateNavBar(
        ActionActive => "",
        %{$Self}
    );

    my $Source = 'CustomerUser';
    my $Search = '*';
    my $Nav    =  '';

    my $ActionTitle = $ConfigObject->Get('CustomerPortal::Core::ActionTitle');

    # Get list of valid IDs.
    my @ValidIDList = $Kernel::OM->Get('Kernel::System::Valid')->ValidIDsGet();

    # To show item to Add CustomerUser
    my $LoginsToAddedCustomerUser = $ConfigObject->Get('CustomerPortal::Core::LoginsToAddedCustomerUser');

    my %HashOfUserConfig = map {$_ => $Self->{UserLogin}} @{$LoginsToAddedCustomerUser};

    if ( defined $HashOfUserConfig{ $Self->{UserLogin} } ) {
        if ( $Self->{Subaction} eq 'Add' ) {
            my %GetParam;
            $GetParam{UserLogin}  = $ParamObject->GetParam( Param => 'UserLogin' )  || '';
            $GetParam{CustomerID} = $ParamObject->GetParam( Param => 'CustomerID' ) || '';
            
            my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{CustomerPortalAdminCustomerUser});

            $Output .= $Self->_Edit(
                Nav    => $Nav,
                Action => 'Add',
                Source => $Source,
                Search => $Search,
                %GetParam,
            );

            $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

            return $Output;
        }
        elsif ( $Self->{Subaction} eq 'AddAction' ) {

            # challenge token check for write action
            $LayoutObject->ChallengeTokenCheck();

            my $Note = '';
            my ( %GetParam, %Errors );

            # Get dynamic field backend object.
            my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

            ENTRY:
            for my $Entry ( @{ $ConfigObject->Get($Source)->{Map} } ) {

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

            $GetParam{UserCustomerID} = $Self->{UserCustomerID};

            # check email address
            if (
                $GetParam{UserEmail}
                && !$CheckItemObject->CheckEmail( Address => $GetParam{UserEmail} )
                && grep { $_ eq $GetParam{ValidID} } @ValidIDList
                )
            {
                $Errors{UserEmailInvalid} = 'ServerError';
                $Errors{ErrorType}        = $CheckItemObject->CheckErrorType() . 'ServerErrorMsg';
            }

            # Check CustomerID, if CustomerCompanySupport is enabled.
            if ( $ConfigObject->Get($Source)->{CustomerCompanySupport} && $GetParam{UserCustomerID} ) {

                my %Company = $Kernel::OM->Get('Kernel::System::CustomerCompany')->CustomerCompanyGet(
                    CustomerID => $GetParam{UserCustomerID},
                );

                if ( !%Company ) {
                    $Errors{UserCustomerIDInvalid} = 'ServerError';
                }
            }

            # if no errors occurred
            if ( !%Errors ) {

                # add user
                my $User = $CustomerUserObject->CustomerUserAdd(
                    %GetParam,
                    UserID => '1',
                    Source => $Source
                );

                if ($User) {

                    $CustomerUserObject->SetPreferences(
                        Key    => 'CustomerUserCreatedBy',
                        Value  => $Self->{UserID},
                        UserID => $GetParam{UserLogin},
                    );

                    my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');
                    my $DateTimeString = $DateTimeObject->Format( Format => '%Y-%m-%d %H:%M:%S' );

                    $CustomerUserObject->SetPreferences(
                        Key    => 'CustomerUserCreatedTime',
                        Value  => $DateTimeString,
                        UserID => $GetParam{UserLogin},
                    );
                
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
                            UserID             => $Self->{UserID},
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

                        $Self->_Overview(
                            Search => $Search,
                        );
                        
                        my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{CustomerPortalAdminCustomerUser});

                        $Output .= $Note;
                        
                        my $UserQuote     = $LayoutObject->Ascii2Html( Text => $User );
                    
                        $Output
                        .= $LayoutObject->Notify(
                        Data => $LayoutObject->{LanguageObject}->Translate(
                            'Customer %s added',
                            $UserQuote,
                            )
                            . "!",
                        );
                        
                        $Output .= $LayoutObject->Output(
                            TemplateFile => 'CustomerPortalAdminCustomerUser',
                            Data         => \%Param,
                        );

                        $Output .= $LayoutObject->Footer( Type => 'Small' );
                        

                        return $Output;
                    }
                }
                else {
                    $Note .= $LayoutObject->Notify( Priority => 'Error' );
                }
            }

            # something has gone wrong
            my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{CustomerPortalAdminCustomerUser});
            $Output .= $Note;
            $Output .= $Self->_Edit(
                Nav    => $Nav,
                Action => 'Add',
                Source => $Source,
                Search => $Search,
                Errors => \%Errors,
                %GetParam,
            );

            $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

            return $Output;
        }
        elsif( $Self->{Subaction} eq 'Change' ){
            my $User         = $ParamObject->GetParam( Param => 'ID' )           || '';
            my $Notification = $ParamObject->GetParam( Param => 'Notification' ) || '';

            # get user data
            my %UserData = $CustomerUserObject->CustomerUserDataGet( User => $User );

            my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{CustomerPortalAdminCustomerUser});

            $Output .= $LayoutObject->Notify( Info => Translatable('Customer updated!') )
                if ( $Notification && $Notification eq 'Update' );
            $Output .= $Self->_Edit(
                Nav    => $Nav,
                Action => 'Change',
                Source => $Source,
                Search => $Search,
                ID     => $User,
                %UserData,
            );

            if ( $Nav eq 'None' ) {
                $Output .= $LayoutObject->Footer( Type => 'Small' );
            }
            else {
                $Output .= $LayoutObject->Footer();
            }

            return $Output;
        }
        elsif ( $Self->{Subaction} eq 'ChangeAction' ) {
            # challenge token check for write action
            $LayoutObject->ChallengeTokenCheck();

            my $Note = '';
            my ( %GetParam, %Errors );

            # Get dynamic field backend object.
            my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

            ENTRY:
            for my $Entry ( @{ $ConfigObject->Get($Source)->{Map} } ) {

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
            $GetParam{ID} = $ParamObject->GetParam( Param => 'ID' ) || '';

            # check email address
            if (
                $GetParam{UserEmail}
                && !$CheckItemObject->CheckEmail( Address => $GetParam{UserEmail} )
                && grep { $_ eq $GetParam{ValidID} } @ValidIDList
                )
            {
                $Errors{UserEmailInvalid} = 'ServerError';
                $Errors{ErrorType}        = $CheckItemObject->CheckErrorType() . 'ServerErrorMsg';
            }


            # Get the current user data for some checks.
            my %CurrentUserData = $CustomerUserObject->CustomerUserDataGet(
                User => $GetParam{ID},
            );


            $GetParam{UserCustomerID} = $Self->{UserCustomerID};

            # if no errors occurred
            if ( !%Errors ) {
            
                my $UpdateSuccess = $CustomerUserObject->CustomerUserUpdate(
                    %GetParam,
                    UserID => '1',
                );

                if ( $UpdateSuccess ) {
                    # Update Preference to save history           
                    $CustomerUserObject->SetPreferences(
                        Key    => 'CustomerUserChangeBy',
                        Value  => $Self->{UserID},
                        UserID => $GetParam{UserLogin},
                    );

                    my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');
                    my $DateTimeString = $DateTimeObject->Format( Format => '%Y-%m-%d %H:%M:%S' );

                    $CustomerUserObject->SetPreferences(
                        Key    => 'CustomerUserChangeTime',
                        Value  => $DateTimeString,
                        UserID => $GetParam{UserLogin},
                    );

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
                            ObjectName         => $GetParam{UserLogin},
                            Value              => $GetParam{ $Entry->[0] },
                            UserID             => $Self->{UserID},
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
                            User => $GetParam{UserLogin}
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
                        my @Params = $Object->Param( UserData => \%UserData );
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

                    # clear customer user cache
                    $CustomerUserObject->CustomerUserCacheClear(
                        UserLogin => $GetParam{UserLogin},
                    );

                    # get user data and show screen again
                    if ( !$Note ) {                  

                        $Self->_Overview(
                            Search => $Search,
                        );
                        
                        my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{CustomerPortalAdminCustomerUser});

                        $Output .= $Note;
                                            
                        $Output
                        .= $LayoutObject->Notify(
                        Data => $LayoutObject->{LanguageObject}->Translate( 'Customer user update!' ) );
                        
                        $Output .= $LayoutObject->Output(
                            TemplateFile => 'CustomerPortalAdminCustomerUser',
                            Data         => \%Param,
                        );

                        $Output .= $LayoutObject->Footer( Type => 'Small' );                        

                        return $Output;
                        
                    }
                }
                else {
                    $Note .= $LayoutObject->Notify( Priority => 'Error' );
                }
            }
     
            # something has gone wrong
            my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{CustomerPortalAdminCustomerUser});
            $Output .= $Note;
            $Output .= $Self->_Edit(
                Nav    => $Nav,
                Action => 'Change',
                Source => $Source,
                Search => $Search,
                Errors => \%Errors,
                %GetParam,
            );

            $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

            return $Output;
        }
        else{
            # ------------------------------------------------------------ #
            # Overview
            # ------------------------------------------------------------ #

            $Self->_Overview();

            my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{CustomerPortalAdminCustomerUser});

            $Output .= $LayoutObject->Output(
                TemplateFile => 'CustomerPortalAdminCustomerUser',
                Data         => \%Param,
            );

            $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

            return $Output;
        }
    }
    else{
        $CustomerPortalLayoutObject->CreateNavBar(
            ActionActive => "CustomerPortalAdminCustomerUser",
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
        my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{CustomerPortalAdminCustomerUser} );

        $Output .= $LayoutObject->Output(
            TemplateFile => "CustomerPortalError",
            Data         => \%Param,
        );

        $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

        return $Output;
    }
}

sub _Overview {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    $LayoutObject->Block(
        Name => 'Overview',
        Data => \%Param,
    );

    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');

    # get writable data sources
    my %CustomerSource = $CustomerUserObject->CustomerSourceList(
        ReadOnly => 0,
    );

    # get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # when there is no data to show, a message is displayed on the table with this colspan
    my $ColSpan = 6;

    # same Limit as $Self->{CustomerUserMap}->{CustomerUserSearchListLimit}
    # smallest Limit from all sources
    my $Limit = 400;
    SOURCE:
    for my $Count ( '', 1 .. 10 ) {
        next SOURCE if !$ConfigObject->Get("CustomerUser$Count");
        my $CustomerUserMap = $ConfigObject->Get("CustomerUser$Count");
        next SOURCE if !$CustomerUserMap->{CustomerUserSearchListLimit};
        if ( $CustomerUserMap->{CustomerUserSearchListLimit} < $Limit ) {
            $Limit = $CustomerUserMap->{CustomerUserSearchListLimit};
        }
    }

    my %List = $CustomerUserObject->CustomerSearch(
        # Search => $Param{Search},
        CustomerID => $Self->{UserCustomerID},
        Valid  => 0,
    );

    $LayoutObject->Block(
        Name => 'OverviewResult',
        Data => \%Param,
    );

    # if there are results to show
    if (%List) {

        # get valid list
        my %ValidList = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();
        for my $ListKey ( sort { lc($a) cmp lc($b) } keys %List ) {

            my %UserData = $CustomerUserObject->CustomerUserDataGet( User => $ListKey );
            $UserData{UserFullname} = $CustomerUserObject->CustomerName(
                UserLogin => $UserData{UserLogin},
            );

            $LayoutObject->Block(
                Name => 'OverviewResultRow',
                Data => {
                    Valid       => $ValidList{ $UserData{ValidID} || '' } || '-',
                    Search      => $Param{Search},
                    CustomerKey => $ListKey,
                    %UserData,
                },
            );
            # if ( $Param{Nav} eq 'None' ) {
            #     $LayoutObject->Block(
            #         Name => 'OverviewResultRowLinkNone',
            #         Data => {
            #             Search      => $Param{Search},
            #             CustomerKey => $ListKey,
            #             %UserData,
            #         },
            #     );
            # }
            # else {
                $LayoutObject->Block(
                    Name => 'OverviewResultRowLink',
                    Data => {
                        Search      => $Param{Search},
                        Nav         => $Param{Nav},
                        CustomerKey => $ListKey,
                        %UserData,
                    },
                );
            # }

        }
    }
    else {
        $LayoutObject->Block(
            Name => 'NoDataFoundMsg',
            Data => {
                ColSpan => $ColSpan,
            },
        );
    }   

    return;
}

sub _Edit {
    my ( $Self, %Param ) = @_;

    # Get layout object.
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $Output = '';

    $LayoutObject->Block(
        Name => 'Overview',
        Data => \%Param,
    );

    $LayoutObject->Block(
        Name => 'OverviewUpdate',
        Data => \%Param,
    );

    if ( $Param{Action} eq 'Change' ) {

        # shows edit header
        $LayoutObject->Block( Name => 'HeaderEdit' );

    }
    # shows add header
    else {
        $LayoutObject->Block( Name => 'HeaderAdd' );
    }

    my $UpdateOnlyPreferences;

    # Get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # update user
    if ( $ConfigObject->Get( $Param{Source} )->{ReadOnly} || $ConfigObject->Get( $Param{Source} )->{Module} =~ /LDAP/i )
    {
        $UpdateOnlyPreferences = 1;
    }

    # Get dynamic field backend object.
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $ParamObject               = $Kernel::OM->Get('Kernel::System::Web::Request');

    ENTRY:
    for my $Entry ( @{ $ConfigObject->Get( $Param{Source} )->{Map} } ) {

        next ENTRY if !$Entry->[0];

        next ENTRY if $Entry->[0] eq 'UserComment';
        next ENTRY if $Entry->[0] eq 'UserCountry';
        next ENTRY if $Entry->[0] eq 'UserZip';
        next ENTRY if $Entry->[0] eq 'UserStreet';
        next ENTRY if $Entry->[0] eq 'UserFax';
        next ENTRY if $Entry->[0] eq 'UserCity';
        next ENTRY if $Entry->[0] eq 'UserTitle';
        next ENTRY if $Entry->[0]  =~ /^UserCustomerID$/i ;

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
                Name => 'Item',
                Data => {},
            );

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
        if ( $ConfigObject->Get( $Param{Source} )->{AutoLoginCreation} && $Entry->[0] eq 'UserLogin' ) {
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
        if ( $Entry->[0] =~ /^ValidID/i ) {

            # build ValidID string
            $Block = 'AddCustomerOption';
            $Param{Option} = $LayoutObject->BuildSelection(
                Data       => { $Kernel::OM->Get('Kernel::System::Valid')->ValidList(), },
                Name       => $Entry->[0],
                SelectedID => defined( $Param{ $Entry->[0] } ) ? $Param{ $Entry->[0] } : 1,
                Class      => "Validate_Required Modernize " . $Param{Errors}->{ $Entry->[0] . 'Invalid' },
                Disabled   => $UpdateOnlyPreferences ? 1 : 0,
            );

            $LayoutObject->Block(
                Name => 'AddCustomerOption',
                Data => {
                    Name  => 'Valid',
                    Label => 'Valid',
                    %Param,
                },
            );
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

    my $PreferencesUsed = $ConfigObject->Get( $Param{Source} )->{AdminSetPreferences};
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

    return $LayoutObject->Output(
        TemplateFile => 'CustomerPortalAdminCustomerUser',
        Data         => \%Param,
    );
}

1;