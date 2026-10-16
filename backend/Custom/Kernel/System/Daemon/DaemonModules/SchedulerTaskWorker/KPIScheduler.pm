# --
# Custom/Kernel/System/Daemon/DaemonModules/SchedulerTaskWorker/KPIScheduler.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * ccresencio@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::System::Daemon::DaemonModules::SchedulerTaskWorker::KPIScheduler;

use strict;
use warnings;

use base qw(Kernel::System::Daemon::DaemonModules::BaseTaskWorker);
use parent qw(Kernel::System::Console::BaseCommand);

use Kernel::Language qw(Translatable);
use Kernel::System::VariableCheck qw(:all);
use utf8;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Daemon::SchedulerDB',
    'Kernel::System::Email',
    'Kernel::System::Log',
    'Kernel::System::Time',
);

=head1 NAME
Kernel::System::Daemon::DaemonModules::SchedulerTaskWorker::Cron - Scheduler daemon task handler module for cron like jobs
=head1 SYNOPSIS
This task handler executes scheduler tasks based in cron notation.
=head1 PUBLIC INTERFACE
=over 4
=cut

=item new()
    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $TaskHandlerObject = $Kernel::OM-Get('Kernel::System::Daemon::DaemonModules::SchedulerTaskWorker::Cron');
=cut

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    $Self->{Debug}      = $Param{Debug};
    $Self->{WorkerName} = 'Worker: KPIScheduler';

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    #  get objects
    my $KPIObject      = $Kernel::OM->Get('Kernel::System::KPI');
    my $LayoutObject   = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject   = $Kernel::OM->Get('Kernel::Config');
    my $GroupObject    = $Kernel::OM->Get('Kernel::System::Group');
    my $UserObject     = $Kernel::OM->Get('Kernel::System::User');
    my $EmailObject    = $Kernel::OM->Get('Kernel::System::Email');
    my $StandardTemplateObject = $Kernel::OM->Get('Kernel::System::StandardTemplate');

    my %JobData = %{ $Param{Data} };

    # Get the emails of the agents in the groups
    my %Agents;
    my @EmailsOfAgentsToSend;

    if(IsArrayRefWithData($JobData{GroupIDs})){
        for my $GroupID ( @{$JobData{GroupIDs}}){
            my %Users = $GroupObject->PermissionGroupGet(
                GroupID => $GroupID,
                Type    => 'ro',
            );

            %Agents = (%Users);
        }

        for my $AgentID (keys %Agents){
       
            my %User = $UserObject->GetUserData(
                UserID => $AgentID,
            );

            push @EmailsOfAgentsToSend, $User{UserEmail};

        }
    }
   
    # To send to additional emails
    if($JobData{AdditionalEmails}){
        push @EmailsOfAgentsToSend, $JobData{AdditionalEmails};
    }

    my @ReturnData;

    # To get KPI data
    if(IsArrayRefWithData($JobData{AssociatedKPIs})){

        for my $TypeExport (@{$JobData{TypeExport}}){

            for my $KPIID (@{$JobData{AssociatedKPIs}}){

                my $KPIDataGet = $KPIObject->KPIGet(
                    ID => $KPIID, 
                    ValidID => 1 
                );

                my %DataExportOfKPI = $Self->_KPIGetReturn( 
                    KPIID => $KPIID,
                    KPIType => $KPIDataGet->{ObjectType},
                    TypeExport => $TypeExport,
                    Prefix   => $JobData{Prefix},
                    %{$KPIDataGet}
                );

                push @ReturnData, \%DataExportOfKPI;         
            }

        }
        
    }

    if(IsArrayRefWithData($JobData{AssociatedStats})){

        $Self->AddOption(
            Name => 'timezone',
            Description =>
                "Target time zone (e.g. Europe/Berlin) for which the file should be generated.",
            Required   => 0,
            HasValue   => 1,
            ValueRegex => qr/.*/smx,
        );

        for my $TypeExport (@{$JobData{TypeExport}}){

            for my $StatsID (@{$JobData{AssociatedStats}}){
            
                my %DataExportOfStat = $Self->_StatsGetReturn( 
                    StatID   => $StatsID,
                    Prefix   => $JobData{Prefix},   
                    TypeExport => $TypeExport,            
                );

                push @ReturnData, \%DataExportOfStat;         
            }
        }

    }

    # Get the template data
    my %StandardTemplateData = $StandardTemplateObject->StandardTemplateGet( ID => $JobData{TemplateKPIID} );

    # Send the email
    my $To = join( ',', @EmailsOfAgentsToSend);

    my $Sent = $EmailObject->Send(
        From          => $ConfigObject->Get('AdminEmail'),
        To            => $To,
        Subject       => $StandardTemplateData{Name},
        Charset       => 'utf-8',
        MimeType      => 'text/html',
        Body          => $StandardTemplateData{Template},
        Attachment    => \@ReturnData,
    );

    # save last execution
    $KPIObject->JobLastExecution( Name => $JobData{Name}, Obs => '(AT)' );

    return 1;
}

