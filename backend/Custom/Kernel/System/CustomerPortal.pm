# --
# Kernel/System/CustomerPortal.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * jsantos@serviceup.com.br
# --

package Kernel::System::CustomerPortal;

use strict;
use warnings;
use List::MoreUtils qw(uniq);

use Kernel::System::VariableCheck (qw(:all));

our @ObjectDependencies = (
    'Kernel::System::Cache',
    'Kernel::System::CheckItem',
    'Kernel::System::Log',
    'Kernel::System::Valid',
);

=head1 NAME

Kernel::System::CustomerPortal

=head1 SYNOPSIS

All CustomerPortal module functions.

=head1 PUBLIC INTERFACE

=head2 new()

create an object

    my $CustomerPortalObject = $Kernel::OM->Get('Kernel::System::CustomerPortal');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{CacheType} = 'SLACustom';
    $Self->{CacheTTL}  = 60 * 60 * 24 * 20;
    $Self->{CacheTTLSurvey}  = 60 * 60 * 24 * 5;

    return $Self;

}

=head2 CategoryCount()

Count the number of categories.

    my $CategoryCount = $FAQObject->CategoryCount(
        ParentIDs => [ 1, 2, 3, 4 ],
        UserID    => 1,
    );

Returns:

    $CategoryCount = 6;

=cut


sub CategoryCount {
    my ( $Self, %Param ) = @_;

    if ( !$Param{UserID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need UserID!',
        );

        return;
    }

    if ( !defined $Param{ParentIDs} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need ParentIDs!',
        );

        return;
    }

    # build SQL
    my $SQL = '
        SELECT id
        FROM faq_category
        WHERE valid_id IN ('
        . join ', ', $Kernel::OM->Get('Kernel::System::Valid')->ValidIDsGet()
        . ')';

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # parent ids are given
    if ( defined $Param{ParentIDs} ) {

        # integer quote the parent ids
        for my $ParentID ( @{ $Param{ParentIDs} } ) {
            $ParentID = $DBObject->Quote( $ParentID, 'Integer' );
        }

        # create string
        my $InString = join ', ', @{ $Param{ParentIDs} };

        $SQL .= ' AND parent_id IN (' . $InString . ')';
    }

    # add group by
    # $SQL .= ' GROUP BY parent_id';

    return if !$DBObject->Prepare(
        SQL   => $SQL,
        Limit => 200,
    );

    my @IDs;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        push @IDs, $Row[0];
    }

    my $FAQObject = $Kernel::OM->Get('Kernel::System::FAQ');

    my $Count = 0;

    IDS:
    for my $ID ( @IDs ) {

        my $CategoryCount = $FAQObject->CategoryCount(
            ParentIDs => [$ID],
            UserID    => $Param{UserID}
        );

        my $FAQCount = $FAQObject->FAQCount(
            CategoryIDs  => [$ID],
            ItemStates   => $Param{ItemStates},
            OnlyApproved => 1,
            Valid        => 1,
            UserID       => $Param{UserID},
        );

        next IDS if $CategoryCount == 0 && $FAQCount == 0;

        $Count++;
    }


    return $Count;
}

=head2 NotificationStatusAdd()

add Notification Status 

Return
    $Success = 1 | 0

    my $Add = $CustomerPortalObject->NotificationStatusAdd(
        CustomerUserLogin          => 'teste',
        ArticleID          => '1',
        IsRead          => '1' || '0',
    );

=cut

sub NotificationStatusAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(CustomerUserLogin ArticleID )) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # create new db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            INSERT INTO customer_portal_notifications (customer_user_login, article_id, is_read) 
            VALUES (?, ?, ?)',
        Bind => [
            \$Param{CustomerUserLogin}, \$Param{ArticleID}, \$Param{IsRead},  
        ],
    );

    return 1;
}

=head2 NotificationNotReadGetByCustomer()

notification not read get by customer

    my $Notification = $CustomerPortalObject->NotificationNotReadGetByCustomer(
        CustomerUserLogin => 'teste'
    );

=cut

sub NotificationNotReadGetByCustomer {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{CustomerUserLogin} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need CustomerUserLogin!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get Kanban
    return if !$DBObject->Prepare(
        SQL => 'SELECT article_id, is_read FROM customer_portal_notifications WHERE customer_user_login = ?',
		Bind => [ \$Param{CustomerUserLogin} ],
    );

    # fetch the result
    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Data{$Row[0]} = $Row[1];
    }

    return %Data;
}


