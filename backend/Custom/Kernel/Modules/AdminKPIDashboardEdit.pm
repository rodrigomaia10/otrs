# --
# Kernel/Modules/AdminKPIDashboardEdit.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dparavani@serviceup.com.br
# --

package Kernel::Modules::AdminKPIDashboardEdit;

use strict;
use warnings;
use utf8;

use Kernel::Language qw(Translatable);
use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless ($Self, $Type);

    return $Self;

}

sub Run {
    my ( $Self, %Param ) = @_;

    # get objects
	my $KPIObject       = $Kernel::OM->Get('Kernel::System::KPI');
    my $JSONObject      = $Kernel::OM->Get('Kernel::System::JSON');
	my $GroupObject     = $Kernel::OM->Get('Kernel::System::Group');
    my $HTMLUtilsObject = $Kernel::OM->Get('Kernel::System::HTMLUtils');
	my $LayoutObject    = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject     = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $DashboardObject = $Kernel::OM->Get('Kernel::System::Dashboard::Dashboard');

    if ( $LayoutObject->{BrowserRichText} ) {

        # reformat from plain to html
        if ( $Param{ContentType} && $Param{ContentType} =~ /text\/plain/i ) {
            $Param{Template} = $HTMLUtilsObject->ToHTML(
                String => $Param{Template},
            );
        }
    }
    else {

        # reformat from html to plain
        if ( $Param{ContentType} && $Param{ContentType} =~ /text\/html/i ) {
            $Param{Template} = $HTMLUtilsObject->ToAscii(
                String => $Param{Template},
            );
        }
    }

    # set up rich text editor
    $LayoutObject->SetRichTextParameters(
        Data => \%Param,
    );
    
    # Search dialog
    if ( $Self->{Subaction} eq 'CardSettings' ) {

        my %GetParam;
        $GetParam{DashboardID} = $ParamObject->GetParam( Param => 'DashboardID' );

        my $KPIs = $KPIObject->KPIList();

        my %KPIData;

        KPI:
        foreach my $KPIID ( @{$KPIs} ){

            my $KPI = $KPIObject->KPIGet(
                ID => $KPIID,
            );

            next KPI if $KPI->{ValidID} == 0;
            next KPI if $KPI->{ObjectType} ne 'ChartSQLQuery';
            
            $KPIData{$KPIID} = $KPI->{Name};
        }

        $GetParam{KPIOptionString} = $LayoutObject->BuildSelection(
            Data         => \%KPIData,
            Name         => 'AssociatedKPIs',
            SelectedID   => '',
            Class        => 'Modernize',
            Multiple     => 0,
        );

        my $Output = $LayoutObject->Output(
            TemplateFile => 'AdminKPIDashboardEditCardSettings',
            Data         => {
                DashboardID => $GetParam{DashboardID},
                %GetParam
            },
        );

        return $LayoutObject->Attachment(
            NoCache     => 1,
            ContentType => 'text/html',
            Charset     => $LayoutObject->{UserCharset},
            Content     => $Output || '',
            Type        => 'inline',
        );
    }

    elsif ( $Self->{Subaction} eq 'SaveCardSettings' ) {

        my ( %GetParam, %Errors );
        for my $Needed (qw(DashboardID CardSettingsID SelectCardType)) {
            $GetParam{$Needed} = $ParamObject->GetParam( Param => $Needed );

            if ( !$GetParam{$Needed} ) {
                $Errors{ $Needed . 'ServerError' }        = 'ServerError';
                $Errors{ $Needed . 'ServerErrorMessage' } = Translatable('This field is required.');
            }
        }

        $GetParam{'AssociatedKPIs'} = $ParamObject->GetParam( Param => 'AssociatedKPIs' );

        $GetParam{'Template'} = $ParamObject->GetParam(
            Param => 'Template',
            Raw   => 1
        ) || '';

        # if no errors occurred
        if ( !%Errors ) {

            # add card
            my $NewCard = $DashboardObject->SaveCardSettings(
                %GetParam,
            );

            if ($NewCard) {

                return $LayoutObject->Redirect( OP => "Action=$Self->{Action};DashboardID=$GetParam{DashboardID}" );
            }
        }

        # something has gone wrong
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        $Output .= $LayoutObject->Notify( Priority => 'Error' );
        
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AdminKPIDashboardEdit',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    elsif ( $Self->{Subaction} eq 'SaveCardsPosition' ) {

        my ( %GetParam, %Errors );
        $GetParam{DashboardID} = $ParamObject->GetParam( Param => 'DashboardID' );
        $GetParam{Cards} = $ParamObject->GetParam( Param => 'Cards' );

        my $Cards = $JSONObject->Decode(
            Data => $GetParam{Cards},
        );

        my $Success;

        for my $Card ( @{$Cards} ) {

            # add card position and size
            $Success = $DashboardObject->CardPositionSizeAdd(
                %{$Card},
                DashboardID => $GetParam{DashboardID},
            );
        }

        return $LayoutObject->Attachment(
            NoCache     => 1,
            ContentType => 'text/html',
            Charset     => $LayoutObject->{UserCharset},
            Content     => $Success || '',
            Type        => 'inline',
        );
    }

    elsif ( $Self->{Subaction} eq 'DeleteCard' ) {

        my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');

        my ( %GetParam, %Errors );
        $GetParam{DashboardID} = $ParamObject->GetParam( Param => 'DashboardID' );
        $GetParam{CardID} = $ParamObject->GetParam( Param => 'CardID' );

        # delete card
        my $Success = $DashboardObject->DeleteCard(
            CardID      => $GetParam{CardID},
            DashboardID => $GetParam{DashboardID},
        );

        return $LayoutObject->Attachment(
            NoCache     => 1,
            ContentType => 'text/html',
            Charset     => $LayoutObject->{UserCharset},
            Content     => $Success || '',
            Type        => 'inline',
        );
    }

    elsif ( $Self->{Subaction} eq 'DashboardSettings' ) {

        my %GetParam;
        $GetParam{DashboardID} = $ParamObject->GetParam( Param => 'DashboardID' );

        my %DashboardSettings = $DashboardObject->DashboardGet( ID => $GetParam{DashboardID} );

        my $DashboardSetting = $JSONObject->Decode(
            Data => $DashboardSettings{Settings},
        );

        $LayoutObject->Block( 
            Name => 'BoardsEdit',
            Data         => {
                DashboardBG => $DashboardSetting->{DashboardBG} ? $DashboardSetting->{DashboardBG} : '#f5f5f5',
                CardBG => $DashboardSetting->{CardBG} ? $DashboardSetting->{CardBG} : '#ebf1c4',
                DashboardID => $GetParam{DashboardID},
            },
        );

        my $Output = $LayoutObject->Output(
            TemplateFile => 'AdminKPIDashboardEditSettings',
        );

        return $LayoutObject->Attachment(
            NoCache     => 1,
            ContentType => 'text/html',
            Charset     => $LayoutObject->{UserCharset},
            Content     => $Output || '',
            Type        => 'inline',
        );
    }

    elsif ( $Self->{Subaction} eq 'SaveDashboardSettings' ) {

        my %GetParam;
        for my $Needed (qw(DashboardBG CardBG DashboardID)) {
            $GetParam{$Needed} = $ParamObject->GetParam( Param => $Needed );
        }

        # add card position and size
        my $Success = $DashboardObject->SaveDashboardSettings(
            %GetParam
        );

        if ($Success) {

            return $LayoutObject->Redirect( OP => "Action=$Self->{Action};DashboardID=$GetParam{DashboardID}" );
        }

    }

    else {
        
        # header
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        my %GetParam;
        $GetParam{DashboardID} = $ParamObject->GetParam( Param => 'DashboardID' );

        # get cards position and size
        my @Cards = $DashboardObject->CardPositionSizeGet( %GetParam );

        # send data to JS
        $LayoutObject->AddJSData(
            Key   => 'DataCards',
            Value => \@Cards
        );
        my @DataCharts;
        my @DataHTML;

        foreach my $Card ( @Cards ) {

            if ( $Card->{CardType} eq 'KPI' ) {

                my $KPI = $KPIObject->KPIGet(
                    ID => $Card->{KPIID},
                );

                if ( $KPI->{ObjectType} eq 'ChartSQLQuery' ){

                    my %DataChart = $Self->_BuildChartsChartSQLQuery(
                        KPIID  => $Card->{KPIID},
                        CardID => $Card->{CardID},
                    );
                    push @DataCharts, \%DataChart;
                }
            }
            elsif ( $Card->{CardType} eq 'HTML' ) {

                push @DataHTML, { 
                    CardType        => $Card->{CardType},
                    CardID          => $Card->{CardID},
                    ContentTemplate => $Card->{ContentTemplate}
                }
            }
        }

        # send data charts to JS
        $LayoutObject->AddJSData(
            Key   => 'DataChart',
            Value => \@DataCharts
        );

        # send data HTML to JS
        $LayoutObject->AddJSData(
            Key   => 'DataHTML',
            Value => \@DataHTML
        );

        my %DashboardSettings = $DashboardObject->DashboardGet( ID => $GetParam{DashboardID} );

        my $DashboardSetting = $JSONObject->Decode(
            Data => $DashboardSettings{Settings},
        );

        # generate output
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AdminKPIDashboardEdit',
            Data         => {
                DashboardBG => $DashboardSetting->{DashboardBG} ? $DashboardSetting->{DashboardBG} : '#f5f5f5',
                CardBG => $DashboardSetting->{CardBG} ? $DashboardSetting->{CardBG} : '#ebf1c4',
            }
        );

        $Output .= $LayoutObject->Footer();

        return $Output;
    }
}

