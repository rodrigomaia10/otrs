# Kernel/Output/HTML/FilterElementPost/CustomerPortalCustomCSS.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * ccresencio@serviceup.com.br
# --
package Kernel::Output::HTML::FilterElementPost::CustomerPortalCustomCSS;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::XML',
    'Kernel::System::Cache'
);

sub new {
    my ($Type, %Param) = @_;

    my $Self = {};
    bless($Self, $Type);

    return $Self;
}

sub Run {
    my ($Self, %Param) = @_;

    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    my $CSS = $CacheObject->Get(
        Type => 'CustomPortalCSS',
        Key  => '1'
    );

    if (!$CSS) {
        my $XMLObject = $Kernel::OM->Get('Kernel::System::XML');

        # Get CSS from DB. 
        my @XMLHash = $XMLObject->XMLHashGet(
            Type => 'CustomPortalCSS',
            Key  => '1'
        );
        $CSS = $XMLHash[0]{'Content'};

        # Only cache if there is something to cache.
        if ($CSS) {
            $CacheObject->Set(
            Type  => 'CustomPortalCSS',
            Key   => '1',
            TTL   => 60 * 60 * 24 * 20,
            Value => $CSS
            );
        }
    }

    # Only return if something exists.
    ${$Param{Data}} =~ s{</style>}{$CSS</style>}smx if ($CSS);
 
    return 1;
}

1;
