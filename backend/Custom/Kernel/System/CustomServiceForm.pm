# --
# Kernel/System/CustomServiceForm.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * jsantos@serviceup.com.br
# * ccresencio@serviceup.com.br
# * nfreitas@serviceup.com.br
# --

package Kernel::System::CustomServiceForm;

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

Kernel::System::CustomServiceForm

=head1 SYNOPSIS

All Service Form Management module functions.

=head1 PUBLIC INTERFACE

=head2 new()

create an object

    my $CustomFormObject = $Kernel::OM->Get('Kernel::System::CustomServiceForm');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{CacheType} = 'CustomServiceForm';
    $Self->{CacheTTL}  = 60 * 60 * 24 * 20;

    return $Self;
}

=head2 CustomFormList()

return a custom form list as hash

Return
    %List = {
        1 => 'Custom Form 1',
        2 => 'Custom Form 2',
    }

    my %List = $CustomFormObject->CustomFormList(
        Valid => 1 | 0, # optional default( all )
    );

=cut

sub CustomFormList {
    my ( $Self, %Param ) = @_;

    my %ValidList = (
        0 => 'Invalid',
        1 => 'Valid',
        2 => 'All'
    );

    my $Valid = $Param{ValidID} || 2;

    # check cached results
    my $CacheKey = 'Cache::CustomFormList::' . $ValidList{$Valid};

    my $Cache = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $Self->{CacheType},
        Key  => $CacheKey,
    );

    return %{$Cache} if ref $Cache eq 'HASH';

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    if ( $Valid != 2){

        # get service from db
        return if !$DBObject->Prepare(
            SQL  => 'SELECT id, name FROM custom_form WHERE valid_id = ?',
            Bind => [ \$Param{ValidID} ],
        );
	}
    else {
        # get service from db
        return if !$DBObject->Prepare(
            SQL => 'SELECT id, name FROM custom_form',
        );
    }

	# fetch the result
	my %Data;
    
	while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data{ $Row[0] } = $Row[1];
	}

    # set cache
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $Self->{CacheType},
        TTL   => $Self->{CacheTTL},
        Key   => $CacheKey,
        Value => \%Data,
    );

	return %Data;
}

=head2 CustomFormSearch()

return a service form list as hash

Return
    FormID => 1

    my %List = $CustomFormObject->CustomFormSearch(
        ServiceID => 123, # required
        Valid     => 1 | 0, # optional default( all )
    );

=cut

sub CustomFormSearch {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ServiceID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need ServiceID!",
        );
        return;
    }

    my %ValidList = (
        0 => 'Invalid',
        1 => 'Valid',
        2 => 'All'
    );

    my $Valid = $Param{Valid} || 1;

    # # check cached results
    # my $CacheKey = 'Cache::CustomFormService::' . $ValidList{$Valid} . '::' . $Param{CustomerID};
    # my $Cache    = $Kernel::OM->Get('Kernel::System::Cache')->Get(
    #     Type => $Self->{CacheType},
    #     Key  => $CacheKey,
    # );
    # return @{$Cache} if ref $Cache eq 'ARRAY';

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    if($Valid != 2){
        # get service from db
        return if !$DBObject->Prepare(
            SQL => 'SELECT CF.id
                FROM custom_form_service CS JOIN custom_form CF
                ON CS.form_id = CF.id
                WHERE service_id = ?
                AND CF.valid_id = ?',
            Bind  => [ \$Param{ServiceID}, \$Valid ],
            Limit => 1
        );
	}
    else{
        # get service from db
        return if !$DBObject->Prepare(
            SQL => 'SELECT CF.id
                FROM custom_form_service CS JOIN custom_form CF
                ON CS.form_id = CF.id
                WHERE service_id = ?',
            Bind  => [ \$Param{ServiceID} ],
            Limit => 1
        );
    }

	# fetch the result
	my $FormID;
	while ( my @Row = $DBObject->FetchrowArray() ) {
		$FormID = $Row[0];
	}

    # # set cache
    # $Kernel::OM->Get('Kernel::System::Cache')->Set(
    #     Type  => $Self->{CacheType},
    #     TTL   => $Self->{CacheTTL},
    #     Key   => $CacheKey,
    #     Value => $FormID,
    # );

	return $FormID;
}

