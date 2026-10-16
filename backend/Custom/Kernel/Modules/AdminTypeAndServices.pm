# --
# Kernel/Modules/AdminTypeAndServices.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# --

package Kernel::Modules::AdminTypeAndServices;

use strict;
use warnings;

sub new {

	my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
	my ( $Self, %Param ) = @_;

	my $TypeAndServicesObject = $Kernel::OM->Get('Kernel::System::TypeAndServices');
	my $LayoutObject          = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $ParamObject           = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $ServiceObject         = $Kernel::OM->Get('Kernel::System::Service');
	my $TypeObject            = $Kernel::OM->Get('Kernel::System::Type');

    # Type
	if ( $Self->{Subaction} eq 'Type' ) {
	
		my $TypeID   = $ParamObject->GetParam( Param => 'ID' );
		my %TypeData = $TypeObject->TypeGet( ID => $TypeID );
		
		my %ServiceData = $ServiceObject->ServiceList( 
			KeepChildren => 1,
			UserID       => $Self->{UserID},
		);
		
		my @Type = $TypeAndServicesObject->TypeAndServicesList(
			TypeID => $TypeID, 
			UserID => $Self->{UserID},
		);
		
		my $Output = $LayoutObject->Header();

        $Output .= $LayoutObject->NavigationBar();

        $Output .= $Self->_Change(
            Data     => \%ServiceData,
			Type     => 'Type',
			Name     => $TypeData{Name},
			ID 	     => $TypeID,
			Selected => \@Type,
        );

		$Output .= $LayoutObject->Footer();

        return $Output;
	} 
    # ChangeType
	elsif($Self->{Subaction} eq 'ChangeType') {
	
		# challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();
    
        # to be set members of the role
        my @TypesIDs = $ParamObject->GetArray( Param => 'Type' );
		
		# get the role id
        my $ID = $ParamObject->GetParam( Param => 'ID' );
       
		@TypesIDs = grep /\S/, @TypesIDs;
		
		if ( @TypesIDs ){

			$TypeAndServicesObject->CleanUp(
				TypeID => $ID,
				UserID => $Self->{UserID},
			);
			
			foreach my $ServiceID ( @TypesIDs ){	

				$TypeAndServicesObject->TypeAndServicesAdd(
					TypeID    => $ID,
					ServiceID => $ServiceID,
					UserID    => $Self->{UserID},
				);
			}
		}
		else {
			my @Types = $TypeAndServicesObject->CleanUp(
				TypeID => $ID,
				UserID => $Self->{UserID},
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
		
		my %TypeData = $TypeObject->TypeList(
			Value  => 1,
			UserID => $Self->{UserID},
		);

		my @Service = $TypeAndServicesObject->TypeAndServicesList(
			ServiceID => $ServiceID, 
			UserID    => $Self->{UserID},
		);
		
		my $Output = $LayoutObject->Header();

        $Output .= $LayoutObject->NavigationBar();

        $Output .= $Self->_Change(
            Data      => \%TypeData,
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

			$TypeAndServicesObject->CleanUp(
				ServiceID => $ID,
				UserID    => $Self->{UserID},
			);
			
			foreach my $TypeIDs ( @ServiceIDs ){

				$TypeAndServicesObject->TypeAndServicesAdd(
					ServiceID   => $ID,
					TypeID      => $TypeIDs,
					UserID      => $Self->{UserID},
				);
			}
		}
		else {
			my @Service = $TypeAndServicesObject->CleanUp(
				ServiceID   => $ID,
				UserID      => $Self->{UserID},
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
	my $TypeObject    = $Kernel::OM->Get('Kernel::System::Type');

	$LayoutObject->Block(
    	Name => 'Overview',
		Data => \%Param,
    );
		
	#List Types and Services
	my %Types = $TypeObject->TypeList( Valid => 1 );

	my %Service = $ServiceObject->ServiceList( 
		KeepChildren => 1,
		UserID       => $Self->{UserID},
	);

	#Show Types and Services
	for my $TypeID ( keys %Types ){

		$LayoutObject->Block(
			Name => 'TypeList',
			Data => {
				Name => $Types{$TypeID},
				ID   => $TypeID,
			},
		);
	}

	for my $ServiceID ( keys %Service){

		$LayoutObject->Block(
			Name => 'ServiceList',
			Data => {
				Name => $Service{$ServiceID},
				ID => $ServiceID,
			},
		);
	}
		
	return $LayoutObject->Output(
        TemplateFile => 'AdminTypeAndServices',
        Data         => \%Param,
	);
}

sub _Change {
	my ( $Self, %Param ) = @_;
	
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	
	my %Data       = %{ $Param{Data} }; 
	my $Type       = $Param{Type} || 'Type';
    my $NeType	   = $Type eq 'Type' ? 'Service' : 'Type';
	my $LinkHeader = "";
	
	my %VisibleType = (
        Type    => 'Type',
        Service => 'Service',
    );
	
	if ( $Type eq 'Type' ){	
		$LinkHeader = "Action=AdminType;Subaction=Change;ID=$Param{ID}";
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
	
	$Param{BreadcrumbTitle} = $LayoutObject->{LanguageObject}->Translate("Change Services Relations for Type");

    if ( $Type eq 'Service' ) {
        $Param{BreadcrumbTitle} = $LayoutObject->{LanguageObject}->Translate("Change Types Relations for Service");
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

    $LayoutObject->Block(
        Name => "ChangeHeader$Type",
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
		
		if($Type eq 'Type'){
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
			$Link = "Action=AdminType;Subaction=Change;ID=$ID";
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
        TemplateFile => 'AdminTypeAndServices',
        Data         => \%Param,
    );
}

1;

