#!/usr/bin/perl
# --
# bin/otrs.SetSLAByDFValueCSV.pl
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

use strict;
use warnings;

use utf8;

use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin);
use lib dirname($RealBin) . '/Kernel/cpan-lib';
use lib dirname($RealBin) . '/Custom';

use Data::Dumper;
use Getopt::Long();

use Kernel::System::VariableCheck qw(:all);

use Kernel::System::ObjectManager;

local $Kernel::OM = Kernel::System::ObjectManager->new(
    'Kernel::System::Log' => {
        LogPrefix => 'OTRS-otrs.SetSLAByDFValueCSV.pl',
    },
);

my ( $Help, $Path );

sub PrintUsage {
    print <<EOF;

Update the config CustomModuleGenericAgent::SetSLAByDFValueConfig::DFRelations.

Usage:
    otrs.SetSLAByDFValueCSV.pl [--path=<PATH>] 

Options:
    [--path=<PATH>] - inform the path of the csv file in UTF-8 format that will be imported. ( requerid )
    [--help]        - Display help for this command.

EOF
    return;
}

sub Run {

    Getopt::Long::GetOptions(
        'help'   => \$Help,
        'path=s' => \$Path
    );

    if ( defined $Help || !( defined $Path ) ) {

        PrintUsage();

        exit 0;
    }   

    Import(
        Path => $Path
    );
}

Run();

sub Import {
    my ( %Param ) = @_;

    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $MainObject   = $Kernel::OM->Get('Kernel::System::Main');
    my $CSVObject    = $Kernel::OM->Get('Kernel::System::CSV');
    my $DBObject     = $Kernel::OM->Get('Kernel::System::DB');

    print "---------- INIT ----------". " \n";

    my $ContentSCALARRef = $MainObject->FileRead(
        Location => $Param{Path},
        Mode     => 'binmode'
    );

    my $RefArray = $CSVObject->CSV2Array(
        String    => $$ContentSCALARRef,
        Separator => ';',
    );

    my $Counter = 0;

    my %NameColumns = (
        0 => 'Estado',
        1 => 'Cidade',
        2 => 'SLA'
    );

    my $First = 1;

    my %Rows; 

    ROW:
    for my $Row ( @{ $RefArray } ) {

        next ROW if( scalar @{ $Row } < 3 );

        if($First){
            $First = 0;
            next ROW;
        }

        if ($Row->[0] && $Row->[1] && $Row->[2]) {

            $Rows{$Row->[0]}{$Row->[1]} = $Row->[2]
        }
    }

    my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

    my %Setting = $SysConfigObject->SettingGet(
         Name => 'CustomModuleGenericAgent::SetSLAByDFValueConfig::DFRelations',  
    );

    my $ExclusiveLockGUID = $SysConfigObject->SettingLock(
        Name      => $Setting{Name},                                           
        LockAll   => 1,                     
        UserID    => 1,                     
    );

    my %Result = $SysConfigObject->SettingUpdate(
        Name                   => $Setting{Name},           
        IsValid                => 1,                         
        EffectiveValue         => \%Rows,                            
        ExclusiveLockGUID      => $ExclusiveLockGUID,        
        UserID                 => 1,                       
    );

    my %ResultD = $SysConfigObject->ConfigurationDeploy(
        Force         => 1,
        UserID        => 1,
        NotDirty      => 1,
        AllSettings   => 1,
        Comments      => "Config change by script otrs.SetSLAByDFValueCSV.pl",
        DirtySettings => [
            $Setting{Name},
        ],
    );

    my $Success = $SysConfigObject->ConfigurationDeploySync();  


    if ( $Success ){
        print "------ Config Change ----------". " \n";

    }
    else{
        print "------ Config NOT Change ----------". " \n";
    }

    print "------ FINISH ----------". " \n";
}