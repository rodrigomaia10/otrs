# --
# var/packagesetup/InBoxCore.pm
# Copyright (C) 2019 ServiceUp, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package var::packagesetup::InBoxCore;

use strict;
use warnings;

use utf8;

use Kernel::System::VariableCheck qw(:all);
use List::Util qw(min);

our @ObjectDependencies = (
    'Kernel::System::SysConfig',
	'Kernel::System::Log',
	'Kernel::Config',
);

=head1 NAME

InBoxCore.pm - code to excecute during package installation

=head1 SYNOPSIS

All functions of package InBoxCore

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

    my $Result = $InBoxCore->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

    $Self->_SendEmailToVendor(
        ModuleName => $Param{ModuleName}
    );

    $Self->_ConfigRepository();

    return 1;
}

=item CodeUpgrade()

run the code code upgrade on version 6.13.7

    my $Result = $InBoxCore->CodeUpgrade();

=cut

sub CodeUpgrade {
    my ( $Self, %Param ) = @_;

    $Self->_ConfigRepository();

    return 1;
}

sub _SendEmailToVendor() {
    my ( $Self, %Param ) = @_;

    my $EmailObject  = $Kernel::OM->Get('Kernel::System::Email');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    
    my $CommunicationLogObject = $Kernel::OM->Create(
        'Kernel::System::CommunicationLog',
        ObjectParams => {
            Transport => 'Email',
            Direction => 'Outgoing',
        }
    );

    $CommunicationLogObject->ObjectLogStart(
        ObjectLogType => 'Message',
    );

    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            TimeZone => 'America/Sao_Paulo',
        }
    );

    my $DateTimeString = $DateTimeObject->Format( Format => '%d/%m/%Y %H:%M' );
    my $Host = $ConfigObject->Get('FQDN');

    my $Body = <<"EOF";
<table style="font-family:Arial, Helvetica, sans-serif; color:#666;font-size:12px;text-shadow: 1px 1px 0px #fff;background:#eaebec;margin:20px;border:#ccc 1px solid;	-moz-border-radius:3px;-webkit-border-radius:3px;border-radius:3px;-moz-box-shadow: 0 1px 2px #d1d1d1;-webkit-box-shadow: 0 1px 2px #d1d1d1;box-shadow: 0 1px 2px #d1d1d1;">
        <thead>
            <tr style="text-align: center; padding-left:20px;">
                <th style="padding:21px 25px 22px 25px;border-top:1px solid #fafafa;border-bottom:1px solid #e0e0e0;background: #ededed;background: -webkit-gradient(linear, left top, left bottom, from(#ededed), to(#ebebeb));background: -moz-linear-gradient(top,  #ededed,  #ebebeb);">
                    Módulo
                </th>
                <th style="padding:21px 25px 22px 25px;border-top:1px solid #fafafa;border-bottom:1px solid #e0e0e0;background: #ededed;background: -webkit-gradient(linear, left top, left bottom, from(#ededed), to(#ebebeb));background: -moz-linear-gradient(top,  #ededed,  #ebebeb);">
                    Host
                </th>
                <th style="padding:21px 25px 22px 25px;border-top:1px solid #fafafa;border-bottom:1px solid #e0e0e0;background: #ededed;background: -webkit-gradient(linear, left top, left bottom, from(#ededed), to(#ebebeb));background: -moz-linear-gradient(top,  #ededed,  #ebebeb);">
                    Data
                </th>
            </tr>
        </thead>
        <tbody>
            <tr style="text-align: center; padding-left:20px;">
                <td style="padding:18px;border-top: 1px solid #ffffff;border-bottom:1px solid #e0e0e0;border-left: 1px solid #e0e0e0;background: #fafafa;background: -webkit-gradient(linear, left top, left bottom, from(#fbfbfb), to(#fafafa));background: -moz-linear-gradient(top,  #fbfbfb,  #fafafa);">
                    $Param{ModuleName}
                </td>
                <td style="padding:18px;border-top: 1px solid #ffffff;border-bottom:1px solid #e0e0e0;border-left: 1px solid #e0e0e0;background: #fafafa;background: -webkit-gradient(linear, left top, left bottom, from(#fbfbfb), to(#fafafa));background: -moz-linear-gradient(top,  #fbfbfb,  #fafafa);">
                    $Host
                </td>
                <td style="padding:18px;border-top: 1px solid #ffffff;border-bottom:1px solid #e0e0e0;border-left: 1px solid #e0e0e0;background: #fafafa;background: -webkit-gradient(linear, left top, left bottom, from(#fbfbfb), to(#fafafa));background: -moz-linear-gradient(top,  #fbfbfb,  #fafafa);">
                    $DateTimeString
                </td>
            </tr>
        </tbody>
    </table>