=head2 ArrayTotalNotifications()

notification array of customer

    my $Notifications = $CustomerPortalObject->ArrayTotalNotifications(
        CustomerUserLogin => 'teste'
    );

=cut

sub ArrayTotalNotifications {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{CustomerUserLogin} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need CustomerUserLogin!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get Kanban
    return if !$DBObject->Prepare(
        SQL => 'SELECT article_id FROM customer_portal_notifications WHERE customer_user_login = ?',
		Bind => [ \$Param{CustomerUserLogin} ],
    );

    # fetch the result
    my @Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        push @Data, $Row[0];
    }

    return @Data;
}

=head2 NotificationUpdate()

update Notification IsRead

    my $Notification = $CustomerPortalObject->NotificationUpdate(
        ID            => 1, 
        IsRead        => 1, 
    );

=cut

sub NotificationUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need ID!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # sql
    return if !$DBObject->Do(
        SQL => 'UPDATE customer_portal_notifications SET is_read = ? WHERE article_id = ?',
        Bind => [
             \$Param{IsRead}, \$Param{ID},
        ],
    );

    return 1;
}

=head2 CounterNotifications()
counts the total number of unread notifications

    my $Notification = $CustomerPortalObject->CounterNotifications(
        CustomerUserLogin            => 'teste', 
    );

=cut

sub CounterNotifications {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{CustomerUserLogin} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need CustomerUserLogin!",
        );
        return;
    }

    # get database object
    my $DBObject              = $Kernel::OM->Get('Kernel::System::DB');
    my $ConfigObject          = $Kernel::OM->Get('Kernel::Config');
    my $NotificationTableSize =  $ConfigObject->Get('CustomerPortal::Core::NotificationTableSize');

    # sql
    return if !$DBObject->Prepare(
        SQL => "SELECT COUNT(id) FROM customer_portal_notifications WHERE customer_user_login = ? AND is_read ='0' ",
        Bind => [
            \$Param{CustomerUserLogin},            
        ],
        Limit => $NotificationTableSize
    );

    my $Data;
    # fetch the result
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Data = $Row[0];
    }

    return $Data ;
}

=head2 DeleteNotification()

Delete notification

    my $Notification = $CustomerPortalObject->DeleteNotification(
        NotificationID => '1'
    );

=cut

sub DeleteNotification {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{NotificationID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need NotificationID!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get Kanban
    return if !$DBObject->Do(
        SQL => 'DELETE FROM customer_portal_notifications WHERE article_id = ?',
		Bind => [ \$Param{NotificationID} ],
    );

    return 1;
}


=head2 CardsList()
return a CardID list as hash

my $Cards = $CustomerPortalObject->CardsList();

=cut

sub CardsList {
    my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

	my $SQL = 'SELECT id FROM customer_portal_cards where name != "Home_Page"';

    # get Cards
    return if !$DBObject->Prepare(
        SQL => $SQL,
    );

 	# fetch the result
	my %Data;
	while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data{ $Row[0] } = $Row[1];
	}

	return %Data;

}

=head2 CardsGet()

get cards

Return
    %Cards = {
        ID             => 1,
        Body           => 'Text',
    }

    my $Cards = $CustomerPortalObject->CardsGet(
        ID => 1 
    );

=cut

sub CardsGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need ID!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get Kanban
    return if !$DBObject->Prepare(
        SQL => 'SELECT id, body, name, valid_id FROM customer_portal_cards WHERE id = ? ',
		Bind => [ \$Param{ID} ],
    );

    # fetch the result
    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data{ID}             = $Row[0];
		$Data{Body}           = $Row[1];
		$Data{Name}           = $Row[2];
		$Data{ValidID}        = $Row[3];
    }

    return \%Data;
}

=head2 HomePageGet()

get home page

Return
    %Cards = {
        ID             => 1,
        Body           => 'Text',
    }

    my $Cards = $CustomerPortalObject->HomePageGet(
        ID => 1 
    );

=cut

