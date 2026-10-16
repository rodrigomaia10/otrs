# --
# Kernel/Output/HTML/TicketZoom/AgentEasyCategorization.pm
# Copyright (C) 2019 Service Up http://www.serviceup.com.br
# --
# written/edited by:
# * pdias@beonup.com.br
# * gesquetini@beonup.com.br
# * mbernardo@beonup.com.br
# * ccresencio@serviceup.com.br
# * poliveira@serviceup.com.br
# * lcavalheiro@serviceup.com.br
# * dparavani@serviceup.com.br
# * gbolsoni@serviceup.com.br
# --

package Kernel::Output::HTML::TicketZoom::AgentEasyCategorization;

use strict;
use warnings;
use utf8; 

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

    # get needed objects
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $QueueObject        = $Kernel::OM->Get('Kernel::System::Queue');
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
	my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
	my $EasyCategorizationObject = $Kernel::OM->Get('Kernel::System::EasyCategorization');
    

	my $JSBlock;

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Self->{TicketID},
        DynamicFields => 1,
        UserID        => $Self->{UserID},
        Silent        => 1,
    );

    # get ACL restrictions
    my %PossibleActions = ( 1 => $Self->{Action} );

    my $Success = $TicketObject->TicketAcl(
        Data          => \%PossibleActions,
        Action        => $Self->{Action},
        TicketID      => $Self->{TicketID},
        ReturnType    => 'Action',
        ReturnSubType => '-',
        UserID        => $Self->{UserID},
    );

    #Gets the statuses configured to be blocked
    my $StateBlock = $ConfigObject->Get('InBox::EasyCategorization::Config')->{StateBlock};   
    
    #Gets the status of the current ticket
    my $NameState = $EasyCategorizationObject->GetSatateTicket( TicketID => $Self->{TicketID});

    my $EasyCategorizationBlock = 0;

    #Checks the status of the ticket to be blocked
    my $IsInArray = 0;

    for my $State ( @{$StateBlock} ) {

        if ( $State eq $NameState ) {
            $IsInArray = 1;
            last;  
        }
    }

    if ( $IsInArray ) {
        $EasyCategorizationBlock = 1;
    }

    $TicketObject->TicketAclActionData();

    my %GetParam;
    for my $Key (
        qw(
        NewStateID NewPriorityID TimeUnits ArticleTypeID Title Subject NewQueueID
        Year Month Day Hour Minute NewOwnerID NewResponsibleID TypeID ServiceID SLAID
        Expand ReplyToArticle StandardTemplateID CreateArticle CustomerUser 
        )
        )
    {
        $GetParam{$Key} = $ParamObject->GetParam( Param => $Key );
    }

    $GetParam{Action} = "AgentEasyCategorization";

    my %Queues = $QueueObject->GetAllQueues( 
            UserID => $Self->{UserID}, 
            Type   => 'rw' 
    );

	# data structure
    my %Data;

    $Data{TicketID} = $Self->{TicketID};

    if ( $ConfigObject->Get('InBox::EasyCategorization::Config')->{Type} ){

        my $Types = {};

        if ( $Queues{ $Ticket{QueueID} } ) { 
            $Types = $EasyCategorizationObject->GetTypeList(
                %GetParam,
                %Ticket,
                TicketID => $Self->{TicketID},
                UserID   => $Self->{UserID}
            );
        }

        $Data{TypeStrg} = $LayoutObject->BuildSelection( 
            Data        => $Types,
            Name        => 'TypeID',
            SelectedID  => $Ticket{TypeID},
            Size        => 5,
            Multiple    => 0,
            TreeView    => 1,
            Translation => 1,
            Max         => 32,
            Class       => 'Modernize 40pc',
            Disabled    => $EasyCategorizationBlock,           
        );

        $LayoutObject->Block(
            Name => 'Type',
            Data => {%Data},
        );
    }

    if ( $ConfigObject->Get('InBox::EasyCategorization::Config')->{Service} ){

        my $Services = {};

        if ( $Queues{ $Ticket{QueueID} } ) { 
            $Services = $EasyCategorizationObject->GetServiceList(
                %GetParam,
                %Ticket,
                TicketID       => $Self->{TicketID},
                CustomerUserID => $Ticket{CustomerUserID},
                QueueID        => $Ticket{QueueID},
                Action		   => $Self->{Action},
                UserID         => $Self->{UserID},
            );
        }

        if (!$Services->{$Ticket{ServiceID}}) {
            $Ticket{ServiceID} = "";
            $Ticket{SLAID} = "";
        }

        $Data{ServiceSrtg} = $LayoutObject->BuildSelection(
            Data        => $Services,
            Name        => 'ServiceID',
            SelectedID  => $Ticket{ServiceID},
            Size        => 5,
            Multiple    => 0,
            TreeView    => 1,
            Translation => 0,
            Max         => 31,
            Class       => 'Modernize W40pc',
            Disabled    => $EasyCategorizationBlock,
        );

        my $SLAs = {};
        if ( $Queues{ $Ticket{QueueID} } ) {
            $SLAs = $EasyCategorizationObject->GetSLAList(
                %GetParam,
                %Ticket,
                UserID => $Self->{UserID},
                Action => $Self->{Action},
            );
        }

        $Data{SLAStrg} .= $LayoutObject->BuildSelection(
            Data        => $SLAs,
            Name        => 'SLAID',
            SelectedID  => $Ticket{SLAID},
            Size        => 5,
            Multiple    => 0,
            TreeView    => 1,
            Translation => 0,
            Max         => 32,
            Class       => 'Modernize W40pc',
            Disabled    => $EasyCategorizationBlock,
        );

        $LayoutObject->Block(
            Name => 'ServiceAndSLA',
            Data => {%Data},
        );
    }

    if ( $ConfigObject->Get('InBox::EasyCategorization::Config')->{Priority} ){

        my $Priorities = {};

        if ( $Queues{ $Ticket{QueueID} } ) {
            $Priorities = $EasyCategorizationObject->GetPriorityList(
                %GetParam,
                %Ticket,
                TicketID => $Self->{TicketID},
                Action	 => $Self->{Action},
                UserID   => $Self->{UserID},
            );
        }

        $Data{PriorityStrg} = $LayoutObject->BuildSelection(
            Data        => $Priorities,
            Name        => 'PriorityID',
            SelectedID  => $Ticket{PriorityID},
            Size        => 5,
            Multiple    => 0,
            TreeView    => 0,
            Translation => 1,
            Max         => 30,
            Class       => 'Modernize W49pc',
            Disabled    => $EasyCategorizationBlock,
        );

        $LayoutObject->Block(
            Name => 'Priority',
            Data => {%Data},
        );
    }

    if ( $ConfigObject->Get('InBox::EasyCategorization::Config')->{State} ){
      
        my $States = {};

        if ( $Queues{ $Ticket{QueueID} } ) {
            $States = $EasyCategorizationObject->GetStateList(
                %GetParam,
                TicketID => $Self->{TicketID},
                UserID   => $Self->{UserID},
            );
        }

        $Data{StateStrg} = $LayoutObject->BuildSelection(
            Data        => $States,
            Name        => 'StateID',
            SelectedID  => $Ticket{StateID},
            Size        => 5,
            Multiple    => 0,
            TreeView    => 1,
            Translation => 1,
            Max         => 30,
            Class       => 'Modernize W49pc',
            Disabled    => $EasyCategorizationBlock,
        );

        $LayoutObject->Block(
            Name => 'State',
            Data => {%Data},
        );
    }

    if ( $ConfigObject->Get('InBox::EasyCategorization::Config')->{Responsible} ){        
        
        my $Responsibles = {};

        if ( $Queues{ $Ticket{QueueID} } ) {
            $Responsibles = $EasyCategorizationObject->GetResponsibleList(
                %GetParam,
                %Ticket,
                TicketID => $Self->{TicketID},
                UserID   => $Self->{UserID},
            );
        }

        $Data{ResponsibleStrg} = $LayoutObject->BuildSelection(
            Data        => $Responsibles,
            Name        => 'ResponsibleID',
            SelectedID  => $Ticket{ResponsibleID},
            Size        => 5,
            Multiple    => 0,
            TreeView    => 1,
            Translation => 1,
            Max         => 30,
            Class       => 'Modernize W49pc',
            Disabled    => $EasyCategorizationBlock,
        );

        $LayoutObject->Block(
            Name => 'Responsible',
            Data => {%Data},
        );
    }

    if ( $ConfigObject->Get('InBox::EasyCategorization::Config')->{Queue} ){
        
        my $QueuesList = {};   
      
        if ( $Queues{ $Ticket{QueueID} } ) {    
            $QueuesList = $EasyCategorizationObject->GetQueueList(
                %GetParam,
                TicketID => $Self->{TicketID},
                UserID   => $Self->{UserID},
            );
        }
            
        $Data{StateStrg} = $LayoutObject->BuildSelection(
            Data        => $QueuesList,
            Name        => 'QueueID',
            SelectedID  => $Ticket{QueueID},
            Size        => 5,
            Multiple    => 0,
            TreeView    => 1,
            Translation => 1,
            Max         => 30,
            Class       => 'Modernize W49pc',
            Disabled    => $EasyCategorizationBlock,
        );

        $LayoutObject->Block(
            Name => 'Queue',
            Data => {%Data},
        );   
             
    }

    if ( $ConfigObject->Get('InBox::EasyCategorization::Config')->{Owner} ){        
        
        my $Owner = {};

        if ( $Queues{ $Ticket{QueueID} } ) {     
            $Owner = $EasyCategorizationObject->GetOwnerList(
                %GetParam,
                %Ticket,
                TicketID => $Self->{TicketID},
                UserID   => $Self->{UserID},
            );
        }
        
        $Data{StateStrg} = $LayoutObject->BuildSelection(
            Data        => $Owner,
            Name        => 'OwnerID',
            SelectedID  => $Ticket{OwnerID},
            Size        => 5,
            Multiple    => 0,
            TreeView    => 1,
            Translation => 1,
            Max         => 30,
            Class       => 'Modernize W49pc',
            Disabled    => $EasyCategorizationBlock,
        );

        $LayoutObject->Block(
            Name => 'Owner',
            Data => {%Data},
        );
    }

    if ( $ConfigObject->Get('InBox::EasyCategorization::Config')->{Lock} ){

        my $Lock = {};

        if ( $Queues{ $Ticket{QueueID} } ) { 

            $Lock = {
                1 => 'Unlocked',
                2 => 'Locked',
            }
        }

        $Data{LockStrg} = $LayoutObject->BuildSelection(
            Data        => $Lock,
            Name        => 'LockID',
            SelectedID  => $Ticket{LockID},
            Size        => 5,
            Multiple    => 0,
            TreeView    => 1,
            Translation => 1,
            Max         => 30,
            Class       => 'Modernize W49pc',
            Disabled    => $EasyCategorizationBlock,
        );

        $LayoutObject->Block(
            Name => 'LockUnlock',
            Data => {%Data},
        );
    }

	if ( $ConfigObject->Get('InBox::EasyCategorization::Config')->{DynamicFields} ){
		my $DynamicFieldsConfig = $ConfigObject->Get('InBox::EasyCategorization::Config')->{DynamicFields};
		DYNAMICFIELD:
		for my $DynamicField (@{$DynamicFieldsConfig}){
			#If fieldType dropdown
            my $SelectedDynamicField = {};
            if ( $Queues{ $Ticket{QueueID} } ) { 
                $SelectedDynamicField = $DynamicFieldObject->DynamicFieldGet(
                    Name => $DynamicField,
                );
            }
			if (%{$SelectedDynamicField}){

				my $Value = $BackendObject->ValueGet(
					DynamicFieldConfig => $SelectedDynamicField,
					ObjectID           => $Self->{TicketID},
				);

				next DYNAMICFIELD if( ($SelectedDynamicField->{FieldType} ne "Contract" || $SelectedDynamicField->{FieldType} ne "Dropdown"  || $SelectedDynamicField->{FieldType} ne "Date" || $SelectedDynamicField->{FieldType} ne "DateTime" || $SelectedDynamicField->{FieldType} ne "Text" ) 
                                    && ($SelectedDynamicField->{ObjectType} ne "Ticket") );

				$Data{ID}    = $SelectedDynamicField->{Name};
				$Data{Label} = $SelectedDynamicField->{Label};
                $Data{List}  = $SelectedDynamicField->{Config}->{PossibleValues};

                my %Format;
                my @ARFormat;
                my $TreeView = 0;
    
                if( $SelectedDynamicField->{FieldType} eq 'Contract' ){

                    return if(!$Ticket{CustomerID});

                    my $ContractObject = $Kernel::OM->Get('Kernel::System::ContractManagement');

                    my %List = $ContractObject->ContractCompany(
                        CustomerID => $Ticket{CustomerID}, 
                        Valid      => 1 
                    );

                    $Data{List} = \%List;

                    $Data{DynamicField} = $LayoutObject->BuildSelection(
                        Data        => $Data{List},
                        Name        => $Data{ID},
                        SelectedID  => $Value,
                        Size        => 5,
                        Multiple    => 0,
                        TreeView    => $TreeView,
                        Translation => 1,
                        Max         => 30,
                        Class       => 'Modernize W40pc DynamicFieldEasy',
                        Disabled    => $EasyCategorizationBlock,
                        %Format,
                    );
                }
                elsif($SelectedDynamicField->{FieldType} eq 'Dropdown' && $SelectedDynamicField->{Config}{FormatOrderField}){

                    $TreeView = $SelectedDynamicField->{Config}{TreeView};
                    
                    @ARFormat = split(';', $SelectedDynamicField->{Config}{FormatOrderField});
                    
                    $Format{Sort} = 'IndividualKey';
                    $Format{SortIndividual} = \@ARFormat;
                    
                    $Data{DynamicField} = $LayoutObject->BuildSelection(
                        Data        => $Data{List},
                        Name        => $Data{ID},
                        SelectedID  => $Value,
                        Size        => 5,
                        Multiple    => 0,
                        TreeView    => $TreeView,
                        Translation => 1,
                        Max         => 30,
                        Class       => 'Modernize W40pc DynamicFieldEasy',
                        Disabled    => $EasyCategorizationBlock,
                        %Format,
                    );
                }
                elsif( $SelectedDynamicField->{FieldType} eq 'Date' ||  $SelectedDynamicField->{FieldType} eq 'DateTime' ){                    
                    my $DateField = $BackendObject->EditFieldRender(
                        DynamicFieldConfig   => $SelectedDynamicField,
                        LayoutObject         => $LayoutObject,
                        ParamObject          => $ParamObject,
                        Value                => $Value,
                        Class                => 'ECDateField DynamicFieldEasy',
                    );

                    $Data{DynamicField} = $DateField->{Field} . "<button id='DynamicField_$Data{ID}_Check' class='FieldECDateButton' type='button'><span><i class='fa fa-check'></i></span></button>";

                    # add js function to DynamicFieldIDs Date
				    $JSBlock .= <<"JS_PRIORITY_BLOCK";

\$('#DynamicField_$Data{ID}_Check').bind('click', function () {
	\$("#AJAXLoader$Data{ID}").css("display","");

    Core.Agent.EasyCategorization.DynamicFieldDateUpdate($Self->{TicketID},"$Data{ID}");
});
JS_PRIORITY_BLOCK

                }
                elsif( $SelectedDynamicField->{FieldType} eq 'Text' ){    
                    my $DateField = $BackendObject->EditFieldRender(
                        DynamicFieldConfig   => $SelectedDynamicField,
                        LayoutObject         => $LayoutObject,
                        ParamObject          => $ParamObject,
                        Value                => $Value,
                        Class                => 'ECTextField DynamicFieldEasy'
                    );

                    $Data{DynamicField} = $DateField->{Field} . "<button id='DynamicField_$Data{ID}_DFText' class='FieldECDateButton' type='button'><span><i class='fa fa-check'></i></span></button>";
                    
                    # add js function to DynamicFieldIDs Text
				    $JSBlock .= <<"JS_PRIORITY_BLOCK";

\$('#DynamicField_$Data{ID}_DFText').bind('click', function () {
	\$("#AJAXLoader$Data{ID}").css("display","");

    Core.Agent.EasyCategorization.DynamicFieldUpdate($Self->{TicketID},"$Data{ID}", "Text");
});
JS_PRIORITY_BLOCK
                }
                else{
                    $Data{DynamicField} = $LayoutObject->BuildSelection(
                        Data        => $Data{List},
                        Name        => $Data{ID},
                        SelectedID  => $Value,
                        Size        => 5,
                        Multiple    => 0,
                        TreeView    => $TreeView,
                        Translation => 1,
                        Max         => 30,
                        Class       => 'Modernize W40pc DynamicFieldEasy',
                        Disabled    => $EasyCategorizationBlock,
                        %Format,
                    );
                }

				$LayoutObject->Block(
					Name => 'DynamicField',
					Data => {%Data},
				);        

				# add js function to DynamicFieldIDs
				$JSBlock .= <<"JS_PRIORITY_BLOCK";
\$("#$Data{ID}").bind('change', function () {
	\$("#AJAXLoader$Data{ID}").css("display","");
	// Set value to Priority
    Core.Agent.EasyCategorization.DynamicFieldUpdate($Self->{TicketID},"$Data{ID}");
});
JS_PRIORITY_BLOCK

			}
		}
	}

    my $ManualSave = $ConfigObject->Get('InBox::EasyCategorization::Config')->{ManualSave}; 

    if ( $ManualSave && !$EasyCategorizationBlock ){
        $LayoutObject->Block(
            Name => 'ButtonSave',
        );
    }

    my $Frame = $LayoutObject->Output(
        TemplateFile => 'AgentEasyCategorization',
        Data         => \%Data,
    );
    ${ $Param{Data} } =~ s{(<div \s+ id="ArticleTree">)}{$Frame $1}xms;

	#Load JS time execution
	my $ZoomFrontendConfiguration = $ConfigObject->Get('Frontend::Module')->{AgentTicketZoom};
    my @CustomJSFiles = ('Core.Agent.EasyCategorization.js');
    push( @{ $ZoomFrontendConfiguration->{Loader}->{JavaScript} || [] }, @CustomJSFiles );


 if ( !$ManualSave ){
    # add js function to TypeID
	$JSBlock .= <<"JS_TYPE_BLOCK";
\$("#TypeID").bind('change', function () {
	\$("#AJAXLoaderTypeID").css("display","");
	// Update Type and load Services data
    Core.Agent.EasyCategorization.TypeUpdate($Self->{TicketID});
});
JS_TYPE_BLOCK

    # add js function to StateID
	$JSBlock .= <<"JS_STATE_BLOCK";
\$("#StateID").bind('change', function () {
	\$("#AJAXLoaderStateID").css("display","");
	// Update Type and load Services data
    Core.Agent.EasyCategorization.StateUpdate($Self->{TicketID});
});
JS_STATE_BLOCK

	# add js function to ServiceID
	$JSBlock .= <<"JS_SERVICE_BLOCK";
\$("#ServiceID").bind('change', function () {
	\$("#AJAXLoaderServiceID").css("display","");
	// Update service and load SLA data based
    Core.Agent.EasyCategorization.ServiceUpdate($Self->{TicketID});
});
JS_SERVICE_BLOCK

	# add js function to SLAID
	$JSBlock .= <<"JS_SLA_BLOCK";
\$("#SLAID").bind('change', function () {
	\$("#AJAXLoaderSLAID").css("display","");
	// Set value to SLA
    Core.Agent.EasyCategorization.SLAUpdate($Self->{TicketID});
});
JS_SLA_BLOCK

	# add js function to PriorityID
	$JSBlock .= <<"JS_PRIORITY_BLOCK";
\$("#PriorityID").bind('change', function () {
	\$("#AJAXLoaderPriorityID").css("display","");
	// Set value to Priority
    Core.Agent.EasyCategorization.PriorityUpdate($Self->{TicketID});
});
JS_PRIORITY_BLOCK

    # add js function to QueueID
	$JSBlock .= <<"JS_QUEUE_BLOCK";
\$("#QueueID").bind('change', function () {
	\$("#AJAXLoaderQueueID").css("display","");
	// Update queue data
    Core.Agent.EasyCategorization.QueueUpdate($Self->{TicketID});
});
JS_QUEUE_BLOCK

    # add js function to OwnerID
	$JSBlock .= <<"JS_OWNER_BLOCK";
\$("#OwnerID").bind('change', function () {
	\$("#AJAXLoaderOwnerID").css("display","");
	// Update owner data
    Core.Agent.EasyCategorization.OwnerUpdate($Self->{TicketID});
});
JS_OWNER_BLOCK

    # add js function to ResponsibleID
    $JSBlock .= <<"JS_RESPONSIBLE_BLOCK";
\$("#ResponsibleID").bind('change', function () {
        \$("#AJAXLoaderResponsibleID").css("display","");
        Core.Agent.EasyCategorization.ResponsibleUpdate($Self->{TicketID});
});
JS_RESPONSIBLE_BLOCK

    # add js function to LockID
	$JSBlock .= <<"JS_LOCK_BLOCK";
\$("#LockID").bind('change', function () {
	\$("#AJAXLoaderLockID").css("display","");
	// Update lock data
    Core.Agent.EasyCategorization.LockUpdate($Self->{TicketID});
});
JS_LOCK_BLOCK
 }
 else{
    # add js function to ButtonUpdate
    $JSBlock .= <<"JS_UPDATEFORM_BLOCK";
	// Update form
\$("#ButtonUpdateEasy").on("click", function(){
    Core.Agent.EasyCategorization.UpdateForm($Self->{TicketID});        
});
JS_UPDATEFORM_BLOCK
 }

    $Self->AddJSOnDocumentCompleteIfNotExists(
        Key  => 'EasyCategorization',
        Code => $JSBlock,
    );


    #return ${ $Param{Data} };
    return {
        Output => $Frame,
        Param => ${ $Param{Data} },
    };

}

