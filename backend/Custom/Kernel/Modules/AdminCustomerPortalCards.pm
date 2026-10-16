# --
# Kernel/Modules/AdminCustomerPortalCards.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#  
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package Kernel::Modules::AdminCustomerPortalCards;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

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

	my $CustomerPortalObject = $Kernel::OM->Get('Kernel::System::CustomerPortal');
    my $LayoutObject         = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');

    # ------------------------------------------------------------ #
    # Cards edit
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'CardsEdit' ) {

        # header
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        # html output
        $Output .= $Self->_MaskNew(
            %Param,
        );
        $Output .= $LayoutObject->Footer();

        return $Output;
    }
    # ------------------------------------------------------------ #
    # Cards save
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'CardsSave' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

        # get params
        my %GetParam;
        for (qw(ID Name ValidID )) {
            $GetParam{$_} = $ParamObject->GetParam( Param => $_ ) || '';
        }
        
        $GetParam{'Body'} = $ParamObject->GetParam(
            Param => 'Body',
            Raw   => 1
        ) || '';

        my %Error;

        if ( !$GetParam{Name} ) {
            $Error{'NameInvalid'} = 'ServerError';
        }

        if ( !%Error ) {

            my $LogObject = $Kernel::OM->Get('Kernel::System::Log');

            # save to database
            if ( $GetParam{ID} eq 'NEW' ) {
                $GetParam{CardID} = $CustomerPortalObject->CardsAdd(
                    %GetParam,
                    UserID => $Self->{UserID},
                );
                if ( !$GetParam{ID} ) {
                    $Error{Message} = $LogObject->GetLogEntry(
                        Type => 'Error',
                        What => 'Message',
                    );
                }
            }
            else {
                my $Success = $CustomerPortalObject->CardsUpdate(
                    %GetParam,
                    UserID => $Self->{UserID},
                );
                if ( !$Success ) {
                    $Error{Message} = $LogObject->GetLogEntry(
                        Type => 'Error',
                        What => 'Message',
                    );
                }
            }

            if ( !%Error ) {
                # redirect to overview
                    return $LayoutObject->Redirect( OP => "Action=$Self->{Action}" );
                
            }
        }

        # something went wrong
        my $Output = $LayoutObject->Header();

        $Output .= $LayoutObject->NavigationBar();

        $Output .= $Error{Message}
            ? $LayoutObject->Notify(
            Priority => 'Error',
            Info     => $Error{Message},
            )
            : '';

        # html output
        $Output .= $Self->_MaskNew(
            %Error,
            %GetParam,
            %Param,
        );

        $Output .= $LayoutObject->Footer();

        return $Output;
    }
    # ------------------------------------------------------------ #
    # Cards overview
    # ------------------------------------------------------------ #
    else {

        # output header
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        # output overview
        $LayoutObject->Block(
            Name => 'Overview',
            Data => { %Param, },
        );

        $LayoutObject->Block( Name => 'ActionList' );
        $LayoutObject->Block( Name => 'ActionAdd' );

        # output overview result
        $LayoutObject->Block(
            Name => 'OverviewList',
            Data => { %Param, },
        );

        # get Cards list
        my %CardsList = $CustomerPortalObject->CardsList();
        my %ValidList = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();

        #  if there are any Series defined, they are shown
        if ( IsHashRefWithData(\%CardsList) ) {
            for my $CardID ( keys %CardsList ) {

				my $Data = $CustomerPortalObject->CardsGet(
					ID => $CardID,
				);

                # output row
                $LayoutObject->Block(
                    Name => 'OverviewListRow',
                    Data => {
                        %{$Data},
                        Valid => $ValidList{ $Data->{ValidID} },
                    },
                );

            }
        }

        # otherwise a no data found msg is displayed
        else {
            $LayoutObject->Block(
                Name => 'NoDataFoundMsg',
                Data => {},
            );
        }

        # generate output
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AdminCustomerPortalCards',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();

        return $Output;
    }
}

sub _MaskNew {
    my ( $Self, %Param ) = @_;

    my $CustomerPortalObject = $Kernel::OM->Get('Kernel::System::CustomerPortal');
    my %CardData;

    # get params
    $CardData{ID} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => "ID" );

    if ( $CardData{ID} ne 'NEW' ) {
        my $Series = $CustomerPortalObject->CardsGet(
            ID => $CardData{ID},
        );

		%CardData = %{$Series};
    }

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # output overview
    $LayoutObject->Block(
        Name => 'Overview',
        Data => { %CardData, },
    );

    $LayoutObject->Block( Name => 'ActionList' );
    $LayoutObject->Block( Name => 'ActionOverview' );

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # get valid list
    my %ValidList        = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();
    my %ValidListReverse = reverse %ValidList;

    $CardData{ValidOptionStrg} = $LayoutObject->BuildSelection(
        Data       => \%ValidList,
        Name       => 'ValidID',
        SelectedID => $CardData{ValidID} || $ValidListReverse{valid},
        Class      => 'Modernize Validate_Required',
    );

    # output Series edit
    $LayoutObject->Block(
        Name => 'CardEdit',
        Data => { %Param, %CardData, },
    );

    # shows header
    if ( $CardData{ID} ne 'NEW' ) {
        $LayoutObject->Block(
            Name => 'HeaderEdit',
            Data => {%CardData},
        );
    }
    else {
        $LayoutObject->Block( Name => 'HeaderAdd' );
    }

    # generate output
    return $LayoutObject->Output(
        TemplateFile => 'AdminCustomerPortalCards',
        Data         => \%Param
    );
}

1;