sub HomePageGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need ID!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get Kanban
    return if !$DBObject->Prepare(
        SQL  => 'SELECT id, body, name, valid_id FROM customer_portal_cards WHERE name = ? ',
		Bind => [ \$Param{ID} ],
    );

    # fetch the result
    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data{ID}             = $Row[0];
		$Data{Body}           = $Row[1];
		$Data{Name}           = $Row[2];
		$Data{ValidID}        = $Row[3];
    }

    return \%Data;
}

=head2 CardsAdd()

add card of Customer Portal

Return
    $Success = 1 | 0

    my $Card = $CustomerPortalObject->CardsAdd(
        Name          => 'Name',
        ValidID       => 1,
        Body          => 'teste',
        UserID        => 1
    );

=cut

sub CardsAdd {
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

    # create new db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            INSERT INTO customer_portal_cards (name, body, valid_id, create_time, create_by, change_time, change_by ) 
            VALUES (?, ?, ?, current_timestamp, ?, current_timestamp, ?)',
        Bind => [
            \$Param{Name}, \$Param{Body}, \$Param{ValidID}, \$Param{UserID}, \$Param{UserID}, 
        ],
    );

    return 1;
}

=head2 CardsUpdate()

update cards

Return
    $Success = 1 | 0

    my $Cards = $CustomerPortalObject->CardsUpdate(
        ID             => 1, 
        Name           => 'Name',
        ValidID        => 1
        Body           => 'teste',
        UserID         => '1'
    );

=cut

sub CardsUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(ID Name ValidID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # sql
    return if !$DBObject->Do(
        SQL => 'UPDATE customer_portal_cards SET name = ?, valid_id = ? , body = ?,  change_time = current_timestamp, change_by = ? WHERE id = ?',
        Bind => [
            \$Param{Name}, \$Param{ValidID}, \$Param{Body}, \$Param{UserID}, \$Param{ID}
        ],
    );

    return 1;
}

=head2 CardsListValids()
return a CardID list as ref hash

my $Cards = $CustomerPortalObject->CardsListValids();

=cut

sub CardsListValids {
    my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

	my $SQL = 'SELECT id FROM customer_portal_cards where valid_id = 1 AND name != "Home_Page"';

    # get Cards
    return if !$DBObject->Prepare(
        SQL => $SQL,
    );

 	# fetch the result
	my @Data;
	while ( my @Row = $DBObject->FetchrowArray() ) {
        push @Data, $Row[0];
	}

	return \@Data;
}

=head2 SLAResponseGet()

return a template data as hash

    my %SLAReports = $SLACustom->SLAResponseGet(
        TN       => 123536383933938,
        UserID   => 1,
    );

=cut

sub SLAResponseGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(TN UserID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # get object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # check cached results
    my $CacheKey = 'Cache::SLAResponseGet::' . $Param{TemplateID};
    my $Cache    = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $Self->{CacheType},
        Key  => $CacheKey,
    );
    
    return %{$Cache} if ref $Cache eq 'HASH';

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get contract from db
    return if !$DBObject->Prepare(
        SQL => 'SELECT tn, response_time_spent, response_time_limit '
            . 'FROM SLA_reports_response WHERE tn = ?',
        Bind  => [ \$Param{TN} ],
        Limit => 1,
    );

    # fetch the result
    my %SLAReports = ();
    
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $SLAReports{TN}                  = $Row[0];
		$SLAReports{ResponseTime}        = $Row[1];
		$SLAReports{ResponseTimeLimit}   = $Row[2];
    }

    # check service
    if ( !$SLAReports{TN} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "No such TN ($SLAReports{TN})!",
        );
        return;
    }

    return %SLAReports;
}

=head2 SLASolutionGet()

return a template data as hash

    my %SLAReports = $SLACustom->SLASolutionGet(
        TN       => 123536383933938,
        UserID   => 1,
    );

=cut

sub SLASolutionGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(TN UserID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # get object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # check cached results
    my $CacheKey = 'Cache::SLASolutionGet::' . $Param{TemplateID};
    my $Cache    = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $Self->{CacheType},
        Key  => $CacheKey,
    );
    
    return %{$Cache} if ref $Cache eq 'HASH';

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get contract from db
    return if !$DBObject->Prepare(
        SQL => 'SELECT tn, solution_time_spent, solution_time_limit '
            . 'FROM SLA_reports_solution WHERE tn = ?',
        Bind  => [ \$Param{TN} ],
        Limit => 1,
    );

    # fetch the result
    my %SLAReports = ();

    while ( my @Row = $DBObject->FetchrowArray() ) {
        $SLAReports{TN}                  = $Row[0];
		$SLAReports{SolutionTime}        = $Row[1];
		$SLAReports{SolutionTimeLimit}   = $Row[2];
    }

    return %SLAReports;
}

