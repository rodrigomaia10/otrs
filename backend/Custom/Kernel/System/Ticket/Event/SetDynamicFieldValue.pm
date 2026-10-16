# --
# Kernel/System/Ticket/Event/SetDynamicFieldValue.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * gesquetini@beonup.com.br
# * jgsantos@serviceup.com.br
# --

package Kernel::System::Ticket::Event::SetDynamicFieldValue;

use strict;
use warnings;

use utf8;

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get object
    my $ConfigObject              = $Kernel::OM->Get('Kernel::Config');
    my $CustomFormObject          = $Kernel::OM->Get('Kernel::System::CustomServiceForm');
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
	my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $DynamicFieldValueObject   = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');
    my $ParamObject               = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $TicketObject              = $Kernel::OM->Get('Kernel::System::Ticket');

    # check needed stuff
    for (qw(Data Event Config)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }
    for (qw(TicketID)) {
        if ( !$Param{Data}->{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_ in Data!"
            );
            return;
        }
    }

    # get params
	my $ServiceID = $ParamObject->GetParam( Param => 'ServiceID' );

    return if (!$ServiceID);

    my $FormSearch = $CustomFormObject->CustomFormSearch(
		ServiceID   => $ServiceID,
	);

    return if (!$FormSearch);

    my $Fields = $CustomFormObject->CustomFormDynamicFieldList(
		FormID  => $FormSearch,
		UserID  => $Param{UserID},
	);

	#Get all the fields in the actual form
    DYNAMICFIELD:
	for my $Field ( @{$Fields} ) {

		my ($FieldName , $Name) = split /_/, $Field->{Name};

		my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
			Name => $Name,
		);

		my $DynamicFieldValue;

		if ( $DynamicField->{FieldType} eq 'Multiselect' ) {
			
			my @DynamicFieldArray = ();
			@DynamicFieldArray = $ParamObject->GetArray( Param => $Field->{Name} );

			foreach my $Item ( @DynamicFieldArray ){
				push @{$DynamicFieldValue}, $Item;
			}
		}
		elsif ( $DynamicField->{FieldType} eq 'Date' ) {
			my $DynamicFieldChecked = $ParamObject->GetParam( Param => "$Field->{Name}Used" );

			if ( $DynamicFieldChecked ){
				my $DateDay   = $ParamObject->GetParam( Param => "$Field->{Name}Day" );
				my $DateMonth = $ParamObject->GetParam( Param => "$Field->{Name}Month" );
				my $DateYear  = $ParamObject->GetParam( Param => "$Field->{Name}Year" );

				if($DateMonth < 10){
					$DateMonth = "0".$DateMonth;
				}
				if($DateDay < 10){
					$DateDay = "0".$DateDay;
				}

				my $FullDate = "$DateYear-$DateMonth-$DateDay 00:00:00";

				$DynamicFieldValue = $FullDate;
			}
		}
		elsif ( $DynamicField->{FieldType} eq 'DateTime' ) {
			my $DynamicFieldChecked = $ParamObject->GetParam( Param => "$Field->{Name}Used" );

			if ( $DynamicFieldChecked ){
				my $DateDay = $ParamObject->GetParam( Param => "$Field->{Name}Day" );
				my $DateMonth = $ParamObject->GetParam( Param => "$Field->{Name}Month" );
				my $DateYear = $ParamObject->GetParam( Param => "$Field->{Name}Year" );
				my $DateHour = $ParamObject->GetParam( Param => "$Field->{Name}Hour" );
				my $DateMinute = $ParamObject->GetParam( Param => "$Field->{Name}Minute" );
				
				if(!$DateHour){
					$DateHour = "0";
				}
				if(!$DateMinute){
					$DateMinute = "0";
				}
				if($DateMonth < 10){
					$DateMonth = "0".$DateMonth;
				}
				if($DateDay < 10){
					$DateDay = "0".$DateDay;
				}
				if($DateHour < 10){
					$DateHour = "0".$DateHour;
				}

				if($DateMinute < 10){
					$DateMinute = "0".$DateMinute;
				}

				my $FullDate = "$DateYear-$DateMonth-$DateDay $DateHour:$DateMinute:00";

				$DynamicFieldValue = $FullDate;
			}
		}
		elsif( $DynamicField->{FieldType} eq 'FileSystem' ) {
			my $DynamicFieldFileSystemValueObject = $Kernel::OM->Get('Kernel::System::DynamicField::Driver::FileSystem');

			my %UploadStuff = $ParamObject->GetMultipleUpload(
                Param => $Field->{Name},
				Source => 'file',
            );

			my $FileCounter = $UploadStuff{Multiple};

			for my $FileID ( 1 .. $FileCounter ) {

				my $Sucess = $Kernel::OM->Get('Kernel::System::DynamicFieldFileSystemValue')->ValueSet(
					FieldID  	=> 	$DynamicField->{ID},
					ObjectID 	=> 	$Param{Data}->{TicketID},
					FileContent => 	$UploadStuff{"DynamicField_"."$DynamicField->{Name}"."_$FileID"},
					UserID 		=> 	$Param{UserID},
				);

				if ( $Sucess ) {
					
					my $OK = $DynamicFieldValueObject->ValueSet(
						FieldID  => $DynamicField->{ID},
						ObjectID => $Param{Data}->{TicketID},
						Value    => [{ ValueText => 1 }],
						UserID   => $Param{UserID},
					);

					if ( $OK ) {
						my $FileName = $UploadStuff{"DynamicField_"."$DynamicField->{Name}"."_$FileID"}->{Filename};

						my $TextValue = 'Formulário de Serviço ( ' . $DynamicField->{Label} . ' = ' . $FileName . ' )';
						my $HistoryAdd = $TicketObject->HistoryAdd(
							Name         => $TextValue,
							HistoryType  => 'Misc',
							TicketID     => $Param{Data}->{TicketID},
							CreateUserID => $Param{UserID},
						);
					}
				}

				if(!$Sucess){
					$Kernel::OM->Get('Kernel::System::Log')->Log(
						Priority => 'error',
						Message  => "Upload of FileID $FileID is invalid!",
					);
				}
			}
		}
        elsif ( $DynamicField->{FieldType} eq 'Table'  ) {

            # get object
            my $DynamicFieldTableObject = $Kernel::OM->Get('Kernel::System::DynamicFieldTable');

            my $FormID = $ParamObject->GetParam( Param => 'FormID' );

            $DynamicFieldValue = $DynamicFieldTableObject->ValueGet(
                FieldID => $DynamicField->{ID},
                FormID  => $FormID
            );
        }
		else {

			my $DynamicFieldScalar = $ParamObject->GetParam( Param => $Field->{Name} );
			$DynamicFieldValue = $DynamicFieldScalar;
		}

		next DYNAMICFIELD if (!defined $DynamicFieldValue);

		my $Success = $DynamicFieldBackendObject->ValueSet(
			DynamicFieldConfig => $DynamicField,     
			ObjectID           => $Param{Data}->{TicketID},
			Value              => $DynamicFieldValue,
			UserID             => $Param{UserID}
		);

		if( $Success ) {

            my $Value = $DynamicFieldValue;

			if( $Value ) {

				my $TextValue = 'Formulário de Serviço ( '. $DynamicField->{Label};

				# create a history
				if( $DynamicField->{FieldType} eq "Multiselect" ) {

					my $FinalItem = scalar @$DynamicFieldValue;
					my $Flag = 1;
					for my $Val (@{$DynamicFieldValue}){
						if ( $Flag == 1 ) {
							$TextValue .= " = { ". $Val . " , ";
						}
						elsif ( $Flag == $FinalItem ) {
							$TextValue .= " ". $Val . " } ";
							
						}
						else {
							$TextValue .= " ".$Val . " , ";
						}
						$Flag++;						
					}
					$TextValue .= ")";
				}
                else {

					$TextValue .=  ' = ' . $Value . ' )';
				}

				my $HistoryAdd = $TicketObject->HistoryAdd(
					Name         => $TextValue,
					HistoryType  => 'Misc',
					TicketID     => $Param{Data}->{TicketID},
					CreateUserID => $Param{UserID},
				);
			}
		}
	}

    return 1;
}

1;
