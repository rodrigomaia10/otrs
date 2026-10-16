# --
# Kernel/System/Macro.pm
# Copyright (C)  2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# * dsilva@serviceup.com.br
# --

package Kernel::System::Macro;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Cache',
    'Kernel::System::DateTime',
    'Kernel::System::DB',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::Queue',
    'Kernel::System::State',
    'Kernel::System::Ticket',
    'Kernel::System::Ticket::Article',
    'Kernel::System::TemplateGenerator',
    'Kernel::System::CustomerUser',
);

=head1 NAME

Kernel::System::Macro - to manage the generic agent jobs

=head1 DESCRIPTION

All functions to manage the generic agent and the generic agent jobs.

=head1 PUBLIC INTERFACE

=head2 new()

Don't use the constructor directly, use the ObjectManager instead:

    my $MacroObject = $Kernel::OM->Get('Kernel::System::Macro');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get dynamic field objects
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # get the dynamic fields for ticket object
    $Self->{DynamicField} = $DynamicFieldObject->DynamicFieldListGet(
        Valid      => 1,
        ObjectType => ['Ticket'],
    );

    # debug
    $Self->{Debug} = $Param{Debug} || 0;

    # notice on STDOUT
    $Self->{NoticeSTDOUT} = $Param{NoticeSTDOUT} || 0;

    my %Map = (
        TicketNumber            => 'SCALAR',
        Title                   => 'SCALAR',
        MIMEBase_From           => 'SCALAR',
        MIMEBase_To             => 'SCALAR',
        MIMEBase_Cc             => 'SCALAR',
        MIMEBase_Subject        => 'SCALAR',
        MIMEBase_Body           => 'SCALAR',
        TimeUnit                => 'SCALAR',
        CustomerID              => 'SCALAR',
        CustomerUserLogin       => 'SCALAR',
        Agent                   => 'SCALAR',
        StateIDs                => 'ARRAY',
        StateTypeIDs            => 'ARRAY',
        QueueIDs                => 'ARRAY',
        PriorityIDs             => 'ARRAY',
        OwnerIDs                => 'ARRAY',
        LockIDs                 => 'ARRAY',
        TypeIDs                 => 'ARRAY',
        ResponsibleIDs          => 'ARRAY',
        ServiceIDs              => 'ARRAY',
        SLAIDs                  => 'ARRAY',
        NewTitle                => 'SCALAR',
        NewCustomerID           => 'SCALAR',
        NewCustomerUserLogin    => 'SCALAR',
        NewStateID              => 'SCALAR',
        NewQueueID              => 'SCALAR',
        NewPriorityID           => 'SCALAR',
        NewOwnerID              => 'SCALAR',
        NewLockID               => 'SCALAR',
        NewTypeID               => 'SCALAR',
        NewResponsibleID        => 'SCALAR',
        NewServiceID            => 'SCALAR',
        NewSLAID                => 'SCALAR',
        ScheduleLastRun         => 'SCALAR',
        ScheduleLastRunUnixTime => 'SCALAR',
        Valid                   => 'SCALAR',
        ScheduleDays            => 'ARRAY',
        ScheduleMinutes         => 'ARRAY',
        ScheduleHours           => 'ARRAY',
        EventValues             => 'ARRAY',
    );

    # add time attributes
    for my $Type (
        qw(Time ChangeTime CloseTime TimePending EscalationTime EscalationResponseTime EscalationUpdateTime EscalationSolutionTime)
        )
    {
        my $Key = $Type . 'SearchType';
        $Map{$Key} = 'SCALAR';
    }
    for my $Type (
        qw(TicketCreate TicketChange TicketClose TicketLastChange TicketPending TicketEscalation TicketEscalationResponse TicketEscalationUpdate TicketEscalationSolution)
        )
    {
        for my $Attribute (
            qw(PointFormat Point PointStart Start StartDay StartMonth StartYear Stop StopDay StopMonth StopYear)
            )
        {
            my $Key = $Type . 'Time' . $Attribute;
            $Map{$Key} = 'SCALAR';
        }
    }

    # Add Dynamic Fields attributes
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        # get the field type of the dynamic fields for edit and search
        my $FieldValueType = $DynamicFieldBackendObject->TemplateValueTypeGet(
            DynamicFieldConfig => $DynamicFieldConfig,
            FieldType          => 'All',
        );

        # Add field type to Map
        if ( IsHashRefWithData($FieldValueType) ) {
            for my $FieldName ( sort keys %{$FieldValueType} ) {
                $Map{$FieldName} = $FieldValueType->{$FieldName};
            }
        }
    }

    $Self->{Map} = \%Map;

    return $Self;
}

