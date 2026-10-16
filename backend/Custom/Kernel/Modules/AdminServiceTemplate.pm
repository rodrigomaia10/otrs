# --
# Custom/Kernel/Modules/AdminServiceTemplate.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * nfreitas@serviceup.com.br
# --

package Kernel::Modules::AdminServiceTemplate;

use strict;
use warnings;

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

    # get objects
    my $LayoutObject          = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $LogObject             = $Kernel::OM->Get('Kernel::System::Log');
    my $ParamObject           = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ServiceTemplateObject = $Kernel::OM->Get('Kernel::System::ServiceTemplate');

    # ------------------------------------------------------------ #
    # service template edit
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'ServiceTemplateEdit' ) {

        # header
        my $Output = $LayoutObject->Header();
        $Output   .= $LayoutObject->NavigationBar();

        # html output
        $Output .= $Self->_Edit(
            %Param,
        );
        $Output .= $LayoutObject->Footer();

        return $Output;
    }
    # ------------------------------------------------------------ #
    # service template save
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ServiceTemplateSave' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        # get params
        my %GetParam;
        for (qw(Name Subject Response ValidID Comment)) {
            $GetParam{$_} = $ParamObject->GetParam( Param => $_ ) || '';
        }

        # get params
        $GetParam{ID} = $ParamObject->GetParam( Param => "TemplateID" );
        my @Service = $ParamObject->GetArray( Param => 'ServiceID' );

        # get content type
        my $ContentType = 'text/plain';
        if ( $LayoutObject->{BrowserRichText} ) {
            $ContentType = 'text/html';
        }

        my %Error;

        if ( !$GetParam{Name} ) {
            $Error{'NameInvalid'} = 'ServerError';
        }

        if ( !%Error ) {

            # save to database
            if ( $GetParam{ID} eq 'NEW' ) {
                my $Success = $ServiceTemplateObject->ServiceTemplateAdd(
                    ServiceID   => \@Service,
                    ContentType => $ContentType,
                    UserID      => $Self->{UserID},
                    %GetParam
                );

                if ( !$Success ) {
                    $Error{Message} = $LogObject->GetLogEntry(
                        Type => 'Error',
                        What => 'Message',
                    );
                }
            }
            else{
                my $Success = $ServiceTemplateObject->ServiceTemplateUpdate(
                    ServiceID   => \@Service,
                    ContentType => $ContentType,
                    UserID      => $Self->{UserID},
                    %GetParam
                );

                if ( !$Success ) {
                    $Error{Message} = $LogObject->GetLogEntry(
                        Type => 'Error',
                        What => 'Message',
                    );
                }
            }

            # if the user would like to continue editing the service, just redirect to the edit screen
            if (
                defined $ParamObject->GetParam( Param => 'ContinueAfterSave' )
                && ( $ParamObject->GetParam( Param => 'ContinueAfterSave' ) eq '1' )
                )
            {
                my $ID = $ParamObject->GetParam( Param => 'TemplateID' ) || '';
                return $LayoutObject->Redirect(
                    OP => "Action=$Self->{Action};Subaction=ServiceTemplateEdit;TemplateID=$ID"
                );
            }
            else {

                # otherwise return to overview
                return $LayoutObject->Redirect( OP => "Action=$Self->{Action}" );
            }

        }

        # something went wrong
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $LayoutObject->Notify( Priority => 'Error' );

        # html output
        $Output .= $Self->_Edit(
            %Error,
            %GetParam,
            %Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }
    # ------------------------------------------------------------ #
    # service template export
    # ------------------------------------------------------------ #
    elsif( $Self->{Subaction} eq 'ServiceTemplateExport'){
        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_ServiceTemplateExport(
            %Param,
        );
    }
    # ------------------------------------------------------------ #
    # service template import
    # ------------------------------------------------------------ #
    elsif( $Self->{Subaction} eq 'ServiceTemplateImport'){
        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_ServiceTemplateImport(
            %Param,
        );
    }

    # ------------------------------------------------------------ #
    # overview
    # ------------------------------------------------------------ #
    return $Self->_Overview(
        %Param,
        Action => 'Overview',
    );

};

