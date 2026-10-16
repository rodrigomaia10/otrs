# --
# Custom/Kernel/System/ServiceTemplate.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * nfreitas@serviceup.com.br
# --

package Kernel::System::ServiceTemplate;

use strict;
use warnings;

use Kernel::System::VariableCheck (qw(:all));

our @ObjectDependencies = (
    'Kernel::System::Cache',
    'Kernel::System::CheckItem',
    'Kernel::System::Log',
    'Kernel::System::Valid',
);

=head1 NAME

Kernel::System::ServiceTemplate - service template lib

=head1 DESCRIPTION

All service template functions.

=head1 PUBLIC INTERFACE

=head2 new()

create an object

    my $ServiceTemplateObject = $Kernel::OM->Get('Kernel::System::ServiceTemplate');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{CacheType} = 'ServiceTemplate';
    $Self->{CacheTTL}  = 60 * 60 * 24 * 20;

    return $Self;
}

=head2 ServiceTemplateGet()

    return a service template as hash

    my %TemplateData = $ServiceTemplateObject->ServiceTemplateGet(
        TemplateID => 123,
        UserID     => 1,
    );

    Return
    $TemplateData{ID}
    $TemplateData{Name}
    $TemplateData{Subject}
    $TemplateData{Response}
    $TemplateData{ContentType}
    $TemplateData{ValidID}
    $TemplateData{Comment}
    $TemplateData{CreateTime}
    $TemplateData{CreateBy}
    $TemplateData{ChangeTime}
    $TemplateData{ChangeBy}


=cut

sub ServiceTemplateGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(TemplateID UserID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # check cached results
    my $CacheKey = 'Cache::ServiceTemplateGet::' . $Param{TemplateID};
    my $Cache    = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $Self->{CacheType},
        Key  => $CacheKey,
    );
    return %{$Cache} if ref $Cache eq 'HASH';

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get service from db
    return if !$DBObject->Prepare(
        SQL => 'SELECT * FROM service_template WHERE id = ?',
        Bind  => [ \$Param{TemplateID} ],
        Limit => 1,
    );

    # fetch the result
    my %TemplateData;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $TemplateData{ID}          = $Row[0];
        $TemplateData{Name}        = $Row[1];
        $TemplateData{Subject}     = $Row[2];
        $TemplateData{Response}    = $Row[3];
        $TemplateData{ContentType} = $Row[4];
        $TemplateData{ValidID}     = $Row[5];
        $TemplateData{Comment}     = $Row[6] || '';
        $TemplateData{CreateTime}  = $Row[7];
        $TemplateData{CreateBy}    = $Row[8];
        $TemplateData{ChangeTime}  = $Row[9];
        $TemplateData{ChangeBy}    = $Row[10];
    }

    # check service
    if ( !$TemplateData{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "No such ID ($Param{TemplateID})!",
        );
        return;
    }

    # set cache
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $Self->{CacheType},
        TTL   => $Self->{CacheTTL},
        Key   => $CacheKey,
        Value => \%TemplateData,
    );

    return %TemplateData;
}

=head2 ServiceList()

    return a ServiceID list as ref array

    Return
    @ServiceList = [ 1, 2, 3 ]

    my @ServiceList = $ServiceTemplateObject->ServiceList(
        TemplateID      => 123,
    );

=cut

sub ServiceList {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{TemplateID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need TemplateID!",
        );
        return;
    }

    # check cached results
    my $CacheKey = 'Cache::ServiceList::' . $Param{TemplateID};
    my $Cache    = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $Self->{CacheType},
        Key  => $CacheKey,
    );
    return @{$Cache} if ref $Cache eq 'ARRAY';

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get service from db
    return if !$DBObject->Prepare(
        SQL =>
            'SELECT service_id FROM service_template_link WHERE template_id = ?',
        Bind  => [ \$Param{TemplateID} ],
    );

    # fetch the result
    my @ServiceList;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        push @ServiceList, $Row[0];
    }

    # check service
    # if ( !@ServiceList ) {
    #     $Kernel::OM->Get('Kernel::System::Log')->Log(
    #         Priority => 'error',
    #         Message  => "No such TemplateID ($Param{TemplateID})!",
    #     );
    #     return;
    # }

    # set cache
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $Self->{CacheType},
        TTL   => $Self->{CacheTTL},
        Key   => $CacheKey,
        Value => \@ServiceList,
    );

    return @ServiceList;
}