sub GetTimeAccountedPeriod {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(TicketID StartDate EndDate )) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get contract from db
    return if !$DBObject->Prepare(
        SQL => 'SELECT time_unit, create_time FROM time_accounting WHERE ticket_id = ? AND create_time BETWEEN ? AND ?',
        Bind  => [ \$Param{TicketID}, \$Param{StartDate}, \$Param{EndDate} ],
    );

    # fetch the result
    my @Return;

    while ( my @Row = $DBObject->FetchrowArray() ) {

        my %Data;

        $Data{TimeUnit}   = $Row[0];
		$Data{CreateTime} = $Row[1];

        push @Return, \%Data;
    }

    return @Return;
}

=head2 SurveyGet()
return a response of a request in HashRef

    my %SurveyData = $SurveyUnansweredObject->SurveyGet(
        TicketID => 1
        Valid    => 1,
        Status   => 'Master'
    );
    
=cut

sub SurveyGet {
   my ( $Self, %Param ) = @_;

     # check needed stuff
    for my $Argument (qw(TicketID Valid Status)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # get objects
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get vote list
    return if !$DBObject->Prepare(
        SQL=> '
            SELECT R.id, R.ticket_id, R.survey_id, R.valid_id, R.public_survey_key, R.send_to, R.send_time, R.vote_time 
            FROM survey_request R JOIN survey S 
            ON R.survey_id = S.id 
            WHERE R.ticket_id = ? 
            AND R.valid_id = ? AND S.id IN (SELECT id FROM survey WHERE status = ? ) ',
        Bind  => [ \$Param{TicketID} , \$Param{Valid}, \$Param{Status} ],
        Limit => 1,
    );

    my %RequestData = ();

    while ( my @Row = $DBObject->FetchrowArray() ) {

        $RequestData{RequestID}       = $Row[0];
        $RequestData{TicketID}        = $Row[1];
        $RequestData{SurveyID}        = $Row[2];
        $RequestData{ValidID}         = $Row[3];
        $RequestData{PublicSurveyKey} = $Row[4];
        $RequestData{SendTo}          = $Row[5];
        $RequestData{SendTime}        = $Row[6];
        $RequestData{VoteTime}        = $Row[7];
    }

    return %RequestData;
}

sub GetSurveyCustomerUser {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw( UserID )) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # read cache
    my $CacheKey = 'GetSurveyCustomerUser::' . $Param{UserID};

    my $Cache = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => 'GetSurveyCustomerUser',
        Key  => $CacheKey,
    );

    return %{$Cache} if ref $Cache eq 'HASH' && !$Param{NoCache};

    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $Period = $ConfigObject->Get('CustomerPortal::Core::UnansweredSurveysPeriod');

    my %TicketIDs = $TicketObject->TicketSearch(
		StateType            => 'Closed',
		CustomerUserLoginRaw => $Param{UserID},
		CustomerUserID       => $Param{UserID},
		Permission           => 'ro',
    );

    my $Counter = 0;
	my @Data;
	
	# fetch the result
	TICKET:
	for my $TicketID (keys %TicketIDs) {
	
		my %Ticket = $TicketObject->TicketGet(
			TicketID => $TicketID,
		);
		
		# condense down the subject
		my $Subject = $TicketObject->TicketSubjectClean(
			TicketNumber => $Ticket{TicketNumber},
			Subject      => $Ticket{Title},
		);

		my %SurveyData = $Self->SurveyGet(
			TicketID => $TicketID, 
			Valid    => 1,
			Status   => 'Master'
		);

		if(IsHashRefWithData(\%SurveyData)) {

			$SurveyData{TicketNumber} = $Ticket{TicketNumber};
			$SurveyData{Subject}      = $Subject;
			$SurveyData{State}        = $Ticket{State};
			
			my $DateNowObject = $Kernel::OM->Create('Kernel::System::DateTime');

            next TICKET if !$SurveyData{SendTime};
            next TICKET if $SurveyData{SendTime} eq '';
			
			my $SendTimeObject = $Kernel::OM->Create('Kernel::System::DateTime',
				ObjectParams => {
					String   => $SurveyData{SendTime},
				}
			);

			my $DateNow  = $DateNowObject->ToEpoch();
			my $SendTime = $SendTimeObject->ToEpoch();
			
			my $Age = $DateNow - $SendTime;
			
			# age design
			$SurveyData{Age} = $LayoutObject->CustomerAge(
				Age   => $Age,
				Space => ' '
			);
			
			# set filter days
			my $Success = $DateNowObject->Subtract(
				Days => $Period,
    		);
		
			my $Result = $SendTimeObject->Compare( DateTimeObject => $DateNowObject );

			next TICKET if ( $Result == -1 );

            push @Data, \%SurveyData;

            $Counter++;	
		}
	}

    my %Data;

    $Data{Counter} = $Counter;
    $Data{Data}    = \@Data;

    # set cache
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => 'GetSurveyCustomerUser',
        TTL   => $Self->{CacheTTLSurvey},
        Key   => $CacheKey,
        Value => \%Data,
    );

    return %Data;
}

