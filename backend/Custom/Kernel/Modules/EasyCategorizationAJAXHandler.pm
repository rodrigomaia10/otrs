# --
# Kernel/Modules/EasyCategorizationAJAXHandler.pm
# Copyright (C) 2019 Service Up http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * pdias@beonup.com.br
# * mbernardo@serviceup.com.br
# * jsantos@serviceup.com.br
# * poliveira@serviceup.com.br
# * lcavalheiro@serviceup.com.br
# * dparavani@serviceup.com.br
# * gbolsoni@serviceup.com.br
# --

package Kernel::Modules::EasyCategorizationAJAXHandler;

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

    # create needed objects
    my $EasyCategorizationObject = $Kernel::OM->Get('Kernel::System::EasyCategorization');
	my $DynamicFieldObject 	     = $Kernel::OM->Get('Kernel::System::DynamicField');
	my $BackendObject      	     = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
	my $TypeObject               = $Kernel::OM->Get('Kernel::System::Type');
	my $LayoutObject       	     = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $TicketObject       	     = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ParamObject        	     = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $LogObject          	     = $Kernel::OM->Get('Kernel::System::Log');
	my $QueueObject       		 = $Kernel::OM->Get('Kernel::System::Queue');
	my $JSONObject               = $Kernel::OM->Get('Kernel::System::JSON');
	my $ConfigObject             = $Kernel::OM->Get('Kernel::Config');


    my $JSON = '{}';

	my %GetParam;
    for my $Key ( qw( TypeID TicketID ServiceID SLAID PriorityID StateID QueueID OwnerID LockID ResponsibleID) ){
        $GetParam{$Key} = $ParamObject->GetParam( Param => $Key );
    }

	my @ParamNames = $ParamObject->GetParamNames();

	my %Ticket = $TicketObject->TicketGet(
		TicketID => $GetParam{TicketID},
		UserID   => $Self->{UserID},
		Silent   => 1,
	);

	# my $Success = $TicketObject->TicketAcl(
   	# 	Data          => 'AgentTickeZoom',
    #     Action        => $Self->{Action},
    #     TicketID      => $GetParam{TicketID},
    #     ReturnType    => 'Action',
    #     ReturnSubType => '-',
    #     UserID        => $Self->{UserID},
	# );

	# my %Data =   $TicketObject->TicketAclActionData();

	# get Type JSON
    if ( $Self->{Subaction} eq 'TypeUpdate' ){

		$Self->_TypeUpdate(
			TypeID   => $GetParam{TypeID},
			TicketID => $GetParam{TicketID}
		);

		my $ServiceList = $EasyCategorizationObject->GetServiceList(
            %GetParam,
            TicketID       => $Self->{TicketID},
            CustomerUserID => $Ticket{CustomerUserID},
            QueueID        => $Ticket{QueueID},
			Action		   => 'AgentTicketZoom'
        );

		my $JSONString = $LayoutObject->BuildSelectionJSON( 
            [
                {
                    Name         => 'ServiceID',
                    Data         => $ServiceList,
                    SelectedID   => $GetParam{ServiceID},
                    PossibleNone => 1,
                    Translation  => 0,
                    TreeView     => 1,
                    Max          => 100,
                },
            ],
        );

		$JSON = $LayoutObject->JSONEncode(
            Data => {
                JSONString => $JSONString,
            },
        );
    }
	# get state object
	elsif( $Self->{Subaction} eq 'StateUpdate' ){

		my $Success = $Self->_StateUpdate(
			StateID  => $GetParam{StateID},
			TicketID => $GetParam{TicketID},
		);

		my $JSONString = $Kernel::OM->Get('Kernel::System::JSON')->Encode(
			Data => {Success => $Success}
		);

		# build JSON output
        $JSON = $LayoutObject->JSONEncode(
            Data => {
                JSONString => $JSONString,
            },
        );
	}
	# get Service JSON
	elsif ( $Self->{Subaction} eq 'ServiceUpdate' ){

		my @DataView;
		my %JSONView;

		$Self->_ServiceUpdate(
			ServiceID => $GetParam{ServiceID},
			TicketID  => $GetParam{TicketID},
		);

		my $SLAs = $EasyCategorizationObject->GetSLAList(
			%GetParam,
            QueueID        => $Ticket{QueueID},
            ServiceID      => $GetParam{ServiceID},
            CustomerUserID => $Ticket{CustomerUserID},
        );

		my @PossibleNone = ('','-','false','false','false');

		push @DataView, \@PossibleNone;

		my $Selected = "";

		foreach my $SLAID ( sort keys %$SLAs ){

			my @DataSelect = ();

			if ($GetParam{SLAID} eq $SLAID) {
				$Selected = 'true';
			}
			else{
				$Selected = 'false';
			}

			@DataSelect = ($SLAID,$SLAs->{$SLAID},'false',$Selected,'false');
			push @DataView, \@DataSelect;
		}

		$JSONView{'SLAID'} = \@DataView;

		my $Priorities = $EasyCategorizationObject->GetPriorityList(
            %GetParam,
            %Ticket,
            TicketID => $Self->{TicketID},
			UserID   => $Self->{UserID},			
        );

		my @DataViewPriorities;

		foreach my $PriorityID ( sort keys %$Priorities ){

			my @DataSelectPrio = ();

			if ($GetParam{PriorityID} eq $PriorityID) {
				$Selected = 'true';
			}
			else{
				$Selected = 'false';
			}

			@DataSelectPrio = ($PriorityID,$LayoutObject->{LanguageObject}->Translate($Priorities->{$PriorityID}),'false',$Selected,'false');
			
			push @DataViewPriorities, \@DataSelectPrio;
		}

		$JSONView{'PriorityID'} = \@DataViewPriorities;

		my $JSONString = $Kernel::OM->Get('Kernel::System::JSON')->Encode(
			Data => \%JSONView
		);

		# replace boolean to no quotes
		$JSONString =~ s/"true"/true/g;
		$JSONString =~ s/"false"/false/g;

        # build JSON output
        $JSON = $LayoutObject->JSONEncode(
            Data => {
                JSONString => $JSONString,
            },
        );
	}
	# get SLA JSON
	elsif ( $Self->{Subaction} eq 'SLAUpdate' ){

		my $Success = $Self->_SLAUpdate(
			SLAID     => $GetParam{SLAID},
			TicketID  => $GetParam{TicketID},
		);

		my $JSONString = $Kernel::OM->Get('Kernel::System::JSON')->Encode(
			Data => {Success => $Success}
		);

		# build JSON output
        $JSON = $LayoutObject->JSONEncode(
            Data => {
                JSONString => $JSONString,
            },
        );
	}
	# get Priority JSON
	elsif ( $Self->{Subaction} eq 'PriorityUpdate' ){

		my $Success = $Self->_PriorityUpdate(
				PriorityID => $GetParam{PriorityID},
				TicketID   => $GetParam{TicketID},
			);

		my $JSONString = $Kernel::OM->Get('Kernel::System::JSON')->Encode(
			Data => {Success => $Success}
		);

		# build JSON output
        $JSON = $LayoutObject->JSONEncode(
            Data => {
                JSONString => $JSONString,
            },
        );
	}
	# get Responsible JSON
	elsif ( $Self->{Subaction} eq 'ResponsibleUpdate' ){
		my $Success = $Self->_ResponsibleUpdate(
			TicketID      => $GetParam{TicketID},
			ResponsibleID => $GetParam{ResponsibleID},
		);

		my $JSONString = $Kernel::OM->Get('Kernel::System::JSON')->Encode(
			Data => { Success => $Success }
		);

		$JSON = $LayoutObject->JSONEncode(
			Data => {
				JSONString => $JSONString,
			},
		);
	}
	# get Queue JSON
	elsif ( $Self->{Subaction} eq 'QueueUpdate' ){

		my @DataView;
		my %JSONView;
		my $Owners;

		$Self->_QueueUpdate(
			QueueID  => $GetParam{QueueID} ||  $Ticket{QueueID},
			TicketID => $GetParam{TicketID},
		);

		#update owner field
		my %Queues = $QueueObject->GetAllQueues( 
			UserID => $GetParam{UserID}, 
			Type => 'rw' 
		);

		if ( $Queues{ $Ticket{QueueID} } ) {
 
			$Owners = $EasyCategorizationObject->GetOwnerList(
				%GetParam,
				%Ticket,
				TicketID => $GetParam{TicketID},
				UserID   => $GetParam{UserID},
			);
		}

		my @PossibleNone = ('','-','false','false','false');

		push @DataView, \@PossibleNone;

		my $Selected = "";

		foreach my $OwnerID ( sort keys %$Owners ){

			my @DataSelect = ();

			if ($GetParam{OwnerID} eq $OwnerID) {
				$Selected = 'true';
			}
			else{
				$Selected = 'false';
			}

			@DataSelect = ($OwnerID,$Owners->{$OwnerID},'false',$Selected,'false');
			push @DataView, \@DataSelect;
		}

		$JSONView{'OwnerID'} = \@DataView;
			

		my $JSONString = $Kernel::OM->Get('Kernel::System::JSON')->Encode(
			Data => \%JSONView
		);

		# replace boolean to no quotes
		$JSONString =~ s/"true"/true/g;
		$JSONString =~ s/"false"/false/g;

		# build JSON output
        $JSON = $LayoutObject->JSONEncode(
            Data => {
                JSONString => $JSONString,
            },
        );
	}
	# get Owner JSON
	elsif ( $Self->{Subaction} eq 'OwnerUpdate' ){
		
		my $Success = $Self->_OwnerUpdate(
				TicketID  => $GetParam{TicketID},
				NewUserID => $GetParam{OwnerID},
		);

		my $JSONString = $Kernel::OM->Get('Kernel::System::JSON')->Encode(
			Data => {Success => $Success}
		);

		# build JSON output
        $JSON = $LayoutObject->JSONEncode(
            Data => {
                JSONString => $JSONString,
            },
        );
	}
    # get Lock JSON
    elsif ( $Self->{Subaction} eq 'LockUpdate' ){

        my $Lock = {};

		my $Success = $Self->_LockUpdate(
            LockID   => $GetParam{LockID},
            TicketID => $GetParam{TicketID},
		);
    	# my $Success = $TicketObject->TicketLockSet(
        #     LockID   => $GetParam{LockID},
        #     TicketID => $GetParam{TicketID},
        #     UserID   => $Self->{UserID},
        # );
                              
        my $JSONString = $Kernel::OM->Get('Kernel::System::JSON')->Encode(
            Data => {Success => $Success}
        );

        # build JSON output
    	$JSON = $LayoutObject->JSONEncode(
        	Data => {
        	    JSONString => $JSONString,
        	},
    	);
    }
	# get DynamicField JSON
	elsif ( $Self->{Subaction} eq 'DynamicFieldUpdate' ){

		my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
			Name => $ParamObject->GetParam( Param => "DynamicFieldName" ),
		);

		$Self->_DynamicFieldUpdate(
			DynamicFieldConfig => $DynamicField,
			ObjectID           => $GetParam{TicketID},
		);
        
        my @DataView;
        my %JSONView;
        
		my $SLAs = $EasyCategorizationObject->GetSLAList(
            %GetParam,
            %Ticket,
            UserID => $Self->{UserID},          
            Action => $Self->{Action},
        );

        my @PossibleNone = ('','-','true','false','false');
        push @DataView, \@PossibleNone;

        foreach my $SLAID ( sort keys %$SLAs ){
            my @DataSelect = ();
            @DataSelect = ($SLAID,$SLAs->{$SLAID},'false','false','false');
            push @DataView, \@DataSelect;
        }

        $JSONView{'SLAID'} = \@DataView;

        my $Types = $EasyCategorizationObject->GetTypeList(
            %GetParam,
            %Ticket,
            TicketID => $Self->{TicketID},
            UserID   => $Self->{UserID}
        );

        my @DataViewTypes;
        foreach my $TypesID ( sort keys %$Types ){
            my @DataSelectType = ();
            @DataSelectType = ($TypesID,$Types->{$TypesID},'false','false','false');
            push @DataViewTypes, \@DataSelectType;
        }
                
		$JSONView{'TypeID'} = \@DataViewTypes;
        my $Priorities = $EasyCategorizationObject->GetPriorityList(
            %GetParam,
            %Ticket,
            TicketID => $Self->{TicketID},
            UserID   => $Self->{UserID},                        
        );

        my @DataViewPriorities;
        foreach my $PriorityID ( sort keys %$Priorities ){
            my @DataSelectPrio = ();
            @DataSelectPrio = ($PriorityID,$LayoutObject->{LanguageObject}->Translate($Priorities->{$PriorityID}),'false','false','false');
            push @DataViewPriorities, \@DataSelectPrio;
        }

        $JSONView{'PriorityID'} = \@DataViewPriorities;
        my $JSONString = $Kernel::OM->Get('Kernel::System::JSON')->Encode(
            Data     => \%JSONView
        );

        # build JSON output
        $JSON = $LayoutObject->JSONEncode(
            Data => {
                JSONString => $JSONString,
            },
        );
    }
    elsif ( $Self->{Subaction} eq 'DynamicFieldDateUpdate' ){
        for my $Key ( qw( DynamicFieldValueDay DynamicFieldValueMonth DynamicFieldValueYear DynamicFieldValueHour DynamicFieldValueMinute IsCheck ) ){
            $GetParam{$Key} = $ParamObject->GetParam( Param => $Key );
        }

        my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
            Name => $ParamObject->GetParam( Param => "DynamicFieldName" ),
        );

        if( $GetParam{DynamicFieldValueMonth} < 10 ){
            $GetParam{DynamicFieldValueMonth} = "0". $GetParam{DynamicFieldValueMonth};
        }
        if( $GetParam{DynamicFieldValueDay} < 10 ){
            $GetParam{DynamicFieldValueDay} = "0". $GetParam{DynamicFieldValueDay};
        }
        if( $GetParam{DynamicFieldValueHour} < 10 ){
            $GetParam{DynamicFieldValueHour} = "0". $GetParam{DynamicFieldValueHour};
        }
        if( $GetParam{DynamicFieldValueMinute} < 10 ){
            $GetParam{DynamicFieldValueMinute} = "0". $GetParam{DynamicFieldValueMinute};
        }
                
		my $FullDate = "$GetParam{DynamicFieldValueYear}-$GetParam{DynamicFieldValueMonth}-$GetParam{DynamicFieldValueDay} 00:00:00";

        if( $DynamicField->{FieldType}  eq 'DateTime' ){
            $FullDate = "$GetParam{DynamicFieldValueYear}-$GetParam{DynamicFieldValueMonth}-$GetParam{DynamicFieldValueDay} $GetParam{DynamicFieldValueHour}:$GetParam{DynamicFieldValueMinute}:00";
        }
                
		$Self->_DynamicFieldUpdate(
            DynamicFieldConfig => $DynamicField,
            ObjectID           => $GetParam{TicketID},
            FieldDateValue     => $FullDate,
            IsCheck            => $GetParam{IsCheck},
		);
	
		my @DataView;
		my %JSONView;

        my $SLAs = $EasyCategorizationObject->GetSLAList(
            %GetParam,
            %Ticket,
            UserID => $Self->{UserID},           
            Action => $Self->{Action},
        );

		my @PossibleNone = ('','-','true','false','false');

		push @DataView, \@PossibleNone;

		foreach my $SLAID ( sort keys %$SLAs ){

			my @DataSelect = ();

			@DataSelect = ($SLAID,$SLAs->{$SLAID},'false','false','false');

			push @DataView, \@DataSelect;
		}

		$JSONView{'SLAID'} = \@DataView;

		my $Types = $EasyCategorizationObject->GetTypeList(
            %GetParam,
            %Ticket,
            TicketID => $Self->{TicketID},
			UserID   => $Self->{UserID}
        );

		my @DataViewTypes;

		foreach my $TypesID ( sort keys %$Types ){

			my @DataSelectType = ();

			@DataSelectType = ($TypesID,$Types->{$TypesID},'false','false','false');

			push @DataViewTypes, \@DataSelectType;
		}

		$JSONView{'TypeID'} = \@DataViewTypes;

		my $Priorities = $EasyCategorizationObject->GetPriorityList(
            %GetParam,
            %Ticket,
            TicketID => $Self->{TicketID},
			UserID   => $Self->{UserID},			
        );

		my @DataViewPriorities;

		foreach my $PriorityID ( sort keys %$Priorities ){

			my @DataSelectPrio = ();

			@DataSelectPrio = ($PriorityID,$LayoutObject->{LanguageObject}->Translate($Priorities->{$PriorityID}),'false','false','false');

			push @DataViewPriorities, \@DataSelectPrio;
		}

		$JSONView{'PriorityID'} = \@DataViewPriorities;

		my $JSONString = $Kernel::OM->Get('Kernel::System::JSON')->Encode(
			Data     => \%JSONView 
		);

		# build JSON output
        $JSON = $LayoutObject->JSONEncode(
            Data => {
                JSONString => $JSONString,
            },
        );

	}
	elsif ( $Self->{Subaction} eq 'UpdateForm' ){

		# update type
		$Self->_TypeUpdate(
			TypeID   => $GetParam{TypeID},
			TicketID => $GetParam{TicketID}
		);
	
		# update state
		$Self->_StateUpdate(
			StateID  => $GetParam{StateID},
			TicketID => $GetParam{TicketID},
		);

		# update service
		$Self->_ServiceUpdate(
			ServiceID => $GetParam{ServiceID},
			TicketID  => $GetParam{TicketID},
		);

		# update SLA
		$Self->_SLAUpdate(
			SLAID    => $GetParam{SLAID},
			TicketID => $GetParam{TicketID},
		);

		# update priority
		$Self->_PriorityUpdate(
			PriorityID => $GetParam{PriorityID},
			TicketID   => $GetParam{TicketID},
		);

		# update queue
		$Self->_QueueUpdate(
			QueueID  => $GetParam{QueueID} || $Ticket{QueueID},
			TicketID => $GetParam{TicketID},
		);

		# update owner
		$Self->_OwnerUpdate(
			TicketID  => $GetParam{TicketID},
			NewUserID => $GetParam{OwnerID},
		);

		# update lock
		$Self->_LockUpdate(
			TicketID  => $GetParam{TicketID},
			LockID    => $GetParam{LockID},
		);

		# update dynamicfield
		my $Param         = $ParamObject->GetParam( Param => 'DynamicFieldNames');
		my $BackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
		my $DynamicFields = $JSONObject->Decode(
        	Data => $Param,
    	);

		for my $Item (keys %{$DynamicFields}) {
			my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
				Name => $Item
			);

			$BackendObject->ValueSet(
				DynamicFieldConfig => $DynamicFieldConfig,
				ObjectID           => $GetParam{TicketID},
				Value              => $DynamicFields->{$Item},
				UserID             => $Self->{UserID},
			);

		}

		# build JSON output
        $JSON = $LayoutObject->JSONEncode(
            Data => {
                JSONString => 1,
            },
        );

		my $Article = $ConfigObject->Get('InBox::EasyCategorization::Config')->{ArticleCreate};

		if ($Article) {

			my $ArticleObject        = $Kernel::OM->Get('Kernel::System::Ticket::Article');
			my $ArticleBackendObject = $ArticleObject->BackendForChannel( ChannelName => 'Internal' );
			my $Title                = $ConfigObject->Get('InBox::EasyCategorization::Config')->{ArticleTitle} || 
												$LayoutObject->{LanguageObject}->Translate( 'Update Easy Categorization' );

			my $Body;

			if ($GetParam{TypeID}){

				my $Type            = $TypeObject->TypeLookup( TypeID => $GetParam{TypeID} );
				my $TypeTranslation = $LayoutObject->{LanguageObject}->Translate( 'Type' );

				$Body .= "$TypeTranslation: $Type \n";
			}

			if ($GetParam{QueueID}){

				my $Queue            = $QueueObject->QueueLookup( QueueID => $GetParam{QueueID} );
				my $QueueTranslation = $LayoutObject->{LanguageObject}->Translate( 'Queue' );

				$Body .= "$QueueTranslation: $Queue \n";
			}

			if ($GetParam{ServiceID}){

				my $ServiceObject      = $Kernel::OM->Get('Kernel::System::Service');
				my $Service            = $ServiceObject->ServiceLookup( ServiceID => $GetParam{ServiceID} );
				my $ServiceTranslation = $LayoutObject->{LanguageObject}->Translate( 'Service' );

				$Body .= "$ServiceTranslation: $Service \n";
			}

			if ($GetParam{SLAID}){

				my $SLAObject = $Kernel::OM->Get('Kernel::System::SLA');
				my $SLA       = $SLAObject->SLALookup( SLAID => $GetParam{SLAID} );

				$Body .= "SLA: $SLA \n";
			}

			if ($GetParam{PriorityID}){

				my $PriorityObject      = $Kernel::OM->Get('Kernel::System::Priority');
				my $Priority            = $PriorityObject->PriorityLookup( PriorityID => $GetParam{PriorityID} );
				my $PriorityTranslation = $LayoutObject->{LanguageObject}->Translate( 'Priority' );

				$Body .= "$PriorityTranslation: $Priority \n";
			}

			if ($GetParam{StateID}){

				my $StateObject      = $Kernel::OM->Get('Kernel::System::State');
				my $State            = $StateObject->StateLookup(StateID => $GetParam{StateID} );
				my $StateTranslation = $LayoutObject->{LanguageObject}->Translate( 'State' );

				$Body .= "$StateTranslation: $State \n";
			}

			if ($GetParam{OwnerID}) {

				my $UserObject = $Kernel::OM->Get('Kernel::System::User');
				my $Owner = $UserObject->UserName( UserID => $GetParam{OwnerID} );
				my $OwnerTranslation = $LayoutObject->{LanguageObject}->Translate( 'Owner' );

				$Body .= "$OwnerTranslation: $Owner \n";
			}

			if ($DynamicFields){
				for my $Item (keys %{$DynamicFields}) {

					my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
						Name => $Item
					);

					$Body .= "$DynamicFieldConfig->{Label}: $DynamicFields->{$Item} \n";
				}
			}
			
			my $ArticleID = $ArticleBackendObject->ArticleCreate(
				TicketID             => $Self->{TicketID},
				SenderType           => 'agent',
				IsVisibleForCustomer => 0,
				From                 => "$Self->{UserFullname} <$Self->{UserEmail}>",
				Subject              => $Title,
				Body                 => $Body,
				Charset              => $LayoutObject->{UserCharset},
				MimeType             => 'text/plain',
				HistoryType          => 'AddNote',
				HistoryComment       => 'Update Easy Categorization',
				UserID               => $Self->{UserID},
				UnlockOnAway         => 1,
			);
		}
	}
	elsif ( $Self->{Subaction} eq 'AJAXUpdate' ){
		$JSON = $Self->_AJAXUpdate(%GetParam);
	}

    # send JSON response
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON || '',
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub _ServiceUpdate {
	my ( $Self, %Param ) = @_;

	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');

	my $Success = $TicketObject->TicketServiceSet(
		ServiceID => $Param{ServiceID},
		TicketID  => $Param{TicketID},
		UserID    => $Self->{UserID}
	);

	if ( $Success ){
		$LogObject->Log(
			Priority => 'notice',
			Message  => "New Service set where TicketID = $Param{TicketID}",
		);
	}

	return $Success;
}

