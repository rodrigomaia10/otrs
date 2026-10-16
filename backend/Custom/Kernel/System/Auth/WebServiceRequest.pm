# --
# Kernel/System/Auth/WebServiceRequest.pm
# Copyright (C) 2019-2020 Service Up, http://serviceup.com.br/
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package Kernel::System::Auth::WebServiceRequest;

use strict;
use warnings;

use LWP::UserAgent;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Encode',
    'Kernel::System::Log',
);

use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # Debug 0=off 1=on
    $Self->{Debug} = 0;

    # get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    $Self->{Count} = $Param{Count} || '';

    return $Self;
}

sub GetOption {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{What} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need What!"
        );
        return;
    }

    # module options
    my %Option = (
        PreAuth => 0,
    );

    # return option
    return $Option{ $Param{What} };
}

sub Auth {
    my ( $Self, %Param ) = @_;

    # get group object
    my $ConfigObject           = $Kernel::OM->Get('Kernel::Config');
    my $GroupObject            = $Kernel::OM->Get('Kernel::System::Group');
    my $TicketInvokerObject    = $Kernel::OM->Get('Kernel::System::TicketInvoker');
    my $UserObject             = $Kernel::OM->Get('Kernel::System::User');

    my $ConfigAuth = $ConfigObject->Get('CustomAuthModule::Core::Auth');

    return if !$ConfigAuth;

    my $UserID = $UserObject->UserLookup(
        UserLogin => $Param{User},
        Silent    => 1
    );    

    my $Request = $TicketInvokerObject->WebServiceRequest(
        Webservice  => $ConfigAuth->{WebService},
        Invoker     => $ConfigAuth->{Invoker},
        Data => {
            Login    => $Param{User},
            Password => $Param{Pw}
        },
        UserID      => 1
    );

    my $User = '';

    return if !$Request->{Auth}; 

    if ( $Request->{Auth} == 200 ) {

        my $Groups = $Request->{Groups};

        if ( $UserID && ( IsArrayRefWithData($Groups) || $Groups ) ) {    

            $UserObject->UserUpdate(
                UserID        => $UserID,
                %{ $Request->{UserData} },
                UserLogin     => $Param{User},
                ValidID       => 1,
                ChangeUserID  => 1
            );  

            my %DataUser = $UserObject->GetUserData(
                UserID => $UserID,
            );
            
            $User = $DataUser{UserLogin};            
        }
        else {                  

            for my $Parameter ( qw( UserFirstname UserLastname UserEmail ) ) {
                if ( !$Request->{$Parameter} ) {
                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'error',
                        Message  => "Need $Parameter!",
                    );
                    return;
                }
            }   

            # if Groups exist, is a agent. Else, is a customer user.
            if ( $Groups ) {
                
                $UserID = $UserObject->UserAdd(
                    %{ $Request->{UserData} },
                    UserLogin     => $Param{User},
                    ValidID       => 1,
                    ChangeUserID  => 1,
                );

                my %DataUser = $UserObject->GetUserData(
                    UserID => $UserID,
                ); 

                $User = $DataUser{UserLogin};
            }            
        }       

        # get system groups and create lookup
        my %SystemGroups       = $GroupObject->GroupList( Valid => 1 );
        my %SystemGroupsByName = reverse %SystemGroups;

        # get system roles and create lookup
        my %SystemRoles       = $GroupObject->RoleList( Valid => 1 );
        my %SystemRolesByName = reverse %SystemRoles;

        # sync WebService group 2 otrs role permissions
        my $UserSyncRolesDefinition = $ConfigObject->Get(
            'AuthSyncModule::WebServiceRequest::UserSyncRolesDefinition' . $Self->{Count}
        );

        # variable to store role permissions from WebService
        my %RolePermissionsFromWebService;

        if ( ref $Groups eq 'ARRAY' ) {

            for my $Group (@{$Groups}) {

                if ($UserSyncRolesDefinition->{$Group}) {

                    # remember role permissions
                    my %SyncRoles = %{ $UserSyncRolesDefinition->{$Group} };

                    SYNCROLE:
                    for my $SyncRole ( sort keys %SyncRoles ) {

                        # only for valid roles
                        if ( !$SystemRolesByName{$SyncRole} ) {
                            $Kernel::OM->Get('Kernel::System::Log')->Log(
                                Priority => 'notice',
                                Message =>
                                    "Invalid role '$SyncRole' in "
                                    . "'AuthSyncModule::SSO::UserSyncRolesDefinition"
                                    . "$Self->{Count}'!",
                            );
                            next SYNCROLE;
                        }

                        # set/overwrite remembered permissions
                        $RolePermissionsFromWebService{ $SystemRolesByName{$SyncRole} } = $SyncRoles{$SyncRole};
                    }
                }
            }
        }
        else {

            if ($UserSyncRolesDefinition->{$Groups}) {

                # remember role permissions
                my %SyncRoles = %{ $UserSyncRolesDefinition->{$Groups} };

                SYNCROLE:
                for my $SyncRole ( sort keys %SyncRoles ) {

                    # only for valid roles
                    if ( !$SystemRolesByName{$SyncRole} ) {
                        $Kernel::OM->Get('Kernel::System::Log')->Log(
                            Priority => 'notice',
                            Message =>
                                "Invalid role '$SyncRole' in "
                                . "'AuthSyncModule::SSO::UserSyncRolesDefinition"
                                . "$Self->{Count}'!",
                        );
                        next SYNCROLE;
                    }

                    # set/overwrite remembered permissions
                    $RolePermissionsFromWebService{ $SystemRolesByName{$SyncRole} } = $SyncRoles{$SyncRole};
                }
            }
        } 

        # get current user roles
        my %UserRoles = $GroupObject->PermissionUserRoleGet(
            UserID => $UserID,
        );

        ROLEID:
        for my $RoleID ( sort keys %SystemRoles ) {

            # if old and new permission for role matches, do nothing
            if (
                ( $UserRoles{$RoleID} && $RolePermissionsFromWebService{$RoleID} )
                ||
                ( !$UserRoles{$RoleID} && !$RolePermissionsFromWebService{$RoleID} )
                )
            {
                next ROLEID;
            }

            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'notice',
                Message  => "User: '$Param{User}' sync SSO role $SystemRoles{$RoleID}!",
            );

            $GroupObject->PermissionRoleUserAdd(
                UID    => $UserID,
                RID    => $RoleID,
                Active => $RolePermissionsFromWebService{$RoleID} || 0,
                UserID => 1,
            );
        }
    }

    return $User;
}

1;
