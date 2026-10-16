# --
# Kernel/Modules/PublicAttachment.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dparavani@serviceup.com.br
# --

package Kernel::Modules::PublicAttachment;

use strict;
use warnings;
use utf8;

use Kernel::Language qw(Translatable);
use Kernel::System::VariableCheck qw(:all);


sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless ($Self, $Type);

    return $Self;

}

sub Run {
    my ( $Self, %Param ) = @_;

    # get param object
	my $DynamicFieldFileSystemValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldFileSystemValue');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # create needed objects
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    # get param token
    my $Token = $ParamObject->GetParam( Param => 'Token' );

    # get data of public key
    my $DataAttachment = $DynamicFieldFileSystemValueObject->GetDataAttachment(
        Token => $Token,
    );

    my $ObjectID = $DataAttachment->{ObjectID};
    my $FieldID = $DataAttachment->{FieldID};
    my $Filename = $DataAttachment->{FileName};

    # get a attachment
    my %Data;

    my $FileData = $DynamicFieldFileSystemValueObject->ValueFileGet(
        ObjectID => $ObjectID,
        FieldID  => $FieldID,
    );

    FILE:
    foreach my $File ( @{$FileData} ) {

        my $Name = "$File->{Filename}";
        next FILE if $Filename ne $Name;

        $Data{Content}     = $File->{Content};
        $Data{ContentType} = $File->{ContentType};
        $Data{Filename}    = $File->{Filename};
    }

    return $LayoutObject->Attachment(%Data);

}

1;