=head2 MacroRun()

run a generic agent job

    $MacroObject->MacroRun(
        MacroName => 'Macro',
        TicketID  => 123,
    );

=cut

sub MacroRun {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(MacroName TicketID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # get Macro from param
    my %Macro;
    my %DynamicFieldSearchTemplate;

    if ( $Param{Config} ) {
        %Macro = %{ $Param{Config} };

        # log event
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'notice',
            Message  => "Run Macro '$Param{MacroName}' from config file.",
        );
    }

    # get db Macro
    else {

        # log event
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'notice',
            Message  => "Run Macro '$Param{MacroName}' from db.",
        );

        # get macro data
        my %DBMacroRaw = $Self->MacroGet( MacroName => $Param{MacroName} );

        # rework
        for my $Key ( sort keys %DBMacroRaw ) {

            if ( $Key =~ /^New/ ) {
                my $NewKey = $Key;
                $NewKey =~ s/^New//;
                $Macro{New}->{$NewKey} = $DBMacroRaw{$Key};
            }
        }
    }

    $Self->_MacroRunTicket(
        Config       => \%Macro,
        MacroName    => $Param{MacroName},
        TicketID     => $Param{TicketID},
        UserID       => $Param{UserID},
    );

    return 1;
}

=head2 MacroList()

returns a hash of macros

    my %List = $MacroObject->MacroList();

=cut

sub MacroList {
    my ( $Self, %Param ) = @_;

    # get cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    # check cache
    my $CacheKey = "MacroList";
    my $Cache    = $CacheObject->Get(
        Type => 'Macro',
        Key  => $CacheKey,
    );
    return %{$Cache} if ref $Cache;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        SQL => 'SELECT DISTINCT(macro_name) FROM macro',
    );

    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Data{ $Row[0] } = $Row[0];
    }

    $CacheObject->Set(
        Type  => 'Macro',
        Key   => $CacheKey,
        Value => \%Data,
        TTL   => 24 * 60 * 60,
    );

    return %Data;
}

=head2 MacroGet()

returns a hash of the job data

    my %Job = $MacroObject->MacroGet(MacroName => 'JobName');

=cut