sub _StatsGetReturn {
    my ( $Self, %Param ) = @_;

    my $CurSysDTObject = $Kernel::OM->Create('Kernel::System::DateTime');
    my $ConfigObject   = $Kernel::OM->Get('Kernel::Config');

    my $DirectoryToSaveKPIScheduler = $ConfigObject->Get('KPI::Core::DirectoryToSaveKPIScheduler');
    my %GetParam;

    my $Stat = $Kernel::OM->Get('Kernel::System::Stats')->StatsGet(
        StatID => $Param{StatID},
        UserID => 1,
    );

    my ( $s, $m, $h, $D, $M, $Y ) = $Kernel::OM->Get('Kernel::System::Time')->SystemTime2Date(
        SystemTime => $Kernel::OM->Get('Kernel::System::Time')->SystemTime(),
    );
    
    $M = sprintf( "%02d", $M );
    $D = sprintf( "%02d", $D );
    $h = sprintf( "%02d", $h );
    $m = sprintf( "%02d", $m );

    my $FileName  = $Param{Prefix} . '_' . $Stat->{StatNumber} . '_' . "$Y-$M-$D" . "_" . "$h:$m";

    if ( $Stat->{StatType} eq 'static' ) {
        $GetParam{Year}  = $CurSysDTObject->Get()->{Year};
        $GetParam{Month} = $CurSysDTObject->Get()->{Month};
        $GetParam{Day}   = $CurSysDTObject->Get()->{Day};

        # get params from -p
        # only for static files
        my $Params = $Kernel::OM->Get('Kernel::System::Stats')->GetParams(
            StatID => $Param{StatID},
            UserID => 1,
        );
        
        for my $ParamItem ( @{$Params} ) {
            if ( !$ParamItem->{Multiple} ) {
                my $Value = $Self->GetParam(
                    Param  => $ParamItem->{Name},
                    Params => $Self->{Params}
                );
                if ( defined $Value ) {
                    $GetParam{ $ParamItem->{Name} } =
                        $Self->GetParam(
                        Param  => $ParamItem->{Name},
                        Params => $Self->{Params},
                        );
                }
                elsif ( defined $ParamItem->{SelectedID} ) {
                    $GetParam{ $ParamItem->{Name} } = $ParamItem->{SelectedID};
                }
            }
            else {
                my @Value = $Self->GetArray(
                    Param  => $ParamItem->{Name},
                    Params => $Self->{Params},
                );
                if (@Value) {
                    $GetParam{ $ParamItem->{Name} } = \@Value;
                }
                elsif ( defined $ParamItem->{SelectedID} ) {
                    $GetParam{ $ParamItem->{Name} } = [ $ParamItem->{SelectedID} ];
                }
            }
        }
    }
    elsif ( $Stat->{StatType} eq 'dynamic' ) {
        %GetParam = %{$Stat};

        # overwrite the default stats timezone with the given timezone
        my $TimeZone = $Self->GetOption('timezone');
        if ( defined $TimeZone && length $TimeZone ) {
            $GetParam{TimeZone} = $TimeZone;
        }
    }

    # run stat...
    my @StatArray = @{
        $Kernel::OM->Get('Kernel::System::Stats')->StatsRun(
            StatID   => $Param{StatID},
            GetParam => \%GetParam,
            UserID   => 1,
        )
    };

    # generate output
    my $TitleArrayRef  = shift(@StatArray);
    my $Title          = $TitleArrayRef->[0];
    my $HeadArrayRef   = shift(@StatArray);
    my $CountStatArray = @StatArray;
    my $Time           = $CurSysDTObject->ToString();
    my @WithHeader;

    if ( !@StatArray ) {
        push( @StatArray, [ ' ', 0 ] );
    }

    my %Attachment;

    if ( $Param{TypeExport} eq 'Excel' ) {

        # Create the Excel data
        my $Output = $Kernel::OM->Get('Kernel::System::CSV')->Array2CSV(
            WithHeader => \@WithHeader,
            Head       => $HeadArrayRef,
            Data       => \@StatArray,
            Format     => 'Excel',
        );

        # save the Excel with the title and timestamp as filename, or read it from param
        %Attachment = (
            Filename    => $FileName . ".xlsx",
            ContentType => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            Content     => $Output,
            Encoding    => "base64",
            Disposition => "attachment",
        );
    }
    # elsif ($Param{TypeExport} eq 'PDF') {

    #     my $PDFString = $Kernel::OM->Get('Kernel::Output::PDF::Statistics')->GeneratePDF(
    #         Stat         => $Stat,
    #         Title        => $Title,
    #         HeadArrayRef => $HeadArrayRef,
    #         StatArray    => \@StatArray,
    #         TimeZone     => $GetParam{TimeZone},
    #     );

    #     # save the pdf with the title and timestamp as filename, or read it from param
    #     %Attachment = (
    #         Filename    => $FileName . ".pdf",
    #         ContentType => "application/pdf",
    #         Content     => $PDFString,
    #         Encoding    => "base64",
    #         Disposition => "attachment",
    #     );
    # }
   
    my $SuccessSaveFile = $Kernel::OM->Get('Kernel::System::Main')->FileWrite(
        Location => "$DirectoryToSaveKPIScheduler/$Attachment{Filename}",
        Content  => \$Attachment{Content},
        Mode     => 'binmode',
    );

    return %Attachment;

}

