# --
# Kernel/System/Kanban.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * dsilva@serviceup.com.br
# --

package Kernel::System::Kanban;

use strict;
use warnings;
use List::MoreUtils qw(uniq);
use utf8;
use Kernel::System::VariableCheck (qw(:all));

our @ObjectDependencies = (
    'Kernel::System::Cache',
    'Kernel::System::CheckItem',
    'Kernel::System::Log',
    'Kernel::System::Valid',
);

=head1 NAME

Kernel::System::Kanban

=head1 SYNOPSIS

All Kanban module functions.

=head1 PUBLIC INTERFACE

=head2 new()

create an object

    my $KanbanObject = $Kernel::OM->Get('Kernel::System::Kanban');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{CacheType} = 'InBoxKanban';
    $Self->{CacheTTL}  = 60 * 60 * 24 * 20;


    return $Self;
}

=head2 KanbanList()

return a KanbanID list as ref array

my $Kanbans = $KanbanObject->KanbanList();

Return
    @Kanbans = [ 1, 2, 3 ]
=cut

sub KanbanList {
    my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

	my $SQL = 'SELECT id FROM kanban';

    # get Kanban
    return if !$DBObject->Prepare(
        SQL => $SQL,
    );

    # fetch the result
    my @Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		push @Data, $Row[0];
    }

    return \@Data;
    
}

=head2 ValidKanbanList()

return a valid KanbanID list as ref array

my $Kanbans = $KanbanObject->ValidKanbanList();

Return
    @Kanbans = [ 1, 2, 3 ]

=cut

sub ValidKanbanList {
    my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

	my $SQL = 'SELECT id FROM kanban WHERE valid_id = 1';

    # get Kanban
    return if !$DBObject->Prepare(
        SQL => $SQL,
    );

    # fetch the result
    my @Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		push @Data, $Row[0];
    }

    return \@Data;
}

=head2 KanbanLookup()

return a KanbanID

  my $Kanbans = $KanbanObject->KanbanLookup(
        Name => 'Kanban Name'
    );

Return
    $KanbanID = 1

=cut

sub KanbanLookup {
    my ( $Self, %Param ) = @_;

    if ( !$Param{Name} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need Name!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

	my $SQL = 'SELECT id FROM kanban WHERE name = ?';

    # get Kanban
    return if !$DBObject->Prepare(
        SQL => $SQL,
		Bind =>[
			\$Param{Name},
		]
    );

    # fetch the result
    my $Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data = $Row[0];
    }

    return $Data;
}

=head2 KanbanTagLookup()

return a KanbanTagLookup

    my $Kanbans = $KanbanObject->KanbanTagLookup(
        Name => 'Kanban Name'
    );

Return
    $KanbanID = 1

=cut

sub KanbanTagLookup {
    my ( $Self, %Param ) = @_;

    if ( !$Param{Name} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need Name!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

	my $SQL = 'SELECT id FROM kanban_tags WHERE name = ?';

    # get Kanban
    return if !$DBObject->Prepare(
        SQL => $SQL,
		Bind =>[
			\$Param{Name},
		],
        Limit => 1
    );

    # fetch the result
    my $Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data = $Row[0];
    }

    return $Data;
}

=head2 KanbanLookupByID()

return a Kanban NAME

Return
    $KanbanID = 1

    my $Kanbans = $KanbanObject->KanbanLookupByID(
        ID => 'Kanban '
    );

=cut

sub KanbanLookupByID {
    my ( $Self, %Param ) = @_;

    if ( !$Param{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need ID!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

	my $SQL = 'SELECT name FROM kanban WHERE id = ?';

    # get Kanban
    return if !$DBObject->Prepare(
        SQL => $SQL,
		Bind =>[
			\$Param{ID},
		]
    );

    # fetch the result
    my $Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data = $Row[0];
    }

    return $Data;
}
=head2 KanbanDelete()

delete Kanban

Return
    $Success = 1 | 0

    my $Kanbans = $KanbanObject->KanbanDelete(
        ID => 1 # Kanban ID
    );

=cut

sub KanbanDelete {
    my ( $Self, %Param ) = @_;

    if ( !$Param{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need ID!",
        );
        return;
    }

    # create new db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            DELETE FROM kanban WHERE id = ?',
        Bind => [
            \$Param{ID},
        ],
    );

    return 1;
}

=head2 KanbanGet()

get Kanban

Return
    %Kanban = {
        ID            => 1,
        Name          => 'Kanban Name',
        Groups        => ['admin', 'users'],
        Search        => JSON string for search
        ValidID       => 1
        LimitValue  =>  1
        StateToMove      => '0'
        QueueToMove      => '50'
        Rules         => JSON string for rules
        SeverityOrder => 'Ascending' # options ('Ascending' | 'Descendant')
        CreateBy => 'Ascending' # options ('Ascending' | 'Descendant')
        ManualSorting => 1
        Ordination => "Ordinaton"
        ButtonsIDs => "Ordinaton"
    }

    my $Kanbans = $KanbanObject->KanbanGet(
        ID => 1 # Kanban ID
    );

=cut

sub KanbanGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need ID!",
        );
        return;
    }


    # get database object
    my $DBObject   = $Kernel::OM->Get('Kernel::System::DB');
    my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');

    # get Kanban
    return if !$DBObject->Prepare(
        SQL => 'SELECT id, name, group_ids, search, valid_id, severity_order, ordination, limit_columm, manual_sorting, create_by, create_time, queue_to_move, state_to_move, buttons_card, start_collapsed, preview_only, priority_to_move FROM kanban WHERE id = ?',
		Bind => [ \$Param{ID} ],
    );

    # fetch the result
    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data{ID}            = $Row[0];
		$Data{Name}          = $Row[1];
		@{$Data{Groups}}     = split /,/, $Row[2];
		$Data{Search}        = $JSONObject->Decode( Data => $Row[3] );
		$Data{ValidID}       = $Row[4];
		$Data{SeverityOrder} = $Row[5];
		$Data{Ordination}    = $Row[6];
		$Data{LimitValue}    = $Row[7];
		$Data{ManualSorting} = $Row[8];
		$Data{CreateBy}      = $Row[9];
		$Data{CreateTime}    = $Row[10];
		$Data{QueueToMove}   = $Row[11];
		$Data{StateToMove}   = $Row[12];
        if($Row[13]){
		    @{$Data{ButtonsIDs}}   = split /,/, $Row[13];
        }
        $Data{StartCollapsed} = $Row[14];
        $Data{PreviewOnly}    = $Row[15];
        $Data{PriorityToMove} = $Row[16];

    }

    return \%Data;
}