sub MacroGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(MacroName)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # get cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    # check cache
    my $CacheKey = 'MacroGet::' . $Param{MacroName};
    my $Cache    = $CacheObject->Get(
        Type => 'Macro',
        Key  => $CacheKey,
    );
    return %{$Cache} if ref $Cache;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        SQL => '
            SELECT macro_key, macro_value
            FROM macro
            WHERE macro_name = ?',
        Bind => [ \$Param{MacroName} ],
    );

    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        if ( $Self->{Map}->{ $Row[0] } && $Self->{Map}->{ $Row[0] } eq 'ARRAY' ) {
            push @{ $Data{ $Row[0] } }, $Row[1];
        }
        else {
            $Data{ $Row[0] } = $Row[1];
        }
    }

    # get time settings
    my %Map = (
        TicketCreate             => 'Time',
        TicketChange             => 'ChangeTime',
        TicketClose              => 'CloseTime',
        TicketLastChange         => 'LastChangeTime',
        TicketPending            => 'TimePending',
        TicketEscalation         => 'EscalationTime',
        TicketEscalationResponse => 'EscalationResponseTime',
        TicketEscalationUpdate   => 'EscalationUpdateTime',
        TicketEscalationSolution => 'EscalationSolutionTime',
    );

    for my $Type (
        qw(TicketCreate TicketChange TicketClose TicketLastChange TicketPending TicketEscalation TicketEscalationResponse TicketEscalationUpdate TicketEscalationSolution)
        )
    {
        my $SearchType = $Map{$Type} . 'SearchType';

        if ( !$Data{$SearchType} || $Data{$SearchType} eq 'None' ) {

            # do nothing on time stuff
            for (
                qw(TimeStartMonth TimeStopMonth TimeStopDay
                TimeStartDay TimeStopYear TimePoint
                TimeStartYear TimePointFormat TimePointStart)
                )
            {
                delete $Data{ $Type . $_ };
            }
        }
        elsif ( $Data{$SearchType} && $Data{$SearchType} eq 'TimeSlot' ) {
            for (qw(TimePoint TimePointFormat TimePointStart)) {
                delete $Data{ $Type . $_ };
            }
            for (qw(Month Day)) {
                $Data{ $Type . "TimeStart$_" } = sprintf( '%02d', $Data{ $Type . "TimeStart$_" } );
                $Data{ $Type . "TimeStop$_" }  = sprintf( '%02d', $Data{ $Type . "TimeStop$_" } );
            }
            if (
                $Data{ $Type . 'TimeStartDay' }
                && $Data{ $Type . 'TimeStartMonth' }
                && $Data{ $Type . 'TimeStartYear' }
                )
            {
                $Data{ $Type . 'TimeNewerDate' } = $Data{ $Type . 'TimeStartYear' } . '-'
                    . $Data{ $Type . 'TimeStartMonth' } . '-'
                    . $Data{ $Type . 'TimeStartDay' }
                    . ' 00:00:01';
            }
            if (
                $Data{ $Type . 'TimeStopDay' }
                && $Data{ $Type . 'TimeStopMonth' }
                && $Data{ $Type . 'TimeStopYear' }
                )
            {
                $Data{ $Type . 'TimeOlderDate' } = $Data{ $Type . 'TimeStopYear' } . '-'
                    . $Data{ $Type . 'TimeStopMonth' } . '-'
                    . $Data{ $Type . 'TimeStopDay' }
                    . ' 23:59:59';
            }
        }
        elsif ( $Data{$SearchType} && $Data{$SearchType} eq 'TimePoint' ) {
            for (
                qw(TimeStartMonth TimeStopMonth TimeStopDay
                TimeStartDay TimeStopYear TimeStartYear)
                )
            {
                delete $Data{ $Type . $_ };
            }
            if (
                $Data{ $Type . 'TimePoint' }
                && $Data{ $Type . 'TimePointStart' }
                && $Data{ $Type . 'TimePointFormat' }
                )
            {
                my $Time = 0;
                if ( $Data{ $Type . 'TimePointFormat' } eq 'minute' ) {
                    $Time = $Data{ $Type . 'TimePoint' };
                }
                elsif ( $Data{ $Type . 'TimePointFormat' } eq 'hour' ) {
                    $Time = $Data{ $Type . 'TimePoint' } * 60;
                }
                elsif ( $Data{ $Type . 'TimePointFormat' } eq 'day' ) {
                    $Time = $Data{ $Type . 'TimePoint' } * 60 * 24;
                }
                elsif ( $Data{ $Type . 'TimePointFormat' } eq 'week' ) {
                    $Time = $Data{ $Type . 'TimePoint' } * 60 * 24 * 7;
                }
                elsif ( $Data{ $Type . 'TimePointFormat' } eq 'month' ) {
                    $Time = $Data{ $Type . 'TimePoint' } * 60 * 24 * 30;
                }
                elsif ( $Data{ $Type . 'TimePointFormat' } eq 'year' ) {
                    $Time = $Data{ $Type . 'TimePoint' } * 60 * 24 * 365;
                }
                if ( $Data{ $Type . 'TimePointStart' } eq 'Before' ) {

                    # more than ... ago
                    $Data{ $Type . 'TimeOlderMinutes' } = $Time;
                }
                elsif ( $Data{ $Type . 'TimePointStart' } eq 'Next' ) {

                    # within the next ...
                    $Data{ $Type . 'TimeNewerMinutes' } = 0;
                    $Data{ $Type . 'TimeOlderMinutes' } = -$Time;
                }
                else {

                    # within the last ...
                    $Data{ $Type . 'TimeOlderMinutes' } = 0;
                    $Data{ $Type . 'TimeNewerMinutes' } = $Time;
                }
            }
        }
    }

    # check valid
    if ( %Data && !defined $Data{Valid} ) {
        $Data{Valid} = 1;
    }
    if (%Data) {
        $Data{MacroName} = $Param{MacroName};
    }

    $CacheObject->Set(
        Type  => 'macro',
        Key   => $CacheKey,
        Value => \%Data,
        TTL   => 24 * 60 * 60,
    );

    return %Data;
}

