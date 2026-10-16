# --
# Kernel/Modules/ConsumptionOfContract.pm
# Copyright (C) 2019 Service UP, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# * nfreitas@serviceup.com.br
# --

package Kernel::Modules::ConsumptionOfContract;

use strict;
use warnings;
use utf8;

use Encode qw(decode encode);
use File::Basename;
use Digest::MD5 qw(md5_hex);

our $ObjectManagerDisabled = 1;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # get form id
    $Self->{FormID} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'FormID' );

    # create form id
    if ( !$Self->{FormID} ) {
        $Self->{FormID} = $Kernel::OM->Get('Kernel::System::Web::UploadCache')->FormIDCreate();
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');
    my $LayoutObject               = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject                = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ConfigObject               = $Kernel::OM->Get('Kernel::Config');

	my $ActionTitle = $ConfigObject->Get('CustomerPortal::Core::ActionTitle');

    if ( !$ConfigObject->Get('CustomerPortal::Core::ToEnableConsumptionOfContract') ) {

		my %Message;

		$Message{Message} = $LayoutObject->{LanguageObject}->Translate("You do not have permission to view this page.");
		$Message{Comment} = $LayoutObject->{LanguageObject}->Translate("Please contact the responsible team for more information.");

		$LayoutObject->Block(
			Name => 'Error',
			Data => \%Message,
		);

		my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{NewTicketService});

		$Output .= $LayoutObject->Output(
			TemplateFile => "CustomerPortalError",
			Data         => \%Message,
		);

		$Output .= $LayoutObject->CustomerFooter(Type => 'Small');

		return $Output;
	}

	if ( $Self->{Subaction} eq 'ExportTicketView' ) {

		$Param{Year}        = $ParamObject->GetParam( Param => 'Year' );
		$Param{Month}       = $ParamObject->GetParam( Param => 'Month' );
        $Param{ContractID}  = $ParamObject->GetParam( Param => 'ContractID' );

		my %MonthPeriod;

		%MonthPeriod = $Self->_GetMonthPeriod( 
            MonthNumber => $Param{Month}, 
            Year        => $Param{Year},
            ContractID  => $Param{ContractID}
        );

        $Param{Types} = $Self->_GetTypeList();

        return $Self->_ExportTickets(%Param, %MonthPeriod);
	}

    $CustomerPortalLayoutObject->CreateNavBar(
        ActionActive => "ConsumptionOfContract",
        %{$Self}
    );

    my $Message  = $ParamObject->GetParam( Param => 'Message' )  || '';
    
    $Param{Title}  = '';
    $Param{Active} = 'ConsumptionOfContract'; 

    # ------------------------------------------------------------ #
    # overview
    # ------------------------------------------------------------ #
    my $Output =  $CustomerPortalLayoutObject->CustomerHeader(
		Type  => 'Small',
		Title => $LayoutObject->{LanguageObject}->Translate($ActionTitle->{ConsumptionOfContract}) || $LayoutObject->{LanguageObject}->Translate('Consumption of Contract')
	);

    $Output .= $Self->_Overview();
    $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

    return $Output;
}

