# --
# Custom/Kernel/Modules/DynamicFieldTableRender.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * mbernardo@serviceup.com.br
# * lcavalheiro@serviceup.com.br
# * ykanegae@serviceup.com.br
# * nfreitas@serviceup.com.br
# --
 
package Kernel::Modules::DynamicFieldTableRender;

use strict;
use warnings;

use Kernel::Language qw(Translatable);
use Kernel::System::VariableCheck qw(:all);

use Text::CSV;
use Excel::Writer::XLSX;

use utf8;
use JSON;

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    $Self->{EditableByMap} = {
        User        => 'agent',
        Customer    => 'customer'
    };

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # create needed objects
    my $ParamObject             = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject            = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $DynamicFieldObject      = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldTableObject = $Kernel::OM->Get('Kernel::System::DynamicFieldTable');
    my $JSONObject              = $Kernel::OM->Get('Kernel::System::JSON');
    my $TicketObject            = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ConfigObject            = $Kernel::OM->Get('Kernel::Config');
    my $WebserviceObject        = $Kernel::OM->Get('Kernel::System::GenericInterface::Webservice');
    my $RequesterObject         = $Kernel::OM->Get('Kernel::GenericInterface::Requester');

    # get params
    $Param{Subaction}   = $ParamObject->GetParam( Param => 'Subaction' ) || '';
    $Param{FieldID}     = $ParamObject->GetParam( Param => 'FieldID' )   || '';
    $Param{FormID}      = $ParamObject->GetParam( Param => 'FormID' )    || '';
    $Param{TicketID}    = $ParamObject->GetParam( Param => 'TicketID' )  || '';
    $Param{ContractID}  = $ParamObject->GetParam( Param => 'ContractID' )  || '';

    my %Ticket;

    if ( $Param{TicketID} ) {
        %Ticket = $TicketObject->TicketGet(
            TicketID => $Param{TicketID},
            UserID   => 1,
        );
    }

    my $UserAuthType    = $Self->{EditableByMap}{$Self->{UserType}};
    $UserAuthType       ||= "agent";

    # ------------------------------------------------------------ #
    # No subaction
    # ------------------------------------------------------------ #
    if ( !$Param{Subaction} ) {

        my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
            ID => $Param{FieldID},
        );

        my $OperationColJSON;
        my $PossSumRowJSON;
     
        if ( $DynamicField->{Config}->{OperationColumn}->{Operation} ) {
            $OperationColJSON = $JSONObject->Encode(
                Data => $DynamicField->{Config}->{OperationColumn}->{Columns}
            );

            if ($DynamicField->{Config}->{RowsSum} eq 'true') {
                $PossSumRowJSON = $JSONObject->Encode(
                    Data => $DynamicField->{Config}->{OperationColumn}->{Columns}
                );
            }
        }

        # Get readonly columns
        for my $i ( 0 .. @{$DynamicField->{Config}->{PossibleColumns}}-1 ) {

            my $ColumnEditableBy = $DynamicField->{Config}->{PossibleColumns}[$i]->{editable};

            if ( $ColumnEditableBy ne 'everyone' && $ColumnEditableBy ne $UserAuthType ) {
                
                $DynamicField->{Config}->{PossibleColumns}[$i]->{ctrlAttr} = {"disabled" => "true"};
            }
        }

        # process default values
        for my $i ( 0 .. @{$DynamicField->{Config}->{PossibleColumns}}-1 ) {       

            my $DefaultValue = $DynamicField->{Config}->{PossibleColumns}[$i]->{value};

            # check if is from config
            if ( rindex( $DefaultValue, "config::") == 0 ) {
                
                my $ConfigName  = substr $DefaultValue, 8;
                my $ConfigValue = $$ConfigObject->Get($ConfigName);

                $DynamicField->{Config}->{PossibleColumns}[$i]->{value} = $ConfigValue;
            }

            # check if is from config
            if ( rindex( $DefaultValue, "module::") == 0 ) {
                
                my $ModuleName      = substr $DefaultValue, 8;
                my $ModuleObject    = $Kernel::OM->Get($ModuleName);
                my $ConfigValue     = $ModuleObject->Run(
                    Data => \%Param
                );

                $DynamicField->{Config}->{PossibleColumns}[$i]->{value} = $ConfigValue;
            }
        }

        my $JSONString = $JSONObject->Encode(
            Data => $DynamicField->{Config}->{PossibleColumns},
        );

        my $Output = $LayoutObject->Header( Type => 'Small' );

        my %MaskMoneyHash;
        my %MaskHash;
        my $JSONValueLoaded;

        my $DependencyTable = $DynamicField->{Config}->{DependencyTable};
        my $DependencyTableJsonValue;

        #Get the masks
        for my $Column ( @{$DynamicField->{Config}->{PossibleColumns}} ) {
            if ( $Column->{type} eq 'maskMoney' ) {

                $MaskMoneyHash{ $Column->{name} } = {
                    Prefix   => $DynamicField->{Config}->{PossibleMasks}->{ $Column->{name} }->{Prefix},
                    Negative => $DynamicField->{Config}->{PossibleMasks}->{ $Column->{name} }->{Negative},
                };

            }
            elsif ( $Column->{type} eq 'mask' ) {

                if ( $DynamicField->{Config}->{PossibleMasks}->{ $Column->{name} }->{Mask} ne '' ) {

                    $MaskHash{ $Column->{name} } = $DynamicField->{Config}->{PossibleMasks}->{ $Column->{name} }->{Mask};
                }
            }
        }

        if ( $Param{FormID} && !$Param{TicketID} && !$Param{ContractID} ) {

            $JSONValueLoaded = $DynamicFieldTableObject->ValueGet(
                FieldID => $Param{FieldID},
                FormID  => $Param{FormID},
            );     

            if ( defined $DependencyTable && $DependencyTable ne '' ) {
                $DependencyTableJsonValue = $DynamicFieldTableObject->ValueGet(
                    FieldID => $DependencyTable,
                    FormID  => $Param{FormID},
                );
            }
        }
        elsif ( $Param{TicketID} ) {

            $JSONValueLoaded = $DynamicFieldTableObject->ValueGet(
                FieldID  => $Param{FieldID},
                ObjectID => $Param{TicketID},
            );

            if(defined $DependencyTable) {
                $DependencyTableJsonValue = $DynamicFieldTableObject->ValueGet(
                    FieldID  => $DependencyTable,
                    ObjectID => $Param{TicketID},
                );
            }
        }
        elsif ( $Param{ContractID} ) {

            $JSONValueLoaded = $DynamicFieldTableObject->ValueGet(
                FieldID  => $Param{FieldID},
                ObjectID => "Contract-$Param{ContractID}",
            );

            if(defined $DependencyTable) {
                $DependencyTableJsonValue = $DynamicFieldTableObject->ValueGet(
                    FieldID  => $DependencyTable,
                    ObjectID => "Contract-$Param{ContractID}",
                );
            }
        }

        if(!defined $JSONValueLoaded) {

            $JSONValueLoaded = $DependencyTableJsonValue;
        }

        my $Format = $LayoutObject->BuildSelection(
            Data         => [ 'PDF', 'Excel' ],
            Name         => 'Format',
            PossibleNone => 1,
            Class        => 'Modernize W20pc',
        );

        if ($JSONValueLoaded) {

            $LayoutObject->Block(
                Name => 'PossibleExport',
                Data => {
                    Format     => $Format,
                    TableLabel => $DynamicField->{Label}
                }
            );
        }

        my $JSONMaskMoney = $JSONObject->Encode(
            Data => \%MaskMoneyHash
        );

        my $JSONMask = $JSONObject->Encode(
            Data => \%MaskHash
        );

        my $Disabled;
        if (
            $Ticket{StateID} && 
            $DynamicField->{Config}->{PossibleStates} &&
            grep { $_ == $Ticket{StateID} } @{ $DynamicField->{Config}->{PossibleStates} }
        ) {
            $Disabled = 'true'
        }
		
		my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
		
        my $OperationDynamicField;

        if ( $DynamicField->{Config}->{ColumnsSum}->{ExtractOperation} ) {

            $OperationDynamicField = $DynamicFieldObject->DynamicFieldGet(
                Name => $DynamicField->{Config}->{ColumnsSum}->{ExtractOperation},
            );	
        }

		my $Operation = $DynamicField->{Config}->{ColumnsSum}->{Operation};

        my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');               

        my $PerlStructureScalar = $JSONObject->Decode(
            Data => $JSONValueLoaded,
        );

        my $DependencyTablePerlStructureScalar = $JSONObject->Decode(
            Data => $DependencyTableJsonValue,
        );

        if(defined $PerlStructureScalar ){

            # get new lines
            if(defined $DependencyTablePerlStructureScalar ){
                my $LoadedJsonLength         = scalar @{$PerlStructureScalar};
                my $DependencyTableLength    = scalar @{$DependencyTablePerlStructureScalar};

                if($LoadedJsonLength < $DependencyTableLength) {
                    my @NewLines = @{$DependencyTablePerlStructureScalar}[$LoadedJsonLength .. $DependencyTableLength-1];

                    push @{$PerlStructureScalar}, @NewLines;
                }
            }

            # define default values if exported

            my %DefaultValues = ();
            for my $index ( 0 .. @{$DynamicField->{Config}->{PossibleColumns}}-1 ) {

                my $FieldName   = $DynamicField->{Config}->{PossibleColumns}[$index]->{name};
                my $FieldValue  = $DynamicField->{Config}->{PossibleColumns}[$index]->{value};

                $DefaultValues{$FieldName} = $FieldValue;
            }

            for my $DataRow (@{$PerlStructureScalar}) {

                $DataRow = { %DefaultValues, %$DataRow };
            }

            $JSONValueLoaded = $JSONObject->Encode(
                Data => $PerlStructureScalar
            );
        }

        $LayoutObject->Block(
            Name => 'Save',
        );

        my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
        my $Sort         = $ConfigObject->Get('DynamicFieldTable::Core')->{SortList};

        $Output .= $LayoutObject->Output(
            TemplateFile => 'DynamicFieldTableRender',
            Data         => {
                ColumnsJSON      => $JSONString,
                TableLabel       => $DynamicField->{Label},
                FormID           => $Param{FormID},
                TicketID         => $Param{TicketID},
                ContractID       => $Param{ContractID},
                FieldID          => $Param{FieldID},
                FieldName        => $DynamicField->{Name},
                JSONMask         => $JSONMask,
                JSONMaskMoney    => $JSONMaskMoney,
                JSONValueLoaded  => $JSONValueLoaded || 'undefined',
                OperationColumn  => $DynamicField->{Config}->{OperationColumn}->{Operation},
                OperationFormula => $DynamicField->{Config}->{OperationColumn}->{Formula},
                OperationColJSON => $OperationColJSON || 'undefined',
                PossibleRowSum   => $DynamicField->{Config}->{RowsSum},
                PossSumRowJSON   => $PossSumRowJSON || 'undefined',
                DisabledTable    => $Disabled || 'false',
                Operation        => $Operation || 'undefined',               
                LabelOperation   => $OperationDynamicField->{Label} || 'undefined',
                Sort             => $Sort,
            },
        );

        $Output .= $LayoutObject->Footer( Type => 'Small' );

        return $Output;
    }
    elsif ( $Self->{Subaction} eq 'ViewMore' ) {

        my $Output;

        my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
            ID => $Param{FieldID},
        );

        my $OperationColJSON;
        my $PossSumRowJSON;

        if ( $DynamicField->{Config}->{OperationColumn}->{Operation} ) {
            $OperationColJSON = $JSONObject->Encode(
                Data => $DynamicField->{Config}->{OperationColumn}->{Columns}
            );

            if ($DynamicField->{Config}->{RowsSum} eq 'true') {
                $PossSumRowJSON = $JSONObject->Encode(
                    Data => $DynamicField->{Config}->{OperationColumn}->{Columns}
                );
            }
        }

        my $JSONString = $JSONObject->Encode(
            Data => $DynamicField->{Config}->{PossibleColumns},
        );		
		
        $Output = $LayoutObject->Header( Type => 'Small' );

        my %MaskMoneyHash;
        my %MaskHash;
        my $JSONValueLoaded;

        #Get the masks
        for my $Column ( @{$DynamicField->{Config}->{PossibleColumns}} ) {
            if ( $Column->{type} eq 'maskMoney' ) {

                $MaskMoneyHash{ $Column->{name} } = {
                    Prefix   => $DynamicField->{Config}->{PossibleMasks}->{ $Column->{name} }->{Prefix},
                    Negative => $DynamicField->{Config}->{PossibleMasks}->{ $Column->{name} }->{Negative},
                };

            }
            elsif ( $Column->{type} eq 'mask' ) {
                if ( $DynamicField->{Config}->{PossibleMasks}->{ $Column->{name} }->{Mask} ne '' ) {

                    $MaskHash{ $Column->{name} }
                        = $DynamicField->{Config}->{PossibleMasks}->{ $Column->{name} }->{Mask};
                }
            }
        }

        if ( $Param{FormID} && !$Param{TicketID} ) {
            $JSONValueLoaded = $DynamicFieldTableObject->ValueGet(
                FieldID => $Param{FieldID},
                FormID  => $Param{FormID},
            );
        }
        elsif ( $Param{TicketID} ) {
            $JSONValueLoaded = $DynamicFieldTableObject->ValueGet(
                FieldID  => $Param{FieldID},
                ObjectID => $Param{TicketID},
            );
        }

        my $JSONMaskMoney = $JSONObject->Encode(
            Data => \%MaskMoneyHash
        );

        my $JSONMask = $JSONObject->Encode(
            Data => \%MaskHash
        );

        my $Disabled;
        if (
            $Ticket{StateID}
            && $DynamicField->{Config}->{PossibleStates}
            &&
            grep { $_ == $Ticket{StateID} } @{ $DynamicField->{Config}->{PossibleStates} }
            )
        {
            $Disabled = 'true'
        }
		
		my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
		
        my $OperationDynamicField;
        if($DynamicField->{Config}->{ColumnsSum}->{ExtractOperation}){
            $OperationDynamicField = $DynamicFieldObject->DynamicFieldGet(
                Name => $DynamicField->{Config}->{ColumnsSum}->{ExtractOperation},
            );	
        }

		my $Operation = $DynamicField->{Config}->{ColumnsSum}->{Operation};

        my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');

        my $PerlStructureScalar = $JSONObject->Decode(
            Data => $JSONValueLoaded,
        );

        if(defined $PerlStructureScalar ){
            $JSONValueLoaded = $JSONObject->Encode(
                Data     => $PerlStructureScalar
            );
        }
         
        my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
        my $Sort         = $ConfigObject->Get('DynamicFieldTable::Core')->{SortList};

        $Output .= $LayoutObject->Output(
            TemplateFile => 'DynamicFieldTableRender',
            Data         => {
                ColumnsJSON      => $JSONString,
                TableLabel       => $DynamicField->{Label},
                FormID           => $Param{FormID},
                TicketID         => $Param{TicketID},
                FieldID          => $Param{FieldID},
                JSONMask         => $JSONMask,
                JSONMaskMoney    => $JSONMaskMoney,
                JSONValueLoaded  => $JSONValueLoaded || 'undefined',
                OperationColumn  => $DynamicField->{Config}->{OperationColumn}->{Operation},
                OperationFormula => $DynamicField->{Config}->{OperationColumn}->{Formula},
                OperationColJSON => $OperationColJSON || 'undefined',
                PossibleRowSum   => $DynamicField->{Config}->{RowsSum},
                PossSumRowJSON   => $PossSumRowJSON || 'undefined',
                DisabledTable    => 'true',
                Operation        => $Operation || 'undefined',               
                LabelOperation   => $OperationDynamicField->{Label} || 'undefined',       
                Sort             => $Sort,        
            },
        );

        $Output .= $LayoutObject->Footer( Type => 'Small' );

        return $Output;
    }

    # ------------------------------------------------------------ #
    # SaveData
    # ------------------------------------------------------------ #
    elsif ( $Param{Subaction} eq 'SaveData' ) {

        $Param{JSON} = $ParamObject->GetParam( Param => 'JSON' );

        my $Success;

        # get config object
        my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

        if ( $Param{TicketID} ) {         

            $Success = $DynamicFieldTableObject->ValueSet(
                FieldID  => $Param{FieldID},
                FormID   => $Param{FormID},
                ObjectID => $Param{TicketID},
                JSON     => $Param{JSON},
            );

            my $SuccessValueSet = $Kernel::OM->Get('Kernel::System::DynamicFieldValue')->ValueSet(
                FieldID  => $Param{FieldID},
                ObjectID => $Param{TicketID},
                Value    => [
                    {
                        ValueText => "1",
                    },
                ],
                UserID => $Self->{UserID},
            );
        }
        elsif ( $Param{ContractID} ) {    

            $Success = $DynamicFieldTableObject->TempSet(
                FieldID => $Param{FieldID},
                FormID  => $Param{FormID},
                JSON    => $Param{JSON},
            );     

            $DynamicFieldTableObject->ValueSet(
                FieldID  => $Param{FieldID},
                ObjectID => "Contract-$Param{ContractID}",
                FormID   => $Param{FormID},
                JSON     => $Param{JSON}
            );            
        }
        else {

            $Success = $DynamicFieldTableObject->TempSet(
                FieldID => $Param{FieldID},
                FormID  => $Param{FormID},
                JSON    => $Param{JSON},
            );
        }

        my $Response;
        
        my $DynamicFieldsSum = $ConfigObject->Get('DynamicFieldTable::Core')->{'DynamicFieldSumConfig'};

        my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
            ID => $Param{FieldID}
        );     

        if ($Success) {
            if ( $DynamicFieldsSum->{ $DynamicField->{Name} } ) {
                $Response->{ColumnsSum} = $DynamicFieldsSum->{ $DynamicField->{Name} };
            }
			
			$Response->{OperationConfig} = $DynamicField->{Config}->{ColumnsSum}->{ExtractOperation};
			
            if ( !$Response ) {
                $Response = 'Data saved.';
                $Response = $JSONObject->Encode(
                    Data => { Success => $Response }
                );
            }
			
			# build JSON output
            $Response = $LayoutObject->JSONEncode(
                Data => $Response,
            );
        }
        else {
            $Response = 'Data not saved.';

            $Response = $JSONObject->Encode(
                Data => { Success => $Response }
            );

            # build JSON output
            $Response = $LayoutObject->JSONEncode(
                Data => {
                    JSONString => $Response,
                },
            );
        }

        # send JSON response
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $Response || '',
            Type        => 'inline',
            NoCache     => 1,
        );
    }
	
	# ------------------------------------------------------------ #
    # CacheData
    # ------------------------------------------------------------ #
    elsif ( $Param{Subaction} eq 'CacheData' ) {
		my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');
		
		my $JSONOperation = $ParamObject->GetParam( Param => 'JSONOperation' );
		my $JSONSum       = $ParamObject->GetParam( Param => 'JSONSum' );
		my $JSON          = $ParamObject->GetParam( Param => 'JSON' );
		
		my $SuccessData = $CacheObject->Set(
			Type  => 'DynamicFieldTable',
			Key   => "DynamicFieldTableData$Param{TicketID}$Param{FormID}",
			Value => $JSON,
			TTL   => 60 * 60 * 60,
		);
		
		my $SuccessSum = $CacheObject->Set(
			Type  => 'DynamicFieldTable',
			Key   => "DynamicFieldTableSum$Param{TicketID}$Param{FormID}",
			Value => $JSONSum,
			TTL   => 60 * 60 * 60,
		);
		
		my $SuccessOperation = $CacheObject->Set(
			Type  => 'DynamicFieldTable',
			Key   => "DynamicFieldTableOperation$Param{TicketID}$Param{FormID}",
			Value => $JSONOperation,
			TTL   => 60 * 60 * 60,
		);
		
		my $Response;
		
		if ( $SuccessData ){
			$Response = 'Data saved.';			
		}
		else{
			$Response = 'Data not saved.';
		}
		
		$Response = $JSONObject->Encode(
			Data => { Success => $Response }
		);

        # build JSON output
		$Response = $LayoutObject->JSONEncode(
			Data => {
				JSONString => $Response,
			},
		);

        # send JSON response
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $Response || '',
            Type        => 'inline',
            NoCache     => 1,
        );
	}
	
    # ------------------------------------------------------------ #
    # ExportData
    # ------------------------------------------------------------ #
    elsif ( $Param{Subaction} eq 'ExportData' ) {

		my $LanguageObject = $Kernel::OM->Get('Kernel::Language');
		my $CacheObject    = $Kernel::OM->Get('Kernel::System::Cache');		
        
        $Param{Format}  = $ParamObject->GetParam( Param => 'Format' );
		
		$Param{JSON} = $CacheObject->Get(
			Type => "DynamicFieldTable",
			Key  => "DynamicFieldTableData$Param{TicketID}$Param{FormID}",
		);
		
		$Param{JSONSum} = $CacheObject->Get(
			Type => 'DynamicFieldTable',
			Key  => "DynamicFieldTableSum$Param{TicketID}$Param{FormID}",
		);
		
		$Param{JSONOperation} = $CacheObject->Get(
			Type => 'DynamicFieldTable',
			Key  => "DynamicFieldTableOperation$Param{TicketID}$Param{FormID}",
		);

        $Param{Caption} = $ParamObject->GetParam( Param => 'Caption' );
        $Param{Caption} =~ s/ /_/g;

        if($Ticket{TicketNumber}){
            $Param{Caption} .= "-$Ticket{TicketNumber}";
        }

        my $PerlStructureScalar = $JSONObject->Decode(
            Data => $Param{JSON},
        );

        my $PerlStructureSum = $JSONObject->Decode(
            Data => $Param{JSONSum},
        );
		
		my $PerlStructureOperation = $JSONObject->Decode(
            Data => $Param{JSONOperation},
        );

        my @Header;
        my @Body;
        my @Operation;
		my %Types;

        my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
            ID => $Param{FieldID},
        );

        for my $Column ( @{ $DynamicField->{Config}->{PossibleColumns} } ) {
            push @Header, $Column->{name};
			$Types{$Column->{name}} = $Column->{type}
        }

        if ( $DynamicField->{Config}->{RowsSum} ) {
            push @Header, "RowTotal";
        }

        for my $Line ( @{$PerlStructureScalar} ) {

            my @LineBody = ();

            for my $Col (@Header) {
			
				if ( $Types{$Col} eq 'date' && $Line->{$Col} ){
					
					$Line->{$Col} = $LanguageObject->FormatTimeString(
						$Line->{$Col} . ' 00:00:00',
						'DateFormat',
						1,
					);	
					$Line->{$Col} = ( split / /, $Line->{$Col} )[0];
				}
                elsif ( $Types{$Col} eq 'number' && $Line->{$Col} ) {

                    $Line->{$Col} =~ s/\./,/g;
                }

                push @LineBody, $Line->{$Col};
            }
			
            push @Body, \@LineBody;
        }

        my @LineFooter = ();

        for my $Col (@Header) {

            if ( $PerlStructureSum->{$Col} ) {
                push @LineFooter, $PerlStructureSum->{$Col};
            }
            else {
                push @LineFooter, '';
            }
        }

        push @Body, \@LineFooter;
		
		if ( $PerlStructureOperation ){

			my @LineOperation;

			foreach my $Label ( keys %{$PerlStructureOperation} ){
				push @LineOperation, $Label;
				push @LineOperation, $PerlStructureOperation->{$Label};
				
				push @Operation, \@LineOperation;
			}
		}

        my $SizeHeader = scalar @Header;

        if($DynamicField->{Config}->{RowsSum}){
            $Header[$SizeHeader - 1] = "TOTAL";
        }

        if ( $Param{Format} eq 'Excel' || $Param{Format} eq 'CSV' ) {

            my $Excel .= $Self->_GenerateExcel(
                Head      => \@Header,
                Data      => \@Body,
				Operation => \@Operation,
                Format    => $Param{Format},
            );

            my $Extension;

            if ( $Param{Format} eq 'Excel' ) {
                $Extension = "xlsx";
            }
            else {
                $Extension = "csv";
            }

            my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');
			
			my $TimeStamp = $DateTimeObject->ToString();

            return $LayoutObject->Attachment(
                Filename    => $Param{Caption} . '-' . $TimeStamp . ".$Extension",
                ContentType => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                Content     => $Excel
            );
        }
        elsif ( $Param{Format} eq 'PDF' ) {

            my $PDFString = $Self->_GeneratePDF(
                Title          => $Param{Caption},
                HeadArrayRef   => \@Header,
                DataArray      => \@Body,
                OperationArray => \@Operation,
                UserID         => $Self->{UserID},
            );
			
			my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');
			
			my $TimeStamp = $DateTimeObject->ToString();
			
            return $LayoutObject->Attachment(
                Filename    => $Param{Caption} . '-' .$TimeStamp . '.pdf',
                ContentType => 'application/pdf',
                Content     => $PDFString,
                Type        => 'inline',
            );
        }
    }

    # ------------------------------------------------------------ #
    # ExportData
    # ------------------------------------------------------------ #
    elsif( $Param{Subaction} eq 'AutoComplete') {
        
        $Param{SearchTerm} = $ParamObject->GetParam( Param => 'SearchTerm' )  || '';

        my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
            ID => $Param{FieldID},
        );

        my @Response;
        for my $column ( @{$DynamicField->{Config}->{PossibleColumns}} ) {

            my $AutoCompleteModuleName = $column->{autocomplete_module};
            my $AutoCompleteWebService = $column->{auto_complete_webservice};
          
            if ( defined  $AutoCompleteModuleName && $AutoCompleteModuleName ne '' ) {

                my $AutoCompleteModule = $Kernel::OM->Get($AutoCompleteModuleName);
                
                @Response = $AutoCompleteModule->Run(
                    SearchTerm  => $Param{SearchTerm}
                );

                last;
            }
            elsif( defined  $AutoCompleteWebService && $AutoCompleteWebService ne '' ) {
                my $Webservice = $WebserviceObject->WebserviceGet(
                    Name => $AutoCompleteWebService,
                );

                my $ResultThread = $RequesterObject->Run(
                    WebserviceID  => $Webservice->{ID},
                    Invoker       => $column->{auto_complete_invoker},
                    Data          => {
                        SearchTerm  => $Param{SearchTerm},
                    },
                );

                # To change _ to espaces of DFTable fields with espace
                for my $Item ( @{ $ResultThread->{Data}{Item} } ) {
                    my $ValueRef = $Item->{value};
                    next unless ref($ValueRef) eq 'HASH';

                    my %NewValue;

                    for my $Key ( keys %$ValueRef ) {
                        (my $NewKey = $Key) =~ s/_/ /g;
                        $NewValue{$NewKey} = $ValueRef->{$Key};
                    }

                    $Item->{value} = \%NewValue;
                }

                @Response = @{ $ResultThread->{Data}{Item} };

            }
        }

        # send JSON response
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => encode_json(\@Response),
            Type        => 'inline',
            NoCache     => 1,
        );
    }
}