=head2 MacroAdd()

adds a new job to the database

    $MacroObject->MacroAdd(
        MacroName => 'JobName',
        Data => {
            Queue => 'SomeQueue',
            ...
            Valid => 1,
        },
        UserID => 123,
    );

=cut

sub MacroAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(MacroName Data UserID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # check if macro name already exists
    my %Check = $Self->MacroGet( MacroName => $Param{MacroName} );

    if (%Check) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "A macro with the name '$Param{MacroName}' already exists.",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # insert data into db
    for my $Key ( sort keys %{ $Param{Data} } ) {

        if ( ref $Param{Data}->{$Key} eq 'ARRAY' ) {

            for my $Item ( @{ $Param{Data}->{$Key} } ) {

                if ( defined $Item ) {

                    $DBObject->Do(
                        SQL => 'INSERT INTO macro '
                            . '(macro_name, macro_key, macro_value) VALUES (?, ?, ?)',
                        Bind => [ \$Param{MacroName}, \$Key, \$Item ],
                    );
                }
            }
        }
        else {
            if ( defined $Param{Data}->{$Key} ) {

                $DBObject->Do(
                    SQL => 'INSERT INTO macro '
                        . '(macro_name, macro_key, macro_value) VALUES (?, ?, ?)',
                    Bind => [ \$Param{MacroName}, \$Key, \$Param{Data}->{$Key} ],
                );
            }
        }
    }

    $Kernel::OM->Get('Kernel::System::Log')->Log(
        Priority => 'notice',
        Message  => "New Macro '$Param{MacroName}' added (UserID=$Param{UserID}).",
    );

    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => 'Macro',
    );

    return 1;
}

=head2 MacroDelete()

deletes a macro from the database

    my $Success = $MacroObject->MacroDelete(
        MacroName => 'MacroName',
        UserID    => 123,
    );

returns:

    $Success = 1;       # or false in case of a failure

=cut

sub MacroDelete {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(MacroName UserID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # delete job
    $Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => 'DELETE FROM macro WHERE macro_name = ?',
        Bind => [ \$Param{MacroName} ],
    );

    $Kernel::OM->Get('Kernel::System::Log')->Log(
        Priority => 'notice',
        Message  => "Macro '$Param{MacroName}' deleted (UserID=$Param{UserID}).",
    );

    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => 'Macro',
    );

    return 1;
}

=head2 _MacroRunTicket()

run a generic agent job on a ticket

    $MacroObject->_MacroRunTicket(
        TicketID => 123,
        Config => {
            %Macro,
        },
        UserID => 1,
    );

=cut