sub _Overview {
    my ( $Self, %Param ) = @_;

    # get layout object
    my $LayoutObject   = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');
	my $ParamObject    = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ConfigObject   = $Kernel::OM->Get('Kernel::Config');

    my $ContractObject = $Kernel::OM->Get('Kernel::System::ContractManagement');

    my $CurrentDate = $DateTimeObject->Get();

    my $CustomUnitsTime  = $ConfigObject->Get('ContractManagement::Core::CustomUnitsTime');
    my $UnitsTime        = $ConfigObject->Get('ContractManagement::Core::UnitsTime');

    if($CustomUnitsTime){
		$Param{UnitsTime} = $CustomUnitsTime;
	}
	elsif($UnitsTime == 1){
		$Param{UnitsTime} = $LayoutObject->{LanguageObject}->Translate('Hours');
		$Param{Title}     = $LayoutObject->{LanguageObject}->Translate('Consumption Hours Customer');
	}
	else{
		$Param{UnitsTime} = $LayoutObject->{LanguageObject}->Translate('Minutes');
		$Param{Title}     = $LayoutObject->{LanguageObject}->Translate('Consumption Minutes Customer');
	}

	my %MonthData = (
		1  => 'January',
		2  => 'February',
		3  => 'March',
		4  => 'April',
		5  => 'May',
		6  => 'June',
		7  => 'July',
		8  => 'August',
		9  => 'September',
		10 => 'October',
		11 => 'November',
		12 => 'December'
	);

	@{ $Param{ContractsID} } = $ParamObject->GetArray( Param => 'ContractID' );
	@{ $Param{Month} }       = $ParamObject->GetArray( Param => 'Month' );
	$Param{Year}             = $ParamObject->GetParam( Param => 'Year' )  || '';

	if (!$Param{Month}->[0]) {
		$Param{Month}->[0] = $CurrentDate->{Month};
	}

    $Param{MonthOptionStrg} = $LayoutObject->BuildSelection(
        Data       => \%MonthData,
        SelectedID => $Param{Month},
        Name       => 'Month',
		Multiple   => 1,
        Class      => 'Modernize',
        Sort       => 'NumericKey',
    );

    # decrement 10 years
	my $OlderYear = $CurrentDate->{Year} - 10;

    my %YearData;

    for my $ItemYear ( $OlderYear .. $CurrentDate->{Year} ) {
        $YearData{$ItemYear} = $ItemYear;
    }

    $Param{YearOptionStrg} = $LayoutObject->BuildSelection(
        Data        => \%YearData,
        Name        => 'Year',
        SelectedID  => $Param{Year} || $CurrentDate->{Year},
        Translation => 1,
		Class       => 'Modernize',
    );

	my %ContractList = $ContractObject->ContractCompany(
		CustomerID => $Self->{CustomerID},
		Valid      => 1
	);

    my @ContractsID = keys %ContractList;

    if ( !@{ $Param{ContractsID} } ) {

        push @{ $Param{ContractsID} }, $ContractsID[0];
    }

    $Param{ContractOptionStrg} = $LayoutObject->BuildSelection(
        Data       => \%ContractList,
        SelectedID => $Param{ContractsID},
        Name       => 'ContractID',
		Multiple   => 1,
        PossibleNone   => 0,
        Class      => 'Modernize',
        Sort       => 'NumericKey',
    );

	if ( !%ContractList ) {

		$LayoutObject->Block(
			Name => 'NoDataFoundMsg',
		);
	}

	# get only ticktes by type
	my $GetTypeList = $Self->_GetTypeList();

	my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');
	my $CurrentDate    = $DateTimeObject->Get();

    CONTRACT:
	for my $ContractID ( sort keys %ContractList ) {

        if ( $Param{ContractsID} ) {
            if ( !($ContractID ~~ @{ $Param{ContractsID} } ) ) {
                next CONTRACT;
            }
        }
        else {
            next CONTRACT if $ContractID != $ContractsID[0];
        }

		my %ContractData = $ContractObject->ContractGet(
			ContractID => $ContractID,
			UserID     => $Self->{UserID}
		);

		for my $Month ( @{ $Param{Month} } ) {

			my %MonthPeriod;

			if ( $Month && $Param{Year} ) {
               
				# %MonthPeriod = $Self->_GetMonthPeriod( 
                #     MonthNumber => $Month, 
                #     Year        => $Param{Year},
                #     ContractID  => $ContractID
                # );
                $Month = $Month;
                $Param{Year} = $Param{Year};
			}
			else {
			
				# %MonthPeriod = $Self->_GetMonthPeriod( 
                #     MonthNumber => $CurrentDate->{Month}, 
                #     Year        => $CurrentDate->{Year},
                #     ContractID  => $ContractID
                # );
                $Month = $CurrentDate->{Month};
                $Param{Year} = $CurrentDate->{Year};
			}

            %MonthPeriod = $Self->_GetMonthPeriod( 
                MonthNumber => $Month, 
                Year        => $Param{Year},
                ContractID  => $ContractID
            );

			my $TicketAccountedTime = $Self->_TicketAccountedTimeGet(
				CustomerID                    => $Self->{CustomerID},
				Types                         => $GetTypeList,
				DynamicField_CustomerContract => {
					Equals => $ContractID,
				},
                ContractID => $ContractID,
				%MonthPeriod
			);

			my $ContractAccountedTime = $TicketAccountedTime->{TicketAccountedTime};
            
			# my $NewContractAccountedTime = $TicketAccountedTime->{TicketAccountedTime}/60;
			my $NewContractAccountedTime;

			my $TotalContractHours;

			if( defined $TotalContractHours && $ContractData{TypeHours} == 2 ){

				$TotalContractHours = sprintf("%.0f", $ContractData{TotalHours}/12);
			}
			else {
				$TotalContractHours = $ContractData{TotalHours};
			}

			# my $ContracAccounted = _ConvertSecondsToHHMMSS($ContractAccountedTime*60);
			my $ContracAccounted;

			my $TotalHours;
   
            if(!$CustomUnitsTime && $UnitsTime == 1){
			    $NewContractAccountedTime = $TicketAccountedTime->{TicketAccountedTime}/60;

                $ContractAccountedTime = sprintf("%.2f", $ContractAccountedTime/60);
                $TotalHours = _ConvertSecondsToHHMMSS($TotalContractHours*60*60);
                $ContracAccounted = _ConvertSecondsToHHMMSS($ContractAccountedTime*60);

            }
            else{
			    $NewContractAccountedTime = $TicketAccountedTime->{TicketAccountedTime};

                $ContractAccountedTime = sprintf("%.2f", $ContractAccountedTime);
                $TotalHours = _ConvertSecondsToHHMMSS($TotalContractHours*60*60);
                $ContracAccounted = _ConvertSecondsToHHMMSS($ContractAccountedTime*60*60);

            }

			# $ContractAccountedTime = sprintf("%.2f", $ContractAccountedTime/60);
			# $TotalHours = _ConvertSecondsToHHMMSS($TotalContractHours*60*60);

            my $ConsumptionHoursString = $ContracAccounted;
            my $ContracAccountedTOTAL;

            if ( $ContractData{TypeHours} == 3 ) {

                my $DateTimeObject = $Kernel::OM->Create(
                    'Kernel::System::DateTime',
                    ObjectParams => {
                        String   => "$Param{Year}-$Month-01 00:00:00",
                    }
                );

                my $LastDayOfMonth = $DateTimeObject->LastDayOfMonthGet();

                my $TicketAccountedTimeProjectTotal = $Self->_TicketAccountedTimeGet(
                    CustomerID                    => $Self->{CustomerID},
                    Types                         => $GetTypeList,
                    DynamicField_CustomerContract => {
                        Equals => $ContractID,
                    },
                    ContractID => $ContractID,
                    ArticleCreateTimeNewerDate => $ContractData{StartDate},
	                ArticleCreateTimeOlderDate => "$Param{Year}-$Month-$LastDayOfMonth->{Day} 23:59:59",
                );

                $ContracAccountedTOTAL = _ConvertSecondsToHHMMSS($TicketAccountedTimeProjectTotal->{TicketAccountedTime}*60);

                $ContractAccountedTime = $TicketAccountedTimeProjectTotal->{TicketAccountedTime};
                
                $NewContractAccountedTime = $TicketAccountedTimeProjectTotal->{TicketAccountedTime}/60;

                $ContractAccountedTime = sprintf("%.2f", $ContractAccountedTime/60);

                $ConsumptionHoursString = "$ContracAccounted(M) - $ContracAccountedTOTAL(T)";

            }

            my $Percent = 0;

			if( $TotalContractHours >= 0 || $ContractAccountedTime >= 0 ){

				if ( $TotalContractHours > 0 ) {
					$Percent = ( $ContractAccountedTime * 100 ) / $TotalContractHours;
				}
			}

            # Old balance
            #my $Balance = $TotalContractHours - $ContractAccountedTime;
            #$Balance = _ConvertSecondsToHHMMSS($Balance*60*60);

            my $NewBalance =  ($TotalContractHours - $NewContractAccountedTime)*60*60;
            my $HoursBalanceTime = _ConvertSecondsToHHMMSS($NewBalance);

            my %TypeHoursList = (
				1 => 'Monthly',
				2 => 'Yearly',
				3 => 'Project/Contract term'
			);

			my $ColorPercNotify;

			if ( $Percent >= 100 ) {
				$ColorPercNotify = '#FF505E';
			}
			elsif ( $Percent < 100 && $Percent >= 75 ) {
				$ColorPercNotify = '#ffae4a';
			}
			elsif ( $Percent < 75 && $Percent >= 50 ) {
				$ColorPercNotify = '#fff14a';
			}
			else {
				$ColorPercNotify = '#69BFCC';
			}

			$LayoutObject->Block(
				Name => 'OverviewListRow',
				Data => {
					Name 			   => $ContractData{Name},
					Type 			   => $LayoutObject->{LanguageObject}->Translate( $TypeHoursList{$ContractData{TypeHours}} ),
					TotalHours         => $TotalHours,
					# ConsumptionHours   => $ContracAccounted,
					ConsumptionHours   => $ConsumptionHoursString,
					PercentConsumption => sprintf("%.0f", $Percent) . '%',
					ColorPercNotify    => $ColorPercNotify,
					Month              => $MonthData{$Month},
					Year               => $Param{Year} || $CurrentDate->{Year},
					MonthNumber        => $Month,
					ContractID         => $ContractData{ID},
                    #Balance            => $Balance
                    Balance            => $HoursBalanceTime
				},
			);
		}
	}
	
    return $LayoutObject->Output(
         TemplateFile => 'ConsumptionOfContract',
        Data         => \%Param,
    );
}