sub _ServiceTemplateImport {
    my ( $Self, %Param ) = @_;

    # Get Objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ServiceTemplateObject = $Kernel::OM->Get('Kernel::System::ServiceTemplate');

    my $FormID      = $ParamObject->GetParam( Param => 'FormID' ) || '';
    my %UploadStuff = $ParamObject->GetUploadAll(
        Param  => 'FileUpload',
        Source => 'string',
    );

    my $OverwriteExistingEntities = $ParamObject->GetParam( Param => 'OverwriteExistingEntities' ) || '';

    my $TemplateImport = $ServiceTemplateObject->ServiceTemplateImport(
        Content                   => $UploadStuff{Content},
        OverwriteExistingEntities => $OverwriteExistingEntities,
        UserID                    => $Self->{UserID},
    );

    if ( !$TemplateImport->{Success} ) {
        my $Message = $TemplateImport->{Message}
            || Translatable(
            'Service Templates could not be Imported due to a unknown error, please check OTRS logs for more information'
            );
        return $LayoutObject->ErrorScreen(
            Message => $Message,
        );
    }

    if ( $TemplateImport->{AddedTemplates} ) {
        push @{ $Param{NotifyData} }, {
            Info => $LayoutObject->{LanguageObject}->Translate(
                'The following Service Templates have been added successfully: %s',
                $TemplateImport->{AddedTemplates}
            ),
        };
    }
    if ( $TemplateImport->{UpdatedTemplates} ) {
        push @{ $Param{NotifyData} }, {
            Info => $LayoutObject->{LanguageObject}->Translate(
                'The following Service Templates have been updated successfully: %s',
                $TemplateImport->{UpdatedTemplates}
            ),
        };
    }
    if ( $TemplateImport->{TemplatesErrors} ) {
        push @{ $Param{NotifyData} }, {
            Priority => 'Error',
            Info     => $LayoutObject->{LanguageObject}->Translate(
                'There where errors adding/updating the following Service Templates: %s. Please check the log file for more information.',
                $TemplateImport->{TemplatesErrors}
            ),
        };
    }

    return $Self->_Overview(
        %Param,
        Action => 'Overview',
    );
}

sub _ServiceTemplateExport {
    my ( $Self, %Param ) = @_;

    my $LayoutObject          = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject           = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ServiceTemplateObject = $Kernel::OM->Get('Kernel::System::ServiceTemplate');
    my $ServiceObject         = $Kernel::OM->Get('Kernel::System::Service');

    my $ServiceTemplateID = $ParamObject->GetParam( Param => 'ID' ) || '';
    my $TemplateData;
    my %TemplateSingleData;
    my $Filename = 'Export_ServiceTemplate.yml';

    if ($ServiceTemplateID) {

        %TemplateSingleData = $ServiceTemplateObject->ServiceTemplateGet(
            TemplateID => $ServiceTemplateID,
            UserID     => 1,
        );

        my @SelectedServices = $ServiceTemplateObject->ServiceList(
            TemplateID => $ServiceTemplateID,
        );

        # To export the services by name
        my @NameOfServices;
        for my $ServiceID ( @SelectedServices ){

            my $ServiceName = $ServiceObject->ServiceLookup(
                ServiceID => $ServiceID,
            );

            push @NameOfServices, $ServiceName;
        }

        $TemplateSingleData{SelectedServices} =  \@NameOfServices;
        
        if ( !%TemplateSingleData ) {
            return $LayoutObject->ErrorScreen(
                Message => $LayoutObject->{LanguageObject}
                    ->Translate( 'There was an error getting data for service template with ID %s', $ServiceTemplateID ),
            );
        }

        my $TemplateName = $TemplateSingleData{Name};
        $TemplateName =~ s{[^a-zA-Z0-9-_]}{_}xmsg;    # cleanup name for saving

        $Filename = 'Export_ServiceTemplate_' . $TemplateName . '.yml';
        $TemplateData  = [\%TemplateSingleData];
    }
    else {

        $TemplateData = $ServiceTemplateObject->ServiceTemplateListGet(
            UserID   => 1,
        );

    }

    # convert the Service Template data hash to string
    my $TemplateDataYAML = $Kernel::OM->Get('Kernel::System::YAML')->Dump( Data => $TemplateData );

    # send the result to the browser
    return $LayoutObject->Attachment(
        ContentType => 'text/html; charset=' . $LayoutObject->{Charset},
        Content     => $TemplateDataYAML,
        Type        => 'attachment',
        Filename    => $Filename,
        NoCache     => 1,
    );
}