=head2 TemplateList()

    return a service template list as ref array

    Return
    @List = [ 1, 2, 3 ]

    my @List = $ServiceTemplateObject->TemplateList(
        Valid => 1 | 0, # optional default( all )
    );

=cut

sub TemplateList {
    my ( $Self, %Param ) = @_;

    my %ValidList = (
        0 => 'Invalid',
        1 => 'Valid',
        2 => 'All'
    );

    my $Valid = $Param{ValidID} || 2;

    # check cached results
    my $CacheKey = 'Cache::TemplateList::' . $ValidList{$Valid};
    my $Cache    = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $Self->{CacheType},
        Key  => $CacheKey,
    );
    return @{$Cache} if ref $Cache eq 'ARRAY';

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    if($Valid != 2){
        # get service from db
        return if !$DBObject->Prepare(
            SQL =>
                'SELECT id FROM service_template WHERE valid_id = ?',
            Bind  => [ \$Param{ValidID} ],
        );
    }
    else{
        # get service from db
        return if !$DBObject->Prepare(
            SQL =>
                'SELECT id FROM service_template',
        );
    }

    # fetch the result
    my @TemplateList;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        push @TemplateList, $Row[0];
    }

    # set cache
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $Self->{CacheType},
        TTL   => $Self->{CacheTTL},
        Key   => $CacheKey,
        Value => \@TemplateList,
    );

    return @TemplateList;
}

=head2 ServiceTemplateAdd()

    add new template

    my $ID = $ServiceTemplateObject->ServiceTemplateAdd(
        Name        => 'New Service Template',
        ServiceID   => [1, 2, 3], # optional
        Subject     => 'New Subject',
        Response    => "--\nSome Service Template Infos",
        ContentType => 'text/plain' || 'charset=utf-8',
        Comment     => 'some comment',
        ValidID     => 1,
        UserID      => 123,
    );

    return 
    $TemplateID

=cut

sub ServiceTemplateAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(Name Subject Response ContentType ValidID UserID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # cleanup given params
    for my $Argument (qw(Name Subject Response Comment)) {
        $Kernel::OM->Get('Kernel::System::CheckItem')->StringClean(
            StringRef         => \$Param{$Argument},
            RemoveAllNewlines => 1,
            RemoveAllTabs     => 1,
        );
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # find existing service template
    return if !$DBObject->Prepare(
        SQL   => 'SELECT id FROM service_template WHERE name = ?',
        Bind  => [ \$Param{Name} ],
        Limit => 1,
    );

    my $Exists;
    while ( $DBObject->FetchrowArray() ) {
        $Exists = 1;
    }

    # add service to database
    if ($Exists) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "A service template with the name '$Param{Name}' already exists.",
        );
        return;
    }

    return if !$DBObject->Do(
        SQL => 'INSERT INTO service_template (name, subject, response, content_type, valid_id, '
            . 'comments, create_time, create_by, change_time, change_by) '
            . 'VALUES (?, ?, ?, ?, ?, ?, current_timestamp, ?, current_timestamp, ?)',
        Bind => [
            \$Param{Name}, \$Param{Subject}, \$Param{Response}, \$Param{ContentType},
            \$Param{ValidID}, \$Param{Comment}, \$Param{UserID}, \$Param{UserID},
        ],
    );

    # get template id
    return if !$DBObject->Prepare(
        SQL   => 'SELECT id FROM service_template WHERE name = ?',
        Bind  => [ \$Param{Name} ],
        Limit => 1,
    );

    my $TemplateID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $TemplateID = $Row[0];
    }

    $Param{ServiceID} = $Param{ServiceID} || [];

    if($TemplateID && ref $Param{ServiceID} eq 'ARRAY'){

        return if !$DBObject->Prepare(
                SQL =>
                'SELECT id, name FROM service WHERE valid_id = 1 AND id NOT IN
                (SELECT SL.service_id FROM service_template_link SL JOIN service_template ST
                    ON SL.template_Id = ST.id WHERE ST.valid_id = 1)',
        );

        # fetch the result
        my @ValidServiceList;
        while ( my @Row = $DBObject->FetchrowArray() ) {           
            push @ValidServiceList, $Row[0];
        }

        for my $ServiceID (@{ $Param{ServiceID} }){
            # if($ServiceID ~~ @ValidServiceList){
            if (grep { $_ eq $ServiceID } @ValidServiceList) {
                return if !$DBObject->Do(
                    SQL => 'INSERT INTO service_template_link (template_id, service_id) VALUES (?, ?)',
                    Bind => [ \$TemplateID, \$ServiceID ],
                );
            }
        }
    }

    # reset cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => $Self->{CacheType},
    );

    return $TemplateID;
}

