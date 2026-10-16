#!/usr/bin/perl
# --
# bin/otrs.UpdateFileSystem.pl
# Copyright (C) 2019 Service Up, http://serviceup.com.br/
# --
# written/edited by:
# * dsilva@serviceup.com.br
# --

use strict;
use warnings;

use Getopt::Long();

use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin);
use lib dirname($RealBin) . '/Kernel/cpan-lib';
use lib dirname($RealBin) . '/Custom';

use Kernel::System::ObjectManager;
local $Kernel::OM = Kernel::System::ObjectManager->new();

# get object
my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

my ( $Year, $TypeObject );

Getopt::Long::GetOptions(
    'year=s' => \$Year,
    'type=s'   => \$TypeObject
);

sub PrintUsage {
    print <<EOF;

Update on DynamicFieldFileSystem, record values ​​in table dynamic_field_value.

Usage:
 otrs.UpdateFileSystem.pl [--year=<YEAR>] [--type=<TYPE>]

Options:
 [--year]     - year he fetched the files.
 [--type]     - dynamic field type (ticket or article).

EOF
    return;
}

my $Type = {
    'article' => 'Article',
    'ticket'  => 'Ticket'
};

if ( !$Year || !$TypeObject || !$Type->{$TypeObject} ) {
    PrintUsage();
    exit 0;
}

print "Start... \n";

my $Total = 0;
my $TotalField = 0;

my $OutputMonth = `ls var/dynamicfield/$Year/`;

my @Months =  split /\n/, $OutputMonth;

MONTH:
for my $Month ( @Months ) {
    
    my $OutputDay = `ls var/dynamicfield/$Year/$Month/`;

    my @Days =  split /\n/, $OutputDay;

    DAY:
    for my $Day ( @Days ) {

        my $CountObject = `ls var/dynamicfield/$Year/$Month/$Day/$Type->{$TypeObject}/ | wc -l`;

        $Total = $Total + $CountObject;

        my $OutputObject = `ls var/dynamicfield/$Year/$Month/$Day/$Type->{$TypeObject}/`;

        my @ObjectIDs =  split /\n/, $OutputObject;

        for my $ObjectID ( @ObjectIDs ) {

            my $OutputField = `ls var/dynamicfield/$Year/$Month/$Day/$Type->{$TypeObject}/$ObjectID/`;

            my @FieldIDs =  split /\n/, $OutputField;

            for my $FieldID ( @FieldIDs ) {

                my $CountFiles = `ls var/dynamicfield/$Year/$Month/$Day/$Type->{$TypeObject}/$ObjectID/$FieldID/ | wc -l`;
                
                $CountFiles = $CountFiles + 0;

                if ( $CountFiles > 0 ) {                   

                    return if !$DBObject->Prepare(
                        SQL   => "SELECT id FROM dynamic_field WHERE id = ?",
                        Bind => [ \$FieldID ]
                    );

                    my $FieldExists = 0;
                    while (my @Row = $DBObject->FetchrowArray()) {
                        $FieldExists = $Row[0];
                    }

                    if ( $FieldExists ) {

                        $TotalField++;

                        return if !$DBObject->Prepare(
                            SQL   => "SELECT id FROM dynamic_field_value WHERE field_id = ? AND object_id = ?",
                            Bind => [ \$FieldID, \$ObjectID ]
                        );

                        my $Return = 0;
                        while (my @Row = $DBObject->FetchrowArray()) {
                            $Return = $Row[0];
                        }

                        if ( !$Return ){
                            return if !$DBObject->Do(
                                SQL => "INSERT INTO dynamic_field_value ( field_id, object_id, value_text )
                                        VALUES( ?, ?, 1 )",
                                Bind => [ \$FieldID, \$ObjectID ],
                            );
                            print "Filed $FieldID added to the $Type->{$TypeObject} $ObjectID ... \n";
                        }                    
                    }
                }                    
            }
        }
    }
}

print "TOTAL $Type->{$TypeObject}: " . $Total . " \n";
print "TOTAL FIELDS: " . $TotalField . " \n";

print "End!\n";