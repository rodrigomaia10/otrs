# --
# Custom/Kernel/Modules/DynamicFieldTableAJAXHandler.pm - a module used to handle ajax requests
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * mbernardo@serviceup.com.br
# * dsilva@serviceup.com.br
# --

package Kernel::Modules::DynamicFieldTableAJAXHandler;

use strict;
use warnings;
use URI::Escape;

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
    my $LayoutObject 		    = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  		    = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $JSONObject   		    = $Kernel::OM->Get('Kernel::System::JSON');
    my $DynamicFieldObject      = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldTableObject = $Kernel::OM->Get('Kernel::System::DynamicFieldTable');
	
	if($Self->{Subaction} eq 'ViewMore'){

		my $TicketID  = $ParamObject->GetParam( Param => 'TicketID');
        my $FieldName = $ParamObject->GetParam( Param => 'FieldName');
        
        my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
            Name => $FieldName,
        );

        my $JSONData = $DynamicFieldTableObject->ValueGetTag(
            ObjectID => $TicketID,
            FieldID => $DynamicField->{ID},
        );

        my $JSONDecode = $JSONObject->Decode(
            Data => $JSONData,
        );
        
        # create column names
        for my $ColumnName (@{$DynamicField->{Config}->{PossibleColumns}}){

            $LayoutObject->Block(
                Name =>'ColumnData',
                Data => { 
                    Name => $ColumnName->{name}
                },
            );
        }

        # create row values
        for my $Columns (@{$JSONDecode}){

            $LayoutObject->Block(
                Name =>'Row',
            );

            for my $ColumnName (@{$DynamicField->{Config}->{PossibleColumns}}){
                
                # date format
                if($ColumnName->{type} eq 'date'){
                    my $DateTimeObject = $Kernel::OM->Create(
                        'Kernel::System::DateTime',
                        ObjectParams => {
                            String   => $Columns->{$ColumnName->{name}} .= " 00:00:00",
                        }
                    );

                    my $DateTimeSettings = $DateTimeObject->Get();

                    if($DateTimeSettings->{Day} < 10){ $DateTimeSettings->{Day} = "0".$DateTimeSettings->{Day};}
                    if($DateTimeSettings->{Month} < 10){ $DateTimeSettings->{Month} = "0".$DateTimeSettings->{Month};}
                    
                    $Columns->{$ColumnName->{name}} = "$DateTimeSettings->{Day}-$DateTimeSettings->{Month}-$DateTimeSettings->{Year}";               
                }

                $LayoutObject->Block(
                    Name =>'RowData',
                    Data => { 
                        Value => $Columns->{$ColumnName->{name}}
                    },
                );
            }
        }

		# build page
		my $Output = $LayoutObject->Header(
			Type  => 'Small',
		);

		$Output .= $LayoutObject->Output(
			TemplateFile => 'DynamicFieldTableViewMore',
			Data => {
                TicketID => $TicketID
			},
		);

		$Output .= $LayoutObject->Footer(
			Type => 'Small',
		);

		return $Output;
	}

	return 1;
}
1;