sub _StateUpdate {
	my ( $Self, %Param ) = @_;

	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $StateObject  = $Kernel::OM->Get('Kernel::System::State');
	my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
	my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');

	my $Success = $TicketObject->TicketStateSet(
		StateID  => $Param{StateID},
		TicketID => $Param{TicketID},
		UserID   => $Self->{UserID}
	);

	my %StateData = $StateObject->StateGet(
		ID => $Param{StateID}
	);

	# check state type
	if ( $StateData{TypeName} =~ /^pending/i ) {

		my $GetCurSysDTUnitFromLowest = sub {

			my %Param = @_;

			my $DateTimeObject = $Kernel::OM->Create(
				'Kernel::System::DateTime'
			);

			if ( $Param{AddCalendar} ) {

				$DateTimeObject->Add( 
					Seconds       => $Param{AddSeconds},
					Calendar      => $Param{AddCalendar},
					AsWorkingTime => 1
				);
			}
			else {

				$DateTimeObject->Add( Seconds => $Param{AddSeconds} );
			}

			my %Details = %{ $DateTimeObject->Get() };

			return map { $Details{$_} } (qw(Second Minute Hour Day Month Year));
		};

		my ( $s, $m, $h, $D, $M, $Y ) = $GetCurSysDTUnitFromLowest->(
			AddSeconds  => $ConfigObject->Get('SetUtilPendingTime::Seconds') || $ConfigObject->Get('Ticket::Frontend::PendingDiffTime'),
			AddCalendar => $ConfigObject->Get('SetUtilPendingTime::CalendarID') || 0,
		);

		# set pending time
		$TicketObject->TicketPendingTimeSet(
			UserID   => $Self->{UserID},
			TicketID => $Param{TicketID},
			Year     => $Y,
			Month    => $M,
			Day      => $D,
			Hour     => $h,
			Minute   => $m,
		);
	}

	if ( $Success ){
		$LogObject->Log(
			Priority => 'notice',
			Message  => "New State set where TicketID = $Param{TicketID}",
		);
	}
	
	return $Success;
}

