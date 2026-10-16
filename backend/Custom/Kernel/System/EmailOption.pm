# --
# Kernel/System/EmailOption.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package Kernel::System::EmailOption;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

Kernel::System::EmailOption - Email Option Management

=head1 SYNOPSIS

Global module to manage EmailOption.

=head1 PUBLIC INTERFACE

=head2 new()

create an object. Do not use it directly, instead use:

    my $EmailOptionObject = $Kernel::OM->Get('Kernel::System::EmailOption');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=head2 RequestSend()

set request data to email option.

    my $PublicKey = $EmailOptionObject->RequestSend(
        TicketID   => 1,
        ArticleID  => 1, # optional
        FieldID    => 1,
        FieldValue => 'Valor 1',
        SendTo     => 'example@serviceup.com'
    );

=cut

sub RequestSend {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed ( qw(TicketID FieldID FieldValue SendTo) ) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # get system time
    my $SystemTime = $Kernel::OM->Create('Kernel::System::DateTime')->ToEpoch();

    # create PublicSurveyKey
    my $MD5 = Digest::MD5->new();
    $MD5->add( $SystemTime . int( rand(999999999) ) );
    my $PublicKey = $MD5->hexdigest();

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
    
    if ( !$Param{ArticleID} ) {

        # insert email option request
        return if !$DBObject->Do(
            SQL => 'INSERT INTO email_option_request (ticket_id, field_id, field_value, valid_id, public_key, send_to, create_time ) 
                    VALUES ( ?, ?, ?, 1, ?, ?, current_timestamp )',
            Bind => [ \$Param{TicketID}, \$Param{FieldID}, \$Param{FieldValue}, \$PublicKey, \$Param{SendTo}, ],
        );
    }
    else {

        # insert email option request
        return if !$DBObject->Do(
            SQL => 'INSERT INTO email_option_request (ticket_id, article_id, field_id, field_value, valid_id, public_key, send_to, create_time ) 
                    VALUES ( ?, ?, ?, ?, 1, ?, ?, current_timestamp )',
            Bind => [ \$Param{TicketID}, \$Param{ArticleID}, \$Param{FieldID}, \$Param{FieldValue}, \$PublicKey, \$Param{SendTo}, ],
        );
    }    

    return $PublicKey;
}

=head2 RequestGet()

get request data to email option.

    my $EmailOptionData = $EmailOptionObject->RequestGet(
        PublicKey => 'b4c14552919018b51ec792c9b812b691' #request
    );

=cut

sub RequestGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{PublicKey} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need PublicKey!"
        );
        return;
    }
    
    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # insert email option request
    return if !$DBObject->Prepare(
        SQL => 'SELECT ticket_id, article_id, field_id, field_value, valid_id, public_key, send_to, answered_by, create_time FROM email_option_request WHERE public_key = ?',
        Bind => [ \$Param{PublicKey} ],
    );

    # fetch the result
    my %RequestData;

    while ( my @Row = $DBObject->FetchrowArray() ) {
        $RequestData{TicketID}   = $Row[0];
        $RequestData{AritcleID}  = $Row[1];
        $RequestData{FieldID}    = $Row[2];
        $RequestData{FieldValue} = $Row[3];
        $RequestData{ValidID}    = $Row[4];
        $RequestData{PublicKey}  = $Row[5];
        $RequestData{SendTo}     = $Row[6];
        $RequestData{AnsweredBy} = $Row[7];
        $RequestData{CreateTime} = $Row[8];
    }

    return \%RequestData;
}

=head2 RequestUpdate()

update request data to email option.

    my $Success = $EmailOptionObject->RequestUpdate(
        TicketID   => 1,
        ArticleID  => 1, # optional
        FieldID    => 1,
        AnsweredBy => 'example@serviceup.com'
    );

=cut

sub RequestUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed ( qw(TicketID FieldID AnsweredBy) ) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    if ( !$Param{ArticleID} ) {

        # insert email option request
        return if !$DBObject->Do(
            SQL => 'UPDATE email_option_request SET answered_by = ?, valid_id = 0 WHERE ticket_id = ? AND field_id = ?',
            Bind => [ \$Param{AnsweredBy}, \$Param{TicketID}, \$Param{FieldID} ],
        );      
    }
    else {

          # insert email option request
        return if !$DBObject->Do(
            SQL => 'UPDATE email_option_request SET answered_by = ?, valid_id = 0 WHERE ticket_id = ? AND article_id = ? AND field_id = ?',
            Bind => [ \$Param{AnsweredBy}, \$Param{TicketID}, \$Param{ArticleID}, \$Param{FieldID}  ],
        );     
    }

    return 1;
}

=head2 ValidRequest()

update request data to email option.

    my $Success = $EmailOptionObject->ValidRequest(
        TicketID   => 1,
        ArticleID  => 1, # optional
        FieldID    => 1,
    );

=cut

sub ValidRequest {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed ( qw(TicketID FieldID ) ) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    if ( !$Param{ArticleID} ) {

        # insert email option request
        return if !$DBObject->Do(
            SQL => 'UPDATE email_option_request SET valid_id = 1 WHERE ticket_id = ? AND field_id = ?',
            Bind => [ \$Param{TicketID}, \$Param{FieldID} ],
        );      
    }
    else {

        # insert email option request
        return if !$DBObject->Do(
            SQL => 'UPDATE email_option_request SET valid_id = 1 WHERE ticket_id = ? AND article_id = ? AND field_id = ?',
            Bind => [ \$Param{TicketID}, \$Param{ArticleID}, \$Param{FieldID}  ],
        );     
    }

    return 1;
}


1;