sub _GetMonthPeriod {
    my ( $Self, %Param ) = @_;

	# check needed stuff
    if ( ! defined $Param{MonthNumber} || ! defined $Param{Year} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need MonthNumber and Year!',
        );
        return;
    }

    my $ContractObject = $Kernel::OM->Get('Kernel::System::ContractManagement');

    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            String   => "$Param{Year}-$Param{MonthNumber}-01 00:00:00",
        }
    );
    my $LastDayOfMonth = $DateTimeObject->LastDayOfMonthGet();

    my %ContractData = $ContractObject->ContractGet(
        ContractID => $Param{ContractID},
        UserID     => '1'
    );

    my %MonthPeriod;

    # To project type
    # if ( $ContractData{TypeHours} eq '3' ){
    #     $MonthPeriod{ArticleCreateTimeNewerDate} = $ContractData{StartDate};
	#     $MonthPeriod{ArticleCreateTimeOlderDate} = "$Param{Year}-$Param{MonthNumber}-$LastDayOfMonth->{Day} 23:59:59";
    # }else{
        $MonthPeriod{ArticleCreateTimeNewerDate} = "$Param{Year}-$Param{MonthNumber}-01 00:00:00";
	    $MonthPeriod{ArticleCreateTimeOlderDate} = "$Param{Year}-$Param{MonthNumber}-$LastDayOfMonth->{Day} 23:59:59";
    # }

    # Old 
    # $MonthPeriod{TicketChangeTimeNewerDate} = "$Param{Year}-$Param{MonthNumber}-01 00:00:00";
	# $MonthPeriod{TicketChangeTimeOlderDate} = "$Param{Year}-$Param{MonthNumber}-$LastDayOfMonth->{Day} 23:59:59";

	return %MonthPeriod;
}