sub GetParentFAQCategories {
    my ($Self, %Param) = @_;

    if ( !$Param{CategoryFAQID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need CategoryFAQID!",
        );

        return [];
    }

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # Consulta SQL para obter as categorias pai de FAQs
    my $SQL = 'SELECT id FROM faq_category WHERE parent_id= ?';

    $DBObject->Prepare(
        SQL   => $SQL,
        Bind => [ \$Param{CategoryFAQID} ],
    );

    my @Categories;
    while (my @Row = $DBObject->FetchrowArray()) {
        push @Categories, $Row[0];
    }

    return @Categories;
}


=head2 CustomFAQTop10Get()

Returns an hash with the access of FAQ to 10 logs with 2 interfaces.

    my $Top10IDsRef = $FAQObject->CustomFAQTop10Get(
        Interface   => 'public',
        CategoryIDs   => [ 1, 2, 3 ],
        UserID      => 1,
    );

=cut
sub CustomFAQTop10Get {
    my ( $Self, %Param ) = @_;

    for my $Argument (qw(Interface UserID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );

            return [];
        }
    }

    # build valid id string
    my $ValidIDsString = join ', ', $Kernel::OM->Get('Kernel::System::Valid')->ValidIDsGet();

    # prepare SQL
    my @Bind;
    my $SQL = 'SELECT item_id, count(item_id) as itemcount, faq_state_type.name, approved '
        . 'FROM faq_log, faq_item, faq_state, faq_state_type '
        . 'WHERE faq_log.item_id = faq_item.id '
        . 'AND faq_item.state_id = faq_state.id '
        . "AND faq_item.valid_id IN ($ValidIDsString) "
        . 'AND faq_state.type_id = faq_state_type.id ';

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # filter just categories with at least ro permission
    if ( $Param{CategoryIDs} && ref $Param{CategoryIDs} eq 'ARRAY' && @{ $Param{CategoryIDs} } ) {

        # integer quote the category ids
        for my $CategoryID ( @{ $Param{CategoryIDs} } ) {
            $CategoryID = $DBObject->Quote( $CategoryID, 'Integer' );
        }

        my @SortedIDs = sort @{ $Param{CategoryIDs} };

        # split IN statement with more than 900 elements in more statements combined with OR
        # because Oracle doesn't support more than 1000 elements in one IN statement.
        my @SQLStrings;
        while ( scalar @SortedIDs ) {

            my @SortedIDsPart = splice @SortedIDs, 0, 900;

            my $IDString = join ',', @SortedIDsPart;

            push @SQLStrings, " faq_item.category_id IN ($IDString) ";
        }

        my $SQLString = join ' OR ', @SQLStrings;

        $SQL .= ' AND ( ' . $SQLString . ' ) ';
    }

    # filter results for public and customer interface
    if ( ( $Param{Interface} eq 'public' ) || ( $Param{Interface} eq 'external' ) ) {

        # only show approved articles
        $SQL .= 'AND faq_item.approved = 1 ';

        # only show the public articles
        $SQL .= "AND ( ( faq_state_type.name = 'public' ) ";

        # customers can additionally see the external articles
        if ( $Param{Interface} eq 'external' ) {
            $SQL .= "OR ( faq_state_type.name = 'external' ) ";
        }

        $SQL .= ') ';
    }

    # filter results for defined time period
    if ( $Param{StartDate} && $Param{EndDate} ) {
        $SQL .= 'AND faq_log.created >= ? AND faq_log.created <= ? ';
        push @Bind, ( \$Param{StartDate}, \$Param{EndDate} );
    }

    # complete SQL statement
    $SQL .= 'GROUP BY item_id, faq_state_type.name, approved '
        . 'ORDER BY itemcount DESC';

    # get the top 10 article ids from database
    return [] if !$DBObject->Prepare(
        SQL   => $SQL,
        Bind  => \@Bind,
        Limit => $Param{Limit} || 10,
    );

    my @Result;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        push @Result, {
            ItemID    => $Row[0],
            Count     => $Row[1],
            Interface => $Row[2],
        };
    }

    return \@Result;
}


