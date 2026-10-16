# --
# Kernel/Modules/AdminKanbanSearch.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package Kernel::Modules::AdminKanbanSearch;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);
use Kernel::System::CheckItem;

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

	if ( $Self->{ObjectType} eq 'Ticket' ){
		return $Self->_BuildTicketParams( GetParam => $Param{Search} );
	}


	return;
}

sub _BuildTicketParams{
	my ( $Self, %Param ) = @_;

	my $ConfigObject        = $Kernel::OM->Get('Kernel::Config');
	my $DynamicFieldObject  = $Kernel::OM->Get('Kernel::System::DynamicField');
	my $BackendObject       = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
	my $LayoutObject        = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $UserObject          = $Kernel::OM->Get('Kernel::System::User');
    my $StateObject         = $Kernel::OM->Get('Kernel::System::State');

	my %GetParam = %{$Param{GetParam}};

	my %Attributes;
	my $Config = $ConfigObject->Get("Ticket::Frontend::AgentTicketSearch");

	my $DynamicFieldFilter = $Config->{DynamicField};

	# get the dynamic fields for ticket object
    my $DynamicField = $DynamicFieldObject->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => [ 'Ticket', 'Article' ],
        FieldFilter => $DynamicFieldFilter || {},
    );

	# get list type
    my $TreeView = 0;
    if ( $ConfigObject->Get('Ticket::Frontend::ListType') eq 'tree' ) {
        $TreeView = 1;
    }

	my @Attributes = (

        # Main fields
        {
            Key   => 'TicketNumber',
            Value => Translatable('Ticket Number'),
        },
        {
            Key   => 'Fulltext',
            Value => Translatable('Fulltext'),
        },
        {
            Key   => 'Title',
            Value => Translatable('Title'),
        },
        {
            Key      => '',
            Value    => '-',
            Disabled => 1,
        },

        # Article fields
        {
            Key   => 'From',
            Value => Translatable('From'),
        },
        {
            Key   => 'To',
            Value => Translatable('To'),
        },
        {
            Key   => 'Cc',
            Value => Translatable('Cc'),
        },
        {
            Key   => 'Subject',
            Value => Translatable('Subject'),
        },
        {
            Key   => 'Body',
            Value => Translatable('Body'),
        },
    );

    if (
        $ConfigObject->Get('Ticket::StorageModule') eq
        'Kernel::System::Ticket::ArticleStorageDB'
        )
    {
        push @Attributes, (
            {
                Key   => 'AttachmentName',
                Value => Translatable('Attachment Name'),
            },
        );
    }

    # Ticket fields
    push @Attributes, (
        {
            Key      => '',
            Value    => '-',
            Disabled => 1,
        },
        {
            Key   => 'CustomerID',
            Value => Translatable('CustomerID (complex search)'),
        },
        {
            Key   => 'CustomerIDRaw',
            Value => Translatable('CustomerID (exact match)'),
        },
        {
            Key   => 'CustomerUserLogin',
            Value => Translatable('Customer User Login (complex search)'),
        },
        {
            Key   => 'CustomerUserLoginRaw',
            Value => Translatable('Customer User Login (exact match)'),
        },
        {
            Key   => 'StateIDs',
            Value => Translatable('State'),
        },
        {
            Key   => 'PriorityIDs',
            Value => Translatable('Priority'),
        },
        {
            Key   => 'LockIDs',
            Value => Translatable('Lock'),
        },
        {
            Key   => 'QueueIDs',
            Value => Translatable('Queue'),
        },
        {
            Key   => 'CreatedQueueIDs',
            Value => Translatable('Created in Queue'),
        },
    );

    if ( $ConfigObject->Get('Ticket::Type') ) {
        push @Attributes, (
            {
                Key   => 'TypeIDs',
                Value => Translatable('Type'),
            },
        );
    }

    if ( $ConfigObject->Get('Ticket::Service') ) {
        push @Attributes, (
            {
                Key   => 'ServiceIDs',
                Value => Translatable('Service'),
            },
            {
                Key   => 'SLAIDs',
                Value => Translatable('SLA'),
            },
			{
				Key   => 'SLARange',
				Value => Translatable('SLA Range'),
			},
			{
				Key   => 'FirstResponseRange',
				Value => Translatable('First Response Range'),
			}
        );
    }

    push @Attributes, (
        {
            Key   => 'OwnerIDs',
            Value => Translatable('Owner'),
        },
        {
            Key   => 'CreatedUserIDs',
            Value => Translatable('Created by'),
        },
    );
    if ( $ConfigObject->Get('Ticket::Watcher') ) {
        push @Attributes, (
            {
                Key   => 'WatchUserIDs',
                Value => Translatable('Watcher'),
            },
        );
    }
    if ( $ConfigObject->Get('Ticket::Responsible') ) {
        push @Attributes, (
            {
                Key   => 'ResponsibleIDs',
                Value => Translatable('Responsible'),
            },
        );
    }

    # Time fields
    push @Attributes, (
        {
            Key      => '',
            Value    => '-',
            Disabled => 1,
        },
        {
            Key   => 'TicketLastChangeTimePoint',
            Value => Translatable('Ticket Last Change Time (before/after)'),
        },
        {
            Key   => 'TicketLastChangeTimeSlot',
            Value => Translatable('Ticket Last Change Time (between)'),
        },
        {
            Key   => 'TicketChangeTimePoint',
            Value => Translatable('Ticket Change Time (before/after)'),
        },
        {
            Key   => 'TicketChangeTimeSlot',
            Value => Translatable('Ticket Change Time (between)'),
        },
        {
            Key   => 'TicketCloseTimePoint',
            Value => Translatable('Ticket Close Time (before/after)'),
        },
        {
            Key   => 'TicketCloseTimeSlot',
            Value => Translatable('Ticket Close Time (between)'),
        },
        {
            Key   => 'TicketCreateTimePoint',
            Value => Translatable('Ticket Create Time (before/after)'),
        },
        {
            Key   => 'TicketCreateTimeSlot',
            Value => Translatable('Ticket Create Time (between)'),
        },
        {
            Key   => 'TicketEscalationTimePoint',
            Value => Translatable('Ticket Escalation Time (before/after)'),
        },
        {
            Key   => 'TicketEscalationTimeSlot',
            Value => Translatable('Ticket Escalation Time (between)'),
        },
        {
            Key   => 'ArticleCreateTimePoint',
            Value => Translatable('Article Create Time (before/after)'),
        },
        {
            Key   => 'ArticleCreateTimeSlot',
            Value => Translatable('Article Create Time (between)'),
        },
    );

    if ( $ConfigObject->Get('Ticket::ArchiveSystem') ) {
        push @Attributes, (
            {
                Key   => 'SearchInArchive',
                Value => 'Archive Search',
            },
        );
    }

    # Dynamic fields
    my $DynamicFieldSeparator = 1;

    # create dynamic fields search options for attribute select
    # cycle trough the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicField} ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);
        next DYNAMICFIELD if !$DynamicFieldConfig->{Name};
        next DYNAMICFIELD if $DynamicFieldConfig->{Name} eq '';

        # create a separator for dynamic fields attributes
        if ($DynamicFieldSeparator) {
            push @Attributes, (
                {
                    Key      => '',
                    Value    => '-',
                    Disabled => 1,
                },
            );
            $DynamicFieldSeparator = 0;
        }

        # get search field preferences
        my $SearchFieldPreferences = $BackendObject->SearchFieldPreferences(
            DynamicFieldConfig => $DynamicFieldConfig,
        );

        next DYNAMICFIELD if !IsArrayRefWithData($SearchFieldPreferences);

        # translate the dynamic field label
        my $TranslatedDynamicFieldLabel = $LayoutObject->{LanguageObject}->Translate(
            $DynamicFieldConfig->{Label},
        );

        PREFERENCE:
        for my $Preference ( @{$SearchFieldPreferences} ) {

            # translate the suffix
            my $TranslatedSuffix = $LayoutObject->{LanguageObject}->Translate(
                $Preference->{LabelSuffix},
            ) || '';

            if ($TranslatedSuffix) {
                $TranslatedSuffix = ' (' . $TranslatedSuffix . ')';
            }

            push @Attributes, (
                {
                    Key => 'Search_DynamicField_'
                        . $DynamicFieldConfig->{Name}
                        . $Preference->{Type},
                    Value => $TranslatedDynamicFieldLabel . $TranslatedSuffix,
                },
            );
        }
    }

    # create HTML strings for all dynamic fields
    my %DynamicFieldHTML;

    # cycle trough the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicField} ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        my $PossibleValuesFilter;

        my $IsACLReducible = $BackendObject->HasBehavior(
            DynamicFieldConfig => $DynamicFieldConfig,
            Behavior           => 'IsACLReducible',
        );

        if ($IsACLReducible) {

            # get PossibleValues
            my $PossibleValues = $BackendObject->PossibleValuesGet(
                DynamicFieldConfig => $DynamicFieldConfig,
            );

            # check if field has PossibleValues property in its configuration
            if ( IsHashRefWithData($PossibleValues) ) {

                # get historical values from database
                my $HistoricalValues = $BackendObject->HistoricalValuesGet(
                    DynamicFieldConfig => $DynamicFieldConfig,
                );

                my $Data = $PossibleValues;

                # add historic values to current values (if they don't exist anymore)
                if ( IsHashRefWithData($HistoricalValues) ) {
                    for my $Key ( sort keys %{$HistoricalValues} ) {
                        if ( !$Data->{$Key} ) {
                            $Data->{$Key} = $HistoricalValues->{$Key}
                        }
                    }
                }

                # convert possible values key => value to key => key for ACLs using a Hash slice
                my %AclData = %{$Data};
                @AclData{ keys %AclData } = keys %AclData;

                # get ticket object
                my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

                # set possible values filter from ACLs
                my $ACL = $TicketObject->TicketAcl(
                    Action        => $Self->{Action},
                    ReturnType    => 'Ticket',
                    ReturnSubType => 'DynamicField_' . $DynamicFieldConfig->{Name},
                    Data          => \%AclData,
                    UserID        => $Self->{UserID},
                );
                if ($ACL) {
                    my %Filter = $TicketObject->TicketAclData();

                    # convert Filer key => key back to key => value using map
                    %{$PossibleValuesFilter} = map { $_ => $Data->{$_} } keys %Filter;
                }
            }
        }

        # get search field preferences
        my $SearchFieldPreferences = $BackendObject->SearchFieldPreferences(
            DynamicFieldConfig => $DynamicFieldConfig,
        );

        next DYNAMICFIELD if !IsArrayRefWithData($SearchFieldPreferences);

        PREFERENCE:
        for my $Preference ( @{$SearchFieldPreferences} ) {

            # get field HTML
            $DynamicFieldHTML{ $DynamicFieldConfig->{Name} . $Preference->{Type} }
                = $BackendObject->SearchFieldRender(
                DynamicFieldConfig   => $DynamicFieldConfig,
                Profile              => \%GetParam,
                PossibleValuesFilter => $PossibleValuesFilter,
                DefaultValue =>
                    $Config->{Defaults}->{DynamicField}
                    ->{ $DynamicFieldConfig->{Name} },
                LayoutObject => $LayoutObject,
                Type         => $Preference->{Type},
                );
        }
    }

    $Attributes{AttributesStrg} = $LayoutObject->BuildSelection(
        Data     => \@Attributes,
        Name     => 'AttributeKanban',
        Multiple => 0,
        Class    => 'Modernize',
    );

	$Attributes{AttributesOrigStrg} = $LayoutObject->BuildSelection(
        Data     => \@Attributes,
        Name     => 'AttributeOrigKanban',
        Multiple => 0,
        Class    => 'Modernize',
    );

	 # get all users of own groups
    my %AllUsers = $UserObject->UserList(
        Type  => 'Long',
        Valid => 0,
    );
    if ( !$ConfigObject->Get('Ticket::ChangeOwnerToEveryone') ) {
        my %Involved = $Kernel::OM->Get('Kernel::System::Group')->PermissionUserInvolvedGet(
            UserID => $Self->{UserID},
            Type   => 'ro',
        );
        for my $UserID ( sort keys %AllUsers ) {
            if ( !$Involved{$UserID} ) {
                delete $AllUsers{$UserID};
            }
        }
    }

    my @ShownUsers;
    my %UsersInvalid;

    # get valid users of own groups
    my %ValidUsers = $UserObject->UserList(
        Type  => 'Long',
        Valid => 1,
    );

    USERID:
    for my $UserID ( sort { $AllUsers{$a} cmp $AllUsers{$b} } keys %AllUsers ) {

        if ( !$ValidUsers{$UserID} ) {
            $UsersInvalid{$UserID} = $AllUsers{$UserID};
            next USERID;
        }

        push @ShownUsers, {
            Key   => $UserID,
            Value => $AllUsers{$UserID},
        };
    }

    # also show invalid agents (if any)
    if ( scalar %UsersInvalid ) {
        push @ShownUsers, {
            Key      => '-',
            Value    => '_____________________',
            Disabled => 1,
        };
        push @ShownUsers, {
            Key      => '-',
            Value    => $LayoutObject->{LanguageObject}->Translate('Invalid Users'),
            Disabled => 1,
        };
        push @ShownUsers, {
            Key      => '-',
            Value    => '',
            Disabled => 1,
        };
        for my $UserID ( sort { $UsersInvalid{$a} cmp $UsersInvalid{$b} } keys %UsersInvalid ) {
            push @ShownUsers, {
                Key   => $UserID,
                Value => $UsersInvalid{$UserID},
            };
        }
    }

    $Attributes{UserStrg} = $LayoutObject->BuildSelection(
        Data       => \@ShownUsers,
        Name       => 'OwnerIDs',
        Multiple   => 1,
        Size       => 5,
        SelectedID => $GetParam{OwnerIDs},
        Class      => 'Modernize',
		PossibleNone => 1,
    );
    $Attributes{CreatedUserStrg} = $LayoutObject->BuildSelection(
        Data       => \@ShownUsers,
        Name       => 'CreatedUserIDs',
        Multiple   => 1,
        Size       => 5,
        SelectedID => $GetParam{CreatedUserIDs},
        Class      => 'Modernize',
		PossibleNone => 1,
    );
    if ( $ConfigObject->Get('Ticket::Watcher') ) {
        $Attributes{WatchUserStrg} = $LayoutObject->BuildSelection(
            Data       => \@ShownUsers,
            Name       => 'WatchUserIDs',
            Multiple   => 1,
            Size       => 5,
            SelectedID => $GetParam{WatchUserIDs},
            Class      => 'Modernize',
			PossibleNone => 1,
        );
    }
    if ( $ConfigObject->Get('Ticket::Responsible') ) {
        $Attributes{ResponsibleStrg} = $LayoutObject->BuildSelection(
            Data       => \@ShownUsers,
            Name       => 'ResponsibleIDs',
            Multiple   => 1,
            Size       => 5,
            SelectedID => $GetParam{ResponsibleIDs},
            Class      => 'Modernize',
			PossibleNone => 1,
        );
    }

    # build service string
    if ( $ConfigObject->Get('Ticket::Service') ) {

        my %Service = $Kernel::OM->Get('Kernel::System::Service')->ServiceList(
            UserID       => $Self->{UserID},
            KeepChildren => $ConfigObject->Get('Ticket::Service::KeepChildren'),
        );
        $Attributes{ServicesStrg} = $LayoutObject->BuildSelection(
            Data        => \%Service,
            Name        => 'ServiceIDs',
			SelectedID  => $GetParam{ServiceIDs},
            TreeView    => $TreeView,
            Sort        => 'TreeView',
            Size        => 5,
            Multiple    => 1,
            Translation => 0,
            Max         => 200,
            Class       => 'Modernize',
			PossibleNone => 1,
        );
        my %SLA = $Kernel::OM->Get('Kernel::System::SLA')->SLAList(
            UserID => $Self->{UserID},
        );
        $Attributes{SLAsStrg} = $LayoutObject->BuildSelection(
            Data        => \%SLA,
            Name        => 'SLAIDs',
            SelectedID  => $GetParam{SLAIDs},
            Sort        => 'AlphanumericValue',
            Size        => 5,
            Multiple    => 1,
            Translation => 0,
            Max         => 200,
            Class       => 'Modernize',
			PossibleNone => 1,
        );

		my %RangePerc = (
			"25"  => "Till 25%",
			"50"  => "25% Till 50%",
			"75"  => "50% Till 75%",
			"100" => "75% Till 100%",
			"101" => "More than 100%",
		);

		$Attributes{SLARangeStrg} = $LayoutObject->BuildSelection(
			Data        => \%RangePerc,
			Name        => 'SLARange',
			Multiple    => 0,
			SelectedID  => $GetParam{SLARange},
			Class       => 'Modernize',
			Sort        => 'NumericKey',
			Translation => 1,
		);

		$Attributes{FirstResponseRangeStrg} = $LayoutObject->BuildSelection(
			Data        => \%RangePerc,
			Name        => 'FirstResponseRange',
			Multiple    => 0,
			SelectedID  => $GetParam{FirstResponseRange},
			Class       => 'Modernize',
			Sort        => 'NumericKey',
			Translation => 1,
		);
    }

    if ( $ConfigObject->Get('Ticket::ArchiveSystem') ) {

        $Attributes{SearchInArchiveStrg} = $LayoutObject->BuildSelection(
            Data => {
                ArchivedTickets    => Translatable('Archived tickets'),
                NotArchivedTickets => Translatable('Unarchived tickets'),
                AllTickets         => Translatable('All tickets'),
            },
            Name       => 'SearchInArchive',
            SelectedID => $GetParam{SearchInArchive},
            Class      => 'Modernize',
			PossibleNone => 1,
        );
    }

    $Attributes{StatesStrg} = $LayoutObject->BuildSelection(
        Data => {
            $StateObject->StateList(
                UserID => $Self->{UserID},
                Action => $Self->{Action},
            ),
        },
        Name       => 'StateIDs',
        Multiple   => 1,
        Size       => 5,
        SelectedID => $GetParam{StateIDs},
        Class      => 'Modernize',
		PossibleNone => 1,
    );
    my %AllQueues = $Kernel::OM->Get('Kernel::System::Queue')->GetAllQueues(
        UserID => $Self->{UserID},
        Type   => 'ro',
    );
    $Attributes{QueuesStrg} = $LayoutObject->AgentQueueListOption(
        Data               => \%AllQueues,
        Size               => 5,
        Multiple           => 1,
        Name               => 'QueueIDs',
        TreeView           => $TreeView,
        SelectedIDRefArray => $GetParam{QueueIDs},
        OnChangeSubmit     => 0,
        Class              => 'Modernize',
		PossibleNone => 1,
    );
    $Attributes{CreatedQueuesStrg} = $LayoutObject->AgentQueueListOption(
        Data               => \%AllQueues,
        Size               => 5,
        Multiple           => 1,
        Name               => 'CreatedQueueIDs',
        TreeView           => $TreeView,
        SelectedIDRefArray => $GetParam{CreatedQueueIDs},
        OnChangeSubmit     => 0,
        Class              => 'Modernize',
		PossibleNone       => 1,
    );
    $Attributes{PrioritiesStrg} = $LayoutObject->BuildSelection(
        Data => {
            $Kernel::OM->Get('Kernel::System::Priority')->PriorityList(
                UserID => $Self->{UserID},
                Action => $Self->{Action},
            ),
        },
        Name         => 'PriorityIDs',
        Multiple     => 1,
        Size         => 5,
        SelectedID   => $GetParam{PriorityIDs},
        Class        => 'Modernize',
		PossibleNone => 1,
    );
    
    $Attributes{LocksStrg} = $LayoutObject->BuildSelection(
        Data => {
            $Kernel::OM->Get('Kernel::System::Lock')->LockList(
                UserID => $Self->{UserID},
                Action => $Self->{Action},
            ),
        },
        Name       => 'LockIDs',
        Multiple   => 1,
        Size       => 5,
        SelectedID => $GetParam{LockIDs},
        Class      => 'Modernize',
		PossibleNone => 1,
    );

    $Attributes{ArticleCreateTimePoint} = $LayoutObject->BuildSelection(
        Data       => [ 1 .. 59 ],
        Name       => 'ArticleCreateTimePoint',
        SelectedID => $GetParam{ArticleCreateTimePoint},
		PossibleNone => 1,
    );
    $Attributes{ArticleCreateTimePointStart} = $LayoutObject->BuildSelection(
        Data => {
            'Last'   => Translatable('within the last ...'),
            'Before' => Translatable('more than ... ago'),
        },
        Name       => 'ArticleCreateTimePointStart',
        SelectedID => $GetParam{ArticleCreateTimePointStart},
		PossibleNone => 1,
    );
    $Attributes{ArticleCreateTimePointFormat} = $LayoutObject->BuildSelection(
        Data => {
            minute => Translatable('minute(s)'),
            hour   => Translatable('hour(s)'),
            day    => Translatable('day(s)'),
            week   => Translatable('week(s)'),
            month  => Translatable('month(s)'),
            year   => Translatable('year(s)'),
        },
        Name       => 'ArticleCreateTimePointFormat',
        SelectedID => $GetParam{ArticleCreateTimePointFormat},
		PossibleNone => 1,
    );
    $Attributes{ArticleCreateTimeStart} = $LayoutObject->BuildDateSelection(
		%GetParam,
        Prefix   => 'ArticleCreateTimeStart',
        Format   => 'DateInputFormat',
        DiffTime => -( ( 60 * 60 * 24 ) * 30 ),
		PossibleNone => 1,
    );
    $Attributes{ArticleCreateTimeStop} = $LayoutObject->BuildDateSelection(
        %GetParam,
        Prefix => 'ArticleCreateTimeStop',
        Format => 'DateInputFormat',
		PossibleNone => 1,
    );
    $Attributes{TicketCreateTimePoint} = $LayoutObject->BuildSelection(
        Data       => [ 1 .. 59 ],
        Name       => 'TicketCreateTimePoint',
        SelectedID => $GetParam{TicketCreateTimePoint},
		PossibleNone => 1,
    );
    $Attributes{TicketCreateTimePointStart} = $LayoutObject->BuildSelection(
        Data => {
            'Last'   => Translatable('within the last ...'),
            'Before' => Translatable('more than ... ago'),
        },
        Name       => 'TicketCreateTimePointStart',
        SelectedID => $GetParam{TicketCreateTimePointStart},
		PossibleNone => 1,
    );
    $Attributes{TicketCreateTimePointFormat} = $LayoutObject->BuildSelection(
        Data => {
            minute => Translatable('minute(s)'),
            hour   => Translatable('hour(s)'),
            day    => Translatable('day(s)'),
            week   => Translatable('week(s)'),
            month  => Translatable('month(s)'),
            year   => Translatable('year(s)'),
        },
        Name       => 'TicketCreateTimePointFormat',
        SelectedID => $GetParam{TicketCreateTimePointFormat},
		PossibleNone => 1,
    );
    $Attributes{TicketCreateTimeStart} = $LayoutObject->BuildDateSelection(
        %GetParam,
        Prefix   => 'TicketCreateTimeStart',
        Format   => 'DateInputFormat',
        DiffTime => -( ( 60 * 60 * 24 ) * 30 ),
		PossibleNone => 1,
    );
    $Attributes{TicketCreateTimeStop} = $LayoutObject->BuildDateSelection(
        %GetParam,
        Prefix => 'TicketCreateTimeStop',
        Format => 'DateInputFormat',
		PossibleNone => 1,
    );

    $Attributes{TicketChangeTimePoint} = $LayoutObject->BuildSelection(
        Data       => [ 1 .. 59 ],
        Name       => 'TicketChangeTimePoint',
        SelectedID => $GetParam{TicketChangeTimePoint},
		PossibleNone => 1,
    );
    $Attributes{TicketChangeTimePointStart} = $LayoutObject->BuildSelection(
        Data => {
            'Last'   => 'within the last ...',
            'Before' => 'more than ... ago',
        },
        Name       => 'TicketChangeTimePointStart',
        SelectedID => $GetParam{TicketChangeTimePointStart},
		PossibleNone => 1,
    );
    $Attributes{TicketChangeTimePointFormat} = $LayoutObject->BuildSelection(
        Data => {
            minute => Translatable('minute(s)'),
            hour   => Translatable('hour(s)'),
            day    => Translatable('day(s)'),
            week   => Translatable('week(s)'),
            month  => Translatable('month(s)'),
            year   => Translatable('year(s)'),
        },
        Name       => 'TicketChangeTimePointFormat',
        SelectedID => $GetParam{TicketChangeTimePointFormat},
		PossibleNone => 1,
    );
    $Attributes{TicketChangeTimeStart} = $LayoutObject->BuildDateSelection(
        %GetParam,
        Prefix   => 'TicketChangeTimeStart',
        Format   => 'DateInputFormat',
        DiffTime => -( ( 60 * 60 * 24 ) * 30 ),
		PossibleNone => 1,
    );
    $Attributes{TicketChangeTimeStop} = $LayoutObject->BuildDateSelection(
        %GetParam,
        Prefix => 'TicketChangeTimeStop',
        Format => 'DateInputFormat',
		PossibleNone => 1,
    );

    $Attributes{TicketCloseTimePoint} = $LayoutObject->BuildSelection(
        Data       => [ 1 .. 59 ],
        Name       => 'TicketCloseTimePoint',
        SelectedID => $GetParam{TicketCloseTimePoint},
		PossibleNone => 1,
    );
    $Attributes{TicketCloseTimePointStart} = $LayoutObject->BuildSelection(
        Data => {
            'Last'   => Translatable('within the last ...'),
            'Before' => Translatable('more than ... ago'),
        },
        Name       => 'TicketCloseTimePointStart',
        SelectedID => $GetParam{TicketCloseTimePointStart},
        PossibleNone => 1,
    );
    $Attributes{TicketCloseTimePointFormat} = $LayoutObject->BuildSelection(
        Data => {
            minute => Translatable('minute(s)'),
            hour   => Translatable('hour(s)'),
            day    => Translatable('day(s)'),
            week   => Translatable('week(s)'),
            month  => Translatable('month(s)'),
            year   => Translatable('year(s)'),
        },
        Name       => 'TicketCloseTimePointFormat',
        SelectedID => $GetParam{TicketCloseTimePointFormat},
		PossibleNone => 1,
    );
    $Attributes{TicketCloseTimeStart} = $LayoutObject->BuildDateSelection(
        %GetParam,
        Prefix   => 'TicketCloseTimeStart',
        Format   => 'DateInputFormat',
        DiffTime => -( ( 60 * 60 * 24 ) * 30 ),
		PossibleNone => 1,
    );
    $Attributes{TicketCloseTimeStop} = $LayoutObject->BuildDateSelection(
        %GetParam,
        Prefix => 'TicketCloseTimeStop',
        Format => 'DateInputFormat',
		PossibleNone => 1,
    );

    $Attributes{TicketLastChangeTimePoint} = $LayoutObject->BuildSelection(
        Data       => [ 1 .. 59 ],
        Name       => 'TicketLastChangeTimePoint',
        SelectedID => $GetParam{TicketLastChangeTimePoint},
		PossibleNone => 1,
    );
    $Attributes{TicketLastChangeTimePointStart} = $LayoutObject->BuildSelection(
        Data => {
            'Last'   => Translatable('within the last ...'),
            'Before' => Translatable('more than ... ago'),
        },
        Name       => 'TicketLastChangeTimePointStart',
        SelectedID => $GetParam{TicketLastChangeTimePointStart},
        PossibleNone => 1,
    );
    $Attributes{TicketLastChangeTimePointFormat} = $LayoutObject->BuildSelection(
        Data => {
            minute => Translatable('minute(s)'),
            hour   => Translatable('hour(s)'),
            day    => Translatable('day(s)'),
            week   => Translatable('week(s)'),
            month  => Translatable('month(s)'),
            year   => Translatable('year(s)'),
        },
        Name       => 'TicketLastChangeTimePointFormat',
        SelectedID => $GetParam{TicketLastChangeTimePointFormat},
		PossibleNone => 1,
    );
    $Attributes{TicketLastChangeTimeStart} = $LayoutObject->BuildDateSelection(
        %GetParam,
        Prefix   => 'TicketLastChangeTimeStart',
        Format   => 'DateInputFormat',
        DiffTime => -( ( 60 * 60 * 24 ) * 30 ),
		PossibleNone => 1,
    );
    $Attributes{TicketLastChangeTimeStop} = $LayoutObject->BuildDateSelection(
        %GetParam,
        Prefix => 'TicketLastChangeTimeStop',
        Format => 'DateInputFormat',
		PossibleNone => 1,
    );

    $Attributes{TicketEscalationTimePoint} = $LayoutObject->BuildSelection(
        Data       => [ 1 .. 59 ],
        Name       => 'TicketEscalationTimePoint',
        SelectedID => $GetParam{TicketEscalationTimePoint},
		PossibleNone => 1,
    );
    $Attributes{TicketEscalationTimePointStart} = $LayoutObject->BuildSelection(
        Data => {
            'Last'   => Translatable('within the last ...'),
            'Next'   => Translatable('within the next ...'),
            'Before' => Translatable('more than ... ago'),
        },
        Name       => 'TicketEscalationTimePointStart',
        SelectedID => $GetParam{TicketEscalationTimePointStart},
		PossibleNone => 1,
    );
    $Attributes{TicketEscalationTimePointFormat} = $LayoutObject->BuildSelection(
        Data => {
            minute => Translatable('minute(s)'),
            hour   => Translatable('hour(s)'),
            day    => Translatable('day(s)'),
            week   => Translatable('week(s)'),
            month  => Translatable('month(s)'),
            year   => Translatable('year(s)'),
        },
        Name       => 'TicketEscalationTimePointFormat',
        SelectedID => $GetParam{TicketEscalationTimePointFormat},
		PossibleNone => 1,
    );
    $Attributes{TicketEscalationTimeStart} = $LayoutObject->BuildDateSelection(
        %GetParam,
        Prefix   => 'TicketEscalationTimeStart',
        Format   => 'DateInputFormat',
        DiffTime => -( ( 60 * 60 * 24 ) * 30 ),
		PossibleNone => 1,
    );
    $Attributes{TicketEscalationTimeStop} = $LayoutObject->BuildDateSelection(
        %GetParam,
        Prefix => 'TicketEscalationTimeStop',
        Format => 'DateInputFormat',
		PossibleNone => 1,
    );

    #my %GetParamBackup = %GetParam;
    #for my $Key (
    #    qw(TicketEscalation TicketClose TicketChange TicketLastChange TicketCreate ArticleCreate)
    #    )
    #{
    #    for my $SubKey (qw(TimeStart TimeStop TimePoint TimePointStart TimePointFormat)) {
    #        delete $GetParam{ $Key . $SubKey };
    #        delete $GetParamBackup{ $Key . $SubKey };
    #    }
    #}

    # build type string
    if ( $ConfigObject->Get('Ticket::Type') ) {
        my %Type = $Kernel::OM->Get('Kernel::System::Type')->TypeList(
            UserID => $Self->{UserID},
        );

        $Attributes{TypesStrg} = $LayoutObject->BuildSelection(
            Data        => \%Type,
            Name        => 'TypeIDs',
            SelectedID  => $GetParam{TypeIDs},
            Sort        => 'AlphanumericValue',
            Size        => 3,
            Multiple    => 1,
            Translation => 0,
            Class       => 'Modernize',
			PossibleNone => 1,
        );
    }

    # output Dynamic fields blocks
    # cycle trough the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicField} ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        # get search field preferences
        my $SearchFieldPreferences = $BackendObject->SearchFieldPreferences(
            DynamicFieldConfig => $DynamicFieldConfig,
        );

        next DYNAMICFIELD if !IsArrayRefWithData($SearchFieldPreferences);

        PREFERENCE:
        for my $Preference ( @{$SearchFieldPreferences} ) {

            # skip fields that HTML could not be retrieved
            next PREFERENCE if !IsHashRefWithData(
                $DynamicFieldHTML{ $DynamicFieldConfig->{Name} . $Preference->{Type} }
            );

			my $ValidClass = '';

			my $DivID = "Search_DynamicField_$DynamicFieldConfig->{Name}$Preference->{Type}";



			if ( $GetParam{$DivID} ){
				$ValidClass = 'ValidFilter';
			}
    
            my $Label = substr($DynamicFieldHTML{ $DynamicFieldConfig->{Name} . $Preference->{Type} }->{Label}, 27);
            $Label = substr($Label, 0,-6);

            $LayoutObject->Block(
                Name => 'DynamicField',
                Data => {
					DivID => "Search_DynamicField_$DynamicFieldConfig->{Name}$Preference->{Type}",
                    Label =>
                        $Label,
                    Field =>
                        $DynamicFieldHTML{ $DynamicFieldConfig->{Name} . $Preference->{Type} }
                        ->{Field},
					DynamicFieldValidClass => $ValidClass,
                },
            );
        }
    }

	return %Attributes;
}

1;