sub _ConvertSecondsToHHMMSS {

    my $Time = $_[0];

    if($_[0] < 0){
        $_[0] = $_[0] *-1;
    }

    my $hourz=int($_[0]/3600);

    my $leftover=$_[0] % 3600;

    my $minz=int($leftover/60);

    my $secz=int($leftover % 60);

    if($secz == 59){
        $secz = 0;
        $minz = $minz+1;
    }

    if( $Time < 0 ){
		return sprintf ("-%02d:%02d:%02d", $hourz,$minz,$secz)
	}
	else{
		return sprintf ("%02d:%02d:%02d", $hourz,$minz,$secz)
	}
}

sub _GetTypeList {
	my ( $Self, %Param ) = @_;

	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

	# get only ticktes by type
	my $ContractTicketType = $ConfigObject->Get('ContractManagement::Core::TypeList');

	my %Types = $TicketObject->TicketTypeList(
		UserID => $Self->{UserID},
	);

	# get only types names
	my @TypeList = values %Types;

	my @GetTypeList;
	if ( $ConfigObject->Get('Ticket::Type') && IsArrayRefWithData($ContractTicketType) ) {
		for my $Type ( @{$ContractTicketType} ){
			@GetTypeList = grep {$_ ne $Type} @TypeList;
		}
	}
	else{
		push @GetTypeList, @TypeList;
	}

	return \@GetTypeList;
}

