# --
# Kernel/GenericInterface/Mapping/XSLT.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::GenericInterface::Mapping::XSLT;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);
use Storable;

our $ObjectManagerDisabled = 1;

=head1 NAME

Kernel::GenericInterface::Mapping::XSLT - GenericInterface C<XSLT> data mapping backend

=head1 PUBLIC INTERFACE

=head2 new()

usually, you want to create an instance of this
by using Kernel::GenericInterface::Mapping->new();

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # Allocate new hash for object.
    my $Self = {};
    bless( $Self, $Type );

    # Check needed params.
    for my $Needed (qw(DebuggerObject MappingConfig)) {
        if ( !$Param{$Needed} ) {
            return {
                Success      => 0,
                ErrorMessage => "Got no $Needed!"
            };
        }
        $Self->{$Needed} = $Param{$Needed};
    }

    # Check mapping config.
    if ( !IsHashRefWithData( $Param{MappingConfig} ) ) {
        return $Self->{DebuggerObject}->Error(
            Summary => 'Got no MappingConfig as hash ref with content!',
        );
    }

    # Check config - if we have a map config, it has to be a non-empty hash ref.
    if (
        defined $Param{MappingConfig}->{Config}
        && !IsHashRefWithData( $Param{MappingConfig}->{Config} )
        )
    {
        return $Self->{DebuggerObject}->Error(
            Summary => 'Got MappingConfig with Data, but Data is no hash ref with content!',
        );
    }

    return $Self;
}

=head2 Map()

Provides mapping based on C<XSLT> style sheets.
Additional data is provided by the function results from various stages in requester and provider.
This data can be included in the C<XSLT> mapping as 'DataInclude' structure via configuration.

    my $ReturnData = $MappingObject->Map(
        Data => {
            'original_key' => 'original_value',
            'another_key'  => 'next_value',
        },
        DataInclude => {
            RequesterRequestInput => { ... },
            RequesterRequestPrepareOutput => { ... },
            RequesterRequestMapOutput => { ... },
            RequesterResponseInput => { ... },
            RequesterResponseMapOutput => { ... },
            RequesterErrorHandlingOutput => { ... },
            ProviderRequestInput => { ... },
            ProviderRequestMapOutput => { ... },
            ProviderResponseInput => { ... },
            ProviderResponseMapOutput => { ... },
            ProviderErrorHandlingOutput => { ... },
        },
    }
    );

    my $ReturnData = {
        'changed_key'          => 'changed_value',
        'original_key'         => 'another_changed_value',
        'another_original_key' => 'default_value',
        'default_key'          => 'changed_value',
    };

=cut

