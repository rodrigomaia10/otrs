# --
# Kernel/System/CustomerAuth/WebServiceRequest.pm
# Copyright (C) 2019-2020 Service Up, http://serviceup.com.br/
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package Kernel::System::CustomerAuth::WebServiceRequest;

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
    my $ConfigObject              = $Kernel::OM->Get('Kernel::Config');
    my $GroupObject               = $Kernel::OM->Get('Kernel::System::Group');
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $CustomerUserObject        = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $TicketInvokerObject       = $Kernel::OM->Get('Kernel::System::TicketInvoker');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my $ConfigAuth = $ConfigObject->Get('CustomAuthModule::Core::Auth');

    return if !$ConfigAuth;

    my %DataUser = $CustomerUserObject->CustomerUserDataGet(
        User => $Param{User},
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
	
	if ( $DataUser{UserLogin} ) {           

            $CustomerUserObject->CustomerUserUpdate(
                Source         => $Request->{Source}, 
                ID             => $Param{User},
                %{ $Request->{CustomerUserData} },
                ValidID        => 1,
                UserID         => 1,
            ); 

            $User = $DataUser{UserLogin};
        }
        else {                  

            for my $Parameter ( qw( UserFirstname UserLastname UserEmail UserCustomerID ) ) {
                if ( !$Request->{CustomerUserData}->{$Parameter} ) {
                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'error',
                        Message  => "Need $Parameter!",
                    );
                    return;
                }
            }      
                            
            my $UserLogin = $CustomerUserObject->CustomerUserAdd(
                Source         => $Request->{Source},
                %{ $Request->{CustomerUserData} },
                ValidID        => 1,
                UserID         => 1,
            );

            $User = $UserLogin;           
        }        

        FIELD:
        for my $Field ( keys %{ $Request->{CustomerUserData} } ) {

            if ( $Field =~ m/DynamicField_/ ) {

                my $Value = $Request->{CustomerUserData}->{$Field};

                $Field =~ s/DynamicField_(.*?)/$1/g;  

                my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
                    Name => $Field,
                );

                $DynamicFieldBackendObject->ValueSet(
                    DynamicFieldConfig => $DynamicFieldConfig,
                    ObjectName         => $Param{User},
                    Value              => $Value,
                    UserID             => 1
                );            

            }
            else {
                next FIELD;
            }
        }
    }

    return $User;
}

1;
