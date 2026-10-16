# --
# Kernel/Modules/AgentKPIDashboard.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dparavani@serviceup.com.br
# --

package Kernel::Modules::AgentKPIDashboard;

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
    my $UserObject      = $Kernel::OM->Get('Kernel::System::User');
    my $JSONObject      = $Kernel::OM->Get('Kernel::System::JSON');
    my $GroupObject     = $Kernel::OM->Get('Kernel::System::Group');
	my $LayoutObject    = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject     = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $DashboardObject = $Kernel::OM->Get('Kernel::System::Dashboard::Dashboard');

    if ( $Self->{Subaction} eq 'DashboardList') {
        
        # header
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        my %Preferences = $UserObject->GetPreferences(
            UserID => $Self->{UserID},
        );

        if ( $Preferences{DashboardID} ) {

            # send data to JS
            $LayoutObject->AddJSData(
                Key   => 'DashboardPreference',
                Value => $Preferences{DashboardID}
            );
        }

        $Self->_Overview();
        
        # generate output
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AgentKPIDashboard',
        );

        $Output .= $LayoutObject->Footer();

        return $Output;
    }

    elsif ( $Self->{Subaction} eq 'Overview' ) {

        # header
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        my $DashboardID = $ParamObject->GetParam( Param => 'ID' ) || '';

        my %Data = $DashboardObject->DashboardGet( ID => $DashboardID );
        
        if ( !%Data ) {
            return $LayoutObject->ErrorScreen(
                Message => Translatable('Dashboard not found!'),
            );
        }

        my %Groups = $GroupObject->PermissionUserGet(
            UserID => $Self->{UserID},
            Type   => 'ro',
        );

	    my @UserGroups = keys %Groups;

        if ( IsArrayRefWithData($Data{Groups}) ){
            my $MatchGroups = 0;
            my @DashboardGroups = @{$Data{Groups}};

            foreach my $GroupID ( @DashboardGroups ){
                if ( grep( $_ == $GroupID, @UserGroups ) ){
                    $MatchGroups++;
                }
            }

            if ( $MatchGroups <= 0 ) {
                return $LayoutObject->ErrorScreen(
                    Message => Translatable('Without permission! Contact the administrator.'),
                );
            }
        }

        # get cards position and size
        my @Cards = $DashboardObject->CardPositionSizeGet( DashboardID => $DashboardID );

        # send data to JS
        $LayoutObject->AddJSData(
            Key   => 'DataCards',
            Value => \@Cards
        );

        my @DataCharts;
        my @DataHTML;
        
        foreach my $Card ( @Cards ) {

            if ( $Card->{CardType} eq 'KPI' ) {

                my %DataChart = $Self->_BuildChartsChartSQLQuery(
                    KPIID  => $Card->{KPIID},
                    CardID => $Card->{CardID},
                );
                push @DataCharts, \%DataChart;
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

        my %DashboardSettings = $DashboardObject->DashboardGet( ID => $DashboardID );

        my $DashboardSetting = $JSONObject->Decode(
            Data => $DashboardSettings{Settings},
        );

        # generate output
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AgentKPIDashboard',
            Data         => {
                DashboardBG => $DashboardSetting->{DashboardBG} ? $DashboardSetting->{DashboardBG} : '#f5f5f5',
                CardBG => $DashboardSetting->{CardBG} ? $DashboardSetting->{CardBG} : '#ebf1c4',
            }
        );

        $Output .= $LayoutObject->Footer();

        return $Output;
    }

    elsif ( $Self->{Subaction} eq 'SetPreferences' ) {

        my $DashboardID = $ParamObject->GetParam( Param => 'DashboardID' );

        $UserObject->SetPreferences(
            Key   => 'DashboardID',
            Value => $DashboardID,
            UserID => $Self->{UserID},
        );

        return $LayoutObject->Attachment(
            NoCache     => 1,
            ContentType => 'text/html',
            Charset     => $LayoutObject->{UserCharset},
            Content     => '',
            Type        => 'inline',
        );

    }

    else {

        # header
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        my %Preferences = $UserObject->GetPreferences(
            UserID => $Self->{UserID},
        );

        if ( $Preferences{DashboardID} ) {

            return $LayoutObject->Redirect( OP => "Action=$Self->{Action};Subaction=Overview;ID=$Preferences{DashboardID}" );
        }
        else {
            return $LayoutObject->Redirect( OP => "Action=$Self->{Action};Subaction=DashboardList" );
        }

        # generate output
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AgentKPIDashboard',
        );

        $Output .= $LayoutObject->Footer();

        return $Output;
    }
}

sub _Overview {
    my ( $Self, %Param ) = @_;

    # get objects
    my $GroupObject     = $Kernel::OM->Get('Kernel::System::Group');
    my $LayoutObject    = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $DashboardObject = $Kernel::OM->Get('Kernel::System::Dashboard::Dashboard');

    my %List = $DashboardObject->DashboardList();

    # if there are any dashboards, they are shown
    if (%List) {

        # get valid list
        my %ValidList = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();

        my %Groups = $GroupObject->PermissionUserGet(
            UserID => $Self->{UserID},
            Type   => 'ro',
        );

	    my @UserGroups = keys %Groups;

        DASHBOARD:
        for my $DashboardID ( sort { $List{$a} cmp $List{$b} } keys %List ) {

            my %Data = $DashboardObject->DashboardGet(
                ID => $DashboardID,
            );

            if ( IsArrayRefWithData($Data{Groups}) ){
				my $MatchGroups = 0;
				my @DashboardGroups = @{$Data{Groups}};

                foreach my $GroupID ( @DashboardGroups ){
					if ( grep( $_ == $GroupID, @UserGroups ) ){
						$MatchGroups++;
					}
				}

                next DASHBOARD if ( $MatchGroups <= 0 );
            }

            $LayoutObject->Block(
                Name => 'Card',
                Data => {
                    Valid => $ValidList{ $Data{ValidID} },
                    %Data,
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

    return 1;
}

sub _BuildChartsChartSQLQuery {
	my ( $Self, %Param ) = @_;

	# get config object
	my $DBObject        = $Kernel::OM->Get('Kernel::System::DB');
	my $KPIObject       = $Kernel::OM->Get('Kernel::System::KPI');
    my $LayoutObject    = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $DashboardObject = $Kernel::OM->Get('Kernel::System::Dashboard::Dashboard');

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

    return %DataChart;
}

1;