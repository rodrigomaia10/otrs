# --
# Kernel/Autoload/SetDynamicFieldFromSurvey.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * dparavani@serviceup.com.br
# --

use Kernel::System::Survey;

package Kernel::System::Survey;

use strict;
use warnings;

use utf8;

=head2 PublicSurveyInvalidSet()

to set a request invalid

    $SurveyObject->PublicSurveyInvalidSet(
        PublicSurveyKey => 'aVkdE82Dw2qw6erCda',
    );

=cut

sub PublicSurveyInvalidSet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{PublicSurveyKey} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need SurveyID!'
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get request
    return if !$DBObject->Prepare(
        SQL => '
            SELECT id
            FROM survey_request
            WHERE public_survey_key = ?',
        Bind  => [ \$Param{PublicSurveyKey} ],
        Limit => 1,
    );

    # fetch the result
    my $RequestID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $RequestID = $Row[0];
    }

    return if !$RequestID;

    # update request
    return if !$DBObject->Do(
        SQL => '
            UPDATE survey_request
            SET valid_id = 0, vote_time = current_timestamp
            WHERE id = ?',
        Bind => [ \$RequestID ],
    );

    # START BLOCK BOU
    my $DynamicFieldFromSurveyObject = $Kernel::OM->Get('Kernel::System::DynamicFieldFromSurvey');

    $DynamicFieldFromSurveyObject->SetDynamicFieldFromSurveyVote(
        PublicSurveyKey => $Param{PublicSurveyKey}
    );
    # END BLOCK BOU

    return 1;
}

1;