sub _Edit {
    my ($Self, %Param) = @_;

    # get object
    my $LayoutObject          = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject           = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ServiceTemplateObject = $Kernel::OM->Get('Kernel::System::ServiceTemplate');
    my $ValidObject           = $Kernel::OM->Get('Kernel::System::Valid');

    my %TemplateData;
    my @SelectedServices;

    my $Output;

    # get params
    $TemplateData{ID} = $ParamObject->GetParam( Param => "TemplateID" );
    if ( $TemplateData{ID} ne 'NEW' ) {
        %TemplateData = $ServiceTemplateObject->ServiceTemplateGet(
            TemplateID => $TemplateData{ID},
            UserID     => $Self->{UserID},
        );

        @SelectedServices = $ServiceTemplateObject->ServiceList(
            TemplateID => $TemplateData{ID},
        );
    }

    # output overview
    $LayoutObject->Block(
        Name => 'Overview',
        Data => {
            ID   => $TemplateData{ID},
            Name => $TemplateData{Name},
            %Param,
        },
    );

    $LayoutObject->Block( Name => 'ActionList' );
    $LayoutObject->Block( Name => 'ActionOverview' );

    my %ServiceList = $ServiceTemplateObject->ValidServiceList(
        TemplateID   => $TemplateData{ID},        
    );

    # check if service is enabled to use it here
    if ( !%ServiceList ) {
        $Output .= $LayoutObject->Notify(
            Priority => 'Error',
            Data     => $LayoutObject->{LanguageObject}->Translate( "There is no available %s!", "Service" ),
        );
    }

    $TemplateData{ServiceOptionStrg} = $LayoutObject->BuildSelection(
        Data           => \%ServiceList,
        Name           => 'ServiceID',
        SelectedID     => \@SelectedServices,
        Multiple       => 1,
        PossibleNone   => 1,
        TreeView       => 1,
        DisabledBranch => $TemplateData{Name},
        Translation    => 0,
        Class          => 'Modernize',
    );

    $LayoutObject->SetRichTextParameters(
        Data => \%Param,
    );

    # get valid list
    my %ValidList        = $ValidObject->ValidList();
    my %ValidListReverse = reverse %ValidList;

    $TemplateData{ValidOptionStrg} = $LayoutObject->BuildSelection(
        Data       => \%ValidList,
        Name       => 'ValidID',
        SelectedID => $TemplateData{ValidID} || $ValidListReverse{valid},
        Class      => 'Modernize',
    );

    # output service edit
    $LayoutObject->Block(
        Name => 'ServiceTemplateEdit',
        Data => { %Param, %TemplateData, },
    );

    # generate output
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AdminServiceTemplate',
        Data         => \%Param
    );

    return $Output;
}

sub _Overview {
    my ( $Self, %Param ) = @_;

    # get object
    my $LayoutObject          = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ServiceTemplateObject = $Kernel::OM->Get('Kernel::System::ServiceTemplate');

    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

    $LayoutObject->Block(
        Name => 'Overview',
        Data => { %Param, },
    );

    # show notifications if any
    if ( $Param{NotifyData} ) {
        for my $Notification ( @{ $Param{NotifyData} } ) {
            $Output .= $LayoutObject->Notify(
                %{$Notification},
            );
        }
    }

    # no actions in action list
    $LayoutObject->Block( Name => 'ActionList' );
    $LayoutObject->Block( Name => 'ActionAdd' );
    $LayoutObject->Block( Name => 'Filter' );

    # output overview result
    $LayoutObject->Block(
        Name => 'OverviewList',
        Data => { %Param, },
    );

    # get templates list
    my @TemplateList = $ServiceTemplateObject->TemplateList();

    if(scalar @TemplateList){

        for my $TemplateID (@TemplateList){

            my %TemplateData = $ServiceTemplateObject->ServiceTemplateGet(
                TemplateID => $TemplateID,
                UserID     => $Self->{UserID}
            );

            # get valid list
            my %ValidList = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();

            # output row
            $LayoutObject->Block(
                Name => 'OverviewListRow',
                Data => {
                    %TemplateData,
                    Valid => $ValidList{ $TemplateData{ValidID} },
                },
            );
        }
    }
    else {
        $LayoutObject->Block(
            Name => 'NoDataFoundMsg',
            Data => {},
        );
    }

    $Output .= $LayoutObject->Output(
        TemplateFile => 'AdminServiceTemplate',
        Data         => \%Param,
    );

    $Output .= $LayoutObject->Footer();
    return $Output;

}

1;