# --
# Function based on module Znuny4OTRS-Repo from Znuny
# --

sub AddJSOnDocumentCompleteIfNotExists {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    NEEDED:
    for my $Needed (qw(Key Code)) {

        next NEEDED if defined $Param{$Needed};

        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    my $Exists = 0;
    CODEJS:
    for my $CodeJS ( @{ $Kernel::OM->Get('Kernel::Output::HTML::Layout')->{_JSOnDocumentComplete} || [] } ) {

        next CODEJS if $CodeJS !~ m{ Key: \s $Param{Key}}xms;
        $Exists = 1;
        last CODEJS;
    }

    return 1 if $Exists;

    my $AddCode = "// Key: $Param{Key}\n" . $Param{Code} . "\n";

    $Kernel::OM->Get('Kernel::Output::HTML::Layout')->AddJSOnDocumentComplete(
        Code => $AddCode,
    );

    return 1;
}

sub _GetServices {
    my ( $Self, %Param ) = @_;

    # get service
    my %Service;

    # check needed
    return \%Service if !$Param{QueueID} && !$Param{TicketID};

    # get options for default services for unknown customers
    my $DefaultServiceUnknownCustomer
        = $Kernel::OM->Get('Kernel::Config')->Get('Ticket::Service::Default::UnknownCustomer');

    # get service list
    if ( $Param{CustomerUserID} || $DefaultServiceUnknownCustomer ) {
        %Service = $Kernel::OM->Get('Kernel::System::Ticket')->TicketServiceList(
            %Param,
            Action         => $Self->{Action},
            CustomerUserID => $Self->{UserID},
        );
    }
    return \%Service;
}


1;
