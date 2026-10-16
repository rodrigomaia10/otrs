# --
# Kernel/Modules/AgentKanban.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * dsilva@serviceup.com.br
# * ghidalgo@serviceup.com.br
# --

package Kernel::Modules::AgentKanban;

use strict;
use warnings;
use Digest::MD5 qw(md5_hex);
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

    # Get objects
    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $KanbanObject  = $Kernel::OM->Get('Kernel::System::Kanban');
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');

    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

    if ( $Self->{Subaction} eq 'KanbanBoard' ) {

        # html output
        $Output .= $Self->_GenerateKanbanBoard(
            %Param,
        );
        $Output .= $LayoutObject->Footer();

        return $Output;

    }
    elsif ( $Self->{Subaction} eq 'FilterKanban' ) {
        # html output with filter
        $Output .= $Self->_GenerateKanbanBoardWithFilter(
            %Param,
        );
        $Output .= $LayoutObject->Footer();

        return $Output;
    }
    else {
      
        my %Groups = $GroupObject->PermissionUserGet(
            UserID => $Self->{UserID},
            Type   => 'ro',
        );

        my @UserGroups = keys %Groups;

        my @KanbansBoards = $KanbanObject->BoardsList(
            ValidID => '1'
        );

        my @BoardsOfGroup;

        BOARD:
        for my $BoardID (@KanbansBoards) {

            my $Board = $KanbanObject->BoardsGet(
                ID => $BoardID
            );

            my @Groups = split /,/, $Board->{GroupIDs};

			if ( IsArrayRefWithData(\@Groups) ) {
				my $MatchGroups = 0;

				foreach my $GroupID ( @Groups ) {
					if ( grep( $_ == $GroupID, @UserGroups ) ){
						$MatchGroups++;
					}
				}
                
                if($MatchGroups <= 0) {
                    next BOARD;
                }
                else {

                    my $TotalTickets = $KanbanObject->GetTotalTicketsOfBoard(
                        BoardID => $Board->{ID},
                    );

                    $LayoutObject->Block(
                        Name => 'BoardNames',
                        Data => {
                            BoardName       => $Board->{Name},
                            BoardColor      => $Board->{Resource_ColorName},
                            BoardColorLabel =>$Board->{Resource_ColorNameLabel},
                            BoardID         => $Board->{ID},
                            TotalTickets    => $TotalTickets
                        }
                    );
                
                    $LayoutObject->Block(
                        Name => 'ToEditBoard',
                        Data => {                      
                            BoardID         => $Board->{ID},
                            BoardColorLabel => $Board->{Resource_ColorNameLabel},
                        }
                    );                   
                      
                }
				
			}
            else {

                $LayoutObject->Block(
                    Name => 'BoardNames',
                    Data => {
                        BoardName  => $Board->{Name},
                        BoardColor => $Board->{Resource_ColorName},
                        BoardID    => $Board->{ID},
                    }
                );

                $LayoutObject->Block(
                    Name => 'ToEditBoard',
                    Data => {                      
                        BoardID         => $Board->{ID},
                        BoardColorLabel => $Board->{Resource_ColorNameLabel},
                    }
                );                                   
               
            }            
        }
       
        $LayoutObject->Block(
            Name => 'KanbanAddBoard'
        );                   
         
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AgentKanban',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();

        return $Output;
    }

  
}