=head2 KanbanGetNewQueueAndState()

get Column queue and state to move card

Return
    %ColumnData = {
        QueueToMove   => 'Postmaster',
        StateToMove   => 'open',
        Ordination    => ''
    }

    my $ColumnData = $KanbanObject->KanbanGetNewQueueAndState(
        ID => 1 # Kanban ID
    );

=cut

sub KanbanGetNewQueueAndState {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need ID!",
        );
        return;
    }

    # get database object
    my $DBObject   = $Kernel::OM->Get('Kernel::System::DB');

    # get Kanban
    return if !$DBObject->Prepare(
        SQL => 'SELECT queue_to_move, state_to_move, manual_sorting, ordination, priority_to_move FROM kanban WHERE id = ?',
		Bind => [ \$Param{ID} ],
    );

    # fetch the result
    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
	    $Data{QueueToMove}    = $Row[0];
		$Data{StateToMove}    = $Row[1];
		$Data{ManualSorting}  = $Row[2];
		$Data{Ordination}     = $Row[3];
		$Data{PriorityToMove} = $Row[4];
    }

    return \%Data;
}

=head2 KanbanGetByName()

get Kanban by name

Return
    %Kanban = {
        ID            => 1,
        Name          => 'Kanban Name',
        ObjectType    => 'Ticket',
        Groups        => ['admin', 'users'],
        Search        => JSON string for search
        ValidID       => 1
        ReturnFormat  => 'normal' # options ('normal' | 'excel')
        MinValue      => '0'
        MaxValue      => '50'
        Rules         => JSON string for rules
        SeverityOrder => 'Ascending' # options ('Ascending' | 'Descendant')
    }

    my $Kanbans = $KanbanObject->KanbanGetByName(
        Name => 1 
    );

=cut


sub KanbanGetByName {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{Name} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need Name!",
        );
        return;
    }  

    # get database object
    my $DBObject   = $Kernel::OM->Get('Kernel::System::DB');
    my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');

    # get Kanban
    return if !$DBObject->Prepare(
        SQL => 'SELECT id, name, group_ids, search, valid_id, severity_order, ordination, limit_columm, manual_sorting, create_by, create_time, queue_to_move, state_to_move, buttons_card, start_collapsed, preview_only, priority_to_move FROM kanban WHERE name = ?',
		Bind => [ \$Param{Name} ],
    );

    # fetch the result
    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data{ID}            = $Row[0];
		$Data{Name}          = $Row[1];
		@{$Data{Groups}}     = split /,/, $Row[2];
		$Data{Search}        = $JSONObject->Decode( Data => $Row[3] );
		$Data{ValidID}       = $Row[4];
		$Data{SeverityOrder} = $Row[5];
		$Data{Ordination}    = $Row[6];
		$Data{LimitValue}    = $Row[7];
		$Data{ManualSorting} = $Row[8];
		$Data{CreateBy}      = $Row[9];
		$Data{CreateTime}    = $Row[10];
		$Data{QueueToMove}   = $Row[11];
		$Data{StateToMove}   = $Row[12];
		$Data{ButtonsIDs}    = $Row[13];
		$Data{StartCollapsed} = $Row[14];
		$Data{PreviewOnly}    = $Row[15];
		$Data{PriorityToMove} = $Row[16];
    }
    
    return if !$Data{ID};

    return \%Data;
}

=head2 KanbanUpdate()

update Kanban

Return
    $Success = 1 | 0

    my $Kanbans = $KanbanObject->KanbanUpdate(
        ID            => 1, # Kanban iD
        Name          => 'Kanban Name',
        ObjectType    => 'Ticket',
        Groups        => ['admin', 'users'],
        Search        => JSON string for search
        ValidID       => 1
        SeverityOrder => 'Ascending' # options ('Ascending' | 'Descendant')
        ButtonsIDs => ['teste']
        PreviewOnly => 1
    );

=cut

sub KanbanUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(ID Name)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

	my $JSONSearch = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->JSONEncode(
        Data        => $Param{Search},
    );

    # sql
    return if !$DBObject->Do(
        SQL => 'UPDATE kanban SET name = ?, group_ids = ?, search = ?, valid_id = ?, severity_order = ?, ordination = ?, limit_columm = ?, manual_sorting = ?,  queue_to_move = ?, state_to_move = ?, buttons_card = ?, start_collapsed = ?, preview_only = ?,  priority_to_move = ? WHERE id = ?',
        Bind => [
            \$Param{Name}, \$Param{GroupIDs}, \$JSONSearch, \$Param{ValidID}, \$Param{SeverityOrder}, \$Param{Ordination}, \$Param{Limit}, \$Param{ManualSorting}, \$Param{QueueToMove},\$Param{StateToMove}, \$Param{ButtonsIDs}, \$Param{StartCollapsed}, \$Param{PreviewOnly},\$Param{PriorityToMove}, \$Param{ID}
        ],
    );

    return 1;
}

=head2 KanbanAdd()

add Kanban collumn

Return
    $Success = 1 | 0

    my $Kanbans = $KanbanObject->KanbanAdd(
        Name          => 'Kanban Name',
        Groups        => ['admin', 'users'],
        Search        => JSON string for search
        ValidID       => 1
        Limit         => 1
        SeverityOrder => 'Ascending' # options ('Ascending' | 'Descendant')
        Ordination    => 'SLA' # options ('SLA' | 'Priority' | 'Age')
        ManualSorting    => 0
        UserID    => 0,
        ButtonsIDs    => 0,
    );

=cut

sub KanbanAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(Name UserID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

	my $JSONSearch = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->JSONEncode(
        Data        => $Param{Search},
    );

	my $JSONRules = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->JSONEncode(
        Data        => $Param{Rules},
    );

    # create new db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            INSERT INTO kanban (name, group_ids, buttons_card, start_collapsed, preview_only, search, valid_id,  severity_order, ordination, limit_columm, manual_sorting, create_by, create_time, queue_to_move , state_to_move, priority_to_move) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?,  ?, ?, current_timestamp, ?, ?, ?)',
        Bind => [
            \$Param{Name}, \$Param{GroupIDs}, \$Param{ButtonsIDs}, \$Param{StartCollapsed}, \$Param{PreviewOnly}, \$JSONSearch, \$Param{ValidID}, \$Param{SeverityOrder}, \$Param{Ordination},\$Param{Limit},\$Param{ManualSorting},\$Param{UserID},\$Param{QueueToMove},\$Param{StateToMove}, \$Param{PriorityToMove}, 
        ],
    );

    return 1;
}

