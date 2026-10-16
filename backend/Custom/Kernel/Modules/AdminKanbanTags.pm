# --
# Kernel/Modules/AdminKanbanTags.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * ghidalgo@serviceup.con.br
# --

package Kernel::Modules::AdminKanbanTags;

use strict;
use warnings;
use utf8;

our $ObjectManagerDisabled = 1;

use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

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
    
    if ( $Self->{Subaction} eq 'TagsEdit' ) {

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
    elsif ( $Self->{Subaction} eq 'TagsSave' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');
        my $KanbanObject     = $Kernel::OM->Get('Kernel::System::Kanban');
        my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
        my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');
        my $BackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

        # get params
        my %GetParam;
        for (qw(ID Name ValidID Tag_Color )) {
            $GetParam{$_} = $ParamObject->GetParam( Param => $_ ) || '';
        }

		my @Kanbans = $ParamObject->GetArray( Param => 'AssociatedBoards' );
		$GetParam{AssociatedBoards} = join ",",@Kanbans;

        my %Error;

        if ( !$GetParam{Name} ) {
            $Error{'NameInvalid'} = 'ServerError';
        }

        if ( !%Error ) {

            my $LogObject = $Kernel::OM->Get('Kernel::System::Log');

            my $Success;
            # save to database
            if ( $GetParam{ID} eq 'NEW' ) {
                $Success = $KanbanObject->TagsAdd(
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
            else {
                $Success = $KanbanObject->TagsUpdate(
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

            if($Success){
                $Self->_UpdateDFTags(
                    %Param,
                    $Self,
                    %GetParam,
                );   
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

        $Output .= $Error{Tags}
        ? $LayoutObject->Notify(
        Priority => 'Error',
        Info     => 'The tag already exists.',
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
        my @TagsList = $KanbanObject->TagsList();


        # if there are any Series defined, they are shown
        if ( IsArrayRefWithData(\@TagsList) ) {
            # get valid list
            my %ValidList = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();

            for my $TagsID ( @TagsList ) {
        
				my $TagsData = $KanbanObject->TagsGet(
					ID => $TagsID,
				);
                
                $LayoutObject->Block(
                    Name => 'OverviewListRow',
                    Data => {
                        %{$TagsData},
                        Valid => $ValidList{ $TagsData->{ValidID} },
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
            TemplateFile => 'AdminKanbanTags',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();

        return $Output;
    }
}

sub _UpdateDFTags {

    my ( $Self, %Param ) = @_;

    my $KanbanObject        = $Kernel::OM->Get('Kernel::System::Kanban');
    my $DynamicFieldObject  = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $LayoutObject        = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

   

     my $TagName = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => "Name" );

    my $TagID = $KanbanObject->KanbanTagLookup(
        Name => $TagName,
    );

    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => 'TagsOfKanban',
    );

    my $FieldConfig = $DynamicField->{Config};

    $FieldConfig->{PossibleValues}->{$TagID} = $TagName;

    # update dynamic field (FieldType and ObjectType cannot be changed; use old values)
    my $UpdateSuccess = $DynamicFieldObject->DynamicFieldUpdate(
        ID         => $DynamicField->{ID},
        Name       => $DynamicField->{Name},
        Label      => $DynamicField->{Label},
        FieldOrder => $DynamicField->{FieldOrder},
        FieldType  => $DynamicField->{FieldType},
        ObjectType => $DynamicField->{ObjectType},
        Config     => $FieldConfig,
        ValidID    => $DynamicField->{ValidID},
        UserID     => $Self->{UserID},
    );

    if ( !$UpdateSuccess ) {
        return $LayoutObject->ErrorScreen(
            Message => $LayoutObject->{LanguageObject}->Translate( 'Could not update the field %s', $TagName ),
        );
    }

    return 1;


}

sub _MaskNew {
    my ( $Self, %Param ) = @_;

    my $KanbanObject = $Kernel::OM->Get('Kernel::System::Kanban');
    my %SeriesData;

    # get params
    $SeriesData{ID} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => "ID" );
    $SeriesData{OpenBy} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => "OpenBy" );

    if ( $SeriesData{ID} ne 'NEW' ) {
        my $Series = $KanbanObject->TagsGet(
            ID => $SeriesData{ID},
        );

		%SeriesData = %{$Series};
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
    my %SeriesList = $KanbanObject->TagsList();

    # get valid list
    my %ValidList        = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();
    my %ValidListReverse = reverse %ValidList;

    $SeriesData{ValidOptionStrg} = $LayoutObject->BuildSelection(
        Data       => \%ValidList,
        Name       => 'ValidID',
        SelectedID => $SeriesData{ValidID} || $ValidListReverse{valid},
        Class      => 'Modernize Validate_Required',
    );

	my %KanbanData;

    my @KanbansBoards = $KanbanObject->BoardsList();

	Kanban:
	foreach my $KanbanID ( @KanbansBoards ){

		my $Kanban = $KanbanObject->BoardsGet(
			ID => $KanbanID,
		);

		next Kanban if $Kanban->{ValidID} == 0;

		$KanbanData{$KanbanID} = $Kanban->{Name};
	}

	my @Kanbans = split ",", $SeriesData{AssociatedBoards};
  
	$SeriesData{KanbanOptionString} = $LayoutObject->BuildSelection(
        Data       => \%KanbanData,
        Name       => 'AssociatedBoards',
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
        Name => 'TagsEdit',
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
        TemplateFile => 'AdminKanbanTags',
        Data         => \%Param
    );
}
1;