=head2 ServiceTemplateUpdate()

    update service template

    my $ID = $ServiceTemplateObject->ServiceTemplateUpdate(
        ID          => 123, # TemplateID
        Name        => 'New Service Template',
        ServiceID   => [1, 2, 3], # optional
        Subject     => 'New Subject',
        Response    => "--\nSome Service Template Infos",
        ContentType => 'text/plain' || 'charset=utf-8',
        Comment     => 'some comment',
        ValidID     => 1,
        UserID      => 123,
    );

=cut

sub ServiceTemplateUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(ID Name Subject Response ContentType ValidID UserID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # cleanup given params
    for my $Argument (qw(Name Subject Response Comment)) {
        $Kernel::OM->Get('Kernel::System::CheckItem')->StringClean(
            StringRef         => \$Param{$Argument},
            RemoveAllNewlines => 1,
            RemoveAllTabs     => 1,
        );
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Do(
        SQL => 'UPDATE service_template SET name = ?, subject = ?, response = ?, content_type = ?, valid_id = ?, '
             . 'comments = ?, change_time = current_timestamp, change_by = ? WHERE id =  ?',
        Bind => [
            \$Param{Name}, \$Param{Subject}, \$Param{Response}, \$Param{ContentType},
            \$Param{ValidID}, \$Param{Comment}, \$Param{UserID}, \$Param{ID},
        ],
    );

   
    $Param{ServiceID} = $Param{ServiceID} || [];

    if( ref $Param{ServiceID} eq 'ARRAY' ){

        return if !$DBObject->Do(
            SQL => 'DELETE FROM service_template_link WHERE template_id = ?',
            Bind => [ \$Param{ID} ],
        );
        
        return if !$DBObject->Prepare(
            SQL =>
                'SELECT id, name FROM service WHERE valid_id = 1 AND id NOT IN
                (SELECT SL.service_id FROM service_template_link SL JOIN service_template ST
                    ON SL.template_Id = ST.id WHERE ST.valid_id = 1)',
        );

        # fetch the result
        my @ValidServiceList;
        while ( my @Row = $DBObject->FetchrowArray() ) {           
            push @ValidServiceList, $Row[0];
        }

        for my $ServiceID (@{ $Param{ServiceID} }){
            if (grep { $_ eq $ServiceID } @ValidServiceList) {
            # if($ServiceID ~~ @ValidServiceList){
                
                return if !$DBObject->Do(
                    SQL => 'INSERT INTO service_template_link (template_id, service_id) VALUES (?, ?)',
                    Bind => [ \$Param{ID}, \$ServiceID ],
                );
            }
            
        }
    }

    # reset cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => $Self->{CacheType},
    );

    return 1;
}

=head2 ValidServiceList()

    returns a list of valid services as hash

    Return
    %ServiceList = {
        1 => 'Service 1',
        2 => 'Service 2',
        3 => 'Service 3'
     }

    my %ServiceList = $ServiceTemplateObject->ValidServiceList(
        TemplateID => 1,
    );

=cut

sub ValidServiceList {
    my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    if($Param{TemplateID} ne 'NEW'){

        return if !$DBObject->Prepare(
            SQL => 'SELECT S.id, S.name FROM service S LEFT JOIN  service_template_link SL ON S.id = SL.service_id WHERE SL.template_id = ? OR SL.template_id IS NULL',
            Bind  => [ \$Param{TemplateID} ],
        );

    }
    else{

        return if !$DBObject->Prepare(
            SQL =>
                'SELECT id, name FROM service WHERE valid_id = 1 AND id NOT IN
            	(SELECT SL.service_id FROM service_template_link SL JOIN service_template ST
            		ON SL.template_Id = ST.id WHERE ST.valid_id = 1)',
        );
    }

    # fetch the result
    my %ValidServiceList;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $ValidServiceList{$Row[0]} = $Row[1];
    }

    return %ValidServiceList;
}

=head2 TemplateGetByService()

    return a service template as hash

    Return
    $TemplateData{ID}
    $TemplateData{Name}
    $TemplateData{Subject}
    $TemplateData{Response}
    $TemplateData{ContentType}
    $TemplateData{ValidID}
    $TemplateData{Comment}
    $TemplateData{CreateTime}
    $TemplateData{CreateBy}
    $TemplateData{ChangeTime}
    $TemplateData{ChangeBy}

    my %TemplateData = $ServiceTemplateObject->TemplateGetByService(
        ServiceID => 123,
        UserID     => 1,
    );