=head2 TagsList()

return a tags list as array

Return
    @Kanbans = ( 1, 2, 3 )

    my $Kanbans = $KanbanObject->TagsList(
        ValidID = 0; # not required
    );

=cut

sub TagsList {
     my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

	my $SQL = 'SELECT id FROM kanban_tags';
    if ($Param{ValidID}){
        $SQL = "SELECT id FROM kanban_tags WHERE valid_id = $Param{ValidID}";
    }

    # get Kanban indexes
    return if !$DBObject->Prepare(
        SQL => $SQL,
    );

    # fetch the result
    my @Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		push @Data, $Row[0];
    }

    return @Data;
}

=head2 BoardsList()

return a series list as array

Return
    @Kanbans = ( 1, 2, 3 )

    my $Kanbans = $KanbanObject->BoardsList(
        ValidID = 0; # not required
    );

=cut

sub BoardsList {
     my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

	my $SQL = 'SELECT id FROM kanban_board';
    if ($Param{ValidID}){
        $SQL = "SELECT id FROM kanban_board WHERE valid_id = $Param{ValidID}";
    }

    # get Kanban indexes
    return if !$DBObject->Prepare(
        SQL => $SQL,
    );

    # fetch the result
    my @Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		push @Data, $Row[0];
    }

    return @Data;
}

=head2 BoardsListNames()

return a board name list as array

Return
    @Kanbans = ( name )

    my $Kanbans = $KanbanObject->BoardsListNames(
        Valid = 0; # not required
    );

=cut

sub BoardsListNames {
     my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

	my $SQL = 'SELECT name FROM kanban_board';
    if ($Param{ValidID}){
        $SQL = "SELECT name FROM kanban_board WHERE valid_id = $Param{ValidID}";
    }

    # get Kanban indexes
    return if !$DBObject->Prepare(
        SQL => $SQL,
    );

    # fetch the result
    my @Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		push @Data, $Row[0];
    }
    
    return @Data;
}

=head2 ValidBoardsList()

return a series list as array

Return
    @Kanbans = ( 1, 2, 3 )

    my $Kanbans = $KanbanObject->ValidBoardsList();

=cut

sub ValidBoardsList {
     my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

	my $SQL = 'SELECT id FROM kanban_board WHERE valid_id = 1';

    # get Kanban indexes
    return if !$DBObject->Prepare(
        SQL => $SQL,
    );

    # fetch the result
    my @Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		push @Data, $Row[0];
    }

    return @Data;
}



=head2 BoardsLookup()

return a BoardsID

Return
    $BoardsID = 1

    my $Kanbans = $KanbanObject->BoardsLookup(
        Name => 'Boards'
    );

=cut

sub BoardsLookup {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{Name} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need Name!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get Kanban
    return if !$DBObject->Prepare(
        SQL => 'SELECT id FROM kanban_board WHERE name = ?',
		Bind =>[ \$Param{Name} ]
    );

    # fetch the result
    my $Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data = $Row[0];
    }

    return $Data;
}

=head2 BoardsGet()

get Boards

Return
    %Boards = {
        ID             => 1,
        Name           => 'Series Name',
        ValidID        => 1
        AssociatedKanbans => '1,2,3,4', # KanbanIDs associated
        GroupIDs       => '1,2,3,4', # GroupIDs associated
    }

    my $Boards = $KanbanObject->BoardsGet(
        ID => 1 # BoardsID
    );

=cut

sub BoardsGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need ID!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get Kanban
    return if !$DBObject->Prepare(
        SQL => 'SELECT id, name, valid_id, associated_column , groupids,  resource_color, resource_color_label FROM kanban_board WHERE id = ?',
		Bind => [ \$Param{ID} ],
    );

    # fetch the result
    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data{ID}                       = $Row[0];
		$Data{Name}                     = $Row[1];
		$Data{ValidID}                  = $Row[2];
		$Data{AssociatedColumn}         = $Row[3];
		$Data{GroupIDs}                 = $Row[4];
		$Data{Resource_ColorName}       = $Row[5];
		$Data{Resource_ColorNameLabel}  = $Row[6];
    }

    return \%Data;
}

=head2 TagsGet()

get tags

Return
    %Tags = {
        ID             => 1,
        Name           => 'Series Name',
        ValidID        => 1
        AssociatedBoards => '1,2,3,4', # KanbanIDs associated
    }

    my $Tags = $KanbanObject->TagsGet(
        ID => 1 # BoardsID
    );

=cut

sub TagsGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need ID!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get Kanban
    return if !$DBObject->Prepare(
        SQL => 'SELECT id, name, valid_id, associated_boards , tag_color FROM kanban_tags WHERE id = ?',
		Bind => [ \$Param{ID} ],
    );

    # fetch the result
    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data{ID}                       = $Row[0];
		$Data{Name}                     = $Row[1];
		$Data{ValidID}                  = $Row[2];
		$Data{AssociatedBoards}          = $Row[3];
		$Data{Tag_Color}                 = $Row[4];
    }

    return \%Data;
}

=head2 SearchTags()

search tags

Return
    %Tags = {
        ID             => 1,
        Name           => 'Series Name',
        ValidID        => 1
        AssociatedBoards => '1,2,3,4', # KanbanIDs associated
    }

    my $Tags = $KanbanObject->SearchTags(
        BoardID => 1 # BoardsID
    );

=cut

sub SearchTags {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{BoardID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need BoardID!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
    $Param{BoardID} = $DBObject->Quote( $Param{BoardID}, 'Like' );
    my $LikeString = '%' . $Param{BoardID} . '%';

    # get Kanban
    return if !$DBObject->Prepare(
        SQL => 'SELECT id, name, valid_id, associated_boards , tag_color  FROM kanban_tags WHERE associated_boards LIKE ?',
		Bind => [ \$LikeString ],
    );

    # fetch the result
    my @Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        push @Data, {
            ID                       => $Row[0],
            Name                     => $Row[1],
            ValidID                  => $Row[2],
            AssociatedBoards         => $Row[3],
            Tag_Color                => $Row[4]
        };
    }

    return \@Data;
}


