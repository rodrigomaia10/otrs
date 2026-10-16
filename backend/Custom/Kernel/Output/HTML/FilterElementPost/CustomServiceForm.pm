# --
# Kernel/Output/HTML/FilterElementPost/CustomServiceForm.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@beonup.com.br
# --

package Kernel::Output::HTML::FilterElementPost::CustomServiceForm;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

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

    return if(
		$Param{TemplateFile} eq 'AgentTicketFreeText' ||
		$Param{TemplateFile} eq 'AgentTicketPriority' ||
		$Param{TemplateFile} eq 'AgentTicketProcess'
	);

    # load required objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # return if template is empty
    return 1 if !$Param{TemplateFile};

    my $TitleLoading = $LayoutObject->{LanguageObject}->Translate("Loading");

    my $JSBlock = <<"JS_BLOCK";
    Core.Agent.CustomServiceForm.Init('$TitleLoading');
JS_BLOCK

    $Self->AddJSOnDocumentCompleteIfNotExists(
        Key  => 'JSCustomServiceForm',
        Code => $JSBlock,
    );

    # done, return information
    return ${ $Param{Data} };

}

sub AddJSOnDocumentCompleteIfNotExists {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # check needed stuff
    NEEDED:
    for my $Needed (qw(Key Code)) {

        next NEEDED if defined $Param{$Needed};

        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    my $Exists = 0;
    CODEJS:
    for my $CodeJS ( @{ $LayoutObject->{_JSOnDocumentComplete} || [] } ) {

        next CODEJS if $CodeJS !~ m{ Key: \s $Param{Key}}xms;
        $Exists = 1;
        last CODEJS;
    }

    return 1 if $Exists;

    my $AddCode = "// Key: $Param{Key}\n" . $Param{Code} . "\n";

    $LayoutObject->AddJSOnDocumentComplete(
        Code => $AddCode,
    );

    return 1;
}

1;