sub _SLAUpdate {
	my ( $Self, %Param ) = @_;

	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');

	my $Success = $TicketObject->TicketSLASet(
		SLAID     => $Param{SLAID},
		TicketID  => $Param{TicketID},
		UserID    => $Self->{UserID},
	);

	if ( $Success ){
		$LogObject->Log(
			Priority => 'notice',
			Message  => "New SLA set where TicketID = $Param{TicketID}",
		);
	}

	return $Success;
}

sub _TypeUpdate {
	my ( $Self, %Param ) = @_;

	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');

	my $Success = $TicketObject->TicketTypeSet(
		TypeID   => $Param{TypeID},
		TicketID => $Param{TicketID},
		UserID   => $Self->{UserID}
	);

	if ( $Success ){
		$LogObject->Log(
			Priority => 'notice',
			Message  => "New Type set where TicketID = $Param{TicketID}",
		);
	}

	return $Success;
}

sub _PriorityUpdate {
	my ( $Self, %Param ) = @_;

	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');

	my $Success = $TicketObject->TicketPrioritySet(
		PriorityID => $Param{PriorityID},
		TicketID   => $Param{TicketID},
		UserID     => $Self->{UserID},
	);

	if ( $Success ){
		$LogObject->Log(
			Priority => 'notice',
			Message  => "New Priority set where TicketID = $Param{TicketID}",
		);
	}

	return $Success;
}