=head2 BoardsGetAssociatedKanbans()

get Get Associated Kanbans

Return
    @Boards = [
       '1,2,3,4',
    ]

    my $Boards = $KanbanObject->BoardsGetAssociatedKanbans(
        ID => 1 # BoardsID
    );

=cut

sub BoardsGetAssociatedKanbans {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need ID!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get Kanban
    return if !$DBObject->Prepare(
        SQL => 'SELECT associated_column FROM kanban_board WHERE id = ?',
		Bind => [ \$Param{ID} ],
    );

    # fetch the result
    my $Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data             = $Row[0];	
    }

    return $Data;
}

=head2 TagsAdd()

add Boards

Return
    $Success = 1 | 0

    my $Kanbans = $KanbanObject->TagsAdd(
        Name           => 'Boards Name',
        ValidID        => 1
        AssociatedBoards => '1,2,3,4', # KanbanIDs associated
        Tag_Color => 'color',
    );

=cut

sub TagsAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(Name ValidID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # create new db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => 'INSERT INTO kanban_tags (name, valid_id, associated_boards , tag_color) VALUES (?, ?, ?, ?)',
        Bind => [
            \$Param{Name}, \$Param{ValidID}, \$Param{AssociatedBoards}, \$Param{Tag_Color}, 
        ],
    );

    return 1;
}

=head2 BoardsAdd()

add Boards

Return
    $Success = 1 | 0

    my $Kanbans = $KanbanObject->BoardsAdd(
        Name           => 'Boards Name',
        ValidID        => 1
        AssociatedColumn => '1,2,3,4', # KanbanIDs associated
        GroupIDs       => '1,2,3,4', # GroupIDs associated
        Resource_ColorName => 'color',
        Resource_ColorNameLabel => 'color',
    );

=cut

sub BoardsAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(Name ValidID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # create new db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => 'INSERT INTO kanban_board (name, valid_id, associated_column , groupids, resource_color, resource_color_label) VALUES (?, ?, ?, ?, ?, ?)',
        Bind => [
            \$Param{Name}, \$Param{ValidID}, \$Param{AssociatedColumn}, \$Param{GroupIDs}, \$Param{Resource_ColorName}, \$Param{Resource_ColorNameLabel}
        ],
    );

    return 1;
}

=head2 BoardsUpdate()

update series

Return
    $Success = 1 | 0

    my $Kanbans = $KanbanObject->BoardsUpdate(
        ID             => 1, # SeriesID
        Name           => 'Series Name',
        ValidID        => 1
        AssociatedCollumn => '1,2,3,4', #  associated
        Resource_ColorName => 'color'
        Resource_ColorNameLabel => 'color'
        GroupIDs       => '1,2,3,4', # GroupIDs associated
    );

=cut

sub BoardsUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(ID Name ValidID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # sql
    return if !$DBObject->Do(
        SQL => 'UPDATE kanban_board SET name = ?, valid_id = ? , associated_column = ?, groupids = ?, resource_color = ?, resource_color_label = ? WHERE id = ?',
        Bind => [
            \$Param{Name}, \$Param{ValidID}, \$Param{AssociatedColumn}, \$Param{GroupIDs},  \$Param{Resource_ColorName}, \$Param{Resource_ColorNameLabel}, \$Param{ID}
        ],
    );

    return 1;
}

=head2 TagsUpdate()

update tags

Return
    $Success = 1 | 0

    my $Kanbans = $KanbanObject->TagsUpdate(
        ID             => 1, # SeriesID
        Name           => 'Series Name',
        ValidID        => 1
        AssociatedBoards => '1,2,3,4', #  associated
        Tag_Color => 'color'   
    );

=cut

sub TagsUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(ID Name ValidID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # sql
    return if !$DBObject->Do(
        SQL => 'UPDATE kanban_tags SET name = ?, valid_id = ? , associated_boards = ?,tag_color = ? WHERE id = ?',
        Bind => [
            \$Param{Name}, \$Param{ValidID}, \$Param{AssociatedBoards}, \$Param{Tag_Color}, \$Param{ID}
        ],
    );

    return 1;
}

=head2 ColumnOrdinanceAdd()

add kanban column ordinance informations

Return
    $Success = 1 | 0

    my $ColumnOrdinance = $KanbanObject->ColumnOrdinanceAdd(
        BoardID        => 1,
        ColumnID       => 1,
        OrderOfTickets => '1,2,3,4', #Order of tickets associates in the column
      
    );

=cut

sub ColumnOrdinanceAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(BoardID ColumnID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # create new db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => 'INSERT INTO kanban_column_ordinance (board_id, column_id, order_of_tickets) VALUES (?, ?, ?)',
        Bind => [
            \$Param{BoardID}, \$Param{ColumnID}, \$Param{OrderOfTickets}
        ],
    );

    return 1;
}

=head2 ColumnOrdinanceUpdate()

update series

Return
    $Success = 1 | 0

    my $ColumnOrdinance = $KanbanObject->ColumnOrdinanceUpdate(
        BoardID        => 1,
        ColumnID       => 1,
        OrderOfTickets => ['1,2,3,4'], #Order of tickets associates in the column
    );

=cut

sub ColumnOrdinanceUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(BoardID ColumnID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # sql
    return if !$DBObject->Do(
        SQL => 'UPDATE kanban_column_ordinance SET order_of_tickets = ? WHERE  board_id  = ? AND column_id =?',
        Bind => [
            \$Param{OrderOfTickets}, \$Param{BoardID}, \$Param{ColumnID}
        ],
    );

    return 1;
}

=head2 ColumnOrdinanceGet()

get Column Ordinance

Return
    @Boards = [
       '1,2,3,4',
    ]

    my $Boards = $KanbanObject->ColumnOrdinanceGet(
        BoardID => 1 # BoardsID
        ColumnID => 1 # BoardsID
    );

=cut

sub ColumnOrdinanceGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(BoardID ColumnID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get Kanban
    return if !$DBObject->Prepare(
        SQL => 'SELECT board_id, column_id, order_of_tickets FROM kanban_column_ordinance WHERE board_id = ? AND column_id = ? ',
		Bind => [ \$Param{BoardID},  \$Param{ColumnID}],
    );

    # fetch the result
    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data{BoardID}        = $Row[0];	
		$Data{ColumnID}       = $Row[1];	
		$Data{OrderOfTickets} = $Row[2];	
    }
   
    return %Data;
}

