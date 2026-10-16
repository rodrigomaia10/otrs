# --
# Kernel/Modules/AdminQueueAndServices.pm
# Copyright (C) 2019 Service Up, http://serviceup.com.br/
#
# written/edited by:
# * jsantos@serviceup.com.br
# --

package Kernel::Modules::AdminQueueAndServices;

use strict;
use warnings;

sub new{

	my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
	my ( $Self, %Param ) = @_;

	my $QueueAndServicesObject = $Kernel::OM->Get('Kernel::System::QueueAndServices');
	my $LayoutObject  		   = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $ParamObject   		   = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $ServiceObject 		   = $Kernel::OM->Get('Kernel::System::Service');
	my $QueueObject   		   = $Kernel::OM->Get('Kernel::System::Queue');

    # Queue
    if ( $Self->{Subaction} eq 'Queue' ) {
	
		my $QueueID   = $ParamObject->GetParam( Param => 'ID' );
		my %QueueData = $QueueObject->QueueGet( ID => $QueueID );
		
		my %ServiceData = $ServiceObject->ServiceList( 
			KeepChildren => 1,
			UserID       => $Self->{UserID},
		);
		
		my @Queue = $QueueAndServicesObject->QueueAndServicesList(
			QueueID => $QueueID, 
			UserID => $Self->{UserID},
		);
		
		my $Output = $LayoutObject->Header();

        $Output .= $LayoutObject->NavigationBar();

        $Output .= $Self->_Change(
            Data     => \%ServiceData,
			Type     => 'Queue',
			Name     => $QueueData{Name},
			ID 	     => $QueueID,
			Selected => \@Queue,
        );

        $Output .= $LayoutObject->Footer();

        return $Output;
	}
    # ChangeQueue
	elsif($Self->{Subaction} eq 'ChangeQueue') {
	
		# challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();
    
        # to be set members of the role
        my @QueuesIDs = $ParamObject->GetArray( Param => 'Queue' );
		
		# get the role id
        my $ID = $ParamObject->GetParam( Param => 'ID' );
       
		@QueuesIDs = grep /\S/, @QueuesIDs;
		
		if ( @QueuesIDs ){

			$QueueAndServicesObject->CleanUp(
				QueueID   => $ID,
				UserID    => $Self->{UserID},
			);
			
			foreach my $ServiceID ( @QueuesIDs ){
							
				$QueueAndServicesObject->QueueAndServicesAdd(
					QueueID   => $ID,
					ServiceID => $ServiceID,
					UserID    => $Self->{UserID},
				);
			}
		}
		else{
			my @Queues = $QueueAndServicesObject->CleanUp(
				QueueID => $ID,
				UserID  => $Self->{UserID},
			);
		}
	}
    # Service
    elsif( $Self->{Subaction} eq 'Service' ) {
	
		my $ServiceID = $ParamObject->GetParam( Param => 'ID' );

		my %ServiceData = $ServiceObject->ServiceGet( 
			ServiceID => $ServiceID,
			UserID    => $Self->{UserID},
		);
		
		my %QueueData = $QueueObject->QueueList(
			Value  => 1,
			UserID => $Self->{UserID},
		);

		my @Service = $QueueAndServicesObject->QueueAndServicesList(
			ServiceID => $ServiceID, 
			UserID    => $Self->{UserID},
		);
		
		my $Output = $LayoutObject->Header();

        $Output .= $LayoutObject->NavigationBar();

        $Output .= $Self->_Change(
            Data      => \%QueueData,
			Type      => 'Service',
			Name 	  => $ServiceData{Name},
			ID	 	  => $ServiceID,
			Selected  => \@Service,
        );

        $Output .= $LayoutObject->Footer();

        return $Output;
	}
    # ChangeService
	elsif($Self->{Subaction} eq 'ChangeService') {
	
		# challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();
    
        # to be set members of the role
        my @ServiceIDs = $ParamObject->GetArray( Param => 'Service' );
		
		# get the role id
        my $ID = $ParamObject->GetParam( Param => 'ID' );
       
		@ServiceIDs = grep /\S/, @ServiceIDs;
		
		if ( @ServiceIDs ){
			
			$QueueAndServicesObject->CleanUp(
				ServiceID => $ID,
				UserID    => $Self->{UserID},
			);
			
			foreach my $QueueIDs ( @ServiceIDs ){

				$QueueAndServicesObject->QueueAndServicesAdd(
					ServiceID => $ID,
					QueueID   => $QueueIDs,
					UserID    => $Self->{UserID},
				);
			}
		}
		else {
			my @Service = $QueueAndServicesObject->CleanUp(
				ServiceID => $ID,
				UserID    => $Self->{UserID},
			);
		}
	}

	my $Output = $LayoutObject->Header();
	$Output .= $LayoutObject->NavigationBar();
	$Output .= $Self->_Overview();
	$Output .= $LayoutObject->Footer();

	return $Output;
}

