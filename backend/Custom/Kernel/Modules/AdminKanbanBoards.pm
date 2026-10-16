# --
# Kernel/Modules/AdminKanbanBoards.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * ghidalgo@serviceup.con.br
# --

package Kernel::Modules::AdminKanbanBoards;

use strict;
use warnings;

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

    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');
	my $KanbanObject     = $Kernel::OM->Get('Kernel::System::Kanban');

    # ------------------------------------------------------------ #
    # Series edit
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'BoardsEdit' ) {

        # header
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        # html output
        $Output .= $Self->_MaskNew(
            %Param,
        );
        $Output .= $LayoutObject->Footer();

        return $Output;
    }

    # ------------------------------------------------------------ #
    # Series save
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'BoardsSave' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

        # get params
        my %GetParam;
        for (qw(ID Name ValidID Resource_ColorName Resource_ColorNameLabel OpenBy)) {
            $GetParam{$_} = $ParamObject->GetParam( Param => $_ ) || '';
        }

		my @Kanbans = $ParamObject->GetArray( Param => 'AssociatedColumn' );
		$GetParam{AssociatedColumn} = join ",",@Kanbans;

		my @GroupIDs = $ParamObject->GetArray( Param => 'GroupIDs' );
		$GetParam{GroupIDs} = join ",",@GroupIDs;

        my %Error;

        if ( !$GetParam{Name} ) {
            $Error{'NameInvalid'} = 'ServerError';
        }

        if ( !%Error ) {

            my $LogObject = $Kernel::OM->Get('Kernel::System::Log');

            # save to database
            if ( $GetParam{ID} eq 'NEW' ) {
                $GetParam{SeriesID} = $KanbanObject->BoardsAdd(
                    %GetParam,
                    UserID => $Self->{UserID},
                );
                if ( !$GetParam{ID} ) {
                    $Error{Message} = $LogObject->GetLogEntry(
                        Type => 'Error',
                        What => 'Message',
                    );
                }
            }
            else {
                my $Success = $KanbanObject->BoardsUpdate(
                    %GetParam,
                    UserID => $Self->{UserID},
                );
                if ( !$Success ) {
                    $Error{Message} = $LogObject->GetLogEntry(
                        Type => 'Error',
                        What => 'Message',
                    );
                }
            }

            if ( !%Error ) {
                # redirect to overview
                if($GetParam{OpenBy} eq 'Kanban'){
                    return $LayoutObject->Redirect( OP => "Action=AgentKanban" );
                }else{
                    return $LayoutObject->Redirect( OP => "Action=$Self->{Action}" );
                }
            }
        }

        # something went wrong
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $Error{Message}
            ? $LayoutObject->Notify(
            Priority => 'Error',
            Info     => $Error{Message},
            )
            : '';

        # html output
        $Output .= $Self->_MaskNew(
            %Error,
            %GetParam,
            %Param,
        );
        $Output .= $LayoutObject->Footer();

    }

    # ------------------------------------------------------------ #
    # Series overview
    # ------------------------------------------------------------ #
    else {

        # output header
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        # output overview
        $LayoutObject->Block(
            Name => 'Overview',
            Data => { %Param, },
        );

        $LayoutObject->Block( Name => 'ActionList' );
        $LayoutObject->Block( Name => 'ActionAdd' );

        # output overview result
        $LayoutObject->Block(
            Name => 'OverviewList',
            Data => { %Param, },
        );

        $LayoutObject->Block( Name => 'FilterBoard' );

        # get Series list
        my @SeriesList = $KanbanObject->BoardsList();

        # if there are any Series defined, they are shown
        if ( IsArrayRefWithData(\@SeriesList) ) {
            # get valid list
            my %ValidList = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();

            for my $SeriesID ( @SeriesList ) {

				my $SeriesData = $KanbanObject->BoardsGet(
					ID => $SeriesID,
				);

                # output row
                $LayoutObject->Block(
                    Name => 'OverviewListRow',
                    Data => {
                        %{$SeriesData},
                        Valid => $ValidList{ $SeriesData->{ValidID} },
                    },
                );
            }
        }

        # otherwise a no data found msg is displayed
        else {
            $LayoutObject->Block(
                Name => 'NoDataFoundMsg',
                Data => {},
            );
        }

        # generate output
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AdminKanbanBoards',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();

        return $Output;
    }
}