sub _GenerateExcel {
    my ( $Self, %Param ) = @_;

    # check required params
    for (qw(Data)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Got no $_ param!"
            );
            return;
        }
    }
    my @Head;
    my @Operation;
    my @Data = ( ['##No Data##'] );
    if ( $Param{Head} ) {
        @Head = @{ $Param{Head} };
    }
    if ( $Param{Data} ) {
        @Data = @{ $Param{Data} };
    }
    my @WithHeader;
    if ( $Param{WithHeader} ) {
        @WithHeader = @{ $Param{WithHeader} };
    }
	if ( $Param{Operation} ){
		@Operation = @{ $Param{Operation} };
	}

    # get format
    $Param{Format} //= 'CSV';

    my $Output = '';

    if ( $Param{Format} eq 'Excel' ) {

        open my $FileHandle, '>', \$Output;    ## no critic
        if ( !$FileHandle ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Failed to open FileHandle: $!",
            );
            return;
        }
        my $Workbook     = Excel::Writer::XLSX->new($FileHandle);
        my $Worksheet    = $Workbook->add_worksheet();
        my $HeaderFormat = $Workbook->add_format(
            bold       => 1,
            num_format => '@',
            bg_color   => 'gray',
            color      => 'white',
            size       => 12,
            top        => 1
        );
        my $FooterFormat = $Workbook->add_format(
            bold       => 1,
            num_format => '@',
            bg_color   => 'gray',
            color      => 'white',
            bottom     => 1
        );
        my $BodyFormat = $Workbook->add_format(
            bold       => 1,
            num_format => '@',
            bg_color   => 'white'
        );
        my $BodyFormatLeft = $Workbook->add_format(
            bold       => 1,
            num_format => '@',
            bg_color   => 'white',
            left       => 1
        );
        my $BodyFormatRight = $Workbook->add_format(
            bold       => 1,
            num_format => '@',
            bg_color   => 'white',
            right      => 1
        );

        # We will try to determine the appropriate length for each column.
        my @ColumnLengths;
        my $Row = 0;

        my @Rows = ( \@Head, @Data, @Operation );

        if ( scalar @WithHeader ) {

            # Adds \@WithHeader to the beggining of @Rows, if not empty.
            #    Otherwise it adds empty first row - see bug#12467.
            unshift @Rows, \@WithHeader;
        }
		
        for my $DataRaw (@Rows) {
            COL:
            for my $Col ( 0 .. ( scalar @{ $DataRaw // [] } ) - 1 ) {
                next COL if !defined( $DataRaw->[$Col] );
                my $CellLength = length( $DataRaw->[$Col] );
                $CellLength = 30 if ( $CellLength > 30 );
                if ( !defined $ColumnLengths[$Col] || $ColumnLengths[$Col] < $CellLength ) {
                    $ColumnLengths[$Col] = $CellLength;
                }                  

                if ( $Row == 0 && @Head ) {

                    # Format header nicely if present.
                    $Worksheet->write( $Row, $Col, "$DataRaw->[$Col]", $HeaderFormat );
                }
                elsif ( ( $Row == ( scalar @Rows ) - 1 )  ) {

                    # Format footer nicely.
                    $Worksheet->write( $Row, $Col, "$DataRaw->[$Col]", $FooterFormat );
                }				
                else {
                    
                    # There are major problems with data recognition in Excel. OTRS
                    #   ticket numbers will be recognized as numbers, but they are so big that
                    #   Excel will (incorrectly) round them. Prevent this by using write_string()
                    #   to protect the data. This might trigger formatting notifications in Excel,
                    #   but these can be turned off.
                    if ( $Col == 0 ) {
                        $Worksheet->write_string( $Row, $Col, "$DataRaw->[$Col]", $BodyFormatLeft );
                    }
                    elsif ( $Col == ( scalar @{ $DataRaw // [] } - 1 ) ) {
                        $Worksheet->write_string( $Row, $Col, "$DataRaw->[$Col]", $BodyFormatRight );
                    }
                    else {
                        $Worksheet->write_string( $Row, $Col, "$DataRaw->[$Col]", $BodyFormat );
                    }
                }
            }
            $Row++;
        }

        # Now apply column lengths.
        my $Col = 0;
        for my $ColumnLength (@ColumnLengths) {
            $Worksheet->set_column( $Col, $Col, $ColumnLength );
            $Col++;
        }

        $Workbook->close();
    }
    else {
        # get separator
        if ( !defined $Param{Separator} || $Param{Separator} eq '' ) {
            $Param{Separator} = ';';
        }

        # get separator
        if ( !defined $Param{Quote} ) {
            $Param{Quote} = '"';
        }

        # create new csv backend object
        my $CSV = Text::CSV->new(
            {
                quote_char          => $Param{Quote},
                escape_char         => $Param{Quote},
                sep_char            => $Param{Separator},
                eol                 => '',
                always_quote        => 1,
                binary              => 1,
                keep_meta_info      => 0,
                allow_loose_quotes  => 0,
                allow_loose_escapes => 0,
                allow_whitespace    => 0,
                verbatim            => 0,
            }
        );

        # set header if given
        if (@WithHeader) {
            my $Status = $CSV->combine(@WithHeader);
            $Output .= $CSV->string() . "\n";
        }

        # if we have head param fill in header
        if (@Head) {
            my $Status = $CSV->combine(@Head);
            $Output .= $CSV->string() . "\n";
        }

        # fill in data
        for my $Row (@Data) {
            my $Status = $CSV->combine( @{$Row} );
            if ($Status) {
                $Output .= $CSV->string() . "\n";
            }
            else {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => 'Failed to build line: ' . $CSV->error_input(),
                );
            }
        }
    }

    return $Output;
}

sub _GeneratePDF {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(Title HeadArrayRef DataArray)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => "error",
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    my $Title        = $Param{Title};
    my @HeadArrayRef = @{ $Param{HeadArrayRef} // [] };
    my @DataArray    = @{ $Param{DataArray} // [] };
    my @OperationArray    = @{ $Param{OperationArray} // [] };
	
    my $PDFObject    = $Kernel::OM->Get('Kernel::System::PDF');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $Page = $LayoutObject->{LanguageObject}->Translate('Page');
    my $Time = $LayoutObject->{Time};

    # get maximum number of pages
    my $MaxPages = $ConfigObject->Get('PDF::MaxPages');
    if ( !$MaxPages || $MaxPages < 1 || $MaxPages > 1000 ) {
        $MaxPages = 100;
    }

    # create the header
    my $CellData;
    my $CounterRow  = 0;
    my $CounterHead = 0;
    for my $Content (@HeadArrayRef) {
        $CellData->[$CounterRow]->[$CounterHead]->{Content} = $Content;
        $CellData->[$CounterRow]->[$CounterHead]->{Font}    = 'ProportionalBold';
        $CounterHead++;
    }
    if ( $CounterHead > 0 ) {
        $CounterRow++;
    }

    # create the content array
    for my $Row (@DataArray) {
        my $CounterColumn = 0;
        for my $Content ( @{$Row} ) {
            $CellData->[$CounterRow]->[$CounterColumn]->{Content} = $Content;
            $CounterColumn++;
        }
        $CounterRow++;
    }
	
	# create the operation array
    for my $Row (@OperationArray) {
        my $CounterColumn = 0;
        for my $Content ( @{$Row} ) {
            $CellData->[$CounterRow]->[$CounterColumn]->{Content} = $Content;
            $CellData->[$CounterRow]->[$CounterColumn]->{Font}    = 'ProportionalBold';
            $CounterColumn++;
        }
        $CounterRow++;
    }

    # output 'No matches found', if no content was given
    if ( !$CellData->[0]->[0] ) {
        $CellData->[0]->[0]->{Content} = $LayoutObject->{LanguageObject}->Translate('No matches found.');
    }

    my $TranslateTimeZone = $LayoutObject->{LanguageObject}->Translate('Time Zone');

    # if a time zone was selected
    if ( $Param{TimeZone} ) {
        $Title .= " ($TranslateTimeZone $Param{TimeZone})";
    }

    # page params
    my %PageParam;
    $PageParam{PageOrientation} = 'landscape';
    $PageParam{MarginTop}       = 30;
    $PageParam{MarginRight}     = 40;
    $PageParam{MarginBottom}    = 40;
    $PageParam{MarginLeft}      = 40;

    $PageParam{HeadlineLeft} = $Title;

    # table params
    my %TableParam;
    $TableParam{CellData}            = $CellData;
    $TableParam{Type}                = 'Cut';
    $TableParam{FontSize}            = 6;
    $TableParam{Border}              = 0;
    $TableParam{BackgroundColorEven} = '#DDDDDD';
    $TableParam{Padding}             = 4;

    # create new pdf document
    $PDFObject->DocumentNew(
        Title  => $ConfigObject->Get('Product') . ': ' . $Title,
        Encode => $Self->{UserCharset},
    );

    # start table output
    $PDFObject->PageNew(
        %PageParam,
        LogoFile    => '',
        FooterRight => $Page . ' 1',
    );

    $PDFObject->PositionSet(
        Move => 'relativ',
        Y    => -6,
    );

    # output title
    $PDFObject->Text(
        Text     => $Title,
        FontSize => 13,
    );

    $PDFObject->PositionSet(
        Move => 'relativ',
        Y    => -6,
    );

    # output "printed by"
    $PDFObject->Text(
        Text     => $Time,
        FontSize => 9,
    );

    $PDFObject->PositionSet(
        Move => 'relativ',
        Y    => -14,
    );

    COUNT:
    for ( 2 .. $MaxPages ) {

        # output table (or a fragment of it)
        %TableParam = $PDFObject->Table( %TableParam, );

        # stop output or output next page
        last COUNT if $TableParam{State};

        $PDFObject->PageNew(
            %PageParam,
            FooterRight => $Page . ' ' . $_,
        );
    }

    return $PDFObject->DocumentOutput();
}

1;