=head2 CustomFormLookup()

return the id or the name of a service form

    my $ID = $CustomFormObject->CustomFormLookup(
        Name => 'Custom Form 1',
    );

    my $CustomFormName = $CustomFormObject->CustomFormLookup(
        ID => 1,
    );

=cut

sub CustomFormLookup {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ID} && !$Param{Name} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need Name or ID!",
        );
        return;
    }

    my %CustomFormList = $Self->CustomFormList();

    my $Key;
    my $ReturnData;

    if ( $Param{ID} ) {
        $Key        = 'ID';
        $ReturnData = $CustomFormList{ $Param{ID} };
    }
    else {
        $Key   = 'Name';
        my %CustomFormListReverse = reverse %CustomFormList;
        $ReturnData = $CustomFormListReverse{ $Param{Name} };
    }

	return $ReturnData;
}

=head2 CustomFormGet()

return a custom form as hash

Return {
        ID         => 1;,
        Name       => 'Custom Form 1',
        Interface  => 'AgentInterface' || 'CustomerInterface' || 'OnBothInterfaces',
        ValidID    => 1,
        CreateTime => '2018-01-01 00:00:00',
        CreateBy   => 1,
        ChangeTime => '2018-02-01 10:00:01',
        ChangeBy   => 1
    }

    my %CustomFormData = $CustomFormObject->CustomFormGet(
        FormID => 123,
        UserID => 1,
    );

=cut

sub CustomFormGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(FormID UserID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # check cached results
    my $CacheKey = 'Cache::CustomFormGet::' . $Param{FormID};
    my $Cache    = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $Self->{CacheType},
        Key  => $CacheKey,
    );

    return %{$Cache} if ref $Cache eq 'HASH';

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get custom service form from db
    return if !$DBObject->Prepare(
        SQL => 'SELECT id, name, interface, valid_id, create_time, create_by, change_time, change_by, description
            FROM custom_form WHERE id = ?',
        Bind  => [ \$Param{FormID} ],
        Limit => 1,
    );

    # fetch the result
    my %CustomFormData;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $CustomFormData{ID}             = $Row[0];
        $CustomFormData{Name}           = $Row[1];
        $CustomFormData{Interface}      = $Row[2];
		$CustomFormData{ValidID}        = $Row[3];
        $CustomFormData{CreateTime}     = $Row[4];
        $CustomFormData{CreateBy}       = $Row[5];
        $CustomFormData{ChangeTime}     = $Row[6];
        $CustomFormData{ChangeBy}       = $Row[7];
        $CustomFormData{Description}    = $Row[8];
    }

    # check service
    if ( !$CustomFormData{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "No such ID ($Param{FormID})!",
        );
        return;
    }

    # set cache
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $Self->{CacheType},
        TTL   => $Self->{CacheTTL},
        Key   => $CacheKey,
        Value => \%CustomFormData,
    );

    return %CustomFormData;
}

=head2 CustomFormGetByName()

return a custom form as hash

Return {
        ID         => 1;,
        Name       => 'Custom Form 1',
        Interface  => 'AgentInterface' || 'CustomerInterface' || 'OnBothInterfaces',
        ValidID    => 1,
        CreateTime => '2018-01-01 00:00:00',
        CreateBy   => 1,
        ChangeTime => '2018-02-01 10:00:01',
        ChangeBy   => 1
    }

    my %CustomFormData = $CustomFormObject->v(
        Name => 123,
        UserID => 1,
    );

=cut