sub _BuildChartsChartSQLQuery {
	my ( $Self, %Param ) = @_;

	# get config object
	my $DBObject        = $Kernel::OM->Get('Kernel::System::DB');
	my $KPIObject       = $Kernel::OM->Get('Kernel::System::KPI');
	my $GroupObject     = $Kernel::OM->Get('Kernel::System::Group');
    my $LayoutObject    = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $DashboardObject = $Kernel::OM->Get('Kernel::System::Dashboard::Dashboard');

    my %Groups = $GroupObject->PermissionUserGet(
        UserID => $Self->{UserID},
        Type   => 'ro',
    );

	my @UserGroups = keys %Groups;

	my %DataChart;

    my $KPIID = $Param{KPIID};

    my $KPI = $KPIObject->KPIGet(
        ID => $KPIID,
        ValidID => 1
    );

    my $DataSQLChart = $DashboardObject->GetChartsData( SQL => $KPI->{SQL} );

    my @Rows = @{$DataSQLChart->{Rows}};
    
    my @Head = @{$DataSQLChart->{Head}};
             
    if ( $KPI->{ReturnChart} eq 'Pie' ) {
        
        my %Data = (
            'x'       => '',
            'columns' => \@Rows,
            'type'    => 'pie',
            'groups'  => 0,
            'rotated' => 0,
        );

        %DataChart = (
            data => \%Data,	
            cardID => $Param{CardID},
            TypeKPI => 'ChartSQLQuery',
            axis => {
                x => {
                    type => 'category',
                    tick => {
                        rotate => '',
                    },
                },
            },
            title => {
                text => $KPI->{Name}
            }
        );
    }

    elsif ( $KPI->{ReturnChart} eq 'Column' ) {
			
        my @AxisY;
        my @Columns;
        my $Count = 0;

        push @AxisY, 'x';
        foreach my $Row ( @Rows ) {

            push @AxisY, $Row->[0];
        }

        push @Columns, \@AxisY;

        HEADER:
        for my $Header ( @Head ) {
            
            next HEADER if $Header eq $Head[0];

            my @Values;
            
            push @Values, $Header;

            ROW:
            for my $Row ( @Rows ) {
                
                next ROW if $Row eq $Rows[$Count]->[0];

                VALUES:
                for my $Value ( @{$Row} ) {
                    
                    next VALUES if $Value eq $Row->[0];
                    
                    push @Values, $Row->[$Count+1];
                    last VALUES;
                }
            }
            
            push @Columns, \@Values;
            $Count++;
            
        }

        my %Data = (
            'x'       => 'x',
            'columns' => \@Columns,
            'type'    => 'bar',
            'groups'  => 0,
            'rotated' => 0,
        );
            

        %DataChart = (
            data => \%Data,	
            cardID => $Param{CardID},
            TypeKPI => 'ChartSQLQuery',
            axis => {
                x => {
                    type => 'category',
                    tick => {
                        rotate => '',
                    },
                },
            },
            title => {
                text => $KPI->{Name}
            }
        );
    }

    elsif ( $KPI->{ReturnChart} eq 'Stacked Column' ) {

        my @AxisY;
        my @Columns;
        my @Group;
        my @Groups;
        my $Count = 0;

        push @AxisY, 'x';
        foreach my $Row ( @Rows ) {

            push @AxisY, $Row->[0];
        }

        push @Columns, \@AxisY;

        HEADER:
        for my $Header ( @Head ) {
            
            next HEADER if $Header eq $Head[0];
            
            my @Values;
            
            push @Values, $Header;
            push @Group, $Header;

            ROW:
            for my $Row ( @Rows ) {

                next ROW if $Row eq $Rows[$Count]->[0];

                VALUES:
                for my $Value ( @{$Row} ) {
                    
                    next VALUES if $Value eq $Row->[0];
                    
                    push @Values, $Row->[$Count+1];
                    last VALUES;
                }
            }
            
            push @Columns, \@Values;
            $Count++;
            
        }

        push @Groups, \@Group;

        my %Data = (
            'x'       => 'x',
            'columns' => \@Columns,
            'type'    => 'bar',
            'groups'  => \@Groups,
            'rotated' => 0,
        );
        
        %DataChart = (
            data => \%Data,	
            cardID => $Param{CardID},
            TypeKPI => 'ChartSQLQuery',
            axis => {
                x => {
                    type => 'category',
                    tick => {
                        rotate => '',
                    },
                },
            },
        title => {
                text => $KPI->{Name}
            }
        );		
    }

    elsif ( $KPI->{ReturnChart} eq 'Bar' ) {

        my @AxisY;
        my @Columns;
        my $Count = 0;

        push @AxisY, 'x';
        foreach my $Row ( @Rows ) {

            push @AxisY, $Row->[0];
        }

        push @Columns, \@AxisY;

        HEADER:
        for my $Header ( @Head ) {
            
            next HEADER if $Header eq $Head[0];
            
            my @Values;
            
            push @Values, $Header;

            ROW:
            for my $Row ( @Rows ) {

                next ROW if $Row eq $Rows[$Count]->[0];

                VALUES:
                for my $Value ( @{$Row} ) {
                    
                    next VALUES if $Value eq $Row->[0];
                    
                    push @Values, $Row->[$Count+1];
                    last VALUES;
                }
            }
            
            push @Columns, \@Values;
            $Count++;
            
        }

        my %Data = (
            'x'       => 'x',
            'columns' => \@Columns,
            'type'    => 'bar',
            'groups'  => 0,
            'rotated' => 'true',
        );

        %DataChart = (
            data => \%Data,	
            cardID => $Param{CardID},
            TypeKPI => 'ChartSQLQuery',
            axis => {
                x => {
                    type => 'category',
                    tick => {
                        rotate => '',
                    },
                },
            },
            title => {
                text => $KPI->{Name}
            }
        );	
    }

    elsif ( $KPI->{ReturnChart} eq 'Stacked Bar' ) {

        my @AxisY;
        my @Columns;
        my @Group;
        my @Groups;
        my $Count = 0;

        push @AxisY, 'x';
        foreach my $Row ( @Rows ) {

            push @AxisY, $Row->[0];
        }
        
        push @Columns, \@AxisY;

        HEADER:
        for my $Header ( @Head ) {
            
            next HEADER if $Header eq $Head[0];
            
            my @Values;
            
            push @Values, $Header;
            push @Group, $Header;

            ROW:
            for my $Row ( @Rows ) {

                next ROW if $Row eq $Rows[$Count]->[0];

                VALUES:
                for my $Value ( @{$Row} ) {
                    
                    next VALUES if $Value eq $Row->[0];
                    
                    push @Values, $Row->[$Count+1];
                    last VALUES;
                }
            }
            
            push @Columns, \@Values;
            $Count++;
            
        }

        push @Groups, \@Group;

        my %Data = (
            'x'       => 'x',
            'columns' => \@Columns,
            'type'    => 'bar',
            'groups'  => \@Groups,
            'rotated' => 1,
        );

        %DataChart = (
            data => \%Data,	
            cardID => $Param{CardID},
            TypeKPI => 'ChartSQLQuery',
            axis => {
                x => {
                    type => 'category',
                    tick => {
                        rotate => '',
                    },
                },
            },
            title => {
                text => $KPI->{Name}
            }
        );
    }

    elsif ( $KPI->{ReturnChart} eq 'Donut' ) {

        my %Data = (
            'x'       => '',
            'columns' => \@Rows,
            'type'    => 'donut',
            'groups'  => 0,
            'rotated' => 0,
        );			

        %DataChart = (
            data => \%Data,	
            cardID => $Param{CardID},
            TypeKPI => 'ChartSQLQuery',
            axis => {
                x => {
                    type => 'category',
                    tick => {
                        rotate => '',
                    },
                },
            },
            title => {
                text => $KPI->{Name}
            }    
        );

    }

    elsif ( $KPI->{ReturnChart} eq 'Line' ) {

        my %Data = (
            'x'       => '',
            'columns' => \@Rows,
            'type'    => 'line',
            'groups'  => 0,
            'rotated' => 0,
        );			

        %DataChart = (
            data => \%Data,	
            cardID => $Param{CardID},
            TypeKPI => 'ChartSQLQuery',
            axis => {
                x => {
                    type => 'category',
                    tick => {
                        rotate => '',
                    },
                },
            },
            title => {
                text => $KPI->{Name}
            }   
        );

    }

    elsif ( $KPI->{ReturnChart} eq 'Area' ) {

        my %Data = (
            'x'       => '',
            'columns' => \@Rows,
            'type'    => 'area',
            'groups'  => 0,
            'rotated' => 0,
        );			

        %DataChart = (
            data => \%Data,	
            cardID => $Param{CardID},
            TypeKPI => 'ChartSQLQuery',
            axis => {
                x => {
                    type => 'category',
                    tick => {
                        rotate => '',
                    },
                },
            },
            title => {
                text => $KPI->{Name}
            }    
        );

    }

    $DataChart{KPIID} = $KPI->{ID};
    $DataChart{DisplayText} = $KPI->{DisplayTextChart};

    return %DataChart;
}

1;