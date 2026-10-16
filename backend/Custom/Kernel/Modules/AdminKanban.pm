# --
# Kernel/Modules/AdminKanban.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * ghidalgo@serviceup.com.br
# * poliveira@serviceup.com.br
# --

package Kernel::Modules::AdminKanban;

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

    # get object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    if ( $Self->{Subaction} eq 'KanbanDelete' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_KanbanDelete(
            %Param,
        );

    }
    elsif ( $Self->{Subaction} eq 'KanbanCopy' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_KanbanCopy(
            %Param,
        );

    }
   
    return $Self->_ShowOverview(
        %Param,
        Action => 'Overview',
    );
}

sub _KanbanCopy {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
	my $KanbanObject = $Kernel::OM->Get('Kernel::System::Kanban');

    # challenge token check for write action
    $LayoutObject->ChallengeTokenCheck();

    my $ID = $ParamObject->GetParam( Param => 'ID' );
 
    # get Kanban data
    my $KanbanData = $KanbanObject->KanbanGet(
        ID     => $ID,
    );

    if ( !$KanbanData ) {
        return $LayoutObject->ErrorScreen(
            Message => "Unknown Kanban Column $ID!",
        );
    }
  
    # Create new ACL name.
    my $Count   = 1;
    my $KanbanName = "$KanbanData->{Name} (" . $LayoutObject->{LanguageObject}->Translate('Copy') . ") $Count";

    while (
        $KanbanObject->KanbanGetByName(
            Name   => $KanbanName,
        )
        && $Count < 100
        )
    {
        $KanbanName =~ s/\d+$/$Count/;      
        $Count++;
    }
   
    # otherwise save configuration and return to overview screen
    my $KanbanID = $KanbanObject->KanbanAdd(
        Name            => $KanbanName,
        GroupIDs        => join (',', @{$KanbanData->{Groups}}),
        ButtonsIDs      => join (',', @{$KanbanData->{ButtonsIDs}}),
        SeverityOrder   => $KanbanData->{SeverityOrder},
        Ordination      => $KanbanData->{Ordination} || '',
        Limit           => $KanbanData->{LimitValue} || '',
        ManualSorting   => $KanbanData->{ManualSorting},
        ValidID         => $KanbanData->{ValidID},
        Search          => $KanbanData->{Search},
        UserID          => $Self->{UserID},
        QueueToMove     => $KanbanData->{QueueToMove},
        StateToMove     => $KanbanData->{StateToMove},
    );

    # show KanbanID if can't create
    if ( !$KanbanID ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('There was an error creating the Kanban column'),
        );
    }

    my $JSON = "{}";

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );


}

sub _KanbanDelete {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $KanbanObject = $Kernel::OM->Get('Kernel::System::Kanban');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');

    my $JSON =  '{}';

    # get the id of the column that will be deleted
    my $ID = $ParamObject->GetParam( Param => 'ID' );

    # get a list of valid board ids
    my @Boards = $KanbanObject->ValidBoardsList();

    # control variable, to control if there is at least one frame associated with the column that will be deleted 
    my $Verify = 0;

    # cycles through array of frames
    for my $BoardID ( @Boards ) {

        # get the data from the board
        my $Board = $KanbanObject->BoardsGet(
            ID => $BoardID
        );

        # get the columns associated with the board
        my @BoardAssociatedColumns = $Board->{AssociatedColumn};          
        
        foreach my $ColumnIDList ( @BoardAssociatedColumns ) {    

            # if $Verify is greater than 0, exit foreach
            last if ( $Verify > 0 );

            if ( $ColumnIDList ne '' ) {

                my @ColumnID = split(',', $ColumnIDList);                

                foreach my $Column ( @ColumnID ) {
                    # if there is a board associated with the column to be deleted, $Verify is incremented
                    if ( $Column == $ID ) {
                        $Verify++;                           
                    } 
                    
                }
            }
           
        }
    }

    my $ContentType;
    my $Content;

    # if $Verify is equal to 0, the column will be deleted
    # else a message is displayed 
    if ( $Verify == 0) {    

        my $Confirmed = $ParamObject->GetParam( Param => 'Confirmed' );

        if ( !$Confirmed ) {
            $LogObject->Log(
                'Priority' => 'error',
                'Message'  => "Need 'Confirmed'!",
            );
            return;
        }        

        my $Success = $KanbanObject->KanbanDelete(
            ID => $ID,
        );

        $ContentType = 'text/html';
        $Content     = $Success;

        

    } else {
       
        my $Output = $LayoutObject->Output(
                TemplateFile => 'KanbanErrorPopUp',
                Data         => {
                    Message => $LayoutObject->{LanguageObject}->Translate('You must disassociate the column from all boards before removing it.')
                }
            );

            $JSON = $LayoutObject->JSONEncode(
                Data     => {
                    Message => $Output 
                }
              
            ); 

            $ContentType = 'application/json; charset=' . $LayoutObject->{Charset};
            $Content     = $JSON || '';

    }

   return $LayoutObject->Attachment(
        ContentType => $ContentType,
        Content     => $Content,
        Type        => 'inline',
        NoCache     => 1,
    );

}