sub CustomFormGetByName {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(Name UserID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # check cached results
    my $CacheKey = 'Cache::CustomFormGet::' . $Param{FormID};
    my $Cache    = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $Self->{CacheType},
        Key  => $CacheKey,
    );

    return %{$Cache} if ref $Cache eq 'HASH';

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get custom service form from db
    return if !$DBObject->Prepare(
        SQL => 'SELECT id, name, interface, valid_id, create_time, create_by, change_time, change_by, description
            FROM custom_form WHERE name = ?',
        Bind  => [ \$Param{Name} ],
        Limit => 1,
    );

    # fetch the result
    my %CustomFormData;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $CustomFormData{ID}             = $Row[0];
        $CustomFormData{Name}           = $Row[1];
        $CustomFormData{Interface}      = $Row[2];
		$CustomFormData{ValidID}        = $Row[3];
        $CustomFormData{CreateTime}     = $Row[4];
        $CustomFormData{CreateBy}       = $Row[5];
        $CustomFormData{ChangeTime}     = $Row[6];
        $CustomFormData{ChangeBy}       = $Row[7];
        $CustomFormData{Description}    = $Row[8];
    }

    # check service
    if ( !$CustomFormData{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "No such ID ($Param{FormID})!",
        );
        return;
    }

    # set cache
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $Self->{CacheType},
        TTL   => $Self->{CacheTTL},
        Key   => $CacheKey,
        Value => \%CustomFormData,
    );

    return %CustomFormData;
}

=head2 CustomFormAdd()

add new custom service form

    my $ID = $CustomFormObject->CustomFormAdd(
        Name        => 'New Custom Form', # required
        Interface  => 'AgentInterface' || 'CustomerInterface' || 'OnBothInterfaces', # required
        ValidID     => 1, # required
        UserID      => 1, # required
    );

=cut

sub CustomFormAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(Name Interface ValidID UserID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # cleanup given params
    for my $Argument (qw(Name Interface)) {
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
        SQL   => 'SELECT id FROM custom_form WHERE name = ?',
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
            Message  => "A Custom Form with the name '$Param{Name}' already exists.",
        );
        return;
    }

    return if !$DBObject->Do(
        SQL => 'INSERT INTO custom_form (name, interface, valid_id, create_time, create_by, change_time, change_by, description) '
            . 'VALUES (?, ?, ?, current_timestamp, ?, current_timestamp, ?, ?)',
        Bind => [
            \$Param{Name}, \$Param{Interface}, \$Param{ValidID}, \$Param{UserID}, \$Param{UserID}, \$Param{Description}
        ],
    );

    # get template id
    return if !$DBObject->Prepare(
        SQL   => 'SELECT id FROM custom_form WHERE name = ?',
        Bind  => [ \$Param{Name} ],
        Limit => 1,
    );

    my $FormID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $FormID = $Row[0];
    }

    # reset cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => $Self->{CacheType},
    );

    return $FormID;
}

=head2 CustomFormUpdate()

edit the custom service form

    my $Sucess = $CustomFormObject->CustomFormUpdate(
        ID        => 1, # required
        Name      => 'Update Custom Form 1', # required
        Interface => 'AgentInterface' || 'CustomerInterface' || 'OnBothInterfaces', # required
        ValidID   => 1, # required
        UserID    => 1, # optional
    );

=cut

sub CustomFormUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(ID Name Interface ValidID UserID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # cleanup given params
    for my $Argument (qw(Name Interface)) {
        $Kernel::OM->Get('Kernel::System::CheckItem')->StringClean(
            StringRef         => \$Param{$Argument},
            RemoveAllNewlines => 1,
            RemoveAllTabs     => 1,
        );
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # find existing service template
    return if !$DBObject->Do(
        SQL  => 'UPDATE custom_form SET name = ?, interface = ? , valid_id = ?, '
		     . 'change_time = current_timestamp, change_by = ?, description = ? WHERE id = ?',
        Bind => [
            \$Param{Name}, \$Param{Interface}, \$Param{ValidID}, \$Param{UserID}, \$Param{Description}, \$Param{ID},
        ],
    );

    # reset cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => $Self->{CacheType},
    );

    return 1;
}

