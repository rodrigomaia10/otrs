# --
# Kernel/System/Console/Command/Maint/Kanban/KanbanReorder.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --
        
package Kernel::System::Console::Command::Maint::Kanban::KanbanReorder;

use strict;
use warnings;

use Kernel::Language qw(Translatable);
use Kernel::System::VariableCheck (qw(:all));

use parent qw(Kernel::System::Console::BaseCommand);

our @ObjectDependencies = (
    'Kernel::System::Main',
    'Kernel::System::Package',
);

sub Configure {
    my ( $Self, %Param ) = @_;

    $Self->Description('Check if kanban need to reorder.');

    return;
}

sub Run {
    my ( $Self, %Param ) = @_;
    my $KanbanObject = $Kernel::OM->Get('Kernel::System::Kanban');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');
    my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');
    my $IndexTickets = $ConfigObject->Get('Kanban::Core::IndexTickets');

    if($IndexTickets eq '0'){
        $Self->Print("<yellow>Checking tickets to kanban ...</yellow>\n");

        my @KanbansBoards = $KanbanObject->BoardsList(
            ValidID => 1,
        );

        for my $BoardID (@KanbansBoards){

            my $Board = $KanbanObject->BoardsGet(
                ID => $BoardID
            );
        
            my @AssociatedColumn = split /,/, $Board->{AssociatedColumn};

            COLUMN:
            for my $ColumnID (@AssociatedColumn){

                my $KanbanColumn = $KanbanObject->KanbanGet(
                    ID => $ColumnID  
                );

                my $ProfileSearch =  $Self->_GetSearchProfiles(
                    ColumnsEnabled => $KanbanColumn->{Search},
                );

                my @TicketIDs = $TicketObject->TicketSearch(
                    Result => 'ARRAY',
                    Limit => $KanbanColumn->{LimitValue},
                    UserID => 1,
                    ContentSearchPrefix => '*',
                    ContentSearchSuffix => '*',
                    FullTextIndex       => 1,
                    %{$ProfileSearch->{ ProfileSearch }},
				    %{$ProfileSearch->{ DynamicFieldSearch }},
                );

                my $JSONStringTickets = $JSONObject->Encode(
                    Data     => \@TicketIDs,
                    SortKeys => 1,         
                    Pretty => 1,          
                );

                my %Boards = $KanbanObject->ColumnOrdinanceGet(
                    BoardID => $BoardID,
                    ColumnID => $ColumnID 
                );

                my $OrderOfTickets = $JSONObject->Decode(
                    Data     => $Boards{OrderOfTickets} ,
                    SortKeys => 1,         
                    Pretty => 1,          
                );

                # Verify if is not in ticket search
                my $CountPosition = 0;

                # POSITION:
                # for $_ (@{$OrderOfTickets}){
                #     $CountPosition++;

                #     if( $_ ~~ @TicketIDs ){
                        
                #         next POSITION;

                #     }else{
                #         my %to_delete = map { $_ => 1 }   $_ ;
                #         @{$OrderOfTickets} = grep { ! $to_delete{$_} } @{$OrderOfTickets};
                #     }
                # }

                POSITION:
                for my $OrderTicketID (@{$OrderOfTickets}){
                    $CountPosition++;
                
                    for my $TicketID ( @TicketIDs ){
                        if( $OrderTicketID eq $TicketID ){
                            
                            next POSITION;

                        }else{
                            my %to_delete = map { $OrderTicketID => 1 }   $OrderTicketID ;
                            @{$OrderOfTickets} = grep { ! $to_delete{$OrderTicketID} } @{$OrderOfTickets};
                        }
                    }

                }

                my @NewTickes;

                # POSITIONTICKETSEARCH:
                # for $_ (@TicketIDs){ 

                #     if( $_ ~~ @{$OrderOfTickets} ){
                        
                #         next POSITIONTICKETSEARCH;

                #     }else{
                #         push @NewTickes, $_;
                #     }
                # }

                POSITIONTICKETSEARCH:
                for my $TicketIDSearch ( @TicketIDs ){ 

                    for my $OrderTicket ( @{$OrderOfTickets} ){
                        if( $OrderTicket eq $TicketIDSearch ){
                            
                            next POSITIONTICKETSEARCH;

                        }else{
                            push @NewTickes, $TicketIDSearch;
                        }
                    }
                    
                }
        

            

                push(@{$OrderOfTickets}, @NewTickes);

                if(scalar @{$OrderOfTickets} > 0){
                    my $TicketsInOrder;
                    if( $KanbanColumn->{Ordination} eq 'Priority'){
                        $TicketsInOrder = $KanbanObject->OrderTicketsByPriority(
                            TicketIDs => \@{$OrderOfTickets},
                            SeverityOrder => $KanbanColumn->{SeverityOrder},
                            ManualOrdination => $KanbanColumn->{ManualSorting},
                            BoardID =>	$BoardID,
                            ColumnID => $KanbanColumn->{ID},
                        );
        
                    }
                    elsif( $KanbanColumn->{Ordination} eq 'Age'){
                        $TicketsInOrder = $KanbanObject->OrderTicketsByAge(
                            TicketIDs => \@{$OrderOfTickets},
                            SeverityOrder => $KanbanColumn->{SeverityOrder},
                            ManualOrdination => $KanbanColumn->{ManualSorting},
                            BoardID =>	$BoardID,
                            ColumnID => $KanbanColumn->{ID},
                        );
                    }
                    elsif( $KanbanColumn->{Ordination} eq 'Solution SLA' ){
                        $TicketsInOrder = $KanbanObject->OrderSolutionSLA(
                            TicketIDs => \@{$OrderOfTickets},
                            SeverityOrder => $KanbanColumn->{SeverityOrder},
                            ManualOrdination => $KanbanColumn->{ManualSorting},
                            BoardID =>	$BoardID,
                            ColumnID => $KanbanColumn->{ID},
                        );
                    }
                    else{                    
                        # By Dynamic Field 
                        $TicketsInOrder = $KanbanObject->OrderTicketsByDynamicField(
                            TicketIDs => \@{$OrderOfTickets},
                            SeverityOrder => $KanbanColumn->{SeverityOrder},
                            DynamicFieldName =>  $KanbanColumn->{Ordination},
                            ManualOrdination => $KanbanColumn->{ManualSorting},
                            BoardID =>	$BoardID,
                            ColumnID => $KanbanColumn->{ID},
                        );
                    }

                    my $JSONStringOfTickets = $JSONObject->Encode(
                        Data     => $TicketsInOrder,
                        SortKeys => 1,        
                        Pretty => 1,           
                    );

                    # To save the order of tickets in database
                    my $NewColumnOrdinanceAdd = $KanbanObject->ColumnOrdinanceAdd(
                        BoardID        => $BoardID, 
                        ColumnID       => $KanbanColumn->{ID},
                        OrderOfTickets => $JSONStringOfTickets,            
                    );
                    

                    # Update the dynmaicfield value to new column
                    my $SucessToSetDFField = $KanbanObject->TicketSetDynamicFieldPosition(
                        TicketPosition => $TicketsInOrder,
                    );

                }

            }     

        }
    }else{
        $Self->Print("<yellow>Kanban configured to be sorted in real time.</yellow>\n"); 
    }

    $Self->Print("<green>Done.</green>\n");
    return $Self->ExitCodeOk();
}