=head2 CustomFAQGetAccessLog()

Returns an hash with the access of FAQ logs.

    my $Top10IDsRef = $FAQObject->CustomFAQGetAccessLog(
        ItemIDs   => [ 1, 2, 3 ],
        UserID      => 1,
    );

Returns:

    $Top10IDsRef = [
        {
            'ItemID'    => 13,
            'Count'     => 159,               # number of visits
            'Interface' => 'public',
        },
        {
            'ItemID'    => 6,
            'Count'     => 78,
            'Interface' => 'public',
        },
        {
            'ItemID'    => 4,
            'Count'     => 59,
            'Interface' => 'internal',
        },
        {
            'ItemID'    => 20,
            'Count'     => 29,
            'Interface' => 'public',
        },
        {
            'ItemID'    => 1,
            'Count'     => 24,
            'Interface' => 'external',
        },
        {
            'ItemID'    => 11,
            'Count'     => 24,
            'Interface' => 'internal',
        },
        {
            'ItemID'    => 5,
            'Count'     => 18,
            'Interface' => 'internal',
        },
        {
            'ItemID'    => 9,
            'Count'     => 16,
            'Interface' => 'external',
        },
        {
            'ItemID'    => 2,
            'Count'     => 14,
            'Interface' => 'internal'
        },
        {
            'ItemID'    => 14,
            'Count'     => 6,
            'Interface' => 'public',
        }
    ];

=cut

sub CustomFAQGetAccessLog {
    my ( $Self, %Param ) = @_;

    for my $Argument (qw(ItemIDs UserID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );

            return [];
        }
    }

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');


	my $SQL = "SELECT item_id, count(item_id) as itemcount, faq_state_type.name, approved FROM faq_log, faq_item, faq_state, faq_state_type 
                WHERE faq_log.item_id = faq_item.id 
                AND faq_item.state_id = faq_state.id 
                AND faq_state.type_id = faq_state_type.id 
                AND (faq_state_type.name = 'external' OR faq_state_type.name = 'public') ";

    # integer quote the item ids
    for my $ItemID ( @{ $Param{ItemIDs} } ) {
        $ItemID = $DBObject->Quote( $ItemID, 'Integer' );
    }

    my @SortedIDs = sort @{ $Param{ItemIDs} };

    # split IN statement with more than 900 elements in more statements combined with OR
    # because Oracle doesn't support more than 1000 elements in one IN statement.
    my @SQLStrings;
    LOOP:
    while ( scalar @SortedIDs ) {

        my @SortedIDsPart = splice @SortedIDs, 0, 900;

        my $IDString = join ',', @SortedIDsPart;

        push @SQLStrings, " faq_item.id IN ($IDString) ";
    }

    my $SQLString = join ' OR ', @SQLStrings;

    $SQL .= ' AND ( ' . $SQLString . ' ) ';
    $SQL .= 'GROUP BY item_id, faq_state_type.name ';
    $SQL .= 'ORDER BY itemcount DESC';

    return [] if !$DBObject->Prepare(
        SQL   => $SQL,
        Bind  => [],
        Limit => 100,
    );


    my @Result;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        push @Result, {
            ItemID    => $Row[0],
            Count     => $Row[1],
        };
    }

    return \@Result;

}


1;