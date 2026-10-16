# Kernel/Modules/AdminCustomerPortalCustomCSS.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * ccresencio@serviceup.com.br
# --

package Kernel::Modules::AdminCustomerPortalCustomCSS;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

sub new {
    my ($Type, %Param) = @_;

    my $Self = {%Param};
    bless($Self, $Type);

    return $Self;
}

sub Run {
    my ($Self, %Param) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $XMLObject    = $Kernel::OM->Get('Kernel::System::XML');
    my $CacheObject  = $Kernel::OM->Get('Kernel::System::Cache');


    if ($Self->{Subaction} eq 'AddAction') {
        $LayoutObject->ChallengeTokenCheck();

        my $CSSField = $ParamObject->GetParam(Param => 'CSSField') || '';

        # Flush old CSS.
        $XMLObject->XMLHashDelete(
            Type => 'CustomPortalCSS',
            Key  => '1'
        );

        # Update new CSS.
        $XMLObject->XMLHashAdd(
            Key     => 1,
            Type    => 'CustomPortalCSS',
            XMLHash => [({'Content' => $CSSField})]
        );

        # Delete Cache.
        $CacheObject->Delete(
            Type => 'CustomPortalCSS',
            Key  => '1'
        );
    
        return $LayoutObject->Redirect(OP => "Action=AdminCustomerPortalCustomCSS");  # Prevent from resubmitting.
    } else {
        $Param{Action} = 'Add';

        # Get the current CSS.
        my @XMLHash = $XMLObject->XMLHashGet(
            Type => 'CustomPortalCSS',
            Key  => '1'
        );

        $Param{'CSSField'} = $XMLHash[0]{'Content'};

        $LayoutObject->Block(
            Name => 'Overview',
            Data => \%Param
        );

        # Create the CodeMirror editor.
        $LayoutObject->SetRichTextParameters(
            Data => {
                %Param,
                RichTextHeight => '600',
                RichTextWidth  => '99%',
                RichTextType   => 'CodeMirror'
            }
        );

        return  $LayoutObject->Header() .
                $LayoutObject->NavigationBar() . 
                $LayoutObject->Output(
                    TemplateFile => 'AdminCustomerPortalCustomCSS',
                    Data         => \%Param
                ) . $LayoutObject->Footer();
    }
}

1;
