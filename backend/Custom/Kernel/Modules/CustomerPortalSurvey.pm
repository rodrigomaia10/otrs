# --
# Kernel/Modules/CustomerPortalSurvey.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# --

package Kernel::Modules::CustomerPortalSurvey;

use strict;
use warnings;
use Digest::MD5 qw(md5_hex);

use Kernel::System::VariableCheck qw(:all);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ParamObject          = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $CustomerUserObject   = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $UserObject           = $Kernel::OM->Get('Kernel::System::User');
    my $CustomerPortalObject = $Kernel::OM->Get('Kernel::System::CustomerPortal');
    my $JSONObject           = $Kernel::OM->Get('Kernel::System::JSON');
    my $LayoutObject         = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ServiceObject        = $Kernel::OM->Get('Kernel::System::Service');
    my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
    my $QueueObject          = $Kernel::OM->Get('Kernel::System::Queue');
    my $Config               = $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::CustomerTicketMessage");
    my $TicketObject         = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ArticleObject        = $Kernel::OM->Get('Kernel::System::Ticket::Article');

    my %GetParam;
    my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');

    $CustomerPortalLayoutObject->CreateNavBar(
        ActionActive => "",
        %{$Self}
    );

    $Param{Title}  = '';
    $Param{Active} = 'Unanswered Surveys';

    $LayoutObject->Block( Name => 'ShowSurvey' );

    my %DataSurvey = $CustomerPortalObject->GetSurveyCustomerUser(
        UserID  => $Self->{UserID},
        NoCache => 1,
    );

    # check start option, if higher than fields available, set
    # it to the last field page
    my $StartHit = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'StartHit' ) || 1;

    my $PageShown = $Self->{UserShowTickets} || 25;

    $Param{Total} = scalar @{ $DataSurvey{Data} };

    # calculate max. shown per page
    if ( $StartHit > $Param{Total} ) {
        my $Pages = int( ( $Param{Total} / $PageShown ) + 0.99999 );
        $StartHit = ( ( $Pages - 1 ) * $PageShown ) + 1;
    }

    # build nav bar
    my $Limit   = $Param{Limit} || 20_000;
    my %PageNav = $LayoutObject->PageNavBar(
        Limit     => $Limit,
        StartHit  => $StartHit,
        PageShown => $PageShown,
        AllHits   => $Param{Total} || 0,
        Action    => 'Action=' . $LayoutObject->{Action},
        Link      => $Param{LinkPage},
        IDPrefix  => $LayoutObject->{Action},
    );

    if (%PageNav) {
        $LayoutObject->Block(
            Name => 'OverviewNavBarPageNavBar',
            Data => \%PageNav,
        );

        $LayoutObject->Block(
            Name => 'ContextSettings',
            Data => { %PageNav, %Param, },
        );
    }

    my $Counter = 0;

    unless ( $DataSurvey{Counter} ) {
        $LayoutObject->Block(
            Name => 'NoDataFoundMsg',
        );
    }
    else {

        for my $Data ( @{ $DataSurvey{Data} } ) {

            $Counter++;

            if ( $Counter >= $StartHit && $Counter < ( $PageShown + $StartHit ) ) {

                $LayoutObject->Block(
                    Name => 'SurveyRow',
                    Data => {
                        TicketNumber => $Data->{TicketNumber},
                        Age          => $Data->{Age},
                        Subject      => $Data->{Subject},
                        State        => $Data->{State},
                        URL          => "/" . $ConfigObject->Get('ScriptAlias') . "public.pl?Action=PublicSurvey;PublicSurveyKey=$Data->{PublicSurveyKey}",
                        ID           => $Data->{SurveyID},
                    }
                );
            }
        }
    }

    # build output
    my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => 'Unanswered Surveys');
    $Output   .= $LayoutObject->Output(
    Data         => \%Param,
        TemplateFile => 'CustomerPortalSurvey',
    );
    $Output   .= $LayoutObject->CustomerFooter(Type => 'Small');

    return $Output;
    
}

1;