sub _GenerateKanbanBoard {
    my ( $Self, %Param ) = @_;

    my $ConfigObject          = $Kernel::OM->Get('Kernel::Config');
    my $JSONObject            = $Kernel::OM->Get('Kernel::System::JSON');
    my $UserObject            = $Kernel::OM->Get('Kernel::System::User');
    my $GroupObject           = $Kernel::OM->Get('Kernel::System::Group');
    my $QueueObject           = $Kernel::OM->Get('Kernel::System::Queue');
    my $KanbanObject          = $Kernel::OM->Get('Kernel::System::Kanban');
    my $TicketObject          = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ServiceObject         = $Kernel::OM->Get('Kernel::System::Service');
    my $ParamObject           = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject          = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $InBoxLibraryObject    = $Kernel::OM->Get('Kernel::System::InBoxLibrary');
    my $CustomerCompanyObject = $Kernel::OM->Get('Kernel::System::CustomerCompany');
    my $CustomerUserObject    = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $DynamicFieldObject    = $Kernel::OM->Get('Kernel::System::DynamicField');

    my $CardData     = $ConfigObject->Get("Kanban::Core::CardData");
    my $TimeToReload = $ConfigObject->Get("Kanban::Core::TimeToReload");
    my $IndexTickets = $ConfigObject->Get('Kanban::Core::IndexTickets');
    my $CardDataDF   = $ConfigObject->Get("Kanban::Core::CardDataDynamicField");

    my %GetParam;
	$GetParam{BoardID} = $ParamObject->GetParam( Param => "BoardID" );

    my $JSONString = '{}';

    my $Board = $KanbanObject->BoardsGet(
        ID => 	$GetParam{BoardID}
    );

    $LayoutObject->Block(
        Name => 'OverviewBoard',
        Data => {
            BoardName  => $Board->{Name},
            BoardColor => $Board->{Resource_ColorName},
            BoardID    => $Board->{ID},
        }
    );

    my $Tags = $KanbanObject->SearchTags(
        BoardID => $GetParam{BoardID}
    );

    my %Column;
    my @AssociatedColumn = split /,/, $Board->{AssociatedColumn};
    my @ColumnsInformations;

    my %Groups = $GroupObject->PermissionUserGet(
        UserID => $Self->{UserID},
        Type   => 'ro',
    );

    my $ColumnInOrder = $Self->_OrderColumnsByName(
        AssociatedColumn => \@AssociatedColumn,
    );

    my @UserGroups = keys %Groups;

    $LayoutObject->Block(
        Name => 'OverviewEditBoard',
        Data => {
                BoardID =>$Board->{ID},
        }
    );
   
    COLUMN:
    for my $ColumnID ( @{$ColumnInOrder} ) {

        my %DataColumn;
        my $KanbanColumn = $KanbanObject->KanbanGet(
            ID => $ColumnID  
        );

        if ( IsArrayRefWithData($KanbanColumn->{Groups}) ) {
            my $MatchGroups = 0;

            foreach my $GroupID ( @{$KanbanColumn->{Groups}} ) {
            
                if ( grep( $_ == $GroupID, @UserGroups ) ){
                    $MatchGroups++;
                }
            }
                
            if($MatchGroups <= 0) {
                next COLUMN;
            }
            else {

                my $TranlateTitleEdit   = $LayoutObject->{LanguageObject}->Translate('Edit Column');
                my $TranlateTitleCreate = $LayoutObject->{LanguageObject}->Translate('New ticket');

                $DataColumn{id} = "$KanbanColumn->{ID}";

                my $ProfileSearch =  $Self->_GetSearchProfiles(
                    ColumnsEnabled => $KanbanColumn->{Search},
                );

                my @TicketIDs = $TicketObject->TicketSearch(
                    Result              => 'ARRAY',
                    Limit               => $KanbanColumn->{LimitValue},
                    UserID              => 1,
                    ContentSearchPrefix => '*',
                    ContentSearchSuffix => '*',
                    FullTextIndex       => 1,
                    %{$ProfileSearch->{ ProfileSearch }},
				    %{$ProfileSearch->{ DynamicFieldSearch }},
                );

                my $TotalTicketsOfColumn = scalar @TicketIDs;

                my $NameShorted = $KanbanColumn->{Name};
                if ( length $KanbanColumn->{Name} > 31 ) {
                    $NameShorted =  substr( $KanbanColumn->{Name}, 0, 28 ).'...';
                }

                $DataColumn{title} = "<div title='$KanbanColumn->{Name}' class='ColumnTitleFormat' id='ColumnTitleFormat_$KanbanColumn->{ID}'>$NameShorted <p class='CounterColumn'>($TotalTicketsOfColumn)</p></div>
                <div class='ColumnsButtons'>";

                if ( $KanbanColumn->{PreviewOnly} eq '1' ) {
                    $DataColumn{PreviewOnly} .= 'kanban-drag-after';
                }

                $DataColumn{title} .= "<span onclick='Core.Agent.Admin.MyKanbanBoard.NewTicket($ColumnID)' class='ColumnSpan' title='$TranlateTitleCreate'><i class='fa fa-plus-square'></i></span>";
                $DataColumn{title} .= "<span title='$TranlateTitleEdit'><a style='color:$Board->{Resource_ColorNameLabel}' class='ColumnSpan' href='?Action=AdminKanbanTicket;Subaction=Change;ID=$ColumnID;OpenBy=Kanban_$Board->{ID}'><i class='fa fa-pencil-square-o'></i></a></span>";           
                $DataColumn{title} .= "<span id='AJAXLoaderKanbanColumn_$KanbanColumn->{ID}' class='AJAXLoaderKanbanColumn' style='display: none;'></span></div>";

                if ( $KanbanColumn->{StartCollapsed} eq '1' ) {
                    $DataColumn{StartCollapsed} .= 'Colapsed';
                }

                my $TicketsInOrder;
                
                if($IndexTickets eq '0') {

                    my %TicketsInOrderEncode = $KanbanObject->ColumnOrdinanceGet(
                        BoardID  => $GetParam{BoardID}, 
                        ColumnID => $KanbanColumn->{ID}
                    );
                
                    $TicketsInOrder = $JSONObject->Decode(
                        Data => $TicketsInOrderEncode{OrderOfTickets},
                    );
                }
                else {                  

                    my @TicketsOfCollumn;
                    if ( scalar @TicketIDs > 0 ) {

                        if ( $KanbanColumn->{Ordination} eq 'Priority') {

                            $TicketsInOrder = $KanbanObject->OrderTicketsByPriority(
                                TicketIDs        => \@TicketIDs,
                                SeverityOrder    => $KanbanColumn->{SeverityOrder},
                                ManualOrdination => $KanbanColumn->{ManualSorting},
                                BoardID          =>	$GetParam{BoardID},
                                ColumnID         => $KanbanColumn->{ID},
                            );
                        }
                        elsif ( $KanbanColumn->{Ordination} eq 'Age') {
                            
                            $TicketsInOrder = $KanbanObject->OrderTicketsByAge(
                                TicketIDs        => \@TicketIDs,
                                SeverityOrder    => $KanbanColumn->{SeverityOrder},
                                ManualOrdination => $KanbanColumn->{ManualSorting},
                                BoardID          =>	$GetParam{BoardID},
                                ColumnID         => $KanbanColumn->{ID},
                            );
                        }
                        elsif ( $KanbanColumn->{Ordination} eq 'Owner') {
                            
                            $TicketsInOrder = $KanbanObject->OrderTicketsByOwner(
                                TicketIDs        => \@TicketIDs,
                                SeverityOrder    => $KanbanColumn->{SeverityOrder},
                                ManualOrdination => $KanbanColumn->{ManualSorting},
                                BoardID          =>	$GetParam{BoardID},
                                ColumnID         => $KanbanColumn->{ID},
                            );

                        }
                        elsif ( $KanbanColumn->{Ordination} eq 'Solution SLA' ) {
                           
                            $TicketsInOrder = $KanbanObject->OrderSolutionSLA(
                                TicketIDs        => \@TicketIDs,
                                SeverityOrder    => $KanbanColumn->{SeverityOrder},
                                ManualOrdination => $KanbanColumn->{ManualSorting},
                                BoardID          =>	$GetParam{BoardID},
                                ColumnID         => $KanbanColumn->{ID},
                            );

                        }                       
                        else {

                            # By Dynamic Field 
                            $TicketsInOrder = $KanbanObject->OrderTicketsByDynamicField(
                                TicketIDs        => \@TicketIDs,
                                SeverityOrder    => $KanbanColumn->{SeverityOrder},
                                DynamicFieldName => $KanbanColumn->{Ordination},
                                ManualOrdination => $KanbanColumn->{ManualOrdination},
                                BoardID          =>	$GetParam{BoardID},
                                ColumnID         => $KanbanColumn->{ID},

                            );
                        }
                          
                        # Update the dynmaicfield value to new column
                        $KanbanObject->TicketSetDynamicFieldPosition(
                            TicketPosition => $TicketsInOrder,
                        );
                    }
                }
            
                my @TicketsOfCollumn;

                if ( $TicketsInOrder ) {
                   
                    for my $TicketId ( @{$TicketsInOrder} ) {

                        my %DataOfticketColumn;
 
                        my %Ticket = $KanbanObject->TicketGetOfKanban(
                            TicketID      => $TicketId,
                        );

                        my $ColorsPriorities = $ConfigObject->Get('Kanban::Core::PrioritiesColor');

                        $DataOfticketColumn{hex} = $ColorsPriorities->{$Ticket{Priority}};

                        my $LockSimbol = 'fa-unlock';
                        my $LockAction = 'Core.Agent.Admin.MyKanbanBoard.TicketLock';

                        if($Ticket{Lock} eq 'lock'){
                            $LockSimbol = 'fa-lock';
                            $LockAction = 'Core.Agent.Admin.MyKanbanBoard.TicketUnLock';
                        }
                      
                        $DataOfticketColumn{id} = $Ticket{TicketID};

                        # To set agent and responsible
                        my $SetResponsibleInCard = $ConfigObject->Get('Kanban::Core::ToEnableResposibleChange');
                       
                        my %User = $UserObject->GetUserData(
                            UserID => $Ticket{OwnerID},
                        );

                        my $HTMLOwners = "<div class='OwnerAvatardiv'>";

                        my $DefaultIcon = $ConfigObject->Get('Frontend::Gravatar::DefaultImage') || 'mm';

                        $DataOfticketColumn{imageOwner} = '//www.gravatar.com/avatar/' . md5_hex( lc $User{UserEmail} ) . '?s=100&d=' . $DefaultIcon;
                        
                        $HTMLOwners .= "<img onclick='Core.Agent.Admin.MyKanbanBoard.TicketChangeOwner($TicketId)' class='OwnerAvatar' src='$DataOfticketColumn{imageOwner}'>";

                        if ( $SetResponsibleInCard eq '1' ) {

                            my %UserResponsible = $UserObject->GetUserData(
                                UserID => $Ticket{ResponsibleID},
                            );

                            my $DefaultIcon = $ConfigObject->Get('Frontend::Gravatar::DefaultImage') || 'mm';

                            $DataOfticketColumn{imageResponsible} = '//www.gravatar.com/avatar/' . md5_hex( lc $UserResponsible{UserEmail} ) . '?s=100&d=' . $DefaultIcon;
                            $HTMLOwners .="<img  class='ResponsibleAvatar' onclick='Core.Agent.Admin.MyKanbanBoard.TicketChangeResponsible($TicketId)' src='$DataOfticketColumn{imageResponsible}'>";
                        }
                        $HTMLOwners .= "</div>";

                        # age design
                        $Ticket{Age} = $LayoutObject->CustomerAge(
                            Age   => $Ticket{Age},
                            Space => ' '
                        );            

                      
                        if ( IsArrayRefWithData($KanbanColumn->{ButtonsIDs} ) ) {

                            for my $Button ( @{$KanbanColumn->{ButtonsIDs}} ){

                                if ( $Button eq 'Details' ) {                             
                                    $LayoutObject->Block(
                                        Name => 'ButtonTitle',
                                        Data => {
                                            TicketID =>   $Ticket{TicketID},
                                        }
                                    );
                                }

                                if ( $Button eq 'AgentTicketFreeText' ) {
                                    $LayoutObject->Block(
                                        Name => 'ButtonFreeText',
                                        Data => {
                                            TicketID =>   $Ticket{TicketID},
                                        }
                                    );                  
                                }

                                if( $Button eq 'AgentTicketNote' ) {
                                    $LayoutObject->Block(
                                        Name => 'ButtonNote',
                                        Data => {
                                            TicketID =>   $Ticket{TicketID},
                                        }
                                    );                  
                                }

                                if ( $Button eq 'AgentTicketClosed' ) {
                                    $LayoutObject->Block(
                                        Name => 'ButtonClosed',
                                        Data => {
                                            TicketID =>   $Ticket{TicketID},
                                        }
                                    );
                                }
                                
                                if ( $Button eq  'Lock' ) {
                                    $LayoutObject->Block(
                                        Name => 'ButtonLock',
                                        Data => {
                                            TicketID =>   $Ticket{TicketID},
                                            LockSimbol => $LockSimbol,
                                            LockAction =>  $LockAction
                                        }
                                    );                   
                                }

                                if( $Button eq 'IncreasePriority' ){
                                    $LayoutObject->Block(
                                        Name => 'ButtonPrioriyUp',
                                        Data => {
                                            TicketID =>   $Ticket{TicketID},
                                        }
                                    );                          
                                }

                                if( $Button eq 'DecreasePriority' ){
                                    $LayoutObject->Block(
                                        Name => 'ButtonPrioriyDown',
                                        Data => {
                                            TicketID =>   $Ticket{TicketID},
                                        }
                                    );                          
                                }

                                if( $Button eq 'ChangeQueues' ){
                                    $LayoutObject->Block(
                                        Name => 'ButtonChangeQueues',
                                        Data => {
                                            TicketID =>   $Ticket{TicketID},
                                        }
                                    );                            
                                }

                                if( $Button eq 'Share' ){
                                    $LayoutObject->Block(
                                        Name => 'ButtonTicketShare',
                                        Data => {
                                            TicketID =>   $Ticket{TicketID},
                                        }
                                    );                            
                                } 

                                if( $Button eq 'ReplyAll' ){
                                    $LayoutObject->Block(
                                        Name => 'ButtonReplyAll',
                                        Data => {
                                            TicketID =>   $Ticket{TicketID},
                                        }
                                    );                            
                                }  

                                if( $Button eq 'AddTag' ){
                                    if(IsArrayRefWithData($Tags) && scalar @{ $Tags } > 0 ){
                                        $LayoutObject->Block(
                                            Name => 'ButtonAddTag',
                                            Data => {
                                                TicketID =>   $Ticket{TicketID},
                                            }
                                        );       
                                    }                     
                                }

                                if ( $Button eq 'Watch' ) {                             
                                    $LayoutObject->Block(
                                        Name => 'ButtonWatch',
                                        Data => {
                                            TicketID =>   $Ticket{TicketID},
                                        }
                                    );
                                }       
                            }
                         
                        }                        

                        if ( $CardData->{Age} eq '1' ) {
                            $LayoutObject->Block(
                                Name => 'TicketAge',
                                Data => {
                                    Age =>   $Ticket{Age},
                                }
                            ); 
                        }

                        if ( $CardData->{CustomerCompany} eq '1' ) {
                            my %CustomerCompany;
                            if($Ticket{CustomerID}){
                                %CustomerCompany = $CustomerCompanyObject->CustomerCompanyGet(
                                    CustomerID => $Ticket{CustomerID},
                                );
                            }
                            
                            $LayoutObject->Block(
                                Name => 'CustomerCompany',
                                Data => {
                                    CustomerCompany => $CustomerCompany{CustomerCompanyName} || '',
                                }
                            ); 
                        }

                        if ( $CardData->{CustomerLogin} eq '1' ) {
                            $LayoutObject->Block(
                                Name => 'CustomerLogin',
                                Data => {
                                    CustomerLogin =>   $Ticket{CustomerUserID},
                                }
                            ); 
                        }

                        if ( $CardData->{Created} eq '1' ) {
                            $LayoutObject->Block(
                                Name => 'TicketCreated',
                                Data => {
                                    Created =>   $Ticket{Created},
                                }
                            ); 
                        }

                        if ( $CardData->{Owner} eq '1' ) {
                           
                            my $Name = $UserObject->UserName(
                                UserID => $Ticket{OwnerID},
                            );

                            $LayoutObject->Block(
                                Name => 'TicketOwner',
                                Data => {
                                    Owner =>   $Name,
                                }
                            ); 
                        }

                        if ( $CardData->{Responsible} eq '1' ) {
                           
                            my $Name = $UserObject->UserName(
                                UserID => $Ticket{ResponsibleID},
                            );

                            $LayoutObject->Block(
                                Name => 'TicketResponsible',
                                Data => {
                                    Responsible =>   $Name,
                                }
                            ); 
                        }

                        if ( $CardData->{CustomerUser} eq '1' ) {
                           
                            my $Name = $CustomerUserObject->CustomerName(
                                UserLogin => $Ticket{CustomerUserID},
                            );

                            $LayoutObject->Block(
                                Name => 'TicketCustomerUser',
                                Data => {
                                    CustomerUser =>   $Name,
                                }
                            ); 
                        }

                        if($CardDataDF){
                            $LayoutObject->Block(
                                Name => 'TicketDynamicField',
                                Data => {}
                            ); 

                            for my $DFName (@{$CardDataDF}){

                                my %TicketGetOTRS = $TicketObject->TicketGet(
                                    TicketID      => $Ticket{TicketID},
                                    DynamicFields => 1,         
                                    UserID        => 1,
                                );
                               
                                my @FielName = split("DynamicField_", $DFName);

                                my $DynamicField  = $DynamicFieldObject->DynamicFieldGet(
                                    Name => $FielName[1],
                                );

                                if($TicketGetOTRS{$DFName}){
                                    $LayoutObject->Block(
                                        Name => 'DynamicFieldName',
                                        Data => {
                                            DynamicFieldValue => $TicketGetOTRS{$DFName},
                                            DynamicFieldName =>  $DynamicField->{Label}
                                        }
                                    ); 
                                }

                            }
                        }

                        my %Flags = $TicketObject->TicketFlagGet(
                            TicketID => $Ticket{TicketID},
                            UserID   => $Self->{UserID}, 
                        );

                        my $IsStars = 0;
                        
                        if ( ! IsHashRefWithData(\%Flags) ) {

                            $IsStars = 1;

                            my $StartTicketKanban;

                            if ( $Ticket{OwnerID} eq  $Self->{UserID}) {                              
                                $StartTicketKanban = 'StartTicketKanbanYellow',                                  
                            }
                            else {
                                $StartTicketKanban = 'StartTicketKanbanGrey',
                            }

                            $LayoutObject->Block(
                                Name => 'StartTicketKanban',
                                Data => {
                                    StartTicketKanban => $StartTicketKanban,
                                }
                            );
                        }

                        my $IsSLA = 0;

                        my $TicketSLAConfig = $ConfigObject->Get('Kanban::Core::TicketSLA');

                        # get SLA Status
                        if ( $Ticket{SLAID} && $TicketSLAConfig ) {

                            $IsSLA = 1;

                            my $StatusSLA = $InBoxLibraryObject->SLAStatusSolutionTime(
                                TicketID => $Ticket{TicketID}
                            );

                            my $SLACLass = 'TicketSLAIn';

                            if ( $StatusSLA->{SLAStatus} eq 'SLA OUT' ) {
                                $SLACLass = 'TicketSLAOut';
                            }

                            $LayoutObject->Block(
                                Name => 'SLATicketKanban',
                                Data => {
                                    SLACLass => $SLACLass,
                                    TicketID => $Ticket{TicketID}
                                }
                            );
                        }

                        #get Tags of ticket
                        my %TicketGetOTRS = $TicketObject->TicketGet(
                            TicketID      => $Ticket{TicketID},
                            DynamicFields => 1,         
                            UserID        => 1,
                        );

                        if($TicketGetOTRS{DynamicField_TagsOfKanban}){                         

                            for my $TagID (@{$TicketGetOTRS{DynamicField_TagsOfKanban}}){

                                my $Tag = $KanbanObject->TagsGet(
                                    ID => $TagID 
                                );
                               
                                $LayoutObject->Block(
                                    Name => 'TagShow',
                                    Data => {
                                        %{$Tag},
                                    }
                                );
                            }
                        }

                        $DataOfticketColumn{title} =  $LayoutObject->Output(
                            TemplateFile => 'KanbanCardBody',
                            Data         => {
                                %Ticket,
                                HTMLOwners    => $HTMLOwners,
                                PriorityColor => $ColorsPriorities->{$Ticket{Priority}},                                
                                StartAndSLA   => $IsStars && $IsSLA ? 'TicketTitleKBSLA' : ''
                            }
                        );
                                                
                        push @TicketsOfCollumn, \%DataOfticketColumn;
                    }

                    $DataColumn{item} = \@TicketsOfCollumn;
                }
            }
        }
     
        push @ColumnsInformations,  \%DataColumn;       
    }

    $JSONString = $JSONObject->Encode(
        Pretty => 1,           
        Data   =>  {
            ColumnData      => \@ColumnsInformations,         
            BoardColor      => $Board->{Resource_ColorName},
            BoardColorLabel => $Board->{Resource_ColorNameLabel},
            RefreshTime     => $TimeToReload, 
        }
    );

    $LayoutObject->AddJSData(
        Key   => "BoardsColumnData",
        Value => $JSONString
    );

    # generate output
    return $LayoutObject->Output(
        TemplateFile => 'MyKanbanBoard',
        Data         => \%Param
    );
}


sub _OrderColumnsByName {
    my ( $Self, %Param ) = @_;

    my $KanbanObject = $Kernel::OM->Get('Kernel::System::Kanban');

    my @ColumnInOrder;
    my %ColumnInOrderData;

    for my $ColumnID (@{$Param{AssociatedColumn}}){
        my $KanbanColumnName = $KanbanObject->KanbanLookupByID(
            ID => $ColumnID 
        );

        $ColumnInOrderData{$ColumnID} = $KanbanColumnName;
    }

    my @Keys = sort { $ColumnInOrderData{$a} cmp $ColumnInOrderData{$b} } keys %ColumnInOrderData;
 
    return \@Keys;

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