EOF

    my $Sent = $EmailObject->Send(
        From          => $ConfigObject->Get('AdminEmail'),
        To            => 'suporte@serviceup.com.br',
        Subject       => '[InBox Core] - Instalação de novo modulo',
        Charset       => 'utf-8',
        MimeType      => 'text/html',
        Body          => $Body,
    );

    my $Result = $EmailObject->SendExecute(
        From                   => $ConfigObject->Get('AdminEmail'),
        To                     => ['suporte@serviceup.com.br'],
        Header                 => $Sent->{Data}->{Header},
        Body                   => $Sent->{Data}->{Body},
        CommunicationLogObject => $CommunicationLogObject
    );

    return $Result;

}

sub _ConfigRepository(){
    my ( $Self, %Param ) = @_;

    # get object
    my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

    # add js and css in the sysconfig of modules

    # my %Setting = $SysConfigObject->SettingGet(
    #     Name => "Loader::Module::AdminPackageManager###001-Framework",
    # );

    # my @CSS = @{ $Setting{EffectiveValue}->{CSS} };
    # my @JavaScript = @{ $Setting{EffectiveValue}->{JavaScript} };

    # my $IsCSS = 0;
    # my $IsJS = 0;

    # for my $Item (@CSS){
    #     if($Item eq 'Core.Agent.Admin.InBoxCore.css'){
    #         $IsCSS = 1;
    #     }
    # }

    # for my $Item (@JavaScript){
    #     if($Item eq 'Core.Agent.Admin.InBoxCore.js'){
    #         $IsJS = 1;
    #     }
    # }

    # if(!$IsCSS){
    #     push @{ $Setting{EffectiveValue}->{CSS} }, 'Core.Agent.Admin.InBoxCore.css';
    # }

    # if(!$IsJS){
    #     push @{ $Setting{EffectiveValue}->{JavaScript} }, 'Core.Agent.Admin.InBoxCore.js';
    # }

    # # Deploy the new settings.
    # my $SettingsDeployed = $SysConfigObject->SettingsSet(
    #     UserID   => 1,
    #     Comments => 'Add config InBoxCore',
    #     Settings => [                                     
	# 		{
	# 			Name                   => 'Loader::Module::AdminPackageManager###001-Framework',
	# 			EffectiveValue         => $Setting{EffectiveValue},
	# 			IsValid                => 1,              
	# 			UserModificationActive => 0,              
	# 		},
	# 	],
    # );

    # if ( !$SettingsDeployed ) {
    #     $Kernel::OM->Get('Kernel::System::Log')->Log(
    #         Message  => "Error while deploying the migrated permissions!",
    #         Priority => 'error',
    #     );
    # }

    # add repositories

    my %SettingRepositories = $SysConfigObject->SettingGet(
        Name => "Package::RepositoryList",
    );

    my $IsFree = 0;
    my $IsPremium = 0;

    for my $Item (values %{$SettingRepositories{EffectiveValue}} ){
        if($Item eq 'InBox ServiceUp Free'){
            $IsFree = 1;
        }
        elsif($Item eq 'InBox ServiceUp Premium'){
            $IsPremium = 1;
        }
    }

    if(!$IsFree){
        $SettingRepositories{EffectiveValue}->{'https://suporte.serviceup.com.br/serviceup-free-repository'} = 'InBox ServiceUp Free';
    }

    if(!$IsPremium){
        $SettingRepositories{EffectiveValue}->{'Empty'} = 'InBox ServiceUp Premium';
    }

    # Deploy the new settings.
    my $SettingsDeployed = $SysConfigObject->SettingsSet(
        UserID   => 1,
        Comments => 'Add config repositories',
        Settings => [                                     
			{
				Name                   => 'Package::RepositoryList',
				EffectiveValue         => $SettingRepositories{EffectiveValue},
				IsValid                => 1,              
				UserModificationActive => 0,              
			},
		],
    );

    if ( !$SettingsDeployed ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Message  => "Error while deploying the migrated permissions!",
            Priority => 'error',
        );
    }
}

1;