sub _TicketAccountedTimeGet {
	my ( $Self, %Param ) = @_;

	# check needed stuff
    if ( ! defined $Param{CustomerID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need CustomerID!',
        );
        return;
    }

    # get objects
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ArticleObject      = $Kernel::OM->Get('Kernel::System::Ticket::Article');
	my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    my %Data = ();

	$Data{TotalTickets} = 0;

	# search in archive
	my %SearchInArchive;
    if (
        $ConfigObject->Get('Ticket::ArchiveSystem')
        && !$ConfigObject->Get('Ticket::CustomerArchiveSystem')
    )
    {
        $SearchInArchive{ArchiveFlags} = [ 'y', 'n' ];
    }

    $Param{CustomerIDRaw} = $Param{CustomerID};

    my $DynamicFieldCustomerContract = $DynamicFieldObject->DynamicFieldGet(
        Name => 'CustomerContract',
    );

    # Old
    # my @TicketIDs = $TicketObject->TicketSearch(
    #     Result         => 'ARRAY',
    #     CustomerIDRaw  => [$Self->{CustomerID}],
	# 	CustomerUserID => $Self->{UserID},
    #     %Param,
    #     %SearchInArchive
    # );
    # ----
    # This function has to be done in place of the standard ticket search because it was necessary to use the 'ArticleCreateTime...Date' Tags for retroactive time.
    # And using them otrs included in its search art.is_visible_for_customer = 1, which did not work with retroactive.
    # ----
    my @TicketIDs = $TicketObject->TicketSearch(
        Result         => 'ARRAY',
        CustomerIDRaw  => [$Self->{CustomerID}],
	 	# CustomerUserID => $Self->{UserID},
	 	UserID => '1',
        %Param,
        %SearchInArchive
    );

    my %TicketClosedSearch = (
        %Param,
        TicketCloseTimeNewerDate => $Param{ArticleCreateTimeNewerDate},
        TicketCloseTimeOlderDate => $Param{ArticleCreateTimeOlderDate},
    );

    delete $TicketClosedSearch{TicketChangeTimeNewerDate};
    delete $TicketClosedSearch{TicketChangeTimeOlderDate};

    my @TicketClosedIDs = $TicketObject->TicketSearch(
        Result         => 'ARRAY',
        CustomerIDRaw  => [$Self->{CustomerID}],
		#CustomerUserID => $Self->{UserID},
        UserID => '1',
        %TicketClosedSearch,
        %SearchInArchive
    );

    $Data{TicketAccountedTime} = 0;
    $Data{AccountedTicket}     = scalar @TicketIDs;
    $Data{TotalAccountedTime}  = 0;

    # get accounted time by article
 	foreach my $TicketID (@TicketIDs){

        if ( grep $_ == $TicketID, @TicketClosedIDs ){
			$Data{TotalAccountedTime} += $TicketObject->TicketAccountedTimeGet(TicketID => $TicketID);
		}

        my @Articles = $ArticleObject->ArticleList(
            TicketID => $TicketID,
        );

    	foreach my $Article (@Articles){
            my $NewerDateObject = $Kernel::OM->Create(
                'Kernel::System::DateTime',
                ObjectParams => {
                    String   => $Param{ArticleCreateTimeNewerDate},
                }
            );

            my $OlderDateObject = $Kernel::OM->Create(
                'Kernel::System::DateTime',
                ObjectParams => {
                    String   => $Param{ArticleCreateTimeOlderDate},
                }
            );

            my $CreateDateObject = $Kernel::OM->Create(
                'Kernel::System::DateTime',
                ObjectParams => {
                    String   => $Article->{CreateTime},
                }
            );

            my $CompareNewer = $CreateDateObject->Compare( DateTimeObject => $NewerDateObject );
            my $CompareOlder = $CreateDateObject->Compare( DateTimeObject => $OlderDateObject );

            if( $CompareNewer >= 0 && $CompareOlder <= 0 ){
                $Data{TicketAccountedTime} += $ArticleObject->ArticleAccountedTimeGet( ArticleID => $Article->{ArticleID} );
            }
        }

        $Data{TotalTickets} += 1;
    }

    return \%Data;
}