=head2 ValidServiceList()

return a valid service list as hash

Return
    %List = {
        1 => 'Service 1',
        2 => 'Service 2',
    }

    my %List = $CustomFormObject->ValidServiceList(
        FormID => 1 # optional
    );

=cut

sub ValidServiceList {
    my ( $Self, %Param ) = @_;

    my $CacheID = '';
    if($Param{FormID}){
        $CacheID = "::$Param{FormID}";
    }

    # check cached results
    my $CacheKey = 'Cache::ValidServiceList' . $CacheID;
    my $Cache    = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $Self->{CacheType},
        Key  => $CacheKey,
    );

    return %{$Cache} if ref $Cache eq 'HASH';

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    if( $Param{FormID} && $Param{FormID} ne 'NEW' ){

        # get service available services
        return if !$DBObject->Prepare(
            SQL  => 'SELECT id, name FROM service WHERE valid_id = 1
                    AND id NOT IN (SELECT CS.service_id
                        FROM custom_form_service CS JOIN custom_form CF
                        ON CS.form_id = CF.id
                        WHERE CS.form_id != ?
                        AND CF.valid_id = 1)',
            Bind => [ \$Param{FormID} ],
        );
	}
    else {

        # get service available services
        return if !$DBObject->Prepare(
            SQL => 'SELECT id, name FROM service WHERE valid_id = 1
                    AND id NOT IN (SELECT CS.service_id
                        FROM custom_form_service CS JOIN custom_form CF
                        ON CS.form_id = CF.id
                        WHERE CF.valid_id = 1)',
        );
    }

	# fetch the result
	my %Services;

	while ( my @Row = $DBObject->FetchrowArray() ) {
		$Services{ $Row[0] } = $Row[1];
	}

    # set cache
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $Self->{CacheType},
        TTL   => $Self->{CacheTTL},
        Key   => $CacheKey,
        Value => \%Services,
    );

	return %Services;
}

=head2 CustomFormServiceList()

add service

    my @ServiceList = $CustomFormObject->CustomFormServiceList(
        FormID => 123, # required
    );

=cut

sub CustomFormServiceList {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{FormID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need FormID!",
        );
        return;
    }

    # check cached results
    my $CacheKey = "Cache::CustomFormServiceList::$Param{FormID}";
    my $Cache    = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $Self->{CacheType},
        Key  => $CacheKey,
    );
    return @{$Cache} if ref $Cache eq 'ARRAY';

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');


    # get service available services
    return if !$DBObject->Prepare(
        SQL  => 'SELECT service_id FROM custom_form_service WHERE form_id = ?',
        Bind => [ \$Param{FormID} ],
    );

	# fetch the result
	my @Services;
	while ( my @Row = $DBObject->FetchrowArray() ) {
		push @Services, $Row[0];
	}

    # set cache
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $Self->{CacheType},
        TTL   => $Self->{CacheTTL},
        Key   => $CacheKey,
        Value => \@Services,
    );

	return @Services;
}

=head2 CustomFormServiceSave()

save service

    my $Success = $CustomFormObject->CustomFormServiceSave(
        FormID    => 123,   # required
        Services => [1, 2]  # required
    );

=cut