sub _ShowOverview {
    my ( $Self, %Param ) = @_;

    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $KanbanObject       = $Kernel::OM->Get('Kernel::System::Kanban');

    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

    # call all needed template blocks
    $LayoutObject->Block(
        Name => 'Main',
        Data => \%Param,
    );

    # get the Kanban types (backends) and its config dialogs
    my %ObjectType = (
		'Ticket' => 'Ticket',
	);

    # create the Add Kanban select
    $Param{AddKanbanStrg} = $LayoutObject->BuildSelection(
        Data          => \%ObjectType,
        Name          => 'KanbanSelect',
        PossibleNone  => 1,
        Translation   => 1,
        Sort          => 'AlphanumericValue',
        SelectedValue => '-',
        Class         => 'Modernize W75pc',
    );

    # call ActionAddKanban block
    $LayoutObject->Block(
        Name => 'ActionAddKanban',
        Data => {
            %Param,
        },
    );

    # call hint block
    $LayoutObject->Block( Name => 'Hint' );

    # get Kanban list
    my $KanbanList = $KanbanObject->KanbanList();

    # print the list of dynamic fields
    $Self->_KanbanListShow(
        Kanbans  => $KanbanList,
        Total => scalar @{$KanbanList},
    );

    $Output .= $LayoutObject->Output(
        TemplateFile => 'AdminKanban',
        Data         => {
            %Param,
        },
    );

    $Output .= $LayoutObject->Footer();
    return $Output;
}

sub _KanbanListShow {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $KanbanObject = $Kernel::OM->Get('Kernel::System::Kanban');
    my $GroupObject  = $Kernel::OM->Get('Kernel::System::Group');
	my $ValidObject  = $Kernel::OM->Get('Kernel::System::Valid');

    # check start option, if higher than Kanbans available, set
    # it to the last field page
    my $StartHit = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'StartHit' ) || 1;

    # get personal page shown count
    my $PageShownPreferencesKey = 'AdminKanbanOverviewPageShown';
    my $PageShown               = $Self->{$PageShownPreferencesKey} || 35;
    my $Group                   = 'KanbanOverviewPageShown';

    # get data selection
    my %Data;
    my $Config = $Kernel::OM->Get('Kernel::Config')->Get('PreferencesGroups');
    if ( $Config && $Config->{$Group} && $Config->{$Group}->{Data} ) {
        %Data = %{ $Config->{$Group}->{Data} };
    }

    # calculate max. shown per page
    if ( $StartHit > $Param{Total} ) {
        my $Pages = int( ( $Param{Total} / $PageShown ) + 0.99999 );
        $StartHit = ( ( $Pages - 1 ) * $PageShown ) + 1;
    }

    # build nav bar
    my $Limit = $Param{Limit} || 20_000;
    
    my %PageNav = $LayoutObject->PageNavBar(
        Limit     => $Limit,
        StartHit  => $StartHit,
        PageShown => $PageShown,
        AllHits   => $Param{Total} || 0,
        Action    => 'Action=' . $LayoutObject->{Action},
        Link      => $Param{LinkPage},
        IDPrefix  => $LayoutObject->{Action},
    );

    # build shown dynamic fields per page
    $Param{RequestedURL}    = "Action=$Self->{Action}";
    $Param{Group}           = $Group;
    $Param{PreferencesKey}  = $PageShownPreferencesKey;
    $Param{PageShownString} = $LayoutObject->BuildSelection(
        Name        => $PageShownPreferencesKey,
        SelectedID  => $PageShown,
        Translation => 0,
        Data        => \%Data,
    );

    if (%PageNav) {
        $LayoutObject->Block(
            Name => 'OverviewNavBarPageNavBar',
            Data => \%PageNav,
        );

        $LayoutObject->Block(
            Name => 'ContextSettings',
            Data => { %PageNav, %Param, },
        );
    }

    # check if at least 1 dynamic field is registered in the system
    if ( $Param{Total} ) {

        # get Kanbans details
        my $Counter = 0;

        KanbanID:
        for my $KanbanID ( @{ $Param{Kanbans} } ) {
            $Counter++;
            if ( $Counter >= $StartHit && $Counter < ( $PageShown + $StartHit ) ) {
                my $Kanban = $KanbanObject->KanbanGet(
                    ID => $KanbanID,
                );
                next KanbanID if !IsHashRefWithData($Kanban);

                # get the object type display name
                my $ObjectTypeName = $Kanban->{ObjectType};

				my @Names;

				foreach my $GroupID ( @{$Kanban->{Groups}} ){
					push @Names, $GroupObject->GroupLookup( GroupID => $GroupID );
				}

				my $GroupNames = join (', ', @Names);

                # print each dynamic field row
                $LayoutObject->Block(
                    Name => 'DynamicFieldsRow',
                    Data => {
                        %{$Kanban},
                        ObjectTypeName => $ObjectTypeName,
                        GroupNames => $GroupNames,
						Validity => $ValidObject->ValidLookup( ValidID => $Kanban->{ValidID} )
                    },
                );
            }
        }
    }

    # otherwise show a no data found message
    else {
        $LayoutObject->Block(
            Name => 'NoDataFound',
            Data => \%Param,
        );
    }

    return;
}



1;