sub _KPIGetReturn {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $KPIObject    = $Kernel::OM->Get('Kernel::System::KPI');

    my $DirectoryToSaveKPIScheduler = $ConfigObject->Get('KPI::Core::DirectoryToSaveKPIScheduler');
    my ( $s, $m, $h, $D, $M, $Y ) = $Kernel::OM->Get('Kernel::System::Time')->SystemTime2Date(
        SystemTime => $Kernel::OM->Get('Kernel::System::Time')->SystemTime(),
    );
    
    $M = sprintf( "%02d", $M );
    $D = sprintf( "%02d", $D );
    $h = sprintf( "%02d", $h );
    $m = sprintf( "%02d", $m );

    my $FileName  = $Param{Prefix} . '_' . $Param{Name} . '_' . "$Y-$M-$D" . "_" . "$h:$m";

    my %HashOfContents;
    my %Result;
    
    if( ($Param{KPIType} eq 'SQL Query') || ($Param{KPIType} eq 'ChartSQLQuery') ){

        %Result = $KPIObject->GetSearchSQL(
            KPIData   => \%Param,
        );
    
    }
    elsif($Param{KPIType} eq 'Ticket'){

        %Result = $KPIObject->GetSearch(
            KPIData   => \%Param,
            UserID    => 1
        );
                    
    }
    elsif($Param{KPIType} eq 'Survey'){
        %Result = $KPIObject->GetSearchSurvey(
            KPIData   => \%Param,
            UserID    => 1
        );
    }

    if($Param{TypeExport} eq 'Excel'){

        # get Separator from language file
        my $UserCSVSeparator = $LayoutObject->{LanguageObject}->{Separator};

        if ( $ConfigObject->Get('PreferencesGroups')->{CSVSeparator}->{Active} ) {
            my %UserData = $Kernel::OM->Get('Kernel::System::User')->GetUserData( UserID => 1 );
            $UserCSVSeparator = $UserData{UserCSVSeparator} if $UserData{UserCSVSeparator};
        }

        # get CSV object
        my $CSVObject = $Kernel::OM->Get('Kernel::System::CSV');

        my $ExcelTicket = $CSVObject->Array2CSV(
            Head   => $Result{Head},
            Data   => $Result{Data},
            Format => 'Excel',
        );

        %HashOfContents = (
            Filename    => "$FileName" . ".xlsx",
            Content     => $ExcelTicket,
            ContentType => "text/csv"
        );

    }

    
    if( $Param{TypeExport} eq 'HTML' ){

        my $HTMLTicket = $Self->_GenerateHTML(
            Head   => $Result{Head},
            Data   => $Result{Data},
        );

        %HashOfContents = (
            Filename    => "$FileName" . ".html",
            Content     => $HTMLTicket,
            ContentType => 'application/octet-stream',
        );
        
    }
    # elsif($Param{TypeExport} eq 'PDF'){
        
    #     my $PDFStringTicket = $Self->_GeneratePDF(
    #         Title        => $FileName,
    #         HeadArrayRef => $Result{Head},
    #         DataArray    => $Result{Data},
    #         UserID       => $Self->{UserID},
    #     );

    #     %HashOfContents = (
    #         Filename    => "$FileName" . ".pdf",
    #         Content     => $PDFStringTicket,
    #         ContentType => 'application/pdf',
    #     );
    # }

    # To save the file in backend directory
    my $SuccessSaveFileKPI = $Kernel::OM->Get('Kernel::System::Main')->FileWrite(
        Location => "$DirectoryToSaveKPIScheduler/$HashOfContents{Filename}",
        Content  => \$HashOfContents{Content},
        Mode     => 'binmode',
    );

    return %HashOfContents;
}