sub CustomFormServiceSave {
    my ($Self, %Param) = @_;

    # check needed stuff
    for (qw(FormID Services)){
        if( !$Param{$_} ){
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    $DBObject->Do(
		SQL => 'DELETE FROM custom_form_service WHERE form_id = ?',
		Bind => [ \$Param{FormID} ],
	);

    return if !$DBObject->Prepare(
        SQL =>
            'SELECT id, name FROM service WHERE valid_id = 1 AND id NOT IN
            (SELECT SL.service_id FROM custom_form_service SL JOIN custom_form ST
                ON SL.form_id = ST.id WHERE ST.valid_id = 1)',
    );

    # fetch the result
    my @ValidServiceList;
    while ( my @Row = $DBObject->FetchrowArray() ) {           
        push @ValidServiceList, $Row[0];
    }

    # for my $ServiceID ( @{$Param{Services}} ){
    #     if($ServiceID ~~ @ValidServiceList){
    #         $DBObject->Do(
    #             SQL => 'INSERT INTO custom_form_service (form_id, service_id) VALUES (?, ?)',
    #             Bind => [ \$Param{FormID}, \$ServiceID ],
    #         );
    #     }
	# }
    for my $ServiceID ( @{$Param{Services}})  {
        if (grep { $_ eq $ServiceID } @ValidServiceList) {
            $DBObject->Do(
                SQL   => 'INSERT INTO custom_form_service (form_id, service_id) VALUES (?, ?)',
                Bind  => [\$Param{FormID}, \$ServiceID],
            );
        }
    }

    # delete cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => $Self->{CacheType},
    );

    return 1;
}

=head2 CustomFormDynamicFieldList()

list dynamic fields, ref array

    my $Success = $CustomFormObject->CustomFormDynamicFieldList(
        FormID    => 123,   # required
    );

=cut

sub CustomFormDynamicFieldList {
    my ($Self, %Param) = @_;

    # check needed stuff
    if( !$Param{FormID} ){
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need FormID!"
        );
        return;
    }

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        SQL  => 'SELECT DF.name, CF.description, CF.mask, CF.default_value, CF.display, CF.field_id
				 FROM custom_form_dynamic_field CF JOIN dynamic_field DF
				 ON CF.field_id = DF.id WHERE form_id = ? ORDER BY CF.field_order',
        Bind => [ \$Param{FormID} ],
    );

    my @Fields;
    while ( my @Row = $DBObject->FetchrowArray() ) {

		my %FieldDetail = ();

		$FieldDetail{Name}             = 'DynamicField_' . $Row[0],
		$FieldDetail{DescriptionShort} = $Row[1],
		$FieldDetail{Mask}             = $Row[2],
		$FieldDetail{DefaultValue}     = $Row[3],
		$FieldDetail{Display}          = $Row[4],
		$FieldDetail{ID}               = $Row[5],

		push @Fields, \%FieldDetail;
    }

    return \@Fields;
}

=head2 CustomFormDynamicFieldGet()

list dynamic fields

    my $Success = $CustomFormObject->CustomFormDynamicFieldGet(
        FormID    => 123,   # required
        FieldID   => 123,   # required
    );

=cut

sub CustomFormDynamicFieldGet {
    my ($Self, %Param) = @_;

    # check needed stuff
    if( !$Param{FormID} ){
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need FormID!"
        );
        return;
    }

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        SQL  => 'SELECT DF.name, CF.description, CF.mask, CF.default_value, CF.display
				 FROM custom_form_dynamic_field CF JOIN dynamic_field DF
				 ON CF.field_id = ? WHERE form_id = ? ',
        Bind => [ \$Param{FieldID}, \$Param{FormID} ],
    );

    my %FieldDetail = ();
    while ( my @Row = $DBObject->FetchrowArray() ) {


		$FieldDetail{Name}             = 'DynamicField_' . $Row[0],
		$FieldDetail{DescriptionShort} = $Row[1],
		$FieldDetail{Mask}             = $Row[2],
		$FieldDetail{DefaultValue}     = $Row[3],
		$FieldDetail{Display}          = $Row[4],
    }

    return %FieldDetail;
}

=head2 CustomFormDynamicFieldDisplayGet()

get display value of dynamic field

    my $Success = $CustomFormObject->CustomFormDynamicFieldDisplayGet(
        FormID    => 123,   # required
        FieldID  => 123,   # required
    );

=cut