=cut

sub TemplateGetByService {
    my ( $Self, %Param ) = @_;

    # check cached results
    my $CacheKey = 'Cache::TemplateGetByService::' . $Param{ServiceID};
    my $Cache    = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $Self->{CacheType},
        Key  => $CacheKey,
    );
    return %{$Cache} if ref $Cache eq 'HASH';

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # check needed stuff
    for my $Argument (qw(ServiceID UserID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # get service from db
    return if !$DBObject->Prepare(
        SQL => 'SELECT * FROM service_template WHERE id =
               ( SELECT template_id FROM service_template_link WHERE service_id = ? )',
        Bind  => [ \$Param{ServiceID} ],
        Limit => 1,
    );

    # fetch the result
    my %TemplateData;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $TemplateData{ID}          = $Row[0];
        $TemplateData{Name}        = $Row[1];
        $TemplateData{Subject}     = $Row[2];
        $TemplateData{Response}    = $Row[3];
        $TemplateData{ContentType} = $Row[4];
        $TemplateData{ValidID}     = $Row[5];
        $TemplateData{Comment}     = $Row[6] || '';
        $TemplateData{CreateTime}  = $Row[7];
        $TemplateData{CreateBy}    = $Row[8];
        $TemplateData{ChangeTime}  = $Row[9];
        $TemplateData{ChangeBy}    = $Row[10];
    }

    # check service
    if ( !$TemplateData{ID} ) {      
        return;
    }

    # set cache
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $Self->{CacheType},
        TTL   => $Self->{CacheTTL},
        Key   => $CacheKey,
        Value => \%TemplateData,
    );

    return %TemplateData;
}

=head2 ServiceTemplateListGet()

    get an template list with all template details
    
    my $List = $ServiceTemplateObject->ServiceTemplateListGet(
        UserID   => 1,
    );

    return 
    \@ArrayRef;

=cut

sub ServiceTemplateListGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{UserID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need UserID!',
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
    my $ServiceObject = $Kernel::OM->Get('Kernel::System::Service');

    my $SQL = 'SELECT id FROM service_template ORDER BY id';

    # SQL
    return if !$DBObject->Prepare(
        SQL => $SQL,
    );

    my @TemplatesIDs;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        push @TemplatesIDs, $Row[0];
    }

    my @Data;
    for my $ItemID (@TemplatesIDs) {

        my %TemplateData = $Self->ServiceTemplateGet(
            TemplateID  => $ItemID,
            UserID => 1,
        );

        my @SelectedServices =  $Self->ServiceList(
            TemplateID => $ItemID,
        );

        my @NameOfServices;
        for my $ServiceID ( @SelectedServices ){

            my $ServiceName = $ServiceObject->ServiceLookup(
                ServiceID => $ServiceID,
            );

            push @NameOfServices, $ServiceName;
        }

        $TemplateData{SelectedServices} =  \@NameOfServices;

        push @Data, \%TemplateData;
    }

    return \@Data;
}

=head2 ServiceTemplateImport()
    import an Service template YAML file/content
    my $ServiceTemplateImport = $ServiceTemplateObject->ServiceTemplateImport(
        Content                   => $YAMLContent, # mandatory, YAML format
        OverwriteExistingEntities => 0,            # 0 || 1
        UserID                    => 1,            # mandatory
    );
=cut

