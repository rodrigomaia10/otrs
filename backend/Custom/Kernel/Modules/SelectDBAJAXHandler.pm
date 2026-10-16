# --
# Kernel/Modules/SelectDBAJAXHandler.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * jsantos@serviceup.com.br
# * ccresencio@serviceup.com.br
# --

package Kernel::Modules::SelectDBAJAXHandler;

use strict;
use warnings;

use URI::Escape;

use Kernel::System::DFSelectDB;

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::CustomerUser',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Driver::SelectDB',
    'Kernel::System::Encode',
    'Kernel::System::Log',
    'Kernel::System::Ticket',
    'Kernel::System::Web::Request',
	'Kernel::System::Valid',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # create needed objects
    $Self->{DynamicFieldObject} = $Kernel::OM->Get('Kernel::System::DynamicField');
    $Self->{CustomerUserObject} = $Kernel::OM->Get('Kernel::System::CustomerUser');
    $Self->{SelectDBObject}     = $Kernel::OM->Get('Kernel::System::DynamicField::Driver::SelectDB');
    $Self->{LayoutObject}       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    $Self->{EncodeObject}       = $Kernel::OM->Get('Kernel::System::Encode');
    $Self->{TicketObject}       = $Kernel::OM->Get('Kernel::System::Ticket');
    $Self->{ParamObject}        = $Kernel::OM->Get('Kernel::System::Web::Request');
    $Self->{LogObject}          = $Kernel::OM->Get('Kernel::System::Log');

	my $JSON = '';

    # get mandatory param
    my $DynamicFieldID = $Self->{ParamObject}->GetParam( Param => 'DynamicFieldID' );

    if ($DynamicFieldID) {

        my $DynamicFieldConfig = $Self->{DynamicFieldObject}->DynamicFieldGet(
            ID => $DynamicFieldID,
        );

        if ( $DynamicFieldConfig->{FieldType} ne 'SelectDB' ) {

            $Self->{LogObject}->Log(
                Priority => 'error',
                Message => "SelectDBAJAXHandler: DynamicField doesn't refer to type SelectDB.",
            );

            return;
        }

        # get needed params
        my $Subaction   = $Self->{ParamObject}->GetParam( Param => 'Subaction' )   || '';
        my $FieldPrefix = $Self->{ParamObject}->GetParam( Param => 'FieldPrefix' ) || '';

        # get used entries
        my @Entries = $Self->{ParamObject}->GetArray( Param => $FieldPrefix . 'DynamicField_' . $DynamicFieldConfig->{Name} );      

        # get attributes from web request
        my @ParamNames = $Self->{ParamObject}->GetParamNames();
        my %WebParams  = map { $_ => 1 } @ParamNames;

        my $DFSelectDBObject = Kernel::System::DFSelectDB->new(
            DatabaseDSN  => $DynamicFieldConfig->{Config}->{DatabaseDSN},
            DatabaseUser => $DynamicFieldConfig->{Config}->{DatabaseUser},
            DatabasePw   => $DynamicFieldConfig->{Config}->{DatabasePw},
            Type         => $DynamicFieldConfig->{Config}->{DatabaseType},
            %{ $Self },
        );

        #handle subaction Search
        if ($Subaction eq 'Search') {

            my $Search    = $Self->{ParamObject}->GetParam( Param => 'Search' ) || '';
            my $SearchEnd = $Self->{ParamObject}->GetParam( Param => 'SearchEnd' ) || '';

            # encode the input
            $Self->{EncodeObject}->EncodeInput( \$Search );

            my @PossibleValues;
			my %ExternalData;

            if ( defined $Search && $Search ne '' ) {

                my $ConfigOnly = $Self->{ParamObject}->GetParam( Param => 'ConfigOnly' ) || '';

                my $TicketID       = '';
                my $CustomerUserID = '';

                if (!$ConfigOnly) {

                    $TicketID       = $Self->{ParamObject}->GetParam( Param => 'TicketID' )   || '';
                    $CustomerUserID = $Self->{ParamObject}->GetParam( Param => 'CustomerUserID' )
                                    || uri_unescape($Self->{ParamObject}->GetParam( Param => 'SelectedCustomerUser' ))
                                    || '';
                }

                my %TicketData;

                if ($TicketID =~ /^\d+$/) {

                    %TicketData = $Self->{TicketObject}->TicketGet(
                        TicketID      => $TicketID,
                        DynamicFields => 1,
                        Extended      => 1,
                        UserID        => 1,
                        Silent        => 1,
                    );

                    $CustomerUserID = $TicketData{CustomerUserID} if ( $TicketData{CustomerUserID} );
                }

                my %CustomerUserData;

                if ( $CustomerUserID ) {
                    %CustomerUserData = $Self->{CustomerUserObject}->CustomerUserDataGet(
                        User => $CustomerUserID,
                    );
                }

                $Search =~ s/\*/%/gi;
                my $QuotedValue = $DFSelectDBObject->Quote($Search);

                my @SearchFields = split( ';', $DynamicFieldConfig->{Config}->{DatabaseFieldSearch} );

                my $QueryCondition = $DFSelectDBObject->QueryCondition(
                    Key           => \@SearchFields,
                    Value         => $QuotedValue,
                    SearchPrefix  => '*',
                    SearchSuffix  => '*',
                    CaseSensitive => $DynamicFieldConfig->{Config}->{CaseSensitive},
                );

                # get used Constrictions
                my $Constrictions = $DynamicFieldConfig->{Config}->{Constrictions};

                # prepare constrictions
                my $ConstrictionsCheck = 1;

                if ( $Constrictions ) {

                    my @Constrictions = split(/[\n\r]+/, $Constrictions);

                    CONSTRICTION:
                    for my $Constriction ( @Constrictions ) {

                        my @ConstrictionRule = split(/::/, $Constriction);
                        my $ConstrictionCheck = 1;
                        my $ConstrictionValue;

                        # check for valid constriction
                        next CONSTRICTION if (
                            scalar(@ConstrictionRule) != 4
                            || $ConstrictionRule[0] eq ""
                            || $ConstrictionRule[1] eq ""
                            || $ConstrictionRule[2] eq ""
                        );

                        # mandatory constriction
                        if (
                            !$ConfigOnly
                            && $ConstrictionRule[3]
                        ) {
                            $ConstrictionCheck = 0;
                        }

                        # only handle static constrictions in admininterface
                        if (
                            $ConstrictionRule[1] eq 'Configuration'
                        ) {
                            $ConstrictionValue = $ConstrictionRule[2];
                            $ConstrictionCheck = 1;
                        } elsif (
                            $ConstrictionRule[1] eq 'Ticket'
                            && (
                                $WebParams{ $ConstrictionRule[2] }
                                || defined( $TicketData{ $ConstrictionRule[2] } )
                            )
                        ) {
                            # get value from ticket data
                            $ConstrictionValue = $TicketData{ $ConstrictionRule[2] };
                            # use only first entry if array is given
                            if ( ref($ConstrictionValue) eq 'ARRAY' ) {
                                $ConstrictionValue = $ConstrictionValue->[0];
                            }
                            # check if attribute is in web params
                            if ( $WebParams{ $ConstrictionRule[2] } ) {
                                $ConstrictionValue = $Self->{ParamObject}->GetParam( Param => $ConstrictionRule[2] ) || '';
                            }
                            # mark check success if value is not empty
                            if ( $ConstrictionValue ) {
                                $ConstrictionCheck = 1;
                            }
                            # set constriction value undef if empty
                            else {
                                $ConstrictionValue = undef;
                            }
                        } elsif (
                            $ConstrictionRule[1] eq 'CustomerUser'
                            && $CustomerUserData{ $ConstrictionRule[2] }
                        ) {
                            $ConstrictionValue = $CustomerUserData{ $ConstrictionRule[2] };
                            $ConstrictionCheck = 1;
                        }

                        # stop if mandatory constriction not valid
                        if ( !$ConstrictionCheck ) {
                            $ConstrictionsCheck = 0;
                            last CONSTRICTION;
                        }

                        # quote constriction value
                        my $QuotedConstrictionValue = $DFSelectDBObject->Quote($ConstrictionValue);

                        # skip if quoted constriction is empty/zero
                        if ( !$QuotedConstrictionValue ) {
                            next CONSTRICTION;
                        }

                        my $QueryConstrictionCondition = $DFSelectDBObject->QueryCondition(
                            Key           => $ConstrictionRule[0],
                            Value         => $QuotedConstrictionValue,
                            SearchPrefix  => $DynamicFieldConfig->{Config}->{SearchPrefix},
                            SearchSuffix  => $DynamicFieldConfig->{Config}->{SearchSuffix},
                            CaseSensitive => $DynamicFieldConfig->{Config}->{CaseSensitive},
                        );

                        if ( $QueryConstrictionCondition ) {

                            if ( $QueryCondition ) {
                                $QueryCondition .= ' AND '
                            }
                            
                            $QueryCondition .= $QueryConstrictionCondition;
                        }
                    }
                }

                my $AndQueryCondition = '';

                if ($SearchEnd ne '') {

                    $AndQueryCondition = $DFSelectDBObject->QueryCondition(
                        Key   => $DynamicFieldConfig->{Config}->{ColumnAnd},
                        Value => $SearchEnd,
                    );
                }

                if ($ConstrictionsCheck) {                

                    my $SQL = 'SELECT ' . $DynamicFieldConfig->{Config}->{DatabaseFieldKey} . " AS $DynamicFieldConfig->{Config}->{DatabaseFieldKey}_1";

                    my @Values = ();

                    for my $Value ( @{$DynamicFieldConfig->{Config}->{DatabaseFieldValue}} ){

                        my ($Key) = %{$Value};

                        push @Values, $Key;
                    }

                    my $DatabaseFieldValue = join( ',', @Values );

                    if ( $DatabaseFieldValue ) {
                        $SQL .= ', ' . $DatabaseFieldValue;
                    }

					$SQL .= ' FROM ' . $DynamicFieldConfig->{Config}->{DatabaseTable} . ' WHERE ' . $QueryCondition;

                    # create cache object
                    if ( $DynamicFieldConfig->{Config}->{CacheTTL} ) {
                        $Self->{CacheObject} = Kernel::System::Cache->new( %{$Self} );

                        # set cache type
                        $Self->{CacheType} = 'DynamicField_SelectDB_' . $DynamicFieldConfig->{Name};

                        my $PossibleValues = $Kernel::OM->Get('Kernel::System::Cache')->Get(
                            Type => $Self->{CacheType},
                            Key  => "Search::" . $SQL . "::" . join('::', @Entries),
                        );
                        @PossibleValues = @{$PossibleValues} if $PossibleValues;
                    }

                    if ($AndQueryCondition ne '') {

                        $SQL .= " AND $AndQueryCondition";
                    }

                    my $Count = 0;
                    my @DFValues;

                    REPLACEMENT:
                    while ( $DynamicFieldConfig->{Config}->{DatabaseTableFreeField} && $DynamicFieldConfig->{Config}->{DatabaseTableFreeField} =~ m{<DynamicField_([A-Za-z0-9_]+)>}msxi && $Count++ < 50 ) {

                        my $Attribute = $1;

                        my $DFValue = $Self->{ParamObject}->GetParam( Param => "DynamicField_$Attribute" ) || '';

                        $DynamicFieldConfig->{Config}->{DatabaseTableFreeField} =~ s{<DynamicField_$Attribute>}{'?' // ''}ige;

                        push @DFValues, \$DFValue;

                        next REPLACEMENT;
                    }

                    if ( $DynamicFieldConfig->{Config}->{DatabaseTableFreeField} ) {

                        $SQL .= " " . $DynamicFieldConfig->{Config}->{DatabaseTableFreeField};
                    }

                    my $OrderByFieldSearch = join ( ',' , @SearchFields );
 		            $SQL .= ' ORDER BY ' . $OrderByFieldSearch;

                    if ( !scalar(@PossibleValues) ) {

                        my $Success = $DFSelectDBObject->Prepare(
                            SQL  => $SQL,
                            Bind => \@DFValues,
                        );
                        
                        if ( !$Success ) {

                            # build JSON output
                            my $JSON = $LayoutObject->JSONEncode(
                                Data => {
                                    Error => "Message: Can't connect to Database"
                                },
                            );

                            # send JSON response
                            return $LayoutObject->Attachment(
                                ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
                                Content     => $JSON,
                                Type        => 'inline',
                                NoCache     => 1,
                            );
                        }

                        my $MaxCount = 1;

                        RESULT:
                        while (my @Row = $DFSelectDBObject->FetchrowArray()) {

                            my $Key = $Row[0];

                            next RESULT if ( grep { my $Temp eq $Key } @Entries );

							my $Value      = $Row[1];
							my $IndexValue = $Row[2];

                            my $Title = $Value;

							my @AllData = ( $DynamicFieldConfig->{Config}->{DatabaseFieldKey} );

                            my @Values = ();

                            for my $Value ( @{$DynamicFieldConfig->{Config}->{DatabaseFieldValue}} ){

                                my ($Key) = %{$Value};

                                push @AllData, $Key;
                            }

							my %Aux;

							foreach my $Index ( 0 .. $#Row ){
								$Aux{ $AllData[$Index] } = $Row[$Index];
							}

							$ExternalData{ $Key } = \%Aux;

                            push @PossibleValues, {
                                Key    => $Key,
                                Value  => "$Value",
                                Title  => $Title,
                            };

                            last RESULT if ($MaxCount == ($DynamicFieldConfig->{Config}->{MaxQueryResult} || 10));

                            $MaxCount++;
                        }

                        # cache request
                        if ( $DynamicFieldConfig->{Config}->{CacheTTL} ) {

                            $Kernel::OM->Get('Kernel::System::Cache')->Set(
                                Type  => $Self->{CacheType},
                                Key   => "Search::" . $SQL . "::" . join('::', @Entries),
                                Value => \@PossibleValues,
                                TTL   => $DynamicFieldConfig->{Config}->{CacheTTL},
                            );
                        }
                    }
                }
            }

            my %DynamicFieldsExternal;

            for my $Value (@{$DynamicFieldConfig->{Config}->{DatabaseFieldValue}}){

                my ($Key) = %{$Value};
                $DynamicFieldsExternal{$Key} = $Value->{$Key};
            }

            # build JSON output
            $JSON = $Self->{LayoutObject}->JSONEncode(
                Data => {
					Values => \@PossibleValues,
					ExternalData => {
						Values => \%ExternalData,
						DynamicFields => \%DynamicFieldsExternal
					}
				}
            );
        }

        # handle subaction PossibleValueCheck
        elsif($Subaction eq 'PossibleValueCheck') {

            my @PossibleValues;

            my $TicketID       = $Self->{ParamObject}->GetParam( Param => 'TicketID' ) || '';
            my $CustomerUserID = $Self->{ParamObject}->GetParam( Param => 'CustomerUserID' )
                                || uri_unescape($Self->{ParamObject}->GetParam( Param => 'SelectedCustomerUser' ))
                                || '';

            my %TicketData;

            if ($TicketID =~ /^\d+$/) {

                %TicketData = $Self->{TicketObject}->TicketGet(
                    TicketID      => $TicketID,
                    DynamicFields => 1,
                    Extended      => 1,
                    UserID        => 1,
                    Silent        => 1,
                );

                $CustomerUserID = $TicketData{CustomerUserID} if ( $TicketData{CustomerUserID} );
            }

            my %CustomerUserData;

            if ( $CustomerUserID ) {
                %CustomerUserData = $Self->{CustomerUserObject}->CustomerUserDataGet(
                    User => $CustomerUserID,
                );
            }

            my @SearchFields = split( ';', $DynamicFieldConfig->{Config}->{DatabaseFieldSearch} );

            my $QueryCondition = $DFSelectDBObject->QueryCondition(
                Key           => \@SearchFields,
                Value         => '*',
                SearchPrefix  => '*',
                SearchSuffix  => '*',
                CaseSensitive => $DynamicFieldConfig->{Config}->{CaseSensitive},
            );

            # get used Constrictions
            my $Constrictions = $DynamicFieldConfig->{Config}->{Constrictions};

            # prepare constrictions
            my $ConstrictionsCheck = 1;

            if ( $Constrictions ) {

                my @Constrictions = split(/[\n\r]+/, $Constrictions);

                CONSTRICTION:
                for my $Constriction ( @Constrictions ) {

                    my @ConstrictionRule = split(/::/, $Constriction);
                    my $ConstrictionCheck = 1;
                    my $ConstrictionValue;

                    # check for valid constriction
                    next CONSTRICTION if (
                        scalar(@ConstrictionRule) != 4
                        || $ConstrictionRule[0] eq ""
                        || $ConstrictionRule[1] eq ""
                        || $ConstrictionRule[2] eq ""
                    );

                    # mandatory constriction
                    if ($ConstrictionRule[3]) {
                        $ConstrictionCheck = 0;
                    }

                    # only handle static constrictions in admininterface
                    if (
                        $ConstrictionRule[1] eq 'Configuration'
                    ) {
                        $ConstrictionValue = $ConstrictionRule[2];
                        $ConstrictionCheck = 1;
                    } elsif (
                        $ConstrictionRule[1] eq 'Ticket'
                        && (
                            $Self->{ParamObject}->GetParam( Param => $ConstrictionRule[2] )
                            || $TicketData{ $ConstrictionRule[2] }
                        )
                    ) {
                        $ConstrictionValue = $Self->{ParamObject}->GetParam( Param => $ConstrictionRule[2] )
                                          || $TicketData{ $ConstrictionRule[2] };
                        $ConstrictionCheck = 1;
                    } elsif (
                        $ConstrictionRule[1] eq 'CustomerUser'
                        && $CustomerUserData{ $ConstrictionRule[2] }
                    ) {
                        $ConstrictionValue = $CustomerUserData{ $ConstrictionRule[2] };
                        $ConstrictionCheck = 1;
                    }

                    # stop if mandatory constriction not valid
                    if ( !$ConstrictionCheck ) {
                        $ConstrictionsCheck = 0;
                        last CONSTRICTION;
                    }

                    # quote constriction value
                    my $QuotedConstrictionValue = $DFSelectDBObject->Quote($ConstrictionValue);

                    # skip if quoted constriction is empty/zero
                    if ( !$QuotedConstrictionValue ) {
                        next CONSTRICTION;
                    }

                    my $QueryConstrictionCondition = $DFSelectDBObject->QueryCondition(
                        Key           => $ConstrictionRule[0],
                        Value         => $QuotedConstrictionValue,
                        SearchPrefix  => '*',
                        SearchSuffix  => '*',
                        CaseSensitive => $DynamicFieldConfig->{Config}->{CaseSensitive},
                    );

                    if ( $QueryConstrictionCondition ) {

                        if ( $QueryCondition ) {
                            $QueryCondition .= ' AND '
                        }

                        $QueryCondition .= $QueryConstrictionCondition;
                    }
                }
            }

            if ($ConstrictionsCheck) {

                my $SQL = 'SELECT '
                    . $DynamicFieldConfig->{Config}->{DatabaseFieldKey}
                    . ' FROM '
                    . $DynamicFieldConfig->{Config}->{DatabaseTable}
                    . ' WHERE '
                    . $QueryCondition;

                # create cache object
                if ( $DynamicFieldConfig->{Config}->{CacheTTL} ) {

                    $Self->{CacheObject} = Kernel::System::Cache->new( %{$Self} );

                    # set cache type
                    $Self->{CacheType} = 'DynamicField_SelectDB_' . $DynamicFieldConfig->{Name};

                    my $PossibleValues = $Kernel::OM->Get('Kernel::System::Cache')->Get(
                        Type => $Self->{CacheType},
                        Key  => "PossibleValueCheck::" . $SQL . "::" . join('::', @Entries),
                    );

                    @PossibleValues = @{$PossibleValues} if $PossibleValues;
                }

                if (!scalar(@PossibleValues)) {

                    my $Success = $DFSelectDBObject->Prepare(
                        SQL   => $SQL,
                    );                   

                    if ( !$Success ) {
                        # build JSON output
                        my $JSON = $LayoutObject->JSONEncode(
                            Data => {
                                Error => "Message: Can't connect to Database"
                            },
                        );

                        # send JSON response
                        return $LayoutObject->Attachment(
                            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
                            Content     => $JSON,
                            Type        => 'inline',
                            NoCache     => 1,
                        );
                    }

                    RESULT:
                    while (my @Row = $DFSelectDBObject->FetchrowArray()) {

                        my $Key = $Row[0];
                        $Key =~ s/\s+$//;

                        push ( @PossibleValues, $Key );
                    }

                    # cache request
                    if ( $DynamicFieldConfig->{Config}->{CacheTTL} ) {

                        $Kernel::OM->Get('Kernel::System::Cache')->Set(
                            Type  => $Self->{CacheType},
                            Key   => "PossibleValueCheck::" . $SQL . "::" . join('::', @Entries),
                            Value => \@PossibleValues,
                            TTL   => $DynamicFieldConfig->{Config}->{CacheTTL},
                        );
                    }
                }
            }

            # build JSON output
            $JSON = $Self->{LayoutObject}->JSONEncode(
                Data => \@PossibleValues,
            );
        }

        # handle subaction AddValue
        elsif($Subaction eq 'AddValue') {

            my %Data;
            my $Key = $Self->{ParamObject}->GetParam( Param => 'Key' )  || '';

            if ( !grep { my $Temp eq $Key } @Entries ) {

                my $Value = $Self->{SelectDBObject}->ValueLookup(
                    Key                => $Key,
                    DynamicFieldConfig => $DynamicFieldConfig,
                );

                my $Title = $Value;

                if ( $DynamicFieldConfig->{Config}->{ShowKeyInTitle} ) {
                    $Title .= ' (' . $Key . ')';
                }

                $Data{Key}   = $Key;
                $Data{Value} = $Value;
                $Data{Title} = $Title;

                # build JSON output
                $JSON = $Self->{LayoutObject}->JSONEncode(
                    Data => \%Data,
                );
            }
        }
    }

    # send JSON response
    return $Self->{LayoutObject}->Attachment(
        ContentType => 'application/json; charset=' . $Self->{LayoutObject}->{Charset},
        Content     => $JSON || '',
        Type        => 'inline',
        NoCache     => 1,
    );
}

1;