sub CustomFormDynamicFieldDisplayGet {
    my ($Self, %Param) = @_;

    # check needed stuff
    if( !$Param{FormID} || !$Param{FieldID} ){
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need FormID or FieldID!"
        );
        return;
    }

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        SQL  => 'SELECT CF.display
				 FROM custom_form_dynamic_field CF JOIN dynamic_field DF
				 ON CF.field_id = ? WHERE form_id = ? ',
        Bind => [ \$Param{FieldID},  \$Param{FormID}],
    );

    my $Field;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		$Field  = $Row[0],
    }
    return $Field;

}

=head2 CustomFormDynamicFieldDescriptionGet()

get description of dynamic field in service form

    my $Success = $CustomFormObject->CustomFormDynamicFieldDescriptionGet(
        FormID    => 123,   # required
        FieldID  => 123,   # required
    );

=cut

sub CustomFormDynamicFieldDescriptionGet {
    my ($Self, %Param) = @_;

    # check needed stuff
    if( !$Param{FormID} || !$Param{FieldID} ){
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need FormID or FieldID!"
        );
        return;
    }

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        SQL  => 'SELECT CF.description
				 FROM custom_form_dynamic_field CF JOIN dynamic_field DF
				 ON CF.field_id = ? WHERE form_id = ? ',
        Bind => [ \$Param{FieldID},  \$Param{FormID}],
    );

    my $Field;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		$Field  = $Row[0],
    }
    return $Field;
}

=head2 CustomFormDynamicFieldSave()

add a custom dynamic form

    my $Fields = $CustomFormObject->CustomFormDynamicFieldSave(
		FormID       => 123, # required,
		Fields       => [1, 2], # dynamic Fields
		FieldDetails => {
            DynamicField_FieldNameX => {
                ID                   => 123, # requerid, ID dynamic field
                IDescriptionShortD   => 'Field', # optional
                Mask                 => '9999-9999', # optional
                DefaultValue         => '1', # optional
                Display              => '1', # requerid
            },
            ...
        },
		UserID     => 1, # requerid
    );

=cut

sub CustomFormDynamicFieldSave {
    my ($Self, %Param) = @_;

    # check needed stuff
    for (qw(FormID UserID)){
        if( !$Param{$_} ){
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    $DBObject->Do(
		SQL => 'DELETE FROM custom_form_dynamic_field WHERE form_id = ?',
		Bind => [ \$Param{FormID} ],
	);
    my $Count = 1;
    for my $Field ( @{$Param{Fields}} ){
        return if !$DBObject->Do(
			SQL => 'INSERT INTO custom_form_dynamic_field(form_id, field_id, description, mask, '
				. 'default_value, display, create_time, create_by, change_time, change_by, field_order) '
				. 'VALUES(?, ?, ?, ?, ?, ?, current_timestamp, ?, current_timestamp, ?, ?)',
			Bind => [
				\$Param{FormID}, \$Param{FieldDetails}->{$Field}->{ID}, \$Param{FieldDetails}->{$Field}->{DescriptionShort},
				\$Param{FieldDetails}->{$Field}->{Mask}, \$Param{FieldDetails}->{$Field}->{DefaultValue},
				\$Param{FieldDetails}->{$Field}->{Display}, \$Param{UserID}, \$Param{UserID}, \$Count
			],
		);
        $Count++;
	}

    # delete cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => $Self->{CacheType},
    );

    return 1;
}

=head2 CustomFormListGet()

    get an list with all custom service form
    
    my $List = $CustomFormObject->CustomFormListGet(
        UserID   => 1,
    );

    return 
    \@ArrayRef;

=cut

sub CustomFormListGet {
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
    my $DBObject      = $Kernel::OM->Get('Kernel::System::DB');
    my $ServiceObject = $Kernel::OM->Get('Kernel::System::Service');

    my $SQL = 'SELECT id FROM custom_form ORDER BY id';

    # SQL
    return if !$DBObject->Prepare(
        SQL => $SQL,
    );

    my @CustomFormIDs;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        push @CustomFormIDs, $Row[0];
    }

    my @Data;
    for my $ItemID ( @CustomFormIDs ) {

        my %CustomFormData = $Self->CustomFormGet(
            FormID => $ItemID,
            UserID => 1,
        );

        my @SelectedServices = $Self->CustomFormServiceList(
            FormID => $ItemID,
        );

        my @NameOfServices;
        for my $ServiceID ( @SelectedServices ){

            my $ServiceName = $ServiceObject->ServiceLookup(
                ServiceID => $ServiceID,
            );

            push @NameOfServices, $ServiceName;
        }

        $CustomFormData{Services} = \@NameOfServices;

		my $Fields = $Self->CustomFormDynamicFieldList(
			FormID     => $ItemID,
		);

        $CustomFormData{DynamicFields} = $Fields;

        push @Data, \%CustomFormData;
    }

    return \@Data;
}