sub Map {
    my ( $Self, %Param ) = @_;

    my $WebserviceObject = $Kernel::OM->Get('Kernel::System::GenericInterface::Webservice');

    # Check data - only accept undef or hash ref or array ref.
    if ( defined $Param{Data} && ref $Param{Data} ne 'HASH' && ref $Param{Data} ne 'ARRAY' ) {
        if ( $Param{Data} ) {
            $Param{Data} = { Return => $Param{Data} };
        }
        else { 
            return $Self->{DebuggerObject}->Error(
                Summary => 'Got Data but it is not a hash or array ref in Mapping XSLT backend!'
            );
        }
    }
  
    # Check included data - only accept undef or hash ref.
    if ( defined $Param{DataInclude} && !IsHashRefWithData( $Param{DataInclude} ) ) {

        return $Self->{DebuggerObject}->Error(
            Summary => 'Got DataInclude but it is not a hash ref in Mapping XSLT backend!'
        );
    }

    # Return if data is empty.
    if (
        !defined $Param{Data}
        || (
            !IsHashRefWithData( $Param{Data} )
            && !IsArrayRefWithData( $Param{Data} )
        )
        )
    {
        return {
            Success => 1,
            Data    => {},
        };
    }

    # Prepare short config variable.
    my $Config = $Self->{MappingConfig}->{Config};

    # No config means we just return input data.
    if ( !$Config || !$Config->{Template} ) {
        return {
            Success => 1,
            Data    => $Param{Data},
        };
    }

    # Load required libraries (XML::LibXML and XML::LibXSLT).
    LIBREQUIRED:
    for my $LibRequired (qw(XML::LibXML XML::LibXSLT)) {
        my $LibFound = $Kernel::OM->Get('Kernel::System::Main')->Require($LibRequired);
        next LIBREQUIRED if $LibFound;

        return $Self->{DebuggerObject}->Error(
            Summary => "Could not find required library $LibRequired",
        );
    }

    # Prepare style sheet.
    my $LibXSLT = XML::LibXSLT->new();

    # Remove template line breaks and white spaces to plain text lines on the fly, see bug# 14106.
    my $Template =
        $Config->{Template}
        =~ s{ > [ \t\n]+ (?= [^< \t\n] ) }{>}xmsgr
        =~ s{ (?<! [> \t\n] ) [ \t\n]+ < }{<}xmsgr;

    $Template = $WebserviceObject->WebserviceConfigReplace($Template);

    my ( $StyleDoc, $StyleSheet );
    eval {
        $StyleDoc = XML::LibXML->load_xml(
            string   => $Template,
            no_cdata => 1,
        );
    };
    if ( !$StyleDoc ) {
        return $Self->{DebuggerObject}->Error(
            Summary => 'Could not load configured XSLT template',
            Data    => $Template,
        );
    }
    eval {
        $StyleSheet = $LibXSLT->parse_stylesheet($StyleDoc);
    };
    if ( !$StyleSheet ) {
        return $Self->{DebuggerObject}->Error(
            Summary => 'Could not parse configured XSLT template',
            Data    => $@,
        );
    }

    my $MergedData = Storable::dclone( $Param{Data} );

    # BLOCK SUP START
    if ( ref $MergedData eq 'ARRAY' ) {
        my $AuxMergedData = $MergedData;
        $MergedData = {
            Data => $AuxMergedData
        };

        $Param{Data} = $MergedData;
    }
    # BLOCK SUP END

    # Append the configured include data to the normal data structure.
    if (
        IsHashRefWithData( $Param{DataInclude} )
        && IsArrayRefWithData( $Config->{DataInclude} )
        )
    {
        DATAINCLUDEMODULE:
        for my $DataIncludeModule ( @{ $Config->{DataInclude} } ) {
            next DATAINCLUDEMODULE if !$Param{DataInclude}->{$DataIncludeModule};

            # Clone the data include hash to prevent circular data structure references
            $MergedData->{DataInclude}->{$DataIncludeModule}
                = Storable::dclone( $Param{DataInclude}->{$DataIncludeModule} );
        }

        $Self->{DebuggerObject}->Debug(
            Summary => 'Data merged with DataInclude before mapping',
            Data    => $MergedData,
        );

        $Param{Data} = $MergedData;
    }

    # Note: XML::Simple was chosen over alternatives like XML::LibXML and XML::Dumper
    #   due to its simplicity and because we just require a straightforward conversion.
    # Other modules provide more possibilities but don't allow directly exporting a complete
    #   and clean structure.
    # Reference:
    #   http://www.perlmonks.org/?node_id=490846
    #   http://stackoverflow.com/questions/12182129/convert-string-to-hash-using-libxml-in-perl

    # XSTL regex recursion.
    if ( IsArrayRefWithData( $Config->{PreRegExFilter} ) ) {
        $Self->_RegExRecursion(
            Data   => $Param{Data},
            Config => $Config->{PreRegExFilter},
        );
        $Self->{DebuggerObject}->Debug(
            Summary => 'Data before mapping after Pre RegExFilter',
            Data    => $Param{Data},
        );
    }

    # limpa campos undef para evitar log
    CleanUndefinedValues( $Param{Data} );

    # Convert data to xml structure.
    $Kernel::OM->Get('Kernel::System::Main')->Require('XML::Simple');
    my $XMLSimple = XML::Simple->new();
    my $XMLPre;
    eval {
        $XMLPre = $XMLSimple->XMLout(
            $Param{Data},
            AttrIndent => 1,
            ContentKey => '-content',
            NoAttr     => 1,
            KeyAttr    => [],
            RootName   => 'RootElement',
        );
    };
    if ( !$XMLPre ) {
        return $Self->{DebuggerObject}->Error(
            Summary => 'Could not convert data from Perl to XML before mapping',
            Data    => $@,
        );
    }

    #BugFix Custom Salta
    $XMLPre =~ s/[[:^print:]]//g;
    
    # Transform xml data.
    my ( $XMLSource, $Result );
    eval {
        $XMLSource = XML::LibXML->load_xml(
            string   => $XMLPre,
            no_cdata => 1,
        );
    };
    if ( !$XMLSource ) {
        return $Self->{DebuggerObject}->Error(
            Summary => 'Could not load data after conversion from Perl to XML',
            Data    => $XMLPre,
        );
    }
    eval {
        $Result = $StyleSheet->transform($XMLSource);
    };
    if ( !$Result ) {
        return $Self->{DebuggerObject}->Error(
            Summary => 'Could not map data',
            Data    => $@,
        );
    }
    my $XMLPost = $StyleSheet->output_as_bytes($Result);
    if ( !$XMLPost ) {
        return $Self->{DebuggerObject}->Error(
            Summary => "Could not write mapped data",
        );
    }

    # Convert data back to perl structure.
    my $ForceArray = 0;
    if ( IsStringWithData( $Config->{ForceArray} ) ) {
        my @ForceArrayTags = split /\s+/, $Config->{ForceArray};
        $ForceArray = \@ForceArrayTags;
    }

    my $ReturnData;
    eval {
        $ReturnData = $XMLSimple->XMLin(
            $XMLPost,
            ForceArray  => $ForceArray,
            ContentKey  => '-content',
            NoAttr      => 1,
            KeyAttr     => [],
        );
    };

    # Convert data back to perl structure to number.
    if ( IsStringWithData( $Config->{ForceNumber} ) ) {
        
        my @ForceNumberTags = split /\s+/, $Config->{ForceNumber};
        
        for my $ParamForceNumber ( @ForceNumberTags ) {
            
            # Verifica se há chaves aninhadas
            if ( $ParamForceNumber =~ /\// ) {
                # Divida o caminho da chave em partes
                my @Keys = split /\//, $ParamForceNumber;
                
                # Inicializa um ponteiro para navegar pelas chaves aninhadas
                my $current_level = $ReturnData;
    
                # Itera por cada parte da chave, exceto a última
                for my $key_part ( @Keys[0 .. $#Keys-1] ) {
                    # Cria a chave se não existir
                    $current_level->{$key_part} ||= {};
                    
                    # Move o ponteiro para o próximo nível
                    $current_level = $current_level->{$key_part};
                }
    
                # Converte o último nível em número
                $current_level->{$Keys[-1]} += 0;
            } 
            else {
                # Caso não haja chaves aninhadas, converte diretamente
                $ReturnData->{$ParamForceNumber} += 0;
            }
        }
    }

    # Convert data back to perl structure to boolean.
    if ( IsStringWithData( $Config->{ForceBoolean} ) ) {
        my @ForceBooleanTags = split /\s+/, $Config->{ForceBoolean};

        for my $ForceBooleanNumber ( @ForceBooleanTags ){
            if( $ReturnData->{$ForceBooleanNumber} eq 'true' ){
                $ReturnData->{$ForceBooleanNumber} = \1;
            }
            elsif( $ReturnData->{$ForceBooleanNumber} eq 'false' ){
                $ReturnData->{$ForceBooleanNumber} = \0;
            }
        }
    }

    # Convert data back to perl structure string empty.
    if ( IsStringWithData( $Config->{ForceEmptyString} ) ) {
        my @ForceEmptyStringTags = split /\s+/, $Config->{ForceEmptyString};

        for my $ForceEmptyString ( @ForceEmptyStringTags ){

            if (ref $ReturnData->{$ForceEmptyString} eq 'HASH') {
                $ReturnData->{$ForceEmptyString} = "";
            }
        }
    }

    if ( !$ReturnData ) {
        return $Self->{DebuggerObject}->Error(
            Summary => 'Could not convert data from XML to Perl after mapping',
            Data    => [ $@, $XMLPost ],
        );
    }

    # XST regex recursion.
    if ( IsArrayRefWithData( $Config->{PostRegExFilter} ) ) {
        $Self->{DebuggerObject}->Debug(
            Summary => 'Data after mapping before Post RegExFilter',
            Data    => $ReturnData,
        );
        $Self->_RegExRecursion(
            Data   => $ReturnData,
            Config => $Config->{PostRegExFilter},
        );
    }

    return {
        Success => 1,
        Data    => $ReturnData,
    };
}

sub CleanUndefinedValues {
    my $data = shift;

    # Se for um hash, percorre cada chave
    if ( ref $data eq 'HASH' ) {
        foreach my $key ( keys %{$data} ) {
            if ( !defined $data->{$key} ) {
                delete $data->{$key}; # Remove chaves indefinidas
            }
            else {
                CleanUndefinedValues( $data->{$key} );
            }
        }
    }
    # Se for um array, percorre cada elemento
    elsif ( ref $data eq 'ARRAY' ) {
        @$data = grep { defined } @$data; # Remove elementos indefinidos
        foreach my $element ( @{$data} ) {
            CleanUndefinedValues($element);
        }
    }
}

sub _RegExRecursion {
    my ( $Self, %Param ) = @_;

    # Data must be hash ref.
    return 1 if !IsHashRefWithData( $Param{Data} );

    KEY:
    for my $Key ( sort keys %{ $Param{Data} } ) {

        # Recurse for array data in value.
        if ( IsArrayRefWithData( $Param{Data}->{$Key} ) ) {

            ARRAYENTRY:
            for my $ArrayEntry ( @{ $Param{Data}->{$Key} } ) {
                $Self->_RegExRecursion(
                    Data   => $ArrayEntry,
                    Config => $Param{Config},
                );
            }
        }

        # Recurse directly otherwise (assume hash reference).
        else {
            $Self->_RegExRecursion(
                Data   => $Param{Data}->{$Key},
                Config => $Param{Config},
            );
        }

        # Apply configured RegEx to key.
        REGEX:
        for my $RegEx ( @{ $Param{Config} } ) {
            next REGEX if $Key !~ m{$RegEx->{Search}};

            # Double-eval the replacement string to allow embedded capturing group replacements,
            #   e.g. Search = '(foo|bar)bar', Replace = '$1foo'
            #   turns 'foobar' into 'foofoo' and 'barbar' into 'barfoo'.
            my $NewKey = $Key =~ s{$RegEx->{Search}}{ '"' . $RegEx->{Replace} . '"' }eer;

            # Skip if new key is equivalent to old key.
            next KEY if $NewKey eq $Key;

            # Replace matched key with new one.
            $Param{Data}->{$NewKey} = delete $Param{Data}->{$Key};
        }

    }

    return 1;
}

1;

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<https://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (GPL). If you
did not receive this file, see L<https://www.gnu.org/licenses/gpl-3.0.txt>.

=cut