sub ServiceTemplateImport {
    my ( $Self, %Param ) = @_;

    my $ServiceObject = $Kernel::OM->Get('Kernel::System::Service');

    for my $Needed (qw(Content UserID)) {

        # check needed stuff
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return {
                Success => 0,
                Message => "$Needed is missing can not continue.",
            };
        }
    }

    my $ServiceTemplateDate = $Kernel::OM->Get('Kernel::System::YAML')->Load( Data => $Param{Content} );

    if ( ref $ServiceTemplateDate ne 'ARRAY' ) {
        return {
            Success => 0,
            Message => Translatable("Couldn't read service template configuration file. Please make sure the file is valid."),
        };
    }

    my @UpdatedTemplates;
    my @AddedTemplates;
    my @TemplatesErrors;

    SERVICETEMPLATE:
    for my $ServiceTemplate ( @{$ServiceTemplateDate} ) {

        next SERVICETEMPLATE if !$ServiceTemplate;
        next SERVICETEMPLATE if ref $ServiceTemplate ne 'HASH';

        $ServiceTemplate = $Self->_ServiceTemplateMigrateFrom33(
            ServiceTemplate    => $ServiceTemplate,
            UserID => $Param{UserID},
        );

        my @ExistingServiceTemplates = @{ $Self->ServiceTemplateListGet( UserID => $Param{UserID} ) || [] };
        @ExistingServiceTemplates = grep { $_->{Name} eq $ServiceTemplate->{Name} } @ExistingServiceTemplates;

        if ( $Param{OverwriteExistingEntities} && $ExistingServiceTemplates[0] ) {

            # To import the services by id
            my @IDsOfServices;
            for my $ServiceName ( @{$ServiceTemplate->{SelectedServices}} ){

                my $ServiceID = $ServiceObject->ServiceLookup(
                    Name => $ServiceName,
                );

                if($ServiceID){

                    push @IDsOfServices, $ServiceID;

                }
                else{
                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'error',
                        Message  => "No such Service with name ( $ServiceName )!",
                    );    
                }             
            }
            
            my $Success = $Self->ServiceTemplateUpdate(
                %{ $ExistingServiceTemplates[0] },
                %{$ServiceTemplate},
                ServiceID => \@IDsOfServices,
                UserID    => $Param{UserID},
            );

            if ($Success) {
                push @UpdatedTemplates, $ServiceTemplate->{Name};
            }
            else {
                push @TemplatesErrors, $ServiceTemplate->{Name};
            }

        }
        else {
            # To import the services by id
            my @IDsOfServices;
            for my $ServiceName ( @{$ServiceTemplate->{SelectedServices}} ){

                my $ServiceID = $ServiceObject->ServiceLookup(
                    Name => $ServiceName,
                );

                if($ServiceID){

                    push @IDsOfServices, $ServiceID;

                }
                else{
                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'error',
                        Message  => "No such Service with name ( $ServiceName )!",
                    );    
                }             
            }
            # now add the ServiceTemplate
            my $Success = $Self->ServiceTemplateAdd(
                %{$ServiceTemplate},
                ServiceID => \@IDsOfServices,
                UserID    => $Param{UserID},
            );

            if ($Success) {
                push @AddedTemplates, $ServiceTemplate->{Name};
            }
            else {
                push @TemplatesErrors, $ServiceTemplate->{Name};
            }
        }
    }

    return {
        Success     => 1,
        AddedTemplates   => join( ', ', @AddedTemplates ) || '',
        UpdatedTemplates => join( ', ', @UpdatedTemplates ) || '',
        TemplatesErrors   => join( ', ', @TemplatesErrors ) || '',
    };
}

=head2 _ServiceTemplateMigrateFrom33()
    Updates Service Template structure my changing the Possible->Action hash ref to a PossibleNot->Action array ref
    with just the elements that where set to 0 in the original Service Template:
    $ServiceTemplate = $Self->_ServiceTemplateMigrateFrom33(
        ServiceTemplate    => $ServiceTemplate,
        UserID => $Param{UserID},
    );
=cut

sub _ServiceTemplateMigrateFrom33 {
    my ( $Self, %Param ) = @_;

    my $ServiceTemplate = $Param{ServiceTemplate};

    return $ServiceTemplate if !ref $ServiceTemplate->{ConfigChange};
    return $ServiceTemplate if !$ServiceTemplate->{ConfigChange}->{Possible}->{Action};
    return $ServiceTemplate if ref $ServiceTemplate->{ConfigChange}->{Possible}->{Action} ne 'HASH';

    # convert old hash into an array using only the keys set to 0, and skip those that are set
    # to 1, set them as PossibleNot and delete the Possible->Action section from the ServiceTemplate.
    my @NewAction = grep { $ServiceTemplate->{ConfigChange}->{Possible}->{Action}->{$_} == 0 }
        sort keys %{ $ServiceTemplate->{ConfigChange}->{Possible}->{Action} };

    delete $ServiceTemplate->{ConfigChange}->{Possible}->{Action};
    $ServiceTemplate->{ConfigChange}->{PossibleNot}->{Action} = \@NewAction;

    return $ServiceTemplate;
}


1;

=head1 TERMS AND CONDITIONS

This software is part of the Service Up plugin (L<http://www.serviceup.com.br>).

=cut