=head2 CustomFormImport()
    import an Custom service Form YAML file/content

    my $CustomFormImport = $CustomFormObject->CustomFormImport(
        Content                   => $YAMLContent, # mandatory, YAML format
        OverwriteExistingEntities => 0,            # 0 || 1
        UserID                    => 1,            # mandatory
    );
=cut

sub CustomFormImport {
    my ( $Self, %Param ) = @_;

    my $ServiceObject      = $Kernel::OM->Get('Kernel::System::Service');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

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

    my $CustomFormDate = $Kernel::OM->Get('Kernel::System::YAML')->Load( Data => $Param{Content} );

    if ( ref $CustomFormDate ne 'ARRAY' ) {
        return {
            Success => 0,
            Message => Translatable("Couldn't read custom form configuration file. Please make sure the file is valid."),
        };
    }

    my @UpdatedTemplates;
    my @AddedTemplates;
    my @TemplatesErrors;

    CUSTOMFORM:
    for my $CustomForm ( @{$CustomFormDate} ) {

        next CUSTOMFORM if !$CustomForm;
        next CUSTOMFORM if ref $CustomForm ne 'HASH';

        $CustomForm = $Self->_CustomFormMigrateFrom33(
            CustomForm    => $CustomForm,
            UserID => $Param{UserID},
        );

        my @ExistingCustomForm = @{ $Self->CustomFormListGet( UserID => $Param{UserID} ) || [] };
        @ExistingCustomForm = grep { $_->{Name} eq $CustomForm->{Name} } @ExistingCustomForm;

        if ( $Param{OverwriteExistingEntities} && $ExistingCustomForm[0] ) {
           
            my $Update = $Self->CustomFormUpdate(
                UserID    => 1,
                %{ $ExistingCustomForm[0] },
                %{ $CustomForm },
            );

            if( $Update ){               

                # To import the services by id
                my @IDsOfServices;
                for my $ServiceName ( @{$CustomForm->{Services}} ){

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

                my $Success = $Self->CustomFormServiceSave(
                    FormID   => $CustomForm->{ID},
                    Services => \@IDsOfServices,
                );

                # To DynamicFields
                my %HashOfDFToUpload;
                my @ArrayOfNames;

                for my $DFData ( @{$CustomForm->{DynamicFields}} ){
                    
                    my @OnlyName = split /DynamicField_/, $DFData->{Name};

                    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
                        Name => $OnlyName[1],
                    );

                    if(IsHashRefWithData($DynamicField)){

                        push @ArrayOfNames, $DFData->{Name};

                        $HashOfDFToUpload{$DFData->{Name}} = {
                            ID           => $DynamicField->{ID},
                            Display      => $DFData->{Display},
                            Mask         => $DFData->{Mask},
                            DefaultValue => $DFData->{DefaultValue},
                            Name         => $DFData->{Name},
                            DescriptionShort => $DFData->{DescriptionShort}
                        }
                    }
                    else{
                        $Kernel::OM->Get('Kernel::System::Log')->Log(
                            Priority => 'error',
                            Message  => "No such DynamicField with name ( $DFData->{Name} )!",
                        );                        
                    }                                        
                }

                my $Fields = $Self->CustomFormDynamicFieldSave(
                    FormID       => $CustomForm->{ID},
                    Fields       => \@ArrayOfNames,
                    FieldDetails => \%HashOfDFToUpload,
                    UserID       => 1,
                );            
           
            }

            if( $Update ){
                push @UpdatedTemplates, $CustomForm->{Name};
            }
            else {
                push @TemplatesErrors, $CustomForm->{Name};
            }

        }
        else {

            my $FormID = $Self->CustomFormAdd(
                UserID    => $Param{UserID},
                %{$CustomForm},
            );

            if( $FormID ){
                
                # To import the services by id
                my @IDsOfServices;
                for my $ServiceName ( @{$CustomForm->{Services}} ){

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

                my $SuccessSave= $Self->CustomFormServiceSave(
                    FormID   => $FormID,
                    Services => \@IDsOfServices,
                );

                # To DynamicFields
                my %HashOfDFToUpload;
                my @ArrayOfNames;

                for my $DFData ( @{$CustomForm->{DynamicFields}} ){
                    
                    my @OnlyName = split /DynamicField_/, $DFData->{Name};

                    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
                        Name => $OnlyName[1],
                    );

                    if(IsHashRefWithData($DynamicField)){

                        push @ArrayOfNames, $DFData->{Name};

                        $HashOfDFToUpload{$DFData->{Name}} = {
                            ID           => $DynamicField->{ID},
                            Display      => $DFData->{Display},
                            Mask         => $DFData->{Mask},
                            DefaultValue => $DFData->{DefaultValue},
                            Name         => $DFData->{Name},
                            DescriptionShort => $DFData->{DescriptionShort}
                        }
                    }
                    else{
                        $Kernel::OM->Get('Kernel::System::Log')->Log(
                            Priority => 'error',
                            Message  => "No such DynamicField with name ( $DFData->{Name} )!",
                        );                        
                    }                                        
                }

                my $FieldsSaved = $Self->CustomFormDynamicFieldSave(
                    FormID       => $FormID,
                    Fields       => \@ArrayOfNames,
                    FieldDetails => \%HashOfDFToUpload,
                    UserID       => 1,
                );         
            }

            if ($FormID) {
                push @AddedTemplates, $CustomForm->{Name};
            }
            else {
                push @TemplatesErrors, $CustomForm->{Name};
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

=head2 _CustomFormMigrateFrom33()
    Updates Service Template structure my changing the Possible->Action hash ref to a PossibleNot->Action array ref
    with just the elements that where set to 0 in the original custom form:
    $CustomForm = $Self->_CustomFormMigrateFrom33(
        CustomForm    => $CustomForm,
        UserID => $Param{UserID},
    );
=cut

sub _CustomFormMigrateFrom33 {
    my ( $Self, %Param ) = @_;

    my $CustomForm = $Param{CustomForm};

    return $CustomForm if !ref $CustomForm->{ConfigChange};
    return $CustomForm if !$CustomForm->{ConfigChange}->{Possible}->{Action};
    return $CustomForm if ref $CustomForm->{ConfigChange}->{Possible}->{Action} ne 'HASH';

    # convert old hash into an array using only the keys set to 0, and skip those that are set
    # to 1, set them as PossibleNot and delete the Possible->Action section from the Custom Form.
    my @NewAction = grep { $CustomForm->{ConfigChange}->{Possible}->{Action}->{$_} == 0 }
        sort keys %{ $CustomForm->{ConfigChange}->{Possible}->{Action} };

    delete $CustomForm->{ConfigChange}->{Possible}->{Action};
    $CustomForm->{ConfigChange}->{PossibleNot}->{Action} = \@NewAction;

    return $CustomForm;
}

1;
