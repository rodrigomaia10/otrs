# --
# Kernel/System/DynamicFieldFromSurvey.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::System::DynamicFieldFromSurvey;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::CustomerUser',
    'Kernel::System::DB',
    'Kernel::System::HTMLUtils',
    'Kernel::System::Log',
    'Kernel::System::User',
    'Kernel::System::YAML',
    'Kernel::System::Encode',
    'Kernel::System::JSON',
);

=head1 NAME

Kernel::System::Survey - survey lib

=head1 DESCRIPTION

All Dynamic Field From Survey functions.

=head1 PUBLIC INTERFACE

=head2 new()

create an object

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $DynamicFieldFromSurveyObject = $Kernel::OM->Get('Kernel::System::DynamicFieldFromSurvey');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=head2 SetDynamicFieldFromSurveyVote()

to count all answers of a question

    my $Success = $DynamicFieldFromSurveyObject->SetDynamicFieldFromSurveyVote(
        PublicSurveyKey => 'aVkdE82Dw2qw6erCda',
    );

=cut

sub SetDynamicFieldFromSurveyVote {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{PublicSurveyKey} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need PublicSurveyKey!',
        );

        return;
    }

    # get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # get mapping config,
    my %VoteMapping    = %{ $ConfigObject->Get('DynamicFieldFromSurvey::Mapping')->{'Vote'} || {} };

    # no mapping is OK
    return 1 if !%VoteMapping;

    # get dynamic field objects
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $HTMLUtilsObject           = $Kernel::OM->Get('Kernel::System::HTMLUtils');
    my $LayoutObject              = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $SurveyObject              = $Kernel::OM->Get('Kernel::System::Survey');

    my %RequestData = $SurveyObject->RequestGet(
        PublicSurveyKey => $Param{PublicSurveyKey}
    );

    my @QuestionList = $SurveyObject->QuestionList(
        SurveyID => $RequestData{SurveyID},
    );

    # get dynamic fields list
    my $DynamicFields = $DynamicFieldObject->DynamicFieldList(
        Valid      => 1,
        ObjectType => 'Ticket',
        ResultType => 'HASH',
    );	

    my $DynamicFieldsReverse = { reverse %{$DynamicFields} };

    my %TypeFieldMapping = (
        "Checkbox" => "Checkbox",
        "NPS"      => "Dropdown",
        "Radio"    => "Dropdown",
        "YesNo"    => "Dropdown",
        "TextArea" => "TextArea",
    );

    # also continue if there was no survey data found - erase values
    # loop over the configured mapping of customer data variables to dynamic fields
    VARIABLENAME:
    for my $VariableName ( sort keys %VoteMapping ) {

        # check config for the particular mapping
        if ( !defined $DynamicFieldsReverse->{ $VoteMapping{$VariableName} } ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message =>
                    "DynamicField $VoteMapping{$VariableName} in DynamicFieldFromSurvey::Mapping###Vote must be set in system and valid.",
            );
            next VARIABLENAME;
        }
        
        my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
            Name => $VoteMapping{$VariableName},
        );

        QUESTION:
        for my $Question ( @QuestionList ){

            next QUESTION if $Question->{Question} ne $VariableName;

            my @Vote = $SurveyObject->VoteGet(
                RequestID => $RequestData{RequestID},
                QuestionID => $Question->{QuestionID}
            );

            my $Value;

            if($Question->{Type} eq 'Checkbox'){
                if( IsArrayRefWithData(\@Vote) ){
                    my $Size = scalar @Vote - 1;
                    my $Flag = 0;
                    for (@Vote){
                        my %Answer = $SurveyObject->AnswerGet(
                            AnswerID => $_->{VoteValue}
                        );

                        if($Flag == $Size){
                            $Value .= $Answer{Answer};
                        }
                        else{
                            $Value .= $Answer{Answer} . ', ';
                        }

                        $Flag++;
                    }
                }       
            }
            elsif($Question->{Type} eq 'NPS'){
                if( IsArrayRefWithData(\@Vote) ){
                    for (@Vote){
                        my %Answer = $SurveyObject->AnswerGet(
                            AnswerID => $_->{VoteValue}
                        );

                        $Value = $Answer{Answer};
                    }
                }
            }
            elsif($Question->{Type} eq 'Radio'){
                if( IsArrayRefWithData(\@Vote) ){
                    for (@Vote){
                        my %Answer = $SurveyObject->AnswerGet(
                            AnswerID => $_->{VoteValue}
                        );

                        $Value = $Answer{Answer};
                    }
                }
            }
            elsif($Question->{Type} eq 'Textarea'){

                $Value = $Vote[0]->{VoteValue};
                $Value =~ s{\A\$html\/text\$\s(.*)}{$1}xms;
                $Value = $LayoutObject->Ascii2Html(
                    Text           => $Value,
                    HTMLResultMode => 1,
                );
                $Value = $HTMLUtilsObject->ToAscii(
                    String => $Value,
                );
            }
            elsif($Question->{Type} eq 'YesNo'){

                $Value = $LayoutObject->{LanguageObject}->Translate($Vote[0]->{VoteValue});
            }

            # update dynamic field value for ticket
            $DynamicFieldBackendObject->ValueSet(
                DynamicFieldConfig => $DynamicFieldConfig,
                ObjectID           => $RequestData{TicketID},
                Value              => $Value || '',
                UserID             => 1,
            );
        }
    }

    my %RequestMapping = %{ $ConfigObject->Get('DynamicFieldFromSurvey::Mapping')->{'Request'} || {} };

    # no mapping is OK
    return 1 if !%RequestMapping;

    # also continue if there was no survey data found - erase values
    # loop over the configured mapping of customer data variables to dynamic fields
    VARIABLENAME:
    for my $VariableName ( sort keys %RequestMapping ) {

        # check config for the particular mapping
        if ( !defined $DynamicFieldsReverse->{ $RequestMapping{$VariableName} } ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message =>
                    "DynamicField $RequestMapping{$VariableName} in DynamicFieldFromSurvey::Mapping###Request must be set in system and valid.",
            );
            next VARIABLENAME;
        }
        
        my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
            Name => $RequestMapping{$VariableName},
        );

        # update dynamic field value for ticket
        $DynamicFieldBackendObject->ValueSet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ObjectID           => $RequestData{TicketID},
            Value              => $RequestData{$VariableName} || '',
            UserID             => 1,
        );

    }

    return 1;
}

1;