sub _GenerateHTML {

    my ( $Self, %Param ) = @_;

    my @HeadArray = @{ $Param{Head} // [] };
    my @DataArray = @{ $Param{Data} // [] };

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $Columns = $ConfigObject->Get('KPI::Core::ColumnsHTMLExport');
    
    my @FilterHead;

    if( scalar @{$Columns} > 0 ){

        my %NumberHead;

        for ( my $i=0; $i <= scalar(@HeadArray); $i++ ){

            $NumberHead{ $HeadArray[$i] } = $i+1;

        }

        my %HashHead = map { $_ => 1 } @HeadArray;
        for my $Item ( @{$Columns} ){

            my $ItemTranslate = $LayoutObject->{LanguageObject}->Translate($Item);

            if( $Item eq 'TicketNumber' ){
                
                $ItemTranslate = $LayoutObject->{LanguageObject}->Translate('Ticket Number');
            
                my %Key = ( $ItemTranslate => $NumberHead{$ItemTranslate} );

                push (@FilterHead, \%Key);
            }
            elsif( $Item eq 'CustomerName' ){

                $ItemTranslate = $LayoutObject->{LanguageObject}->Translate('Customer Realname');

                my %Key = ( $ItemTranslate => $NumberHead{$ItemTranslate} );
                push (@FilterHead, \%Key);
            }
            elsif( exists( $HashHead{$ItemTranslate} ) ){

                my %Key = ( $ItemTranslate => $NumberHead{$ItemTranslate} );
                push (@FilterHead, \%Key);
            }

        }
    }
    else{


        for ( my $i=0; $i <= scalar(@HeadArray); $i++ ){

            my %Item = ( $HeadArray[$i] => $i+1 );
            
            push (@FilterHead, \%Item);
        }

    }
  
    for my $ColumnName ( @FilterHead ) {
 
        $LayoutObject->Block(
            Name => 'TicketListHeadTemplate',
            Data => { 'ColumnName' => keys %{$ColumnName} },
        );
    }

    for my $ItemArray ( @DataArray ){

        $LayoutObject->Block(
            Name => 'TicketRow',
        );
    
        for my $ColumnName ( @FilterHead ){
            
            my %Name = ( Name => keys %{$ColumnName} );
        
            my $Position = $ColumnName->{  $Name{Name} };

            $LayoutObject->Block(
                Name => 'TicketRowContent',
                Data => { 'TicketRowItem' => $ItemArray->[$Position-1] }
            );

        } 
    }
    
    
    my $HtmlContent = $LayoutObject->Output(
        TemplateFile => 'AgentKPISchedulerExport',
    );
    
    return $HtmlContent;
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
    for my $Content ( @HeadArrayRef ) {
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
        Encode => $LayoutObject->{UserCharset},
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