sub _QueueUpdate {
	my ( $Self, %Param ) = @_;

	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');

	my $Success = $TicketObject->TicketQueueSet(
		QueueID  => $Param{QueueID},
		TicketID => $Param{TicketID},
		UserID   => $Self->{UserID},
	);

	if ( $Success ){
		$LogObject->Log(
			Priority => 'notice',
			Message  => "New Queue set where TicketID = $Param{TicketID}",
		);	
	}

	return $Success;
}

sub _OwnerUpdate {
	my ( $Self, %Param ) = @_;

	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
	
	my $Success = $TicketObject->TicketOwnerSet(
		TicketID  => $Param{TicketID},
		NewUserID => $Param{NewUserID},
		UserID    => $Self->{UserID},
	);		

	if ( $Success ){
		$LogObject->Log(
			Priority => 'notice',
			Message  => "New Owner set where TicketID = $Param{TicketID}",
		);

		$TicketObject->TicketLockSet(
			Lock     => 'lock',
			TicketID => $Param{TicketID},
			UserID   => $Self->{UserID},
		);
	}

	return $Success;
}

sub _LockUpdate {
	my ( $Self, %Param ) = @_;

	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');

    my $Success = $TicketObject->TicketLockSet(
        LockID   => $Param{LockID},
        TicketID => $Param{TicketID},
        UserID   => $Self->{UserID},
    );

	if ( $Success ){
		$LogObject->Log(
			Priority => 'notice',
			Message  => "New Lock Status set where TicketID = $Param{TicketID}",
		);	
	}

	return $Success;
}