sub _ExportTickets {
    my ( $Self, %Param ) = @_;

    # get objects
	my $CustomerPortalObject = $Kernel::OM->Get('Kernel::System::CustomerPortal');
    my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
    my $ContractObject       = $Kernel::OM->Get('Kernel::System::ContractManagement');
    my $CSVObject            = $Kernel::OM->Get('Kernel::System::CSV');
    my $LayoutObject         = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject         = $Kernel::OM->Get('Kernel::System::Ticket');
    my $DynamicFieldObject   = $Kernel::OM->Get('Kernel::System::DynamicField');

    my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');
    my $CurrentDate    = $DateTimeObject->Get();

    my $CustomUnitsTime = $ConfigObject->Get('ContractManagement::Core::CustomUnitsTime');
    my $UnitsTime       = $ConfigObject->Get('ContractManagement::Core::UnitsTime');


    my %ContractData = $ContractObject->ContractGet(
        ContractID => $Param{ContractID},
        UserID     => $Self->{UserID},
    );

    # search in archive
    my %SearchInArchive;
    if (
        $ConfigObject->Get('Ticket::ArchiveSystem')
        && !$ConfigObject->Get('Ticket::CustomerArchiveSystem')
    )
    {
        $SearchInArchive{ArchiveFlags} = [ 'y', 'n' ];
    }

    # ----
    # This function has to be done in place of the standard ticket search because it was necessary to use the 'ArticleCreateTime...Date' Tags for retroactive time.
    # And using them otrs included in its search art.is_visible_for_customer = 1, which did not work with retroactive.
    # ----

    my @TicketIDs =  $TicketObject->TicketSearch(
        Result         => 'ARRAY',
        CustomerIDRaw  => [$Self->{CustomerID}],
        #CustomerUserID => $Self->{UserID},
        UserID         => '1',
        Types          => $Param{Types},
        DynamicField_CustomerContract => {
            Equals => $Param{ContractID},
        },
        %SearchInArchive,
        %Param,
    );

    my $DefaultColumns       = $ConfigObject->Get('CustomerPortal::Core::ColumnsReportContractInPortal');
    my $DisplatFormatConfig  = $ConfigObject->Get('CustomerPortal::Core::Contract::DisplayFormat') || 'Article';

    my @DataARRAY;

	for my $TicketID ( @TicketIDs ) {

		my %Ticket = $TicketObject->TicketGet(
            TicketID       => $TicketID,
            CustomerUserID => $Self->{UserID},
            DynamicFields  => 1,
        );
        
        my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
        my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

        for my $ColumnHeader (@{$DefaultColumns}){
            if ( $ColumnHeader =~ m{DynamicField_(\S+)} ) {
                my $DynamicFieldName = $1;

                my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
                    Name => $DynamicFieldName,
                );

                my $PossibleValues = $BackendObject->PossibleValuesGet(
                    DynamicFieldConfig => $DynamicField,       # complete config of the DynamicField
                );


                if ($DynamicField->{FieldType} eq 'Dropdown'){
                    $Ticket{"DynamicField_$DynamicFieldName"} = $PossibleValues->{$Ticket{"DynamicField_$DynamicFieldName"}};
                }

                if ($DynamicField->{FieldType} eq 'Multiselect'){
                    $Ticket{"DynamicField_$DynamicFieldName"} = join(',', @{$Ticket{"DynamicField_$DynamicFieldName"}});
                }

            }
        
        }
       

		my @DataArticle = $CustomerPortalObject->GetTimeAccountedPeriod(
			TicketID  => $TicketID,
            StartDate => $Param{ArticleCreateTimeNewerDate},
			EndDate   => $Param{ArticleCreateTimeOlderDate},
		);

        if ( $DisplatFormatConfig eq 'Ticket' ) {
            
            my @Data;

            my $TotalTime = 0;
            for my $ArticleRow ( @DataArticle ) {
                $TotalTime += $ArticleRow->{TimeUnit};
            }

            for my $Columns ( @{$DefaultColumns} ) {
                    
                if( $Columns eq 'Accounted Time' ) {
                    
                    if( $UnitsTime == 1 && !$CustomUnitsTime ) {
                        push @Data, _ConvertSecondsToHHMMSS($TotalTime * 60);
                    }
                    else {
                        push @Data, _ConvertSecondsToHHMMSS($TotalTime * 60 * 60);
                    }
                }
                else{
                    push @Data, $Ticket{$Columns};
                }
            }

            push @DataARRAY, \@Data;
        }
        else {

            for my $ArticleRow ( @DataArticle ) {

                my @Data;

                my $CreateDateArticleObject = $Kernel::OM->Create(
                    'Kernel::System::DateTime',
                    ObjectParams => {
                        String   => $ArticleRow->{CreateTime},
                    }
                ); 

                my $Count = 0;

                for my $Columns (@{$DefaultColumns}){
                    
                    if ($Columns eq 'Accounted Time'){
                        
                        if ( $UnitsTime == 1 && !$CustomUnitsTime ) {
                            push @Data, _ConvertSecondsToHHMMSS($ArticleRow->{TimeUnit} * 60);
                        }
                        else {
                            push @Data, _ConvertSecondsToHHMMSS($ArticleRow->{TimeUnit} * 60 * 60);
                        }
                    }
                    elsif ( $Columns eq 'Appointment Date' ) {
                        push @Data, $CreateDateArticleObject->Format( Format => '%d/%m/%Y %H:%M' );
                    }
                    else {
                        push @Data, $Ticket{$Columns};
                    }
                }

                push @DataARRAY, \@Data;
            }
        }
	}

    my @HeaderTranslable;
    for my $ColumnHeader (@{$DefaultColumns}){
        if ( $ColumnHeader =~ m{DynamicField_(\S+)} ) {
            my $DynamicFieldName = $1;

            my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
                Name => $DynamicFieldName,
            );
            push @HeaderTranslable,$DynamicField->{Label};
        }
        else{
            if ( $DisplatFormatConfig ne 'Ticket' || $ColumnHeader ne 'Accounted Time' ) {
                push @HeaderTranslable, $LayoutObject->{LanguageObject}->Translate($ColumnHeader);
            }
        }        
    }

    my $CurrentData = $DateTimeObject->ToString();

    # $CurrentData =~ s/[:-]//g;
    $CurrentData =~ s/ /--/;

    my $FileName  = $LayoutObject->{LanguageObject}->Translate("ContractTickets_"). '_' . $CurrentData;

    my $Content = $CSVObject->Array2CSV(
        Head   => \@HeaderTranslable,
        Data   => \@DataARRAY,
        Format => 'Excel',
    );

    return $LayoutObject->Attachment(
        Filename    => $FileName . '.xlsx',
        ContentType => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
		Charset     => 'utf-8',
        Content     => $Content,
    );
}

1;