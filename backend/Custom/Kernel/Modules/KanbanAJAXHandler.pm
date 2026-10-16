# --
# Kernel/Modules/KanbanAJAXHandler.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * ghidalgo@serviceup.com.br
# * ccresencio@serviceup.com.br
# * poliveira@serviceup.com.br
# --

package Kernel::Modules::KanbanAJAXHandler;

use strict;
use warnings;

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

    # get objects
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $KanbanObject       = $Kernel::OM->Get('Kernel::System::Kanban');
    my $JSONObject         = $Kernel::OM->Get('Kernel::System::JSON');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $PriorityObject     = $Kernel::OM->Get('Kernel::System::Priority');
    my $QueueObject        = $Kernel::OM->Get('Kernel::System::Queue');
    my $UserObject         = $Kernel::OM->Get('Kernel::System::User');
    my $ArticleObject      = $Kernel::OM->Get('Kernel::System::Ticket::Article');
    my $InBoxLibraryObject = $Kernel::OM->Get('Kernel::System::InBoxLibrary');

    my $JSON =  '{}';

    if ( $Self->{Subaction} eq 'TicketLock' ) {
        # get params
        my $TicketID = $ParamObject->GetParam( Param => 'TicketID' ) || '';
    
        my $Success = $TicketObject->TicketLockSet(
            Lock     => 'lock',
            TicketID => $TicketID,
            UserID   => $Self->{UserID},
        );

        if( $Success ){
            $TicketObject->TicketOwnerSet(
                TicketID  => $TicketID,
                NewUserID => $Self->{UserID},
                UserID    => $Self->{UserID},
            );
        }

        $JSON = $JSONObject->Encode(
            Data     =>  {
                Success => $Success,
            },
            Pretty => 1,           
        );

    }
    elsif ( $Self->{Subaction} eq 'TicketUnlock' ) {
        # get params
        my $TicketID = $ParamObject->GetParam( Param => 'TicketID' ) || '';

        my $Success = $TicketObject->TicketLockSet(
            Lock     => 'unlock',
            TicketID => $TicketID,
            UserID   => $Self->{UserID},
        );

        $JSON = $JSONObject->Encode(
            Data     =>  {
                Success => $Success,
            },
            Pretty => 1,           
        );

    }
    elsif ( $Self->{Subaction} eq 'TicketPrioriyUp' ) {
        # get params
        my $TicketID = $ParamObject->GetParam( Param => 'TicketID' ) || '';

        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $TicketID,
            DynamicFields => 0,        
            UserID        => 1,
        );

        my %Priorities = $TicketObject->TicketPriorityList(
            TicketID => $TicketID,
            UserID   => $Self->{UserID},
        );

        my $QTDOfPriorities = keys %Priorities;
        my $UpdatePrioritiesValue = 1;

        for (my $i = $Ticket{PriorityID}; $i <= $QTDOfPriorities; $i++) {
        
            if($Ticket{PriorityID} < $QTDOfPriorities){
                my $ColorsPriorities = $ConfigObject->Get('Kanban::Core::PrioritiesColor');
                my $NewPriority =  $Ticket{PriorityID} + $UpdatePrioritiesValue;                        
     

                my %List = $PriorityObject->PriorityGet(
                    PriorityID => $NewPriority,
                    UserID     => 1,
                );


                if($List{ValidID} eq '1'){
            
                    my $Priority = $PriorityObject->PriorityLookup(
                        PriorityID =>  $NewPriority,
                    );

                    my $Success = $TicketObject->TicketPrioritySet(
                        TicketID   => $TicketID,
                        PriorityID => $NewPriority,
                        UserID     => $Self->{UserID},
                    );
           
                    if($ColorsPriorities->{$Priority}){
                        $JSON = $JSONObject->Encode(
                            Data     =>  {
                                Success       => $Success,
                                PriorityColor => $ColorsPriorities->{$Priority}
                            },
                            Pretty => 1,           
                        );
                    }else{
                        $JSON = $JSONObject->Encode(
                            Data     =>  {
                                Success       => $Success,
                                PriorityColor => '#c4c4c4'
                            },
                            Pretty => 1,           
                        );
                    }   

                    last;

                }else{
                    $UpdatePrioritiesValue = $UpdatePrioritiesValue + 1;                        
                }     
            }
            
        }

        my $TesteCron = $KanbanObject->RealoadIdemCron();

       
    }
    elsif ( $Self->{Subaction} eq 'TicketPrioriyDown' ) {
        # get params
        my $TicketID = $ParamObject->GetParam( Param => 'TicketID' ) || '';

        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $TicketID,
            DynamicFields => 0,        
            UserID        => 1,
        );

        my %Priorities = $TicketObject->TicketPriorityList(
            TicketID => $TicketID,
            UserID   => $Self->{UserID},
        );

        my $QTDOfPriorities = keys %Priorities;
        my $UpdatePrioritiesValue = 1;
      
        for (my $i = 0; $i <= $QTDOfPriorities; $i++) {
            if($Ticket{PriorityID} > 1){
                my $ColorsPriorities = $ConfigObject->Get('Kanban::Core::PrioritiesColor');

                my $NewPriority =  $Ticket{PriorityID} - $UpdatePrioritiesValue; 
               
                my %List = $PriorityObject->PriorityGet(
                    PriorityID => $NewPriority,
                    UserID     => 1,
                );

                if($List{ValidID} eq '1'){
            
                    my $Priority = $PriorityObject->PriorityLookup(
                        PriorityID =>  $NewPriority,
                    );

                    my $Success = $TicketObject->TicketPrioritySet(
                        TicketID   => $TicketID,
                        PriorityID => $NewPriority,
                        UserID     => $Self->{UserID},
                    );

                    if($ColorsPriorities->{$Priority}){
                        $JSON = $JSONObject->Encode(
                            Data     =>  {
                                Success => $Success,
                                PriorityColor => $ColorsPriorities->{$Priority}
                            },
                            Pretty => 1,           
                        );
                    }else{
                        $JSON = $JSONObject->Encode(
                            Data     =>  {
                                Success => $Success,
                                PriorityColor => '#c4c4c4'
                            },
                            Pretty => 1,           
                        );
                    }   

                    last;

                }else{
                    $UpdatePrioritiesValue = $UpdatePrioritiesValue + 1;                        
                }     
            }
            
        }
        my $TesteCron = $KanbanObject->RealoadIdemCron();

    }
    elsif ( $Self->{Subaction} eq 'TicketDetails' ) {
        # get params
        my $TicketID = $ParamObject->GetParam( Param => 'TicketID' ) || '';

        my $Output = '';

        # get information
        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $TicketID,
            DynamicFields => 1,        
            UserID        => 1,
        );

        my $DetailsValues = $ConfigObject->Get('Kanban::Core::TicketInformationDetails');

        for my $DataLabel (@{$DetailsValues}){
            if($DataLabel eq 'Age'){
                # age design
                $Ticket{Age} = $LayoutObject->CustomerAge(
                    Age   => $Ticket{Age},
                    Space => ' '
                );

                $LayoutObject->Block(
                    Name => 'DataValues',
                    Data => {
                        DataLabel =>  $LayoutObject->{LanguageObject}->Translate($DataLabel),
                        DataValue =>  $LayoutObject->{LanguageObject}->Translate($Ticket{$DataLabel}),
                    }
                );

            }else {
                 
                my $Value = $Ticket{$DataLabel};

                if( $Value ){
                    if( $DataLabel =~ m/DynamicField/  ) {

                        my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

                        my @spl = split('DynamicField_', $DataLabel); 

                        my $DynamicField  = $DynamicFieldObject->DynamicFieldGet(
                            Name => $spl[1],
                        );

                        $DataLabel = $DynamicField->{Label};
                    }

                    $LayoutObject->Block(
                        Name => 'DataValues',
                        Data => {
                            DataLabel =>  $LayoutObject->{LanguageObject}->Translate($DataLabel),
                            DataValue =>  $LayoutObject->{LanguageObject}->Translate($Value),
                        }
                    );
                }

                
            }
           
        }      

        if(%Ticket){
            $Output = $LayoutObject->Output(
                TemplateFile => 'KanbanTicketInformation',
                Data         => \%Ticket,
            );
        }

        $JSON = $LayoutObject->JSONEncode(
            Data     =>  $Output
        );     

    }
    elsif ( $Self->{Subaction} eq 'TicketSetQueue' ) {
        # get params
        my $TicketID = $ParamObject->GetParam( Param => 'TicketID' ) || '';
        my $BoardID = $ParamObject->GetParam( Param => 'BoardID' ) || '';

        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $TicketID,
            DynamicFields => 0,        
            UserID        => 1,
        );
        my $Output = '';

        my %Queues = $QueueObject->GetAllQueues( UserID => $Self->{UserID}, Type => 'ro' );
          
        if(%Queues){
            my $QueuesStrg = $LayoutObject->BuildSelection(
                Data          => \%Queues,
                Name          => 'Queues',
                SelectedValue => $Ticket{Queue},
                PossibleNone  => 0,
                Translation   => 1,
                Sort          => 'AlphaNumericKey',
                Class         => 'Modernize W50pc',
            );
          
            $Output = $LayoutObject->Output(
                TemplateFile => 'KanbanQueueInformation',
                Data         => {
                    QueuesStrg => $QueuesStrg,
                    TicketID => $TicketID,
                    BoardID  => $BoardID
                }
            );
        }

        $JSON = $LayoutObject->JSONEncode(
            Data     =>  $Output
        );     

    }
    elsif ( $Self->{Subaction} eq 'TicketWatchers' ) {
        # get params
        my $TicketID = $ParamObject->GetParam( Param => 'TicketID' ) || '';
        my $BoardID = $ParamObject->GetParam( Param => 'BoardID' ) || '';

        my $Output = '';

         my %List = $UserObject->UserList(
            Type          => 'Long', 
            Valid         => 1,       
            NoOutOfOffice => 1      
        );
          
        if(%List){
            my @Watch = $TicketObject->TicketWatchGet(
                TicketID => $TicketID,
                Result => 'ARRAY',
            );
            
           
            my $WatchersStrg  = $LayoutObject->BuildSelection(
                Data          => \%List,
                Name          => 'Users',
                SelectedID    => \@Watch,
                PossibleNone  => 1,
                Translation   => 1,
                Sort          => 'AlphaNumericKey',
                Class         => 'Modernize W30pc',
                Multiple      => 1
            );
          
            $Output = $LayoutObject->Output(
                TemplateFile => 'KanbanWatchersInformation',
                Data         => {
                    WatchersStrg => $WatchersStrg,
                    TicketID => $TicketID,
                    BoardID  => $BoardID
                }
            );
        }

        $JSON = $LayoutObject->JSONEncode(
            Data     =>  $Output
        );     

    }
    elsif($Self->{Subaction} eq 'TicketUpdateNewWatchers'){
        my $TicketID = $ParamObject->GetParam(Param => 'TicketID') || '';
        my $BoardID = $ParamObject->GetParam( Param => 'BoardID' ) || '';
        my %GetParam;
        my %List = $UserObject->UserList(
            Type          => 'Long', 
            Valid         => 1,       
            NoOutOfOffice => 1      
        );

        @{$GetParam{UserIDs}} = $ParamObject->GetArray( Param => "Users" );

        for my $UserID (keys %List){
            my $Success = $TicketObject->TicketWatchUnsubscribe(
                TicketID => $TicketID,
                WatchUserID => $UserID,
                UserID => $Self->{UserID},
            );            
        }

        for my $AgentID (@{$GetParam{UserIDs}}) {

            my $Success = $TicketObject->TicketWatchSubscribe(
                TicketID => $TicketID,
                WatchUserID => $AgentID,
                UserID => $Self->{UserID},
            );           
        }

         

        return $LayoutObject->Redirect(
            OP => "Action=AgentKanban;Subaction=KanbanBoard;BoardID=$BoardID",
        );

    }
    elsif ( $Self->{Subaction} eq 'TicketSetTag' ) {
        # get params
        my $TicketID = $ParamObject->GetParam( Param => 'TicketID' ) || '';
        my $BoardID = $ParamObject->GetParam( Param => 'BoardID' ) || '';

        # my %Ticket = $TicketObject->TicketGet(
        #     TicketID      => $TicketID,
        #     DynamicFields => 0,        
        #     UserID        => 1,
        # );

        my @KanbanTagsList = $KanbanObject->TagsList(
            ValidID => 1
        );

        my @TagInBoard;
        for my $TagID (@KanbanTagsList){
            my $Tags = $KanbanObject->TagsGet(
                ID => $TagID
            );
            
            my @AssociatedBoards = split ",", $Tags->{AssociatedBoards};

            for my $AssociateBoard ( @AssociatedBoards ){
                if( $BoardID eq $AssociateBoard ){
                    push @TagInBoard, $Tags;
                }
            }
        }

        for my $Tag( @TagInBoard ){

            $LayoutObject->Block(
                Name => 'TagField',
                Data => { 
                    %{$Tag},
                    TicketID => $TicketID,
                    BoardID  => $BoardID
                },
            );   
        }
        my $Output = '';
       
        if(scalar @TagInBoard > 0){           
          
            $Output = $LayoutObject->Output(
                TemplateFile => 'KanbanTagInformation',
                Data         => {
                    TicketID => $TicketID,
                    BoardID  => $BoardID
                }
            );
        }

        $JSON = $LayoutObject->JSONEncode(
            Data     =>  $Output
        );     

    }
    elsif ( $Self->{Subaction} eq 'AddTicketTag' ) {
        my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
        my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');
        my $BackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

        # get params
        my $TicketID = $ParamObject->GetParam( Param => 'TicketID' ) || '';
        my $BoardID = $ParamObject->GetParam( Param => 'BoardID' ) || '';
        my $TagID = $ParamObject->GetParam( Param => 'TagID' ) || '';

        my $DynamicField  = $DynamicFieldObject->DynamicFieldGet(
            Name => 'TagsOfKanban',
        );

        my $Tag = $KanbanObject->TagsGet(
            ID => $TagID 
        );

        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $TicketID,
            DynamicFields => 1,        
            UserID        => 1,
        );

        my @ArrayOfTags;
        if($Ticket{DynamicField_TagsOfKanban}){
            for (@{$Ticket{DynamicField_TagsOfKanban}}){                
                push @ArrayOfTags, $_;            
            }

            # To remove tag if was clicked
            if ( my ($matched) = grep $_ eq $Tag->{ID}, @ArrayOfTags ) {
                my $index = 0;
                $index++ until $ArrayOfTags[$index] eq $Tag->{ID};
                splice(@ArrayOfTags, $index, 1);
            }
            else{
                push @ArrayOfTags, $Tag->{ID};
            }

        }else{
            push @ArrayOfTags, $Tag->{ID};
        }

        my $Success = $BackendObject->ValueSet(
            DynamicFieldConfig => $DynamicField,    
            ObjectID           => $TicketID,                                            
            Value              => \@ArrayOfTags,                   
            UserID             => 1,
        );

        $JSON = $LayoutObject->JSONEncode(
            Data     =>  {
               Success => '1',
            }

        );     

    }
    elsif ( $Self->{Subaction} eq 'TicketUpdateNewQueue' ) {
        # get params
        my $TicketID = $ParamObject->GetParam( Param => 'TicketID' ) || '';
        my $Queues   = $ParamObject->GetParam( Param => 'Queues' ) || '';
        my $BoardID  = $ParamObject->GetParam( Param => 'BoardID' ) || '';

        my $Success = $TicketObject->TicketQueueSet(
            QueueID  => $Queues,
            TicketID => $TicketID,
            UserID   => $Self->{UserID},
        );

        my $TesteCron = $KanbanObject->RealoadIdemCron();

        return $LayoutObject->Redirect(
            OP => "Action=AgentKanban;Subaction=KanbanBoard;BoardID=$BoardID",
        );

       
    }
    elsif ( $Self->{Subaction} eq 'TicketChangeOfColumn' ) {

        my $TicketID          = $ParamObject->GetParam( Param => 'TicketID' ) || '';
        my $TicketBelow       = $ParamObject->GetParam( Param => 'TicketBelow' ) || '';
        my $NewColumnID       = $ParamObject->GetParam( Param => 'NewColumnID' ) || '';        
        my $OldColumn         = $ParamObject->GetParam( Param => 'OldColumn' ) || '';
        my $BoardID           = $ParamObject->GetParam( Param => 'BoardID' ) || '';
        my $OldColumnsTickets = $ParamObject->GetParam( Param => 'OldColumnsTickets' ) || '';
        my $NewColumnsTickets = $ParamObject->GetParam( Param => 'NewColumnsTickets' ) || '';

        my $PermissionInQueue = $ConfigObject->Get('Kanban::Core::Permission');

        my $ColumnDatatoMove = $KanbanObject->KanbanGet(
            ID => $NewColumnID
        );

        # Verify User permission in queue
        my %Queues = $QueueObject->GetAllQueues( 
            UserID => $Self->{UserID}, 
            Type => $PermissionInQueue 
        );
     
        if ( exists($Queues{$ColumnDatatoMove->{QueueToMove}}) || !$ColumnDatatoMove->{QueueToMove} ) {

            # To old column
            my $OldColumnRemoveData = $KanbanObject->ColumnOrdinanceDelete(
                BoardID => $BoardID, 
                ColumnID => $OldColumn,
            );

            my $OldColumnOrdinanceAdd = $KanbanObject->ColumnOrdinanceAdd(
                BoardID        => $BoardID, 
                ColumnID       => $OldColumn,
                OrderOfTickets => $OldColumnsTickets,            
            );

            my $NewColumnRemoveData = $KanbanObject->ColumnOrdinanceDelete(
                BoardID  => $BoardID, 
                ColumnID => $NewColumnID,
            );

            if($ColumnDatatoMove->{ManualSorting} eq '0' || $ColumnDatatoMove->{ManualSorting} eq undef ){

                if( $ColumnDatatoMove->{Ordination} eq 'Priority'){
                    $NewColumnsTickets = $KanbanObject->OrderTicketsByPriority(
                        TicketIDs        => $JSONObject->Decode(Data => $NewColumnsTickets),
                        SeverityOrder    => $ColumnDatatoMove->{SeverityOrder},
                        ManualOrdination => $ColumnDatatoMove->{ManualSorting},
                        BoardID          =>	$BoardID,
                        ColumnID         => $ColumnDatatoMove->{ID},
                    );
                }
                elsif( $ColumnDatatoMove->{Ordination} eq 'Age'){
                    $NewColumnsTickets = $KanbanObject->OrderTicketsByAge(
                        TicketIDs        => $JSONObject->Decode(Data => $NewColumnsTickets),
                        SeverityOrder    => $ColumnDatatoMove->{SeverityOrder},
                        ManualOrdination => $ColumnDatatoMove->{ManualSorting},
                        BoardID          =>	$BoardID,
                        ColumnID         => $ColumnDatatoMove->{ID},
                    );
                }
                elsif( $ColumnDatatoMove->{Ordination} eq 'Owner'){
                    $NewColumnsTickets = $KanbanObject->OrderTicketsByOwner(
                        TicketIDs        => $JSONObject->Decode(Data => $NewColumnsTickets),
                        SeverityOrder    => $ColumnDatatoMove->{SeverityOrder},
                        ManualOrdination => $ColumnDatatoMove->{ManualSorting},
                        BoardID          =>	$BoardID,
                        ColumnID         => $ColumnDatatoMove->{ID},
                    );
                }
                elsif( $ColumnDatatoMove->{Ordination} eq 'Solution SLA' ){
                    $NewColumnsTickets = $KanbanObject->OrderSolutionSLA(
                        TicketIDs        => $JSONObject->Decode(Data => $NewColumnsTickets),
                        SeverityOrder    => $ColumnDatatoMove->{SeverityOrder},
                        ManualOrdination => $ColumnDatatoMove->{ManualSorting},
                        BoardID          =>	$BoardID,
                        ColumnID         => $ColumnDatatoMove->{ID},
                    );
                }
                else{                    
                    # By Dynamic Field 
                    $NewColumnsTickets = $KanbanObject->OrderTicketsByDynamicField(
                        TicketIDs        => $JSONObject->Decode(Data => $NewColumnsTickets),
                        SeverityOrder    => $ColumnDatatoMove->{SeverityOrder},
                        DynamicFieldName =>  $ColumnDatatoMove->{Ordination},
                        ManualOrdination => $ColumnDatatoMove->{ManualSorting},
                        BoardID          =>	$BoardID,
                        ColumnID         => $ColumnDatatoMove->{ID},
                    );
                }
                 
                # To new column             
                my $NewColumnOrdinanceAdd = $KanbanObject->ColumnOrdinanceAdd(
                    BoardID        => $BoardID, 
                    ColumnID       => $NewColumnID,
                    OrderOfTickets => $JSONObject->Encode(Data => $NewColumnsTickets),          
                );

                # Update the dynmaicfield value to new column            
                my $SucessToSetDFField = $KanbanObject->TicketSetDynamicFieldPosition(
                    TicketPosition => $NewColumnsTickets,
                );

                my $Output = $LayoutObject->Output(
                    TemplateFile => 'KanbanErrorPopUp',
                    Data         => {
                        Message => $LayoutObject->{LanguageObject}->Translate('This column cannot be sorted manually. The calling card will be reordered.')
                    }
                );

                $JSON = $LayoutObject->JSONEncode(
                    Data     => {
                        Message => $Output 
                    }
                
                ); 
        
            }else{
                
                # To manual ordiance   
                # To new column              
                my $NewColumnOrdinanceAdd = $KanbanObject->ColumnOrdinanceAdd(
                    BoardID        => $BoardID, 
                    ColumnID       => $NewColumnID,
                    OrderOfTickets => $NewColumnsTickets,            
                );

                # Update the dynmaicfield value to new column            
                my $SucessToSetDFField = $KanbanObject->TicketSetDynamicFieldPosition(
                    TicketPosition =>  $JSONObject->Decode(Data => $NewColumnsTickets),
                );
        
            }                    

           
            if($ColumnDatatoMove->{QueueToMove}){
                my $SuccessSetQueue = $TicketObject->TicketQueueSet(
                    QueueID    => $ColumnDatatoMove->{QueueToMove},
                    TicketID   => $TicketID ,
                    UserID     => $Self->{UserID},
                );

                my $SuccessSetHistoryQueue = $TicketObject->HistoryAdd(
                    Name         => $LayoutObject->{LanguageObject}->Translate('Queue change by InBox Kanban'),
                    HistoryType  => 'Move', 
                    TicketID     => $TicketID,
                    CreateUserID => $Self->{UserID},
                );
            }

            if($ColumnDatatoMove->{StateToMove}){               
                my $SuccessSetState = $TicketObject->TicketStateSet(
                    StateID  => $ColumnDatatoMove->{StateToMove},
                    TicketID => $TicketID ,
                    UserID   => $Self->{UserID},
                );

                my $SuccessSetHistoryState = $TicketObject->HistoryAdd(
                    Name         => $LayoutObject->{LanguageObject}->Translate('State change by InBox Kanban'),
                    HistoryType  => 'StateUpdate', 
                    TicketID     => $TicketID,
                    CreateUserID => $Self->{UserID},
                );
            }

            if($ColumnDatatoMove->{PriorityToMove}){               
                my $SuccessSetPrio = $TicketObject->TicketPrioritySet(
                    PriorityID   => $ColumnDatatoMove->{PriorityToMove},
                    TicketID     => $TicketID ,
                    UserID       => $Self->{UserID},
                );

                my $SuccessSetHistoryPrio = $TicketObject->HistoryAdd(
                    Name         => $LayoutObject->{LanguageObject}->Translate('Priority change by InBox Kanban'),
                    HistoryType  => 'PriorityUpdate', 
                    TicketID     => $TicketID,
                    CreateUserID => $Self->{UserID},
                );
            }
            
         
        }
        else {
            
            my $Output = $LayoutObject->Output(
                TemplateFile => 'KanbanErrorPopUp',
                Data         => {
                    Message => $LayoutObject->{LanguageObject}->Translate('Sorry, you have not permission to do this action')
                }
            );

            $JSON = $LayoutObject->JSONEncode(
                Data     => {
                    Message => $Output 
                }
              
            ); 
        }
       
    }
    elsif ( $Self->{Subaction} eq 'TicketChangeOwnerAndResponsible' ) {

        my $TicketID = $ParamObject->GetParam( Param => 'TicketID' ) || '';
        my $BoardID  = $ParamObject->GetParam( Param => 'BoardID' ) || '';
        my $TypeUser = $ParamObject->GetParam( Param => 'TypeUser' ) || '';
        
        my $PermissionInQueue = $ConfigObject->Get('Kanban::Core::Permission');

        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $TicketID,
            DynamicFields => 0,        
            UserID        => 1,
        );

        my %UserList = $UserObject->UserList(
            Type          => 'Long',
            Valid         => 1,
            NoOutOfOffice => 1,
        );

        my $Output = '';
        my @ArrayOfUserQueues;
        
        my %List;

        for my $UserId (keys %UserList){
            # Check user queue permissions
            my %QueuesOfUser = $QueueObject->GetAllQueues(
                UserID => $UserId,
                Type => $PermissionInQueue
            );

            # Saves to the array only users allowed in that queue
            for my $QueueUser (keys %QueuesOfUser){
                if($Ticket{QueueID} eq $QueueUser){
                    $List{$UserId} = $UserList{$UserId};
                    push @ArrayOfUserQueues, \%List;
                }
            }
        }

        if(%List){
            my $OwnersStrg;
            if( $TypeUser eq 'Owner'){
                $OwnersStrg = $LayoutObject->BuildSelection(
                    Data          => \%List,
                    Name          => 'Owners',
                    SelectedID => $Ticket{OwnerID},
                    PossibleNone  => 0,
                    Translation   => 1,
                    Sort          => 'AlphaNumericKey',
                    Class         => 'Modernize W50pc',
                );
            }else{
                $OwnersStrg = $LayoutObject->BuildSelection(
                    Data          => \%List,
                    Name          => 'Owners',
                    SelectedID => $Ticket{ResponsibleID},
                    PossibleNone  => 0,
                    Translation   => 1,
                    Sort          => 'AlphaNumericKey',
                    Class         => 'Modernize W50pc',
                );
            }
          
            $Output = $LayoutObject->Output(
                TemplateFile => 'KanbanOwnerAndResponsibleInformation',
                Data         => {
                    OwnersStrg => $OwnersStrg,
                    TicketID   => $TicketID,
                    BoardID    => $BoardID,
                    TypeUser   => $TypeUser
                }
            );
        }

        $JSON = $LayoutObject->JSONEncode(
            Data     =>  $Output
        );     
    }
    elsif ( $Self->{Subaction} eq 'TicketUpdateNewOwner' ) {

        # get params
        my $TicketID = $ParamObject->GetParam( Param => 'TicketID' ) || '';
        my $Owners = $ParamObject->GetParam( Param => 'Owners' ) || '';
        my $BoardID = $ParamObject->GetParam( Param => 'BoardID' ) || '';
        my $TypeUser = $ParamObject->GetParam( Param => 'TypeUser' ) || '';
        my $Success;

        if($TypeUser eq 'Owner'){
            $Success = $TicketObject->TicketOwnerSet(
                TicketID  => $TicketID,
                NewUserID => $Owners,
                UserID    => $Self->{UserID},
            );
        }else{
            $Success = $TicketObject->TicketResponsibleSet(
                TicketID  => $TicketID,
                NewUserID =>  $Owners,
                UserID    => $Self->{UserID},
            );
        }
        
        return $LayoutObject->Redirect(
            OP => "Action=AgentKanban;Subaction=KanbanBoard;BoardID=$BoardID",
        );
       
    }
    elsif ( $Self->{Subaction} eq 'TicketShare' ) {

        # get params
        my $TicketID = $ParamObject->GetParam( Param => 'TicketID' ) || '';
        my $BoardID = $ParamObject->GetParam( Param => 'BoardID' ) || '';

        my $ArticleToSplit = $ConfigObject->Get('Kanban::Core::ArticleToSplit');

        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $TicketID,
            DynamicFields => 0,        
            UserID        => 1,
        );
        my $Output = '';

        my %Options = (
            EmailTicket =>  $LayoutObject->{LanguageObject}->Translate('Ticket Email'),
            PhoneTicket =>  $LayoutObject->{LanguageObject}->Translate('Ticket Phone')
        );
   
        my $OptionsStrg = $LayoutObject->BuildSelection(
            Data          => \%Options,
            Name          => 'SplitSelection',
            SelectedValue => 'EmailTicket',
            PossibleNone  => 0,
            Translation   => 1,
            Sort          => 'AlphaNumericKey',
            Class         => 'Modernize W50pc',
        );

        my $ArticleID;
        my @Articles;
        if($ArticleToSplit eq '1'){
            @Articles = $ArticleObject->ArticleList(

                TicketID   => $TicketID,
                OnlyLast   => 1,                
            );
           
        }else{
            @Articles = $ArticleObject->ArticleList(

                TicketID    => $TicketID,
                OnlyFirst   => 1,                
            );
  
        }

        $ArticleID = $Articles[0]{ArticleID};
        
        $Output = $LayoutObject->Output(
            TemplateFile => 'KanbanShareInformation',
            Data         => {
                OptionsStrg => $OptionsStrg,
                TicketID    => $TicketID,
                BoardID     => $BoardID,
                ArticleID   => $ArticleID
            }
        );
 

        $JSON = $LayoutObject->JSONEncode(
            Data     =>  $Output
        );     
    }
    elsif ( $Self->{Subaction} eq 'NewTicket') {

        my $ActionToOpen = $ConfigObject->Get("Kanban::Core::OpenTicketBy");

        my $URLLink;
        if($ActionToOpen eq '0'){
            $URLLink = '/' . $ConfigObject->Get('ScriptAlias') . 'index.pl?Action=AgentTicketPhone;OpenBy=Kanban';
        }elsif($ActionToOpen eq '1'){
            $URLLink = '/' . $ConfigObject->Get('ScriptAlias') . 'index.pl?Action=AgentTicketEmail;OpenBy=Kanban';
        }elsif($ActionToOpen eq '2'){
            $URLLink = '/' . $ConfigObject->Get('ScriptAlias') . 'index.pl?Action=AgentTicketProcess;OpenBy=Kanban';
        }

        $JSON = $LayoutObject->JSONEncode(
            Data     =>  $URLLink 
        );     


    }
    elsif ( $Self->{Subaction} eq 'TicketSLA' ) {
        # get params
        my $TicketID = $ParamObject->GetParam( Param => 'TicketID' ) || '';

        # get information
        my %Ticket = $TicketObject->TicketGet(
            TicketID  => $TicketID,     
            Extendend => 1,     
            UserID    => 1
        );

        if ( defined $Ticket{SolutionTime} ) {

            my $SolutionTime = $LayoutObject->CustomerAge(
                Age                => $Ticket{SolutionTime},
                TimeShowAlwaysLong => 1,
                Space              => ' '
            );

            my $Class = '';
            if ( $Ticket{SolutionTime} < 0 ) {
                $Class = 'Warning';
            }

            $LayoutObject->Block(
                Name => 'DataValues',
                Data => {
                    DataLabel                   => $LayoutObject->{LanguageObject}->Translate('Solution Time'),
                    DataSolutionTime            => $SolutionTime,
                    DataSolutionTimeDestination => $Ticket{SolutionTimeDestinationDate},
                    SLAClass                    => $Class
                }
            );
        }
        else {

            my $StatusSLA = $InBoxLibraryObject->SLAStatusSolutionTime(
                TicketID => $TicketID
            );

            my $Class = '';
            if ( $StatusSLA->{SLAStatus} eq 'SLA OUT' ) {
                $Class = 'Warning';
            }

            $LayoutObject->Block(
                Name => 'DataValues',
                Data => {
                    DataLabel                   => $LayoutObject->{LanguageObject}->Translate('Solution Time'),
                    DataSolutionTimeDestination => $StatusSLA->{SLACreateTime} || $LayoutObject->{LanguageObject}->Translate('SLA In'),
                    SLAClass                    => $Class
                }
            );
        }
        
        my $Output = $LayoutObject->Output(
            TemplateFile => 'KanbanTicketSLA',
            Data         => \%Ticket,
        );

        $JSON = $LayoutObject->JSONEncode(
            Data     =>  $Output
        );
    }
    
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON || '',
        Type        => 'inline',
        NoCache     => 1,
    );
}

1;