sub _ResponsibleUpdate {
    my ( $Self, %Param ) = @_;

    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');

    my $Success = $TicketObject->TicketResponsibleSet(
		TicketID   => $Param{TicketID},
		NewUserID  => $Param{ResponsibleID},
		UserID     => $Self->{UserID},
	);

    if ( $Success ) {
        $LogObject->Log(
            Priority => 'notice',
            Message  => "New Responsible set where TicketID = $Param{TicketID}",
        );
    }

    return $Success;
}

sub _DynamicFieldUpdate {
	my ( $Self, %Param ) = @_;

	my $TicketObject  = $Kernel::OM->Get('Kernel::System::Ticket');
	my $LogObject     = $Kernel::OM->Get('Kernel::System::Log');
	my $ParamObject   = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $BackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
	my $Success;

	# Incompleto
	if ($Param{DynamicFieldConfig}->{FieldType} eq "Multiselect"){

		my @Param = $ParamObject->GetArray( Param => 'DynamicFieldValue[]');

		$Success = $BackendObject->ValueSet(
			DynamicFieldConfig => $Param{DynamicFieldConfig},
			ObjectID           => $Param{ObjectID},
			Value              => \@Param,
			UserID             => $Self->{UserID},
		);
	}
    elsif( $Param{DynamicFieldConfig}->{FieldType} eq "Date" || $Param{DynamicFieldConfig}->{FieldType} eq "DateTime" ){
        if( $Param{IsCheck} ){
            $Success = $BackendObject->ValueSet(
                DynamicFieldConfig => $Param{DynamicFieldConfig},
                ObjectID           => $Param{ObjectID},
            	Value              => $Param{FieldDateValue},
                UserID             => $Self->{UserID},
            );
        }
        else{
        	$Success = $BackendObject->ValueDelete(
                DynamicFieldConfig => $Param{DynamicFieldConfig},  
                ObjectID           => $Param{ObjectID},            
                UserID             => $Self->{UserID},
            );
        }
    }
    else{

		my $DynamicFieldValue = $ParamObject->GetParam( Param => "DynamicFieldValue" );

		$Success = $BackendObject->ValueSet(
			DynamicFieldConfig => $Param{DynamicFieldConfig},
			ObjectID           => $Param{ObjectID},
			Value              => $DynamicFieldValue,
			UserID             => $Self->{UserID},
		);
	}

	if ( $Success ){
		$LogObject->Log(
			Priority => 'notice',
			Message => "New Value to DynamicField set where TicketID = $Param{TicketID}",
		);
	}

	return $Success;
}

