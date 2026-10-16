# --
# Kernel/Modules/AgentKPIWidget.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * pdias@beonup.com.br
# * dsilva@serviceup.com.br
# --

package Kernel::Modules::AgentKPIWidget;

use strict;
use warnings;

use Kernel::Language qw(Translatable);
use Kernel::System::VariableCheck qw(:all);
use Kernel::Output::HTML::Dashboard::KPIWidget;

use utf8;

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

    my $UserObject            = $Kernel::OM->Get('Kernel::System::User');
	my $LayoutObject          = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $TicketObject          = $Kernel::OM->Get('Kernel::System::Ticket');
	my $CustomerCompanyObject = $Kernel::OM->Get('Kernel::System::CustomerCompany');
	my $ConfigObject          = $Kernel::OM->Get('Kernel::Config');
	my $JSONObject            = $Kernel::OM->Get('Kernel::System::JSON');
	my $QueueObject           = $Kernel::OM->Get('Kernel::System::Queue');

	my $Configs = $ConfigObject->Get('DashboardBackend');

	my $Object = Kernel::Output::HTML::Dashboard::KPIWidget->new(
        %{$Self},
        Config                => $Configs->{"0000-KPIWidget"},
        Name                  => "0000-KPIWidget",
        CustomerID            => $Self->{CustomerID} || '',
    );
    
	my $Content   = $Object->Run(
       AJAX       => $Param{AJAX},
       CustomerID => $Self->{CustomerID} || '',
    );

    $LayoutObject->AddJSData(
        Key   => 'FullScreen',
        Value => 1,
    );

	my $ConfigBlackBackground = $ConfigObject->Get('KPI::Core::BlackBackground');

    if($ConfigBlackBackground eq '0'){
        $LayoutObject->Block(
            Name => 'Adjust',
        );

        $LayoutObject->AddJSData(
            Key   => 'Adjust',
            Value => 1,
        );
    }  

	# build output
    my $Output = $LayoutObject->Header(Title => "Ticket KPI");
    $Output   .= $LayoutObject->NavigationBar();
    $Output   .= $LayoutObject->Output(
        TemplateFile => 'AgentKPIWidget',
		Data => {
			Title => $Configs->{"0000-KPIWidget"}->{Title},
			Content => $Content
		}
    );
    $Output   .= $LayoutObject->Footer();

    return $Output;
}

1;