sub _GetSearchProfiles {
	my ( $Self, %Param ) = @_;

	my $SearchProfileObject = $Kernel::OM->Get('Kernel::System::SearchProfile');
	my $UserObject          = $Kernel::OM->Get('Kernel::System::User');
	my $ConfigObject        = $Kernel::OM->Get('Kernel::Config');
	my $DynamicFieldObject  = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $BackendObject       = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
	my $ParamObject         = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $LayoutObject        = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $TicketObject        = $Kernel::OM->Get('Kernel::System::Ticket');
	my $JSONObject          = $Kernel::OM->Get('Kernel::System::JSON');
	my $KanbanObject        = $Kernel::OM->Get('Kernel::System::Kanban');
    
	my $Config = $ConfigObject->Get("Ticket::Frontend::AgentTicketSearch");

	my %ProfileData;
	my %ProfileUserPermission;
	my @ProfileSearch;

    my $DynamicFieldFilter = $Config->{DynamicField};
    my $SearchLimit = $Config->{SearchLimit};

    # get the dynamic fields for ticket object
    my $DynamicField = $DynamicFieldObject->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => [ 'Ticket', 'Article' ],
        FieldFilter => $DynamicFieldFilter || {},
    );

	my $Config = $ConfigObject->Get("Ticket::Frontend::AgentTicketSearch");

    my %GetParam;

    %GetParam = %{$Param{ColumnsEnabled}};

    # get article create time option
    if ( !$GetParam{ArticleTimeSearchType} ) {
        $GetParam{'ArticleTimeSearchType::None'} = 1;
    }
    elsif ( $GetParam{ArticleTimeSearchType} eq 'TimePoint' ) {
        $GetParam{'ArticleTimeSearchType::TimePoint'} = 1;
    }
    elsif ( $GetParam{ArticleTimeSearchType} eq 'TimeSlot' ) {
        $GetParam{'ArticleTimeSearchType::TimeSlot'} = 1;
    }

    # get create time option
    if ( !$GetParam{TimeSearchType} ) {
        $GetParam{'TimeSearchType::None'} = 1;
    }
    elsif ( $GetParam{TimeSearchType} eq 'TimePoint' ) {
        $GetParam{'TimeSearchType::TimePoint'} = 1;
    }
    elsif ( $GetParam{TimeSearchType} eq 'TimeSlot' ) {
        $GetParam{'TimeSearchType::TimeSlot'} = 1;
    }

    # get change time option
    if ( !$GetParam{ChangeTimeSearchType} ) {
        $GetParam{'ChangeTimeSearchType::None'} = 1;
    }
    elsif ( $GetParam{ChangeTimeSearchType} eq 'TimePoint' ) {
        $GetParam{'ChangeTimeSearchType::TimePoint'} = 1;
    }
    elsif ( $GetParam{ChangeTimeSearchType} eq 'TimeSlot' ) {
        $GetParam{'ChangeTimeSearchType::TimeSlot'} = 1;
    }

    # get last change time option
    if ( !$GetParam{LastChangeTimeSearchType} ) {
        $GetParam{'LastChangeTimeSearchType::None'} = 1;
    }
    elsif ( $GetParam{LastChangeTimeSearchType} eq 'TimePoint' ) {
        $GetParam{'LastChangeTimeSearchType::TimePoint'} = 1;
    }
    elsif ( $GetParam{LastChangeTimeSearchType} eq 'TimeSlot' ) {
        $GetParam{'LastChangeTimeSearchType::TimeSlot'} = 1;
    }

    # get close time option
    if ( !$GetParam{CloseTimeSearchType} ) {
        $GetParam{'CloseTimeSearchType::None'} = 1;
    }
    elsif ( $GetParam{CloseTimeSearchType} eq 'TimePoint' ) {
        $GetParam{'CloseTimeSearchType::TimePoint'} = 1;
    }
    elsif ( $GetParam{CloseTimeSearchType} eq 'TimeSlot' ) {
        $GetParam{'CloseTimeSearchType::TimeSlot'} = 1;
    }

    # get escalation time option
    if ( !$GetParam{EscalationTimeSearchType} ) {
        $GetParam{'EscalationTimeSearchType::None'} = 1;
    }
    elsif ( $GetParam{EscalationTimeSearchType} eq 'TimePoint' ) {
        $GetParam{'EscalationTimeSearchType::TimePoint'} = 1;
    }
    elsif ( $GetParam{EscalationTimeSearchType} eq 'TimeSlot' ) {
        $GetParam{'EscalationTimeSearchType::TimeSlot'} = 1;
    }

    my %TimeMap = (
        ArticleCreate    => 'ArticleTime',
        TicketCreate     => 'Time',
        TicketChange     => 'ChangeTime',
        TicketLastChange => 'LastChangeTime',
        TicketClose      => 'CloseTime',
        TicketEscalation => 'EscalationTime',
    );

    for my $TimeType ( sort keys %TimeMap ) {

        # get create time settings
        if ( !$GetParam{ $TimeMap{$TimeType} . 'SearchType' } ) {

            # do nothing with time stuff
        }
        elsif ( $GetParam{ $TimeMap{$TimeType} . 'SearchType' } eq 'TimeSlot' ) {
            for my $Key (qw(Month Day)) {
                $GetParam{ $TimeType . 'TimeStart' . $Key }
                    = sprintf( "%02d", $GetParam{ $TimeType . 'TimeStart' . $Key } );
                $GetParam{ $TimeType . 'TimeStop' . $Key }
                    = sprintf( "%02d", $GetParam{ $TimeType . 'TimeStop' . $Key } );
            }
            if (
                $GetParam{ $TimeType . 'TimeStartDay' }
                && $GetParam{ $TimeType . 'TimeStartMonth' }
                && $GetParam{ $TimeType . 'TimeStartYear' }
                )
            {
                $GetParam{ $TimeType . 'TimeNewerDate' } = $GetParam{ $TimeType . 'TimeStartYear' } . '-'
                    . $GetParam{ $TimeType . 'TimeStartMonth' } . '-'
                    . $GetParam{ $TimeType . 'TimeStartDay' }
                    . ' 00:00:00';
            }
            if (
                $GetParam{ $TimeType . 'TimeStopDay' }
                && $GetParam{ $TimeType . 'TimeStopMonth' }
                && $GetParam{ $TimeType . 'TimeStopYear' }
                )
            {
                $GetParam{ $TimeType . 'TimeOlderDate' } = $GetParam{ $TimeType . 'TimeStopYear' } . '-'
                    . $GetParam{ $TimeType . 'TimeStopMonth' } . '-'
                    . $GetParam{ $TimeType . 'TimeStopDay' }
                    . ' 23:59:59';
            }
        }
        elsif ( $GetParam{ $TimeMap{$TimeType} . 'SearchType' } eq 'TimePoint' ) {
            if (
                $GetParam{ $TimeType . 'TimePoint' }
                && $GetParam{ $TimeType . 'TimePointStart' }
                && $GetParam{ $TimeType . 'TimePointFormat' }
                )
            {
                my $Time = 0;
                if ( $GetParam{ $TimeType . 'TimePointFormat' } eq 'minute' ) {
                    $Time = $GetParam{ $TimeType . 'TimePoint' };
                }
                elsif ( $GetParam{ $TimeType . 'TimePointFormat' } eq 'hour' ) {
                    $Time = $GetParam{ $TimeType . 'TimePoint' } * 60;
                }
                elsif ( $GetParam{ $TimeType . 'TimePointFormat' } eq 'day' ) {
                    $Time = $GetParam{ $TimeType . 'TimePoint' } * 60 * 24;
                }
                elsif ( $GetParam{ $TimeType . 'TimePointFormat' } eq 'week' ) {
                    $Time = $GetParam{ $TimeType . 'TimePoint' } * 60 * 24 * 7;
                }
                elsif ( $GetParam{ $TimeType . 'TimePointFormat' } eq 'month' ) {
                    $Time = $GetParam{ $TimeType . 'TimePoint' } * 60 * 24 * 30;
                }
                elsif ( $GetParam{ $TimeType . 'TimePointFormat' } eq 'year' ) {
                    $Time = $GetParam{ $TimeType . 'TimePoint' } * 60 * 24 * 365;
                }
                if ( $GetParam{ $TimeType . 'TimePointStart' } eq 'Before' ) {

                    # more than ... ago
                    $GetParam{ $TimeType . 'TimeOlderMinutes' } = $Time;
                }
                elsif ( $GetParam{ $TimeType . 'TimePointStart' } eq 'Next' ) {

                    # within next
                    $GetParam{ $TimeType . 'TimeNewerMinutes' } = 0;
                    $GetParam{ $TimeType . 'TimeOlderMinutes' } = -$Time;
                }
                else {

                    # within last ...
                    $GetParam{ $TimeType . 'TimeOlderMinutes' } = 0;
                    $GetParam{ $TimeType . 'TimeNewerMinutes' } = $Time;
                }
            }
        }
    }

    # Special behavior for the fulltext search toolbar module:
    # - Check full text string to see if contents is a ticket number.
    # - If exists and not in print or CSV mode, redirect to the ticket.
    # See http://bugs.otrs.org/show_bug.cgi?id=4238 for details.
    #   The original problem was that tickets with customer reply will be
    #   found by a fulltext search (ticket number is in the subjects), but
    #   'new' tickets will not be found.
    if (
        $GetParam{Fulltext}
        && $ParamObject->GetParam( Param => 'CheckTicketNumberAndRedirect' )
        && $GetParam{ResultForm} ne 'Normal'
        && $GetParam{ResultForm} ne 'Print'
        )
    {
        my $TicketID = $TicketObject->TicketIDLookup(
            TicketNumber => $GetParam{Fulltext},
            UserID       => $Self->{UserID},
        );
        if ($TicketID) {
            return $LayoutObject->Redirect(
                OP => "Action=AgentTicketZoom;TicketID=$TicketID",
            );
        }
    }

    # prepare full text search
    if ( $GetParam{Fulltext} ) {
        $GetParam{ContentSearch} = 'OR';
        for my $Key (qw(From To Cc Subject Body)) {
            $GetParam{$Key} = $GetParam{Fulltext};
        }
    }

    # prepare archive flag
    if ( $ConfigObject->Get('Ticket::ArchiveSystem') ) {

        $GetParam{SearchInArchive} ||= '';
        if ( $GetParam{SearchInArchive} eq 'AllTickets' ) {
            $GetParam{ArchiveFlags} = [ 'y', 'n' ];
        }
        elsif ( $GetParam{SearchInArchive} eq 'ArchivedTickets' ) {
            $GetParam{ArchiveFlags} = ['y'];
        }
        else {
            $GetParam{ArchiveFlags} = ['n'];
        }
    }

        # dynamic fields search parameters for ticket search
    my %DynamicFieldSearchParameters;

    # cycle trough the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicField} ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        # get search field preferences
        my $SearchFieldPreferences = $BackendObject->SearchFieldPreferences(
            DynamicFieldConfig => $DynamicFieldConfig,
        );

        next DYNAMICFIELD if !IsArrayRefWithData($SearchFieldPreferences);

        PREFERENCE:
        for my $Preference ( @{$SearchFieldPreferences} ) {

            # extract the dynamic field value from the profile
            my $SearchParameter = $BackendObject->SearchFieldParameterBuild(
                DynamicFieldConfig => $DynamicFieldConfig,
                Profile            => \%GetParam,
                LayoutObject       => $LayoutObject,
                Type               => $Preference->{Type},
            );

            # set search parameter
            if ( defined $SearchParameter ) {
                $DynamicFieldSearchParameters{ 'DynamicField_' . $DynamicFieldConfig->{Name} }
                    = $SearchParameter->{Parameter};
            }
        }
        
    }

    my %Return;

    %Return = (
        ProfileSearch => \%GetParam,
        DynamicFieldSearch => \%DynamicFieldSearchParameters ,
    );

	return \%Return;

}
1;