sub _AJAXUpdate {
	my ( $Self, %Param ) = @_;

	my $ConfigObject             = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject             = $Kernel::OM->Get('Kernel::System::Ticket');
	my $LayoutObject       	     = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $QueueObject              = $Kernel::OM->Get('Kernel::System::Queue');
	my $BackendObject            = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
	my $EasyCategorizationObject = $Kernel::OM->Get('Kernel::System::EasyCategorization');
	my $StateBlock               = $ConfigObject->Get('InBox::EasyCategorization::Config')->{StateBlock};   
    
    #Gets the status of the current ticket
    my $NameState = $EasyCategorizationObject->GetSatateTicket( TicketID => $Param{TicketID});

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

	my %Data;

	my %Ticket = $TicketObject->TicketGet(
		TicketID => $Param{TicketID},
		UserID   => $Self->{UserID},
		Silent   => 1,
	);

	$Param{Action} = "AgentEasyCategorization";

	delete $Param{TicketID};

	my $Types = $EasyCategorizationObject->GetTypeList(
		%Param,
		UserID   => $Self->{UserID},
		TicketID => $Param{TicketID} || $Ticket{TicketID},	
	);

	$Data{TypeStrg} = $LayoutObject->BuildSelection( 
		Data        => $Types,
		Name        => 'TypeID',
		SelectedID  => $Param{TypeID},
		Size        => 5,
		TreeView    => 1,
		Translation => 1,
		Max         => 32,
		Class       => 'Modernize W49pc',
		Disabled    => $EasyCategorizationBlock,
	);

	my $Responsibles = $EasyCategorizationObject->GetResponsibleList(
		%Param,
		UserID  => $Self->{UserID},
		TicketID => $Param{TicketID} || $Ticket{TicketID},	
	);

	$Data{ResponsibleStrg} = $LayoutObject->BuildSelection( 
		Data        => $Responsibles,
		Name        => 'ResponsibleID',
		SelectedID  => $Param{ResponsibleID} || $Ticket{ResponsibleID},
		Size        => 5,
		TreeView    => 1,
		Translation => 1,
		Max         => 32,
		Class       => 'Modernize W49pc',
		Disabled    => $EasyCategorizationBlock,
	);

	my $Queues = $EasyCategorizationObject->GetQueueList2(
		%Param,		
		UserID   => $Self->{UserID},
		TicketID => $Param{TicketID} || $Ticket{TicketID},	
	);	

	$Data{QueueStrg} = $LayoutObject->BuildSelection( 
		Data        => $Queues,
		Name        => 'QueueID',
		SelectedID  => $Param{QueueID} || $Ticket{QueueID},
		Size        => 5,
		TreeView    => 1,
		Translation => 1,
		Max         => 32,
		Class       => 'Modernize W49pc',
		Disabled    => $EasyCategorizationBlock,
	);

	my $Services = $EasyCategorizationObject->GetServiceList(
		%Param,		
		UserID  => $Self->{UserID},
		CustomerUserID => $Ticket{CustomerUserID},
		TicketID  => $Param{TicketID} || $Ticket{TicketID},	
		Action    => 'AgentEasyCategorization'
	);	

	$Data{ServiceStrg} = $LayoutObject->BuildSelection( 
		Data        => $Services,
		Name        => 'ServiceID',
		SelectedID  => $Param{ServiceID},
		Size        => 5,
		TreeView    => 1,
		Translation => 1,
		Max         => 32,
		Class       => 'Modernize W49pc',
		Disabled    => $EasyCategorizationBlock,
	);

	my $SLAs = $EasyCategorizationObject->GetSLAList(
		%Param,
		TicketID => $Param{TicketID} || $Ticket{TicketID},			
		UserID   => $Self->{UserID}
	);

	$Data{SLAStrg} = $LayoutObject->BuildSelection( 
		Data        => $SLAs,
		Name        => 'SLAID',
		SelectedID  => $Param{SLAID},
		Size        => 5,
		Multiple    => 0,
		TreeView    => 1,
		Translation => 1,
		Max         => 32,
		Class       => 'Modernize W49pc',
		Disabled    => $EasyCategorizationBlock,
	);

	my $Prioritys = $EasyCategorizationObject->GetPriorityList(
		%Param,		
		UserID   => $Self->{UserID},
		TicketID => $Param{TicketID} || $Ticket{TicketID},	
		Action   => 'AgentEasyCategorization'
	);

	$Data{PriorityStrg} = $LayoutObject->BuildSelection( 
		Data        => $Prioritys,
		Name        => 'PriorityID',
		SelectedID  => $Param{PriorityID},
		Size        => 5,
		Multiple    => 0,
		TreeView    => 1,
		Translation => 1,
		Max         => 32,
		Class       => 'Modernize W49pc',
		Disabled    => $EasyCategorizationBlock,
	);

	my $States = $EasyCategorizationObject->GetStateList(
		%Param,	
		TicketID => $Param{TicketID} || $Ticket{TicketID},	
		UserID   => $Self->{UserID}
	);

	$Data{StateStrg} = $LayoutObject->BuildSelection( 
		Data        => $States,
		Name        => 'StateID',
		SelectedID  => $Param{StateID},
		Size        => 5,
		Multiple    => 0,
		TreeView    => 1,
		Translation => 1,
		Max         => 32,
		Class       => 'Modernize W49pc',
		Disabled    => $EasyCategorizationBlock,
	);

	my $Owners = $EasyCategorizationObject->GetOwnerListByQueue(
		%Param,
		QueueID => $Param{QueueID} || $Ticket{QueueID},	
		UserID  => $Self->{UserID}
	);

	$Data{OwnerStrg} = $LayoutObject->BuildSelection( 
		Data        => $Owners,
		Name        => 'OwnerID',
		SelectedID  => $Param{OwnerID},
		Size        => 5,
		Multiple    => 0,
		TreeView    => 1,
		Translation => 1,
		Max         => 32,
		Class       => 'Modernize W49pc',
		Disabled    => $EasyCategorizationBlock,
	);

	my $Lock = {};

	$Lock = {
        1 => 'Unlocked',
        2 => 'Locked',
    };

	$Data{LockStrg} = $LayoutObject->BuildSelection(
        Data        => $Lock,
        Name        => 'LockID',
        SelectedID  => $Param{LockID},
        Size        => 5,
        Multiple    => 0,
        TreeView    => 1,
        Translation => 1,
        Max         => 30,
        Class       => 'Modernize W49pc',
        Disabled    => $EasyCategorizationBlock,
    );

	my $JSONFields = [
		{
			Name   => "TypeID",
			Values => $Data{TypeStrg},
		},
		{
			Name   => "QueueID",
			Values => $Data{QueueStrg},
		},
		{
			Name   => "ServiceID",
			Values => $Data{ServiceStrg},
		},
		{
			Name   => "SLAID",
			Values => $Data{SLAStrg},
		},
		{
			Name   => "PriorityID",
			Values => $Data{PriorityStrg},
		},
		{
			Name   => "StateID",
			Values => $Data{StateStrg},
		},
		{
			Name   => "OwnerID",
			Values => $Data{OwnerStrg},
		},
		{
			Name   => "LockID",
			Values => $Data{LockStrg},
		},
		{
			Name   => "ResponsibleID",
			Values => $Data{ResponsibleStrg},
		},
	];

	my $JSON = $LayoutObject->JSONEncode(
		Data => {
			JSONString => $JSONFields,
		},
	);

	return $JSON;
}

1;
