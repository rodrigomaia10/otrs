# --
# Kernel/Autoload/CustomSumBuild.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * ykanegae@serviceup.com.br
# --

use Kernel::System::Stats;

package Kernel::System::Stats;

use strict;
use warnings;

sub SumBuild {
    my ( $Self, %Param ) = @_;

    my @Data = @{ $Param{Array} };

    # add sum y
    if ( $Param{SumCol} ) {

        push @{ $Data[1] }, Translatable('Sum');

        for my $Index1 ( 2 .. $#Data ) {

            my $Sum = 0;
            INDEX2:
            for my $Index2 ( 1 .. $#{ $Data[$Index1] } ) {

                next INDEX2 if !$Data[$Index1][$Index2];

                # extract the value
                my $Value = $Data[$Index1][$Index2];

                # clean the string
                $Value =~ s{ \A \s+ }{}xms;
                $Value =~ s{ \s+ \z }{}xms;
                $Value =~ s{ , }{.}xms;

                # add value to summary
                if ( $Value =~ m{^-?\d+(\.\d+)?$} ) {
                    $Sum += $Value;
                }
            }

            push @{ $Data[$Index1] }, $Sum;
        }
    }

    # add sum x
    if ( $Param{SumRow} ) {

        my @SumRow = ();
        $SumRow[0] = 'Sum';

        # START BLOCK SUP

        # The aim is to find out the index of which columns are eligible to be in the sum row.
        my @EnabledColumns      = @{$Kernel::OM->Get('Kernel::Config')->Get('DynamicFieldTable::Core')->{SumColumns}};
        my @TicketColumnIndex;

        for my $Index ( 1 .. $#{ $Data[1] }) {

            my $found = grep { $_ eq $Data[1][$Index] } @EnabledColumns;
            if( $found ) {

                push @TicketColumnIndex, $Index;
            }
        }

        for my $Index1 ( 2 .. $#Data ) {

            INDEX2:
            for my $Index2 ( 1 .. $#{ $Data[$Index1] } ) {

                # Skip over column 
                my $found = grep { $_ eq $Index2 } @TicketColumnIndex;
                next INDEX2 if ((@EnabledColumns != 0 && !$found) || 0);

                # make sure we have a value to add
                if ( !defined $Data[$Index1][$Index2] ) {
                    $Data[$Index1][$Index2] = 0;
                }

                # extract the value
                my $Value = $Data[$Index1][$Index2];

                # clean the string
                $Value =~ s{ \A \s+ }{}xms;
                $Value =~ s{ \s+ \z }{}xms;
                $Value =~ s{ , }{.}xms;

                # add value to summary
                if ( $Value =~ m{^-?\d+(\.\d+)?$} ) {
                    $SumRow[$Index2] += $Value;
                }
            }
        }

        # END BLOCK SUP
        push @Data, \@SumRow;
    }
    return @Data;
}