=head2 ColumnOrdinanceDelete()

Delete Column Ordinance

Return
    $Board = 0;

    my $Boards = $KanbanObject->ColumnOrdinanceDelete(
        BoardID => 1 # BoardsID
        ColumnID => 1 # BoardsID
    );

=cut

sub ColumnOrdinanceDelete {
    my ( $Self, %Param ) = @_;

  # check needed stuff
    for my $Argument (qw(BoardID ColumnID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }
    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get Kanban
    return if !$DBObject->Prepare(
        SQL => 'DELETE FROM kanban_column_ordinance WHERE board_id = ? AND column_id = ? ',
		Bind => [ \$Param{BoardID},  \$Param{ColumnID}],
    );

    return 1;
}

=head2 TicketGetOfKanban()

Get ticket info inportant to kanban

    my %Ticket = $KanbanObject->TicketGetOfKanban(
        TicketID      => 123,
    );

Returns:
       
   %Ticket = (
        TicketID       => '123',
        Title              => 'some title',
        PriorityID         => 123,
        LockID           => 123,
        OwnerID           => 123,
        ResponsibleID     => 1,
        Created           => 1,
        TicketNumber           => '20101027000001',
        CustomerCompany => 'SUP',
        CustomerLogin => 'teste'
    );
    

=cut

sub TicketGetOfKanban {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{TicketID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need TicketID!'
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        SQL => '
            SELECT id, title, ticket_priority_id, ticket_lock_id,
                user_id, responsible_user_id, create_time, tn, customer_id, customer_user_id, sla_id
            FROM ticket WHERE id = ?',
        Bind  => [ \$Param{TicketID} ],
        Limit => 1
    );

    my %Ticket;

    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Ticket{TicketID}       = $Row[0];
        $Ticket{Title}          = $Row[1];
        $Ticket{PriorityID}     = $Row[2];
        $Ticket{LockID}         = $Row[3];
        $Ticket{OwnerID}        = $Row[4];
        $Ticket{ResponsibleID}  = $Row[5];  
        $Ticket{Created}        = $Row[6];
        $Ticket{TicketNumber}   = $Row[7];
        $Ticket{CustomerID}     = $Row[8];
        $Ticket{CustomerUserID} = $Row[9];
        $Ticket{SLAID}          = $Row[10];
       
    }

    # check ticket
    if ( !$Ticket{TicketID} ) {
        if ( !$Param{Silent} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "No such TicketID ($Param{TicketID})!",
            );
        }
        return;
    }

    # fillup runtime values
    my $TicketCreatedDTObj = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            String => $Ticket{Created}
        },
    );

    my $Delta = $TicketCreatedDTObj->Delta( DateTimeObject => $Kernel::OM->Create('Kernel::System::DateTime') );
    $Ticket{Age} = $Delta->{AbsoluteSeconds};

    # get lock
    $Ticket{Lock} = $Kernel::OM->Get('Kernel::System::Lock')->LockLookup(
        LockID => $Ticket{LockID},
    );

    # get priority
    $Ticket{Priority} = $Kernel::OM->Get('Kernel::System::Priority')->PriorityLookup(
        PriorityID => $Ticket{PriorityID},
    );

    return %Ticket;
}

=head2 OrderTicketsByPriority()

Order tickets by priority

    $TicketsInOrder = $KanbanObject->OrderTicketsByPriority(
        TicketIDs => \@{$OrderOfTickets},
        SeverityOrder => $KanbanColumn->{SeverityOrder},
        ManualOrdination => $KanbanColumn->{ManualSorting},
        BoardID =>	$BoardID,
        ColumnID => $KanbanColumn->{ID},
    );  

=cut

sub OrderTicketsByPriority {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');

    my @TicketInOrder; 
    my $TicketInOrderManu; 

    # Implements to Manual Ordination
    if($Param{ManualOrdination} eq '1'){

        my %ColumnData = $Self->ColumnOrdinanceGet(
            BoardID  => $Param{BoardID},
            ColumnID => $Param{ColumnID} 
        );
     
        $TicketInOrderManu = $JSONObject->Decode(
            Data => $ColumnData{OrderOfTickets}
        );

        my %Count;
        for my $Element (@{$Param{TicketIDs}}, @{$TicketInOrderManu}) { $Count{$Element}++ }

        my ( @Union, @Intersection, @Difference );
        
        for my $Element (keys %Count) {
            push @Union, $Element;
            push @{ $Count{$Element} > 1 ? \@Intersection : \@Difference }, $Element;
        }

        push @{$TicketInOrderManu}, @Difference;

        my @NewArray;
        # for (@{$TicketInOrderManu}) {
        #     if($_ ~~ @{$Param{TicketIDs}}){
        #         push @NewArray, $_;
        #     }
        # }

        for my $TicketID ( @{$TicketInOrderManu} ) {           
            if ( my ($matched) = grep $_ eq $TicketID, @{$Param{TicketIDs}} ) {
                push @NewArray, $TicketID;
            }
        }

        return \@NewArray;
    }
    else{

        my %TicketAndPriority;
        for my $TicketId (@{$Param{TicketIDs}}){

            my %Ticket = $Self->TicketGetOfKanban(
                TicketID => $TicketId,
            );

            my @PriorityData = split / /, $Ticket{Priority};

            $TicketAndPriority{ $TicketId} = $PriorityData[0] ;     
        }
      
        if($Param{SeverityOrder} eq 'Ascending'){
            foreach my $TicketID (sort { $TicketAndPriority{$a} <=> $TicketAndPriority{$b} } keys %TicketAndPriority) {
                push @TicketInOrder, $TicketID;            
            }
        }else{
            foreach my $TicketID (reverse sort { $TicketAndPriority{$a} <=> $TicketAndPriority{$b} } keys %TicketAndPriority) {
                push @TicketInOrder, $TicketID;            
            }
        }
        return \@TicketInOrder;
    }
}

=head2 OrderTicketsByOwner()

Order tickets by owner

    $TicketsInOrder = $KanbanObject->OrderTicketsByOwner(
        TicketIDs => \@{$OrderOfTickets},
        SeverityOrder => $KanbanColumn->{SeverityOrder},
        ManualOrdination => $KanbanColumn->{ManualSorting},
        BoardID =>	$BoardID,
        ColumnID => $KanbanColumn->{ID},
    );  