sub _MaskNew {
    my ( $Self, %Param ) = @_;

    my $KanbanObject = $Kernel::OM->Get('Kernel::System::Kanban');
    my %SeriesData;

    # get params
    $SeriesData{ID} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => "ID" );
    $SeriesData{OpenBy} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => "OpenBy" );

    if ( $SeriesData{ID} ne 'NEW' ) {
        my $Series = $KanbanObject->BoardsGet(
            ID => $SeriesData{ID},
        );
        my $OpenBy =  $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => "OpenBy" );

		%SeriesData = %{$Series};
        $SeriesData{OpenBy} = $OpenBy;
    }

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # output overview
    $LayoutObject->Block(
        Name => 'Overview',
        Data => { %SeriesData, },
    );

    $LayoutObject->Block( Name => 'ActionList' );
    $LayoutObject->Block( Name => 'ActionOverview' );

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # get list type
    my $ListType = $ConfigObject->Get('Ticket::Frontend::ListType');

    # generate ParentOptionStrg
    my %SeriesList = $KanbanObject->BoardsList();

    # get valid list
    my %ValidList        = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();
    my %ValidListReverse = reverse %ValidList;

    $SeriesData{ValidOptionStrg} = $LayoutObject->BuildSelection(
        Data       => \%ValidList,
        Name       => 'ValidID',
        SelectedID => $SeriesData{ValidID} || $ValidListReverse{valid},
        Class      => 'Modernize Validate_Required',
    );

	#Get only the not used Kanbans
	# my @UsedKanban = ();

	# my @AllSeries = $KanbanObject->BoardsList();

	# SERIES:
	# foreach my $SeriesID ( @AllSeries ){

	# 	next SERIES if ( $SeriesID == $SeriesData{ID} );

	# 	my $SeriesData = $KanbanObject->BoardsGet(
	# 		ID => $SeriesID,
	# 	);

	# 	my @Profiles = split ",", $SeriesData->{AssociatedColumn};

	# 	@UsedKanban = ( @UsedKanban, @Profiles );
	# }

	my $Kanbans = $KanbanObject->KanbanList();

	my %KanbanData;

	Kanban:
	foreach my $KanbanID ( @{$Kanbans} ){

		# next Kanban if ( grep( $_ == $KanbanID, @UsedKanban ) );

		my $Kanban = $KanbanObject->KanbanGet(
			ID => $KanbanID,
		);

		next Kanban if $Kanban->{ValidID} == 0;

		$KanbanData{$KanbanID} = $Kanban->{Name};
	}

	my @Kanbans = split ",", $SeriesData{AssociatedColumn};

	$SeriesData{KanbanOptionString} = $LayoutObject->BuildSelection(
        Data       => \%KanbanData,
        Name       => 'AssociatedColumn',
        SelectedID => \@Kanbans,
        Class      => 'Modernize W50pc',
		Multiple => 1,
    );

	my @GroupIDs = split ",", $SeriesData{GroupIDs};

	my %Groups       = $Kernel::OM->Get('Kernel::System::Group')->GroupList( Valid => 1 );
	$SeriesData{GroupsStrg} = $LayoutObject->BuildSelection(
        Data         => \%Groups,
        Name         => 'GroupIDs',
        SelectedID   => \@GroupIDs,
        PossibleNone => 1,
        Translation  => 1,
        Class        => 'Modernize W50pc Validate_Required ',
		Multiple     => 1,
    );

    # output Series edit
    $LayoutObject->Block(
        Name => 'BoardsEdit',
        Data => { %Param, %SeriesData, },
    );

    # shows header
    if ( $SeriesData{ID} ne 'NEW' ) {
        $LayoutObject->Block(
            Name => 'HeaderEdit',
            Data => {%SeriesData},
        );
    }
    else {
        $LayoutObject->Block( Name => 'HeaderAdd' );
    }

    # generate output
    return $LayoutObject->Output(
        TemplateFile => 'AdminKanbanBoards',
        Data         => \%Param
    );
}

1;
