# --
# Kernel/Autoload/CustomReplaceFieldTable.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * poliveira@serviceup.com.br
# --

use Kernel::System::ProcessManagement::TransitionAction::Base;

package Kernel::System::ProcessManagement::TransitionAction::Base;

use strict;
use warnings;

use utf8;

sub _ReplaceTicketAttributes {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $JSONObject                = $Kernel::OM->Get('Kernel::System::JSON');
    my $DynamicFieldTableObject   = $Kernel::OM->Get('Kernel::System::DynamicFieldTable');
    my $LayoutObject              = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    for my $Attribute ( sort keys %{ $Param{Config} } ) {

        # Replace ticket attributes such as
        # <OTRS_Ticket_DynamicField_Name1> or <OTRS_TICKET_DynamicField_Name1>
        # or
        # <OTRS_TICKET_DynamicField_Name1_Value> or <OTRS_Ticket_DynamicField_Name1_Value>.
        # <OTRS_Ticket_*> is deprecated and should be removed in further versions of OTRS.
        my $Count = 0;
        REPLACEMENT:
        while (
            $Param{Config}->{$Attribute}
            && $Param{Config}->{$Attribute} =~ m{<OTRS_TICKET_([A-Za-z0-9_]+)>}msxi
            && $Count++ < 1000
            )
        {
            my $TicketAttribute = $1;

            if ( $TicketAttribute =~ m{DynamicField_(\S+?)_Value} ) {
                   
                my $DynamicFieldName = $1;

                my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
                    Name => $DynamicFieldName,
                );
                next REPLACEMENT if !$DynamicFieldConfig;

                # Get the display value for each dynamic field.
                my $DisplayValue = $DynamicFieldBackendObject->ValueLookup(
                    DynamicFieldConfig => $DynamicFieldConfig,
                    Key                => $Param{Ticket}->{"DynamicField_$DynamicFieldName"},
                );

                my $DisplayValueStrg = $DynamicFieldBackendObject->ReadableValueRender(
                    DynamicFieldConfig => $DynamicFieldConfig,
                    Value              => $DisplayValue,
                );

                # START BLOCK SUP                
                
                if ($DynamicFieldConfig->{FieldType} eq 'Table'){
                    
                    my $JSONData = $DynamicFieldTableObject->ValueGetTag(
                        ObjectID => $Param{Ticket}->{TicketID},
                        FieldID => $DynamicFieldConfig->{ID} 
                    );	
                    
                    my $PerlStructureScalar = $JSONObject->Decode(
                        Data => $JSONData,
                    );

                    my %SortColumn;
                    my $Count = 1;
                    for (@{$DynamicFieldConfig->{Config}->{PossibleColumns}}){
                        $SortColumn{$Count} = $_->{display};
                        $Count++;
                    }        

                    my $Flag = 0;
                    my (@TableSort, @Header);
                    for (@{$PerlStructureScalar}){
                        my %RowSort;
                        for my $Key (sort keys %SortColumn){
                            
                            $RowSort{$Key} = $_->{$SortColumn{$Key}};

                            if(!$Flag){
                                push @Header, $SortColumn{$Key};
                            }
                        }

                        my $SizeColumn = scalar keys %{$_};
                        my $SizeSortColumn = scalar keys %SortColumn;

                        if($SizeColumn > $SizeSortColumn){
                            $RowSort{$SizeColumn} = $_->{'RowTotal'};
                            if(!$Flag){
                                push @Header, 'RowTotal';
                            }
                        }               

                        $Flag = 1;
                        push @TableSort, sort \%RowSort;
                    }

                    for my $Header (@Header){
                        $LayoutObject->Block(
                            Name => 'HeaderRow',
                            Data => {
                                Column => $Header,
                            },
                        );
                    }

                    for my $Row (@TableSort){

                        my @Values;

                        for (sort keys %{$Row}){
                            push @Values, $Row->{$_};
                        }
                                    
                        $LayoutObject->Block(
                            Name => 'Row',
                            Data => {},
                        );
                        
                        foreach my $Values (@Values){
                            $LayoutObject->Block(
                                Name => 'ValuesRow',
                                Data => {
                                    Values => $Values,
                                },
                            );
                        }				
                    }
                                
                    # generate HTML
                    $DisplayValueStrg->{Value} = $LayoutObject->Output(
                        TemplateFile => "DynamicFieldTable/AgentDynamicFieldTable"				
                    );			
                }
                else{
                    # get the readable value (key) for each dynamic field
                    $DisplayValueStrg = $DynamicFieldBackendObject->ReadableValueRender(
                        DynamicFieldConfig => $DynamicFieldConfig,
                        Value              => $Param{Ticket}->{ 'DynamicField_' . $DynamicFieldConfig->{Name} },
                    );
                }

                # END BLOCK SUP

                $Param{Config}->{$Attribute}
                    =~ s{<OTRS_TICKET_$TicketAttribute>}{$DisplayValueStrg->{Value} // ''}ige;

                next REPLACEMENT;
            }
            elsif ( $TicketAttribute =~ m{DynamicField_(\S+)} ) {
                my $DynamicFieldName = $1;

                my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
                    Name => $DynamicFieldName,
                );
                next REPLACEMENT if !$DynamicFieldConfig;

                # Get the readable value (key) for each dynamic field.
                my $ValueStrg = $DynamicFieldBackendObject->ReadableValueRender(
                    DynamicFieldConfig => $DynamicFieldConfig,
                    Value              => $Param{Ticket}->{"DynamicField_$DynamicFieldName"},
                );

                $Param{Config}->{$Attribute}
                    =~ s{<OTRS_TICKET_$TicketAttribute>}{$ValueStrg->{Value} // ''}ige;

                next REPLACEMENT;
            }

            # if ticket value is scalar substitute all instances (as strings)
            # this will allow replacements for "<OTRS_TICKET_Title> <OTRS_TICKET_Queue"
            if ( !ref $Param{Ticket}->{$TicketAttribute} ) {
                $Param{Config}->{$Attribute}
                    =~ s{<OTRS_TICKET_$TicketAttribute>}{$Param{Ticket}->{$TicketAttribute} // ''}ige;
            }
            else {

                # if the vale is an array (e.g. a multiselect dynamic field) set the value directly
                # this unfortunately will not let a combination of values to be replaced
                $Param{Config}->{$Attribute} = $Param{Ticket}->{$TicketAttribute};
            }
        }
    }

    return 1;
}


1;