=cut

sub OrderTicketsByOwner {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');
    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');

    my @TicketInOrder; 
    my $TicketInOrderManu; 

    # Implements to Manual Ordination
    if($Param{ManualOrdination} eq '1'){
    
        my %ColumnData = $Self->ColumnOrdinanceGet(
            BoardID  => $Param{BoardID},
            ColumnID => $Param{ColumnID} 
        );
     
        $TicketInOrderManu = $JSONObject->Decode(
            Data => $ColumnData{OrderOfTickets}
        );

        my %Count;
        for my $Element (@{$Param{TicketIDs}}, @{$TicketInOrderManu}) { $Count{$Element}++ }

        my ( @Union, @Intersection, @Difference );
        
        for my $Element (keys %Count) {
            push @Union, $Element;
            push @{ $Count{$Element} > 1 ? \@Intersection : \@Difference }, $Element;
        }

        push @{$TicketInOrderManu}, @Difference;

        my @NewArray;
        # for (@{$TicketInOrderManu}) {
        #     if($_ ~~ @{$Param{TicketIDs}}){
        #         push @NewArray, $_;
        #     }
        # }

        for my $TicketID ( @{$TicketInOrderManu} ) {           
            if ( my ($matched) = grep $_ eq $TicketID, @{$Param{TicketIDs}} ) {
                push @NewArray, $TicketID;
            }
        }

        return \@NewArray;
    }
    else{

        my %TicketAndOwner;
        for my $TicketId (@{$Param{TicketIDs}}){

            my %Ticket = $Self->TicketGetOfKanban(
                TicketID => $TicketId,
            );

            my $Name = $UserObject->UserName(
                UserID => $Ticket{OwnerID},
            );

            $TicketAndOwner{ $TicketId} = $Name ;           
        }
      
        if($Param{SeverityOrder} eq 'Ascending'){
            foreach my $TicketID (sort { $TicketAndOwner{$a} cmp $TicketAndOwner{$b} } keys %TicketAndOwner) {          
                push @TicketInOrder, $TicketID;            
            }
        }else{
            foreach my $TicketID (reverse sort { $TicketAndOwner{$a} cmp $TicketAndOwner{$b} } keys %TicketAndOwner) {
                push @TicketInOrder, $TicketID;            
            }
        }
        return \@TicketInOrder;
    }
}

=head2 OrderTicketsByAge()

Order tickets by age

    $TicketsInOrder = $KanbanObject->OrderTicketsByAge(
        TicketIDs => \@{$OrderOfTickets},
        SeverityOrder => $KanbanColumn->{SeverityOrder},
        ManualOrdination => $KanbanColumn->{ManualSorting},
        BoardID =>	$BoardID,
        ColumnID => $KanbanColumn->{ID},
    );  

=cut

sub OrderTicketsByAge {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');

    my @TicketInOrder; 
    my $TicketInOrderManu; 

    # Implements to Manual Ordination
    if($Param{ManualOrdination}  eq '1'){
        my %ColumnData = $Self->ColumnOrdinanceGet(
            BoardID => $Param{BoardID},
            ColumnID => $Param{ColumnID} 
        );

      
        $TicketInOrderManu = $JSONObject->Decode(
            Data => $ColumnData{OrderOfTickets}
        );        

        my %Count;
        for my $Element (@{$Param{TicketIDs}}, @{$TicketInOrderManu}) { $Count{$Element}++ }

        my ( @Union, @Intersection, @Difference );
        
        for my $Element (keys %Count) {
            push @Union, $Element;
            push @{ $Count{$Element} > 1 ? \@Intersection : \@Difference }, $Element;
        }

        push @{$TicketInOrderManu}, @Difference;

        my @NewArray;
        # for (@{$TicketInOrderManu}) {
        #     if($_ ~~ @{$Param{TicketIDs}}){
        #         push @NewArray, $_;
        #     }
        # }

        for my $TicketID ( @{$TicketInOrderManu} ) {           
            if ( my ($matched) = grep $_ eq $TicketID, @{$Param{TicketIDs}} ) {
                push @NewArray, $TicketID;
            }
        }    

        return \@NewArray;
    }else{
        my %TicketAndAge;
        for my $TicketId (@{$Param{TicketIDs}}){
        
            my %Ticket = $Self->TicketGetOfKanban(
                TicketID      => $TicketId,
            );

            $TicketAndAge{ $TicketId} = $Ticket{Age} ; 
    
        }
    
        if($Param{SeverityOrder} eq 'Ascending'){
            foreach my $TicketID (sort { $TicketAndAge{$a} <=> $TicketAndAge{$b} } keys %TicketAndAge) {
                push @TicketInOrder, $TicketID;            
            }
        }else{
            foreach my $TicketID (reverse sort { $TicketAndAge{$a} <=> $TicketAndAge{$b} } keys %TicketAndAge) {
                push @TicketInOrder, $TicketID;            
            }
        }
        
        return \@TicketInOrder;
    }

}


=head2 OrderTicketsByDynamicField()

Order tickets by dynamif field

    $TicketsInOrder = $KanbanObject->OrderTicketsByDynamicField(
        TicketIDs => \@{$OrderOfTickets},
        SeverityOrder => $KanbanColumn->{SeverityOrder},
        ManualOrdination => $KanbanColumn->{ManualSorting},
        BoardID =>	$BoardID,
        ColumnID => $KanbanColumn->{ID},
    );  

