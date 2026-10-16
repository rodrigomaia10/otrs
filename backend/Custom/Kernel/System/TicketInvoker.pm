# --
# Kernel/System/TicketInvoker.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * jsantos@serviceup.com.br
# --

package Kernel::System::TicketInvoker;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::Cache',
    'Kernel::System::DB',
    'Kernel::System::Log'
);

=head1 NAME

Kernel::System::TicketInvoker

=head1 SYNOPSIS

All Ticket Invoker module functions.

=head1 PUBLIC INTERFACE

=head2 new()

create an object

    my $TicketInvokerObject = $Kernel::OM->Get('Kernel::System::TicketInvoker');

=cut


sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{CacheType} = 'TicketInvoker';
    $Self->{CacheTTL}  = 60 * 60 * 24 * 20;

    return $Self;
}

=head2 TokenGet()

Save Webservice request data.

    my $Data = $TicketInvokerObject->TokenGet(
        Webservice     => 'Webservice 1',
        Invoker        => 'Invoker 1'
    );

=cut

sub TokenGet {
    my ( $Self, %Param ) = @_;
    
     # check needed stuff
    for my $Parameter ( qw( Webservice Invoker ) ) {
        if ( !$Param{$Parameter} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Parameter!",
            );
            return;
        }
    }

    # check cached results
    my $CacheKey = 'Cache::TokenGet::' . $Param{Webservice} . '-' . $Param{Invoker};
    my $Cache    = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $Self->{CacheType},
        Key  => $CacheKey,
    );
    return $Cache if ref $Cache eq 'HASH';

    # get objects
    my $DBObject   = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        SQL   => 'SELECT * FROM ticket_invoker_oauth WHERE web_service = ? AND invoker = ?',
        Bind  => [ \$Param{Webservice}, \$Param{Invoker} ],
        Limit => 1
    );
   
    # fetch the result
    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Data{Webservice}     = $Row[0];
        $Data{Invoker}        = $Row[1];
        $Data{Token}          = $Row[2];
        $Data{ExpirationDate} = $Row[3];
    }

    # set cache
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $Self->{CacheType},
        TTL   => $Self->{CacheTTL},
        Key   => $CacheKey,
        Value => \%Data,
    );

    return \%Data;
}

=head2 TokenAdd()

Save Webservice request data.

    my $Data = $TicketInvokerObject->TokenAdd(
        Webservice     => 'Webservice 1',
        Invoker        => 'Invoker 1',
        Token          => '1abd4afd-466e-32a0-8d75-979efd181d93',
        ExpirationDate => '2021-01-01 00:00:00'
    );

=cut

sub TokenAdd {
    my ( $Self, %Param ) = @_;
    
     # check needed stuff
    for my $Parameter ( qw( Webservice Invoker Token ) ) {
        if ( !$Param{$Parameter} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Parameter!",
            );
            return;
        }
    }   

    # get objects
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Do(
        SQL  => 'DELETE FROM ticket_invoker_oauth WHERE web_service = ? AND invoker = ?',
        Bind  => [ \$Param{Webservice}, \$Param{Invoker} ],
    );   

    if ( $Param{ExpirationDate} ) {
        return if !$DBObject->Prepare(
            SQL  => 'INSERT INTO ticket_invoker_oauth(web_service, invoker, token, expiration_tate) VALUES(?, ?, ?, ?)',
            Bind  => [ \$Param{Webservice}, \$Param{Invoker}, \$Param{Token}, \$Param{ExpirationDate} ],
        );
    }
    else {
        return if !$DBObject->Prepare(
            SQL  => 'INSERT INTO ticket_invoker_oauth(web_service, invoker, token, expiration_tate) VALUES(?, ?, ?)',
            Bind  => [ \$Param{Webservice}, \$Param{Invoker}, \$Param{Token} ]
        );
    }
   
    # reset cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => $Self->{CacheType},
    );

    return 1;
}

=head2 WebServiceRequest()

Returns the payload of the backend.

    my $Result = $TicketInvokerObject->Request(
        Webservice => '...',
        Invoker => '...',
        # OR
        InvokerSearch => '...',
        # OR
        InvokerGet => '...',
        UserID => 1,
    );

Returns:

    my $Result = '';

=cut

sub WebServiceRequest {
    my ( $Self, %Param ) = @_;

    # get objects
    my $LogObject        = $Kernel::OM->Get('Kernel::System::Log');
    my $WebserviceObject = $Kernel::OM->Get('Kernel::System::GenericInterface::Webservice');
    my $RequesterObject  = $Kernel::OM->Get('Kernel::GenericInterface::Requester');

    $Param{Invoker} //= $Param{InvokerSearch} // $Param{InvokerGet};

    NEEDED:
    for my $Needed (qw(Webservice Invoker UserID)) {
        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    my $WebserviceData = $WebserviceObject->WebserviceGet(
        Name => $Param{Webservice}
    );
    if ( !IsHashRefWithData($WebserviceData) ) {
        $LogObject->Log(
            Priority => 'error',
            Message  => "Web service '$Param{Webservice}' not found."
        );
    }

    my $ResultData;

    if ( $Param{Data} ) {

        $ResultData = $RequesterObject->Run(
            WebserviceID => $WebserviceData->{ID},
            Invoker      => $Param{Invoker},
            Data         => {
                SearchTerms => '***',
                UserID      => $Param{UserID},
                %{ $Param{Data} } 
            },
        );
    }
    else {

        $ResultData = $RequesterObject->Run(
            WebserviceID => $WebserviceData->{ID},
            Invoker      => $Param{Invoker},
            Data         => {
                SearchTerms => '***',
                UserID      => $Param{UserID}
            },
        );
    }    

    if (
        !IsHashRefWithData($ResultData)
        && !IsArrayRefWithData( $ResultData->{Data} )
        || (
            !$ResultData->{Success}
            && !$ResultData->{ResponseSuccess}
        )
        )
    {
        my %Error = (
            Error => "Error while getting result from web service $Param{Webservice}!",
        );

        $LogObject->Log(
            Priority => 'error',
            Message  => $Error{Error}
        );

        # do not return on an error! just log it.
        # it's just for ajax request which will produce
        # an ugly message to the user which does not really help him at all
    }

    # if we got a valid result pass key value to the json
    # a valid result should be an array which includes one or more hashes
    # with the structure:
    #   {
    #       Key   => 'Znuny',
    #       Value => 'Bar'
    #   }
    # please tell your invoker to send the right stuff

    return $ResultData->{Data};
}

1;