sub _Overview {
	my ( $Self, %Param ) = @_;

	my $ServiceObject = $Kernel::OM->Get('Kernel::System::Service');
	my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $QueueObject   = $Kernel::OM->Get('Kernel::System::Queue');

	$LayoutObject->Block(
    	Name => 'Overview',
		Data => \%Param,
    );

	#List Queues and Services
	my %Queues = $QueueObject->QueueList( Valid => 1 );

	my %Service = $ServiceObject->ServiceList( 
		KeepChildren => 1,
		UserID       => $Self->{UserID},
	);

	#Show Queues and Services
	for my $QueueID ( keys %Queues ){

		$LayoutObject->Block(
			Name => 'QueueList',
			Data => {
				Name => $Queues{$QueueID},
				ID   => $QueueID,
			},
		);
	}

	for my $ServiceID ( keys %Service){

		$LayoutObject->Block(
			Name => 'ServiceList',
			Data => {
				Name => $Service{$ServiceID},
				ID 	 => $ServiceID,
			},
		);
	}

	return $LayoutObject->Output(
        TemplateFile => 'AdminQueueAndServices',
        Data         => \%Param,
    );
}

sub _Change {
	my ( $Self, %Param ) = @_;
	
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

	my %Data       = %{ $Param{Data} }; 
	my $Type       = $Param{Type} || 'Queue';
    my $NeType	   = $Type eq 'Queue' ? 'Service' : 'Queue';
	my $LinkHeader = "";
	
	my %VisibleType = (
        Queue    => 'Queue',
        Service  => 'Service',
    );
	
	if ( $Type eq 'Queue' ){	
		$LinkHeader = "Action=AdminQueue;Subaction=Change;QueueID=$Param{ID}";
	}
	else{
		$LinkHeader = "Action=AdminService;Subaction=ServiceEdit;ServiceID=$Param{ID}";
	}
	
	$LayoutObject->Block(
        Name => 'ActionList',
    );
    $LayoutObject->Block(
        Name => 'ActionOverview',
    );
	
	$Param{BreadcrumbTitle} = $LayoutObject->{LanguageObject}->Translate("Change Services Relations for Queues");

    if ( $Type eq 'Service' ) {
        $Param{BreadcrumbTitle} = $LayoutObject->{LanguageObject}->Translate("Change Queues Relations for Service");
    }
	
    $LayoutObject->Block(
        Name => 'Change',
        Data => {
            %Param,
            LinkHeader    => $LinkHeader,
            NeType        => $NeType,
            VisibleType   => $VisibleType{$Type},
            VisibleNeType => $VisibleType{$NeType},
        },
    );

	# check if there are groups
    if ( $NeType eq 'Service' ) {
        if ( !%Data ) {
            $LayoutObject->Block(
                Name => 'NoDataFoundMsgList',
                Data => {
                    ColSpan => 8,
                },
            );
        }
    }
   
    $LayoutObject->Block(
        Name => 'ChangeHeader',
        Data => {
            %Param,
            Type   => $Type,
            NeType => $NeType,
        },
    );
	
	$LayoutObject->AddJSData(
        Key   => 'RelationItems',
        Value => [$Type],
    );
	
	for my $ID ( sort { uc( $Data{$a} ) cmp uc( $Data{$b} ) } keys %Data ) {
	
		my $Selected;
		my $Link = "";
		
		if($Type eq 'Queue'){
			# set output class
			if ( grep( $_ eq $ID, @{$Param{Selected}} ) ){
				$Selected = ' checked="checked"'
			}
			else{
				$Selected = '';
			}
			$Link = "Action=AdminService;Subaction=ServiceEdit;ServiceID=$ID";
		}
		else{
			# set output class
			if ( grep( $_ == $ID, @{$Param{Selected}} ) ){
				$Selected = ' checked="checked"'
			}
			else{
				$Selected = '';
			}		
			$Link = "Action=AdminQueue;Subaction=Change;QueueID=$ID";
		}
		
        # set output class
        $LayoutObject->Block(
            Name => 'ChangeRow',
            Data => {
                %Param,
				Link     => $Link,
				Name     => $Param{Data}->{$ID},
				ID       => $ID,
				NeType   => $NeType,
				Selected => $Selected,
            },
        );
	}
	
	return $LayoutObject->Output(
        TemplateFile => 'AdminQueueAndServices',
        Data         => \%Param,
    );
}

1;