=cut
sub OrderTicketsByDynamicField {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');


    my %TicketAndDynamicField;

    my $TicketInOrder; 
    my $TicketInOrderManu; 

    # Implements to Manual Ordination
    if($Param{ManualOrdination} eq '1'){
        my %ColumnData = $Self->ColumnOrdinanceGet(
            BoardID  => $Param{BoardID},
            ColumnID => $Param{ColumnID} 
        );

        $TicketInOrderManu = $JSONObject->Decode(
            Data => $ColumnData{OrderOfTickets}
        );

        my %Count;
        for my $Element (@{$Param{TicketIDs}}, @{$TicketInOrderManu}) { $Count{$Element}++ }

        my ( @Union, @Intersection, @Difference );
        
        for my $Element (keys %Count) {
            push @Union, $Element;
            push @{ $Count{$Element} > 1 ? \@Intersection : \@Difference }, $Element;
        }

        push @{$TicketInOrderManu}, @Difference;

        my @NewArray;
        # for (@{$TicketInOrderManu}) {
        #     if($_ ~~ @{$Param{TicketIDs}}){
        #         push @NewArray, $_;
        #     }
        # }

        for my $TicketID ( @{$TicketInOrderManu} ) {           
            if ( my ($matched) = grep $_ eq $TicketID, @{$Param{TicketIDs}} ) {
                push @NewArray, $TicketID;
            }
        }    

        return \@NewArray;

    }else{
        for my $TicketId (@{$Param{TicketIDs}}){
            
            my %Ticket = $TicketObject->TicketGet(
                TicketID      => $TicketId,
                UserID        => 1,
                DynamicFields => 1,     
            );

            $TicketAndDynamicField{ $TicketId} = $Ticket{"DynamicField_$Param{DynamicFieldName}"} ; 

        }

        my @TicketInOrder; 
        if($Param{SeverityOrder} eq 'Ascending'){
            foreach my $TicketID (sort { $TicketAndDynamicField{$a} <=> $TicketAndDynamicField{$b} } keys %TicketAndDynamicField) {
                push @TicketInOrder, $TicketID;            
            }
        }else{
            foreach my $TicketID (reverse sort { $TicketAndDynamicField{$a} <=> $TicketAndDynamicField{$b} } keys %TicketAndDynamicField) {
                push @TicketInOrder, $TicketID;            
            }
        }

        return \@TicketInOrder;
    }

}

=head2 OrderSolutionSLA()

Order tickets by solution time SLA

    $TicketsInOrder = $KanbanObject->OrderSolutionSLA(
        TicketIDs        => \@{$OrderOfTickets},
        SeverityOrder    => $KanbanColumn->{SeverityOrder},
        ManualOrdination => $KanbanColumn->{ManualSorting},
        BoardID          =>	$BoardID,
        ColumnID         => $KanbanColumn->{ID},
    );  

=cut

sub OrderSolutionSLA {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');
    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');
    my $SLAObject    = $Kernel::OM->Get('Kernel::System::SLA');

    my @TicketInOrder; 
    my $TicketInOrderManu; 

    # Implements to Manual Ordination
    if($Param{ManualOrdination} eq '1'){
    
        my %ColumnData = $Self->ColumnOrdinanceGet(
            BoardID  => $Param{BoardID},
            ColumnID => $Param{ColumnID} 
        );
     
        $TicketInOrderManu = $JSONObject->Decode(
            Data => $ColumnData{OrderOfTickets}
        );

        my %Count;
        for my $Element (@{$Param{TicketIDs}}, @{$TicketInOrderManu}) { $Count{$Element}++ }

        my ( @Union, @Intersection, @Difference );
        
        for my $Element (keys %Count) {
            push @Union, $Element;
            push @{ $Count{$Element} > 1 ? \@Intersection : \@Difference }, $Element;
        }

        push @{$TicketInOrderManu}, @Difference;

        my @NewArray;
        # for (@{$TicketInOrderManu}) {
        #     if($_ ~~ @{$Param{TicketIDs}}){
        #         push @NewArray, $_;
        #     }
        # }

        for my $TicketID ( @{$TicketInOrderManu} ) {           
            if ( my ($matched) = grep $_ eq $TicketID, @{$Param{TicketIDs}} ) {
                push @NewArray, $TicketID;
            }
        }

        return \@NewArray;
    }
    else{

        my %TicketAndSLASolution;

        for my $TicketId (@{$Param{TicketIDs}}){
    
            my %Ticket = $TicketObject->TicketGet(
                TicketID => $TicketId,
                UserID   => 1,
            );

            my %Escalation = $TicketObject->TicketEscalationDateCalculation(
                Ticket => \%Ticket,
                UserID => 1,
            );

            if( !$Ticket{SLAID} ){
                $TicketAndSLASolution{ $TicketId }  = '0';   
            }
            else{

                my %SLAData = $SLAObject->SLAGet(
                    SLAID  => $Ticket{SLAID},
                    UserID => 1,
                );

                my $VB = $SLAData{SolutionTime}*60; 
                my $VA = $Escalation{SolutionTime}; 

                if( !$VA ){
                    $TicketAndSLASolution{ $TicketId }  = '0';   
                }
                else{
                    my $Aux = $VB - $VA;
                    my $PC  = ( ($Aux*100)/ $VB );
                    my $Rounded = sprintf("%.f", $PC);
                    
                    $TicketAndSLASolution{ $TicketId }  = $Rounded;  

                }       
            }
        }
      
        # if($Param{SeverityOrder} eq 'Ascending'){
        #     foreach my $TicketID (sort { $TicketAndSLASolution{$a} cmp $TicketAndSLASolution{$b} } keys %TicketAndSLASolution) {          
        #         push @TicketInOrder, $TicketID;            
        #     }
        # }else{
        #     foreach my $TicketID (reverse sort { $TicketAndSLASolution{$a} cmp $TicketAndSLASolution{$b} } keys %TicketAndSLASolution) {
        #         push @TicketInOrder, $TicketID;            
        #     }
        # }

        if($Param{SeverityOrder} eq 'Ascending'){
            foreach my $TicketID (sort { $TicketAndSLASolution{$a} <=> $TicketAndSLASolution{$b} } keys %TicketAndSLASolution) {
                push @TicketInOrder, $TicketID;            
            }
        }else{
            foreach my $TicketID (reverse sort { $TicketAndSLASolution{$a} <=> $TicketAndSLASolution{$b} } keys %TicketAndSLASolution) {
                push @TicketInOrder, $TicketID;            
            }
        }

        return \@TicketInOrder;
    }
}

=head2 TicketSetDynamicFieldPosition()

Fuction to set the dynamic field 'PositionOnKanbanBoard' value

    $TicketsInOrder = $KanbanObject->TicketSetDynamicFieldPosition(
        TicketPosition => $TicketsInOrder,
    );


=cut

sub TicketSetDynamicFieldPosition {
    my ( $Self, %Param ) = @_;

    # Get objects
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $BackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my $Counter = 1;

    my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
        Name => 'PositionOnKanbanBoard',
    );

    for my $TicketID (@{$Param{TicketPosition}}){
        my $Success = $BackendObject->ValueSet(
            DynamicFieldConfig => $DynamicFieldConfig,     
            ObjectID           => $TicketID,
            Value              => $Counter,                            
            UserID             => 1,
        );
        $Counter++;
    }

    return 1;

}

=head2 GetTotalTicketsOfBoard()

Get number of tickets per frame

    $TotalTickets = $KanbanObject->GetTotalTicketsOfBoard(
        BoardID => '1',
    );


=cut

sub GetTotalTicketsOfBoard {
    my ( $Self, %Param ) = @_;
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

     # check needed stuff
    if ( !$Param{BoardID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need BoardID!'
        );
        return;
    } 

    my $BoardData = $Self->BoardsGet(
        ID => $Param{BoardID} 
    );

    my @AssociatedColumn = split /,/, $BoardData->{AssociatedColumn};

    my @AllTickets;
    for my $ColumnID (@AssociatedColumn){
        my $KanbanColumn = $Self->KanbanGet(
            ID => $ColumnID  
        );

        my $ProfileSearch =  $Self->GetSearchProfiles(
            ColumnsEnabled => $KanbanColumn->{Search},
        );

        my @TicketIDs = $TicketObject->TicketSearch(
            Result => 'ARRAY',
            Limit => $KanbanColumn->{LimitValue},
            UserID => 1,
            %{$ProfileSearch->{ ProfileSearch }},
            %{$ProfileSearch->{ DynamicFieldSearch }},
        );

        push @AllTickets,@TicketIDs;

    }

    my @ArrayDistinct = uniq @AllTickets;

    return  scalar @ArrayDistinct;

}

=head2 GetSearchProfiles()

Get number of tickets per column search params

=cut

sub GetSearchProfiles {
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


=head2 GetTotalTicketsOfColumn()

Get number of tickets per column

    $TotalTickets = $KanbanObject->GetTotalTicketsOfColumn(
        ColumnID => '1',
    );


=cut

sub GetTotalTicketsOfColumn {
    my ( $Self, %Param ) = @_;
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

     # check needed stuff
    if ( !$Param{ColumnID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need ColumnID!'
        );
        return;
    } 

    my $KanbanColumn = $Self->KanbanGet(
        ID => $Param{ColumnID} 
    );

    my $TicketIDs = $TicketObject->TicketSearch(
        Result => 'COUNT',
        Limit => $KanbanColumn->{LimitValue},
        UserID => 1,
        %{$KanbanColumn->{Search}},
    );

    return  $TicketIDs;

}

=head2 RealoadIdemCron()

Execute the implements of KanbanReorder

    $TicketsInOrder = $KanbanObject->RealoadIdemCron();


=cut
sub RealoadIdemCron {
    my ( $Self, %Param ) = @_;

    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');
    my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');

    my @KanbansBoards = $Self->BoardsList(
        ValidID => 1,
    );

    for my $BoardID (@KanbansBoards){

        my $Board = $Self->BoardsGet(
            ID => $BoardID
        );
    
        my @AssociatedColumn = split /,/, $Board->{AssociatedColumn};

        COLUMN:
        for my $ColumnID (@AssociatedColumn){

            my $KanbanColumn = $Self->KanbanGet(
                ID => $ColumnID  
            );

            my @TicketIDs = $TicketObject->TicketSearch(
                Result => 'ARRAY',
                Limit  => $KanbanColumn->{LimitValue},
                UserID => 1,
                %{$KanbanColumn->{Search}},
            );

            my $JSONStringTickets = $JSONObject->Encode(
                Data     => \@TicketIDs,
                SortKeys => 1,         
                Pretty   => 1,          
            );

            my %Boards = $Self->ColumnOrdinanceGet(
                BoardID  => $BoardID,
                ColumnID => $ColumnID 
            );

            my $OrderOfTickets = $JSONObject->Decode(
                Data     => $Boards{OrderOfTickets} ,
                SortKeys => 1,         
                Pretty   => 1,          
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
                    $TicketsInOrder = $Self->OrderTicketsByPriority(
                        TicketIDs        => \@{$OrderOfTickets},
                        SeverityOrder    => $KanbanColumn->{SeverityOrder},
                        ManualOrdination => $KanbanColumn->{ManualSorting},
                        BoardID          =>	$BoardID,
                        ColumnID         => $KanbanColumn->{ID},
                    );
    
                }
                elsif( $KanbanColumn->{Ordination} eq 'Age'){
                    $TicketsInOrder = $Self->OrderTicketsByAge(
                        TicketIDs        => \@{$OrderOfTickets},
                        SeverityOrder    => $KanbanColumn->{SeverityOrder},
                        ManualOrdination => $KanbanColumn->{ManualSorting},
                        BoardID          =>	$BoardID,
                        ColumnID         => $KanbanColumn->{ID},
                    );
                }
                elsif($KanbanColumn->{Ordination} eq 'Owner'){
                    $TicketsInOrder = $Self->OrderTicketsByOwner(
                        TicketIDs        => \@{$OrderOfTickets},
                        SeverityOrder    => $KanbanColumn->{SeverityOrder},
                        ManualOrdination => $KanbanColumn->{ManualSorting},
                        BoardID          =>	$BoardID,
                        ColumnID         => $KanbanColumn->{ID},
                    );
                }
                else{                    
                    # By Dynamic Field 
                    $TicketsInOrder = $Self->OrderTicketsByDynamicField(
                        TicketIDs        => \@{$OrderOfTickets},
                        SeverityOrder    => $KanbanColumn->{SeverityOrder},
                        DynamicFieldName =>  $KanbanColumn->{Ordination},
                        ManualOrdination => $KanbanColumn->{ManualSorting},
                        BoardID          =>	$BoardID,
                        ColumnID         => $KanbanColumn->{ID},
                    );
                }

                my $JSONStringOfTickets = $JSONObject->Encode(
                    Data     => $TicketsInOrder,
                    SortKeys => 1,        
                    Pretty   => 1,           
                );

                # To save the order of tickets in database
                my $NewColumnOrdinanceAdd = $Self->ColumnOrdinanceAdd(
                    BoardID        => $BoardID, 
                    ColumnID       => $KanbanColumn->{ID},
                    OrderOfTickets => $JSONStringOfTickets,            
                );
                

                # Update the dynmaicfield value to new column
                my $SucessToSetDFField = $Self->TicketSetDynamicFieldPosition(
                    TicketPosition => $TicketsInOrder,
                );

            }

        }     

    }
}
1;

=head1 TERMS AND CONDITIONS

This software is part of the Service Up plugin (L<http://www.serviceup.com.br>).

=cut
