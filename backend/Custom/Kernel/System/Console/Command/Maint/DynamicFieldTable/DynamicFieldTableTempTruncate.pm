# --
# Custom/Kernel/System/Console/Command/Maint/DynamicFieldTable/DynamicFieldTableTempTruncate.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package Kernel::System::Console::Command::Maint::DynamicFieldTable::DynamicFieldTableTempTruncate;

use strict;
use warnings;

use base qw(Kernel::System::Console::BaseCommand);
use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (    
    'Kernel::System::DynamicFieldTable',    
);

sub Configure {
    my ( $Self, %Param ) = @_;

    $Self->Description('Truncate the df_table_temp.');

    return;
}

sub Run {
    my ( $Self, %Param ) = @_;

    $Self->Print("<yellow>Truncate Table: df_table_temp...</yellow>\n");
    
    # remove data from table
    my $Sucess = $Kernel::OM->Get('Kernel::System::DynamicFieldTable')->_TruncateTempTable();

    if($Sucess){
        $Self->Print("<green>Done.</green>\n");
    }
    else{
        $Self->Print("<green>Error. Check the log file.</green>\n");
    }

    return $Self->ExitCodeOk();
}

1;