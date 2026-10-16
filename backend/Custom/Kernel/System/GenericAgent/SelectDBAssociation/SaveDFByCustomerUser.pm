# --
# Kernel/System/GenericAgent/SelectDBAssociation/SaveDFByCustomerUser.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by: 
# * dparavani@serviceup.com.br
# --

package Kernel::System::GenericAgent::SelectDBAssociation::SaveDFByCustomerUser;

use strict;
use warnings;

use utf8;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::Ticket',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # 0=off; 1=on;
    $Self->{Debug} = $Param{Debug} || 0;

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;  

    # get object
    my $ConfigObject          = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject          = $Kernel::OM->Get('Kernel::System::Ticket');
    my $CustomerCompanyObject = $Kernel::OM->Get('Kernel::System::CustomerCompany');
    my $CustomerUserObject    = $Kernel::OM->Get('Kernel::System::CustomerUser');

    my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    return 0 if !$Param{New}->{SelectDBField};
    return 0 if !$Param{New}->{AtributeSearchObject};
    return 0 if !$Param{New}->{AtributeSearchField};

    my $SelectDBField        = $Param{New}->{SelectDBField};
    my $AtributeSearchObject = $Param{New}->{AtributeSearchObject};
    my $AtributeSearchField  = $Param{New}->{AtributeSearchField};

    my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
        Name => $SelectDBField,
    );

    return 0 if !$DynamicFieldConfig;

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        DynamicFields => 1,
        UserID        => 1
    ); 

    my $Search;

    if ( $AtributeSearchObject eq 'Customer' ) {

        my %CustomerCompany = $CustomerCompanyObject->CustomerCompanyGet(
            CustomerID => $Ticket{CustomerID},
        );       

        $Search = $CustomerCompany{$AtributeSearchField};

    }
    elsif ( $AtributeSearchObject eq 'CustomerUser' ) {

        my %CustomerUser = $CustomerUserObject->CustomerUserDataGet(
            User => $Ticket{CustomerUserID},
        );

        $Search = $CustomerUser{$AtributeSearchField};
    }
    elsif ( $AtributeSearchObject eq 'Ticket' ) {        

        $Search = $Ticket{$AtributeSearchField};
    }

    return if !$Search;

    my $DFSelectDBObject = Kernel::System::DFSelectDB->new(
        DatabaseDSN  => $DynamicFieldConfig->{Config}->{DatabaseDSN},
        DatabaseUser => $DynamicFieldConfig->{Config}->{DatabaseUser},
        DatabasePw   => $DynamicFieldConfig->{Config}->{DatabasePw},
        Type         => $DynamicFieldConfig->{Config}->{DatabaseType},
        %{ $Self },
    );

    my $QuotedValue = $DFSelectDBObject->Quote($Search);

    my @SearchFields = split( ';', $DynamicFieldConfig->{Config}->{DatabaseFieldSearch} );

    my $QueryCondition = $DFSelectDBObject->QueryCondition(
        Key           => \@SearchFields,
        Value         => $QuotedValue,
        SearchPrefix  => '*',
        SearchSuffix  => '*',
        CaseSensitive => $DynamicFieldConfig->{Config}->{CaseSensitive},
    );

    my @Entries = ( '' );
    my @PossibleValues;
    my %ExternalData;
   
    # prepare constrictions
    my $ConstrictionsCheck = 1;
  
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

        my $Count = 0;
        my @DFValues;

        REPLACEMENT:
        while ( $DynamicFieldConfig->{Config}->{DatabaseTableFreeField} && $DynamicFieldConfig->{Config}->{DatabaseTableFreeField} =~ m{<DynamicField_([A-Za-z0-9_]+)>}msxi && $Count++ < 50 ) {

            my $Attribute = $1;

            my $DFValue = $Self->{ParamObject}->GetParam( Param => $Attribute ) || '';

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
           
                return 0;
            }

            my $MaxCount = 1;

            RESULT:
            while (my @Row = $DFSelectDBObject->FetchrowArray()) {

                my $Key = $Row[0];

                next RESULT if ( grep( /^$Key$/, @Entries ) );

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

    VALUE:
    for my $Value ( @{$DynamicFieldConfig->{Config}->{DatabaseFieldValue}} ) {

        my ($Key) = %{$Value};

        next VALUE if !$Value->{$Key};

        my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
            Name => $Value->{$Key},
        );

        my $Success = $BackendObject->ValueSet(
            DynamicFieldConfig => $DynamicField,
            ObjectID           => $Param{TicketID},
            Value              => $ExternalData{$Seach}->{$Key},
            UserID             => 1,
        );
    }

    return 1;
}

1;