sub _MacroRunTicket {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(TicketID Config UserID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    $Param{TicketNumber} = $TicketObject->TicketNumberLookup(
        TicketID => $Param{TicketID},
    );

    my $Ticket = "($Param{TicketNumber}/$Param{TicketID})";

    # disable sending emails
    $TicketObject->{SendNoNotification} = $Param{Config}->{New}->{SendNoNotification} ? 1 : 0;

    # move ticket
    if ( $Param{Config}->{New}->{Queue} ) {
        if ( $Self->{NoticeSTDOUT} ) {
            print "  - Move Ticket $Ticket to Queue '$Param{Config}->{New}->{Queue}'\n";
        }
        $TicketObject->TicketQueueSet(
            QueueID => $Kernel::OM->Get('Kernel::System::Queue')->QueueLookup(
                Queue => $Param{Config}->{New}->{Queue},
                Cache => 1,
            ),
            UserID   => $Param{UserID},
            TicketID => $Param{TicketID},
        );
    }
    if ( $Param{Config}->{New}->{QueueID} ) {
        if ( $Self->{NoticeSTDOUT} ) {
            print "  - Move Ticket $Ticket to QueueID '$Param{Config}->{New}->{QueueID}'\n";
        }
        $TicketObject->TicketQueueSet(
            QueueID  => $Param{Config}->{New}->{QueueID},
            UserID   => $Param{UserID},
            TicketID => $Param{TicketID},
        );
    }

    my $ContentType = 'text/plain';

    # add note if wanted
    if ( $Param{Config}->{New}->{Note}->{Body} || $Param{Config}->{New}->{NoteBody} ) {
        if ( $Self->{NoticeSTDOUT} ) {
            print "  - Add note to Ticket $Ticket\n";
        }

        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $Param{TicketID},
            DynamicFields => 0,
        );

        my %CustomerUserData;

        # We can only do OTRS Tag replacement if we have a CustomerUserID (langauge settings...)
        if ( IsHashRefWithData( \%Ticket ) && IsStringWithData( $Ticket{CustomerUserID} ) ) {
            my %CustomerUserData = $Kernel::OM->Get('Kernel::System::CustomerUser')->CustomerUserDataGet(
                User => $Ticket{CustomerUserID},
            );

            my %Notification = (
                Subject     => $Param{Config}->{New}->{NoteSubject},
                Body        => $Param{Config}->{New}->{NoteBody},
                ContentType => 'text/plain',
            );

            my %GenericAgentArticle = $Kernel::OM->Get('Kernel::System::TemplateGenerator')->GenericAgentArticle(
                TicketID     => $Param{TicketID},
                Recipient    => \%CustomerUserData,    # Agent or Customer data get result
                Notification => \%Notification,
                UserID       => $Param{UserID},
            );

            if (
                IsStringWithData( $GenericAgentArticle{Body} )
                || IsHashRefWithData( $GenericAgentArticle{Subject} )
                )
            {
                $Param{Config}->{New}->{Note}->{Subject} = $GenericAgentArticle{Subject} || '';
                $Param{Config}->{New}->{Note}->{Body}    = $GenericAgentArticle{Body}    || '';
                $ContentType                             = $GenericAgentArticle{ContentType};
            }
        }

        my $ArticleBackendObject = $Kernel::OM->Get('Kernel::System::Ticket::Article')->BackendForChannel(
            ChannelName => 'Internal',
        );

        my $ArticleID = $ArticleBackendObject->ArticleCreate(
            TicketID             => $Param{TicketID},
            SenderType           => 'agent',
            IsVisibleForCustomer => $Param{Config}->{New}->{Note}->{IsVisibleForCustomer}
                // $Param{Config}->{New}->{NoteIsVisibleForCustomer}
                // 0,
            From => $Param{Config}->{New}->{Note}->{From}
                || $Param{Config}->{New}->{NoteFrom}
                || 'GenericAgent',
            Subject => $Param{Config}->{New}->{Note}->{Subject}
                || $Param{Config}->{New}->{NoteSubject}
                || 'Note',
            Body           => $Param{Config}->{New}->{Note}->{Body} || $Param{Config}->{New}->{NoteBody},
            MimeType       => $ContentType,
            Charset        => 'utf-8',
            UserID         => $Param{UserID},
            HistoryType    => 'AddNote',
            HistoryComment => 'Generic Agent note added.',
            NoAgentNotify  => $Param{Config}->{New}->{SendNoNotification} || 0,
        );
        my $TimeUnits = $Param{Config}->{New}->{Note}->{TimeUnits}
            || $Param{Config}->{New}->{NoteTimeUnits};
        if ( $ArticleID && $TimeUnits ) {
            $TicketObject->TicketAccountTime(
                TicketID  => $Param{TicketID},
                ArticleID => $ArticleID,
                TimeUnit  => $TimeUnits,
                UserID    => $Param{UserID},
            );
        }
    }

    my %PendingStates = $Kernel::OM->Get('Kernel::System::State')->StateGetStatesByType(
        StateType => [ 'pending auto', 'pending reminder' ],
        Result    => 'HASH',
    );

    $Self->{PendingStateList} = \%PendingStates || {};

    # set new state
    my $IsPendingState;
    if ( $Param{Config}->{New}->{State} ) {
        if ( $Self->{NoticeSTDOUT} ) {
            print "  - changed state of Ticket $Ticket to '$Param{Config}->{New}->{State}'\n";
        }
        $TicketObject->TicketStateSet(
            TicketID => $Param{TicketID},
            UserID   => $Param{UserID},
            State    => $Param{Config}->{New}->{State},
        );

        $IsPendingState = grep { $_ eq $Param{Config}->{New}->{State} } values %{ $Self->{PendingStateList} };
    }
    if ( $Param{Config}->{New}->{StateID} ) {
        if ( $Self->{NoticeSTDOUT} ) {
            print "  - changed state id of ticket $Ticket to '$Param{Config}->{New}->{StateID}'\n";
        }
        $TicketObject->TicketStateSet(
            TicketID => $Param{TicketID},
            UserID   => $Param{UserID},
            StateID  => $Param{Config}->{New}->{StateID},
        );

        $IsPendingState = grep { $_ == $Param{Config}->{New}->{StateID} } keys %{ $Self->{PendingStateList} };
    }

    if (
        $Param{Config}->{New}->{PendingTime}
        && !$Param{Config}->{New}->{State}
        && !$Param{Config}->{New}->{StateID}
        )
    {
        # if pending time is provided, but there is no new ticket state provided,
        # check if ticket is already in pending state
        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $Param{TicketID},
            DynamicFields => 0,
        );

        $IsPendingState = grep { $_ eq $Ticket{State} } values %{ $Self->{PendingStateList} };
    }

    # set pending time, if new state is pending state
    if ( $IsPendingState && $Param{Config}->{New}->{PendingTime} ) {

        # pending time
        my $PendingTime = $Param{Config}->{New}->{PendingTime};

        # calculate pending time based on hours, minutes, years...
        if ( $Param{Config}->{New}->{PendingTimeType} ) {
            $PendingTime *= $Param{Config}->{New}->{PendingTimeType};
        }

        # add systemtime
        my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');
        $DateTimeObject->Add( Seconds => $PendingTime );

        # set pending time
        $TicketObject->TicketPendingTimeSet(
            Year     => $DateTimeObject->Format( Format => '%Y' ),
            Month    => $DateTimeObject->Format( Format => '%m' ),
            Day      => $DateTimeObject->Format( Format => '%d' ),
            Hour     => $DateTimeObject->Format( Format => '%H' ),
            Minute   => $DateTimeObject->Format( Format => '%M' ),
            TicketID => $Param{TicketID},
            UserID   => $Param{UserID},
        );
    }

    # set customer id and customer user
    if ( $Param{Config}->{New}->{CustomerID} || $Param{Config}->{New}->{CustomerUserLogin} ) {
        if ( $Param{Config}->{New}->{CustomerID} ) {
            if ( $Self->{NoticeSTDOUT} ) {
                print
                    "  - set customer id of Ticket $Ticket to '$Param{Config}->{New}->{CustomerID}'\n";
            }
        }
        if ( $Param{Config}->{New}->{CustomerUserLogin} ) {
            if ( $Self->{NoticeSTDOUT} ) {
                print
                    "  - set customer user id of Ticket $Ticket to '$Param{Config}->{New}->{CustomerUserLogin}'\n";
            }
        }
        $TicketObject->TicketCustomerSet(
            TicketID => $Param{TicketID},
            No       => $Param{Config}->{New}->{CustomerID} || '',
            User     => $Param{Config}->{New}->{CustomerUserLogin} || '',
            UserID   => $Param{UserID},
        );
    }

    # set new title
    if ( $Param{Config}->{New}->{Title} ) {
        if ( $Self->{NoticeSTDOUT} ) {
            print "  - set title of Ticket $Ticket to '$Param{Config}->{New}->{Title}'\n";
        }
        $TicketObject->TicketTitleUpdate(
            Title    => $Param{Config}->{New}->{Title},
            TicketID => $Param{TicketID},
            UserID   => $Param{UserID},
        );
    }

    # set new type
    if ( $Param{Config}->{New}->{Type} ) {
        if ( $Self->{NoticeSTDOUT} ) {
            print "  - set type of Ticket $Ticket to '$Param{Config}->{New}->{Type}'\n";
        }
        $TicketObject->TicketTypeSet(
            TicketID => $Param{TicketID},
            UserID   => $Param{UserID},
            Type     => $Param{Config}->{New}->{Type},
        );
    }
    if ( $Param{Config}->{New}->{TypeID} ) {
        if ( $Self->{NoticeSTDOUT} ) {
            print "  - set type id of Ticket $Ticket to '$Param{Config}->{New}->{TypeID}'\n";
        }
        $TicketObject->TicketTypeSet(
            TicketID => $Param{TicketID},
            UserID   => $Param{UserID},
            TypeID   => $Param{Config}->{New}->{TypeID},
        );
    }

    # set new service
    if ( $Param{Config}->{New}->{Service} ) {
        if ( $Self->{NoticeSTDOUT} ) {
            print "  - set service of Ticket $Ticket to '$Param{Config}->{New}->{Service}'\n";
        }
        $TicketObject->TicketServiceSet(
            TicketID => $Param{TicketID},
            UserID   => $Param{UserID},
            Service  => $Param{Config}->{New}->{Service},
        );
    }
    if ( $Param{Config}->{New}->{ServiceID} ) {
        if ( $Self->{NoticeSTDOUT} ) {
            print "  - set service id of Ticket $Ticket to '$Param{Config}->{New}->{ServiceID}'\n";
        }
        $TicketObject->TicketServiceSet(
            TicketID  => $Param{TicketID},
            UserID    => $Param{UserID},
            ServiceID => $Param{Config}->{New}->{ServiceID},
        );
    }

    # set new sla
    if ( $Param{Config}->{New}->{SLA} ) {
        if ( $Self->{NoticeSTDOUT} ) {
            print "  - set sla of Ticket $Ticket to '$Param{Config}->{New}->{SLA}'\n";
        }
        $TicketObject->TicketSLASet(
            TicketID => $Param{TicketID},
            UserID   => $Param{UserID},
            SLA      => $Param{Config}->{New}->{SLA},
        );
    }
    if ( $Param{Config}->{New}->{SLAID} ) {
        if ( $Self->{NoticeSTDOUT} ) {
            print "  - set sla id of Ticket $Ticket to '$Param{Config}->{New}->{SLAID}'\n";
        }
        $TicketObject->TicketSLASet(
            TicketID => $Param{TicketID},
            UserID   => $Param{UserID},
            SLAID    => $Param{Config}->{New}->{SLAID},
        );
    }

    # set new priority
    if ( $Param{Config}->{New}->{Priority} ) {
        if ( $Self->{NoticeSTDOUT} ) {
            print "  - set priority of Ticket $Ticket to '$Param{Config}->{New}->{Priority}'\n";
        }
        $TicketObject->TicketPrioritySet(
            TicketID => $Param{TicketID},
            UserID   => $Param{UserID},
            Priority => $Param{Config}->{New}->{Priority},
        );
    }
    if ( $Param{Config}->{New}->{PriorityID} ) {
        if ( $Self->{NoticeSTDOUT} ) {
            print
                "  - set priority id of Ticket $Ticket to '$Param{Config}->{New}->{PriorityID}'\n";
        }
        $TicketObject->TicketPrioritySet(
            TicketID   => $Param{TicketID},
            UserID     => $Param{UserID},
            PriorityID => $Param{Config}->{New}->{PriorityID},
        );
    }

    # set new owner
    if ( $Param{Config}->{New}->{Owner} ) {
        if ( $Self->{NoticeSTDOUT} ) {
            print "  - set owner of Ticket $Ticket to '$Param{Config}->{New}->{Owner}'\n";
        }
        $TicketObject->TicketOwnerSet(
            TicketID => $Param{TicketID},
            UserID   => $Param{UserID},
            NewUser  => $Param{Config}->{New}->{Owner},
        );
    }
    if ( $Param{Config}->{New}->{OwnerID} ) {
        if ( $Self->{NoticeSTDOUT} ) {
            print "  - set owner id of Ticket $Ticket to '$Param{Config}->{New}->{OwnerID}'\n";
        }
        $TicketObject->TicketOwnerSet(
            TicketID  => $Param{TicketID},
            UserID    => $Param{UserID},
            NewUserID => $Param{Config}->{New}->{OwnerID},
        );
    }

    # set new responsible
    if ( $Param{Config}->{New}->{Responsible} ) {
        if ( $Self->{NoticeSTDOUT} ) {
            print
                "  - set responsible of Ticket $Ticket to '$Param{Config}->{New}->{Responsible}'\n";
        }
        $TicketObject->TicketResponsibleSet(
            TicketID => $Param{TicketID},
            UserID   => $Param{UserID},
            NewUser  => $Param{Config}->{New}->{Responsible},
        );
    }
    if ( $Param{Config}->{New}->{ResponsibleID} ) {
        if ( $Self->{NoticeSTDOUT} ) {
            print
                "  - set responsible id of Ticket $Ticket to '$Param{Config}->{New}->{ResponsibleID}'\n";
        }
        $TicketObject->TicketResponsibleSet(
            TicketID  => $Param{TicketID},
            UserID    => $Param{UserID},
            NewUserID => $Param{Config}->{New}->{ResponsibleID},
        );
    }

    # set new lock
    if ( $Param{Config}->{New}->{Lock} ) {
        if ( $Self->{NoticeSTDOUT} ) {
            print "  - set lock of Ticket $Ticket to '$Param{Config}->{New}->{Lock}'\n";
        }
        $TicketObject->TicketLockSet(
            TicketID => $Param{TicketID},
            UserID   => $Param{UserID},
            Lock     => $Param{Config}->{New}->{Lock},
        );
    }
    if ( $Param{Config}->{New}->{LockID} ) {
        if ( $Self->{NoticeSTDOUT} ) {
            print "  - set lock id of Ticket $Ticket to '$Param{Config}->{New}->{LockID}'\n";
        }
        $TicketObject->TicketLockSet(
            TicketID => $Param{TicketID},
            UserID   => $Param{UserID},
            LockID   => $Param{Config}->{New}->{LockID},
        );
    }

    return 1;
}

1;