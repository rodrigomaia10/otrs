# --
# Kernel/Autoload/TemplateGenerator.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

use Kernel::System::TemplateGenerator;

package Kernel::System::TemplateGenerator;
## nofilter(TidyAll::Plugin::OTRS::Perl::DBObject)

use strict;
use warnings;

use Mail::Address;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

=begin Internal:

=cut

sub _Replace {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(Text RichText Data UserID)) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # check for mailto links
    # since the subject and body of those mailto links are
    # uri escaped we have to uri unescape them, replace
    # possible placeholders and then re-uri escape them
    $Param{Text} =~ s{
        (href="mailto:[^\?]+\?)([^"]+")
    }
    {
        my $MailToHref        = $1;
        my $MailToHrefContent = $2;

        $MailToHrefContent =~ s{
            ((?:subject|body)=)(.+?)("|&)
        }
        {
            my $SubjectOrBodyPrefix  = $1;
            my $SubjectOrBodyContent = $2;
            my $SubjectOrBodySuffix  = $3;

            my $SubjectOrBodyContentUnescaped = URI::Escape::uri_unescape $SubjectOrBodyContent;

            my $SubjectOrBodyContentReplaced = $Self->_Replace(
                %Param,
                Text     => $SubjectOrBodyContentUnescaped,
                RichText => 0,
            );

            my $SubjectOrBodyContentEscaped = URI::Escape::uri_escape_utf8 $SubjectOrBodyContentReplaced;

            $SubjectOrBodyPrefix . $SubjectOrBodyContentEscaped . $SubjectOrBodySuffix;
        }egx;

        $MailToHref . $MailToHrefContent;
    }egx;

    my $Start = '<';
    my $End   = '>';
    if ( $Param{RichText} ) {
        $Start = '&lt;';
        $End   = '&gt;';
        $Param{Text} =~ s/(\n|\r)//g;
    }

    my %Ticket;
    if ( $Param{TicketData} ) {
        %Ticket = %{ $Param{TicketData} };
    }

    # Replace Unix time format tags.
    # If language is defined, they will be converted into a correct format in below IF statement.
    for my $UnixFormatTime (
        qw(RealTillTimeNotUsed EscalationResponseTime EscalationUpdateTime EscalationSolutionTime)
        )
    {
        if ( $Ticket{$UnixFormatTime} ) {
            $Ticket{$UnixFormatTime} = $Kernel::OM->Create(
                'Kernel::System::DateTime',
                ObjectParams => {
                    Epoch => $Ticket{$UnixFormatTime},
                    }
            )->ToString();
        }
    }

    # translate ticket values if needed
    if ( $Param{Language} ) {

        my $LanguageObject = Kernel::Language->new(
            UserLanguage => $Param{Language},
        );

        # Translate the different values.
        for my $Field (qw(Type State StateType Lock Priority)) {
            $Ticket{$Field} = $LanguageObject->Translate( $Ticket{$Field} );
        }

        # Transform the date values from the ticket data (but not the dynamic field values).
        ATTRIBUTE:
        for my $Attribute ( sort keys %Ticket ) {
            next ATTRIBUTE if $Attribute =~ m{ \A DynamicField_ }xms;
            next ATTRIBUTE if !$Ticket{$Attribute};

            if ( $Ticket{$Attribute} =~ m{\A(\d\d\d\d)-(\d\d)-(\d\d)\s(\d\d):(\d\d):(\d\d)\z}xi ) {
                $Ticket{$Attribute} = $LanguageObject->FormatTimeString(
                    $Ticket{$Attribute},
                    'DateFormat',
                    'NoSeconds',
                );
            }
        }

        my $LocalLayoutObject = Kernel::Output::HTML::Layout->new(
            Lang => $Param{Language},
        );

        # Convert tags in seconds to more readable appropriate format if language is defined.
        for my $TimeInSeconds (
            qw(UntilTime EscalationTimeWorkingTime EscalationTime FirstResponseTimeWorkingTime FirstResponseTime UpdateTimeWorkingTime
            UpdateTime SolutionTimeWorkingTime SolutionTime)
            )
        {
            if ( $Ticket{$TimeInSeconds} ) {
                $Ticket{$TimeInSeconds} = $LocalLayoutObject->CustomerAge(
                    Age   => $Ticket{$TimeInSeconds},
                    Space => ' '
                );
            }
        }
    }

    my %Queue;
    if ( $Param{QueueID} ) {
        %Queue = $Kernel::OM->Get('Kernel::System::Queue')->QueueGet(
            ID => $Param{QueueID},
        );
    }

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # Replace config options.
    my $Tag = $Start . 'OTRS_CONFIG_';
    $Param{Text} =~ s{$Tag(.+?)$End}{
        my $Replace = '';
        # Mask secret config options.
        if ($1 =~ m{(Password|Pw)\d*$}smxi) {
            $Replace = 'xxx';
        }
        else {
            $Replace = $ConfigObject->Get($1) // '';
        }
        $Replace;
    }egx;

    # cleanup
    $Param{Text} =~ s/$Tag.+?$End/-/gi;

    my %Recipient = %{ $Param{Recipient} || {} };

    # get user object
    my $UserObject = $Kernel::OM->Get('Kernel::System::User');

    if ( !%Recipient && $Param{RecipientID} ) {

        %Recipient = $UserObject->GetUserData(
            UserID        => $Param{RecipientID},
            NoOutOfOffice => 1,
        );
    }

    my $HashGlobalReplace = sub {
        my ( $Tag, %H ) = @_;

        # Generate one single matching string for all keys to save performance.
        my $Keys = join '|', map {quotemeta} grep { defined $H{$_} } keys %H;

        # Set all keys as lowercase to be able to match case insensitive,
        #   e. g. <OTRS_CUSTOMER_From> and <OTRS_CUSTOMER_FROM>.
        %H = map { lc $_ => $H{$_} } sort keys %H;

        # If tag is 'OTRS_CUSTOMER_' add the body alias 'email/note' to be replaced.
        if ( $Tag =~ m/OTRS_(CUSTOMER|AGENT)_/ ) {
            KEY:
            for my $Key (qw( email note )) {
                my $Value = $H{$Key};
                next KEY if defined($Value);

                $H{$Key} = $H{'body'};
                $Keys .= '|' . ucfirst $Key;
            }
        }

        $Param{Text} =~ s/(?:$Tag)($Keys)$End/$H{ lc $1 }/ieg;
    };

    # get recipient data and replace it with <OTRS_...
    $Tag = $Start . 'OTRS_';

    # include more readable tag <OTRS_NOTIFICATION_RECIPIENT
    my $RecipientTag = $Start . 'OTRS_NOTIFICATION_RECIPIENT_';

    if (%Recipient) {

        # HTML quoting of content
        if ( $Param{RichText} ) {
            ATTRIBUTE:
            for my $Attribute ( sort keys %Recipient ) {
                next ATTRIBUTE if !$Recipient{$Attribute};
                $Recipient{$Attribute} = $Kernel::OM->Get('Kernel::System::HTMLUtils')->ToHTML(
                    String => $Recipient{$Attribute},
                );
            }
        }

        $HashGlobalReplace->( "$Tag|$RecipientTag", %Recipient );
    }

    # cleanup
    $Param{Text} =~ s/$RecipientTag.+?$End/-/gi;

    # get owner data and replace it with <OTRS_OWNER_...
    $Tag = $Start . 'OTRS_OWNER_';

    # include more readable version <OTRS_TICKET_OWNER
    my $OwnerTag = $Start . 'OTRS_TICKET_OWNER_';

    if ( $Ticket{OwnerID} ) {

        my %Owner = $UserObject->GetUserData(
            UserID        => $Ticket{OwnerID},
            NoOutOfOffice => 1,
        );

        # html quoting of content
        if ( $Param{RichText} ) {

            ATTRIBUTE:
            for my $Attribute ( sort keys %Owner ) {
                next ATTRIBUTE if !$Owner{$Attribute};
                $Owner{$Attribute} = $Kernel::OM->Get('Kernel::System::HTMLUtils')->ToHTML(
                    String => $Owner{$Attribute},
                );
            }
        }

        $HashGlobalReplace->( "$Tag|$OwnerTag", %Owner );
    }

    # cleanup
    $Param{Text} =~ s/$Tag.+?$End/-/gi;
    $Param{Text} =~ s/$OwnerTag.+?$End/-/gi;

    # get owner data and replace it with <OTRS_RESPONSIBLE_...
    $Tag = $Start . 'OTRS_RESPONSIBLE_';

    # include more readable version <OTRS_TICKET_RESPONSIBLE
    my $ResponsibleTag = $Start . 'OTRS_TICKET_RESPONSIBLE_';

    if ( $Ticket{ResponsibleID} ) {
        my %Responsible = $UserObject->GetUserData(
            UserID        => $Ticket{ResponsibleID},
            NoOutOfOffice => 1,
        );

        # HTML quoting of content
        if ( $Param{RichText} ) {

            ATTRIBUTE:
            for my $Attribute ( sort keys %Responsible ) {
                next ATTRIBUTE if !$Responsible{$Attribute};
                $Responsible{$Attribute} = $Kernel::OM->Get('Kernel::System::HTMLUtils')->ToHTML(
                    String => $Responsible{$Attribute},
                );
            }
        }

        $HashGlobalReplace->( "$Tag|$ResponsibleTag", %Responsible );
    }

    # cleanup
    $Param{Text} =~ s/$Tag.+?$End/-/gi;
    $Param{Text} =~ s/$ResponsibleTag.+?$End/-/gi;

    $Tag = $Start . 'OTRS_Agent_';
    my $Tag2        = $Start . 'OTRS_CURRENT_';
    my %CurrentUser = $UserObject->GetUserData(
        UserID        => $Param{UserID},
        NoOutOfOffice => 1,
    );

    # HTML quoting of content
    if ( $Param{RichText} ) {

        ATTRIBUTE:
        for my $Attribute ( sort keys %CurrentUser ) {
            next ATTRIBUTE if !$CurrentUser{$Attribute};
            $CurrentUser{$Attribute} = $Kernel::OM->Get('Kernel::System::HTMLUtils')->ToHTML(
                String => $CurrentUser{$Attribute},
            );
        }
    }

    $HashGlobalReplace->( "$Tag|$Tag2", %CurrentUser );

    # replace other needed stuff
    $Param{Text} =~ s/$Start OTRS_FIRST_NAME $End/$CurrentUser{UserFirstname}/gxms;
    $Param{Text} =~ s/$Start OTRS_LAST_NAME $End/$CurrentUser{UserLastname}/gxms;

    # cleanup
    $Param{Text} =~ s/$Tag2.+?$End/-/gi;

    # ticket data
    $Tag = $Start . 'OTRS_TICKET_';

    # html quoting of content
    if ( $Param{RichText} ) {

        ATTRIBUTE:
        for my $Attribute ( sort keys %Ticket ) {
            next ATTRIBUTE if !$Ticket{$Attribute};
            $Ticket{$Attribute} = $Kernel::OM->Get('Kernel::System::HTMLUtils')->ToHTML(
                String => $Ticket{$Attribute},
            );
        }
    }

    # Dropdown, Checkbox and MultipleSelect DynamicFields, can store values (keys) that are
    # different from the the values to display
    # <OTRS_TICKET_DynamicField_NameX> returns the stored key
    # <OTRS_TICKET_DynamicField_NameX_Value> returns the display value

    my %DynamicFields;

    # For systems with many Dynamic fields we do not want to load them all unless needed
    # Find what Dynamic Field Values are requested
    while ( $Param{Text} =~ m/$Tag DynamicField_(\S+?)(_Value)? $End/gixms ) {
        $DynamicFields{$1} = 1;
    }

    # to store all the required DynamicField display values
    my %DynamicFieldDisplayValues;

    # get dynamic field objects
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # START BLOCK SUP
    my $JSONObject                = $Kernel::OM->Get('Kernel::System::JSON');
    my $LayoutObject              = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $BackendObject             = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $DynamicFieldTableObject;

    my $MainObject = $Kernel::OM->Get('Kernel::System::Main');

    if ( $MainObject->Require( 'Kernel::System::DynamicFieldTable', Silent => 1 ) ) {
        $DynamicFieldTableObject = $Kernel::OM->Get('Kernel::System::DynamicFieldTable');
    }

    # END BLOCK SUP

    # get the dynamic fields for ticket object
    my $DynamicFieldList = $DynamicFieldObject->DynamicFieldListGet(
        Valid      => 1,
        ObjectType => ['Ticket'],
    ) || [];

    # cycle through the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicFieldList} ) {

        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        # we only load the ones requested
        next DYNAMICFIELD if !$DynamicFields{ $DynamicFieldConfig->{Name} };

        my $LanguageObject;

        # translate values if needed
        if ( $Param{Language} ) {
            $LanguageObject = Kernel::Language->new(
                UserLanguage => $Param{Language},
            );
        }

        # get the display value for each dynamic field
        my $DisplayValue = $DynamicFieldBackendObject->ValueLookup(
            DynamicFieldConfig => $DynamicFieldConfig,
            Key                => $Ticket{ 'DynamicField_' . $DynamicFieldConfig->{Name} },
            LanguageObject     => $LanguageObject,
        );

        # get the readable value (value) for each dynamic field
        my $DisplayValueStrg = $DynamicFieldBackendObject->ReadableValueRender(
            DynamicFieldConfig => $DynamicFieldConfig,
            Value              => $DisplayValue,
        );

        # fill the DynamicFielsDisplayValues
        if ($DisplayValueStrg) {
            $DynamicFieldDisplayValues{ 'DynamicField_' . $DynamicFieldConfig->{Name} . '_Value' }
                = $DisplayValueStrg->{Value};
        }

        # START BLOCK SUP

        my $ValueStrg;

        if ( $DynamicFieldConfig->{FieldType} eq 'Table' && $DynamicFieldTableObject ){
					
			my $JSONData = $DynamicFieldTableObject->ValueGetTag(
				ObjectID => $Ticket{TicketID},
                FieldID => $DynamicFieldConfig->{ID} 
			);	
			
		    my $PerlStructureScalar = $JSONObject->Decode(
				Data => $JSONData,
			);

            my %SortColumn;
            my $Count = 1;
            for (@{$DynamicFieldConfig->{Config}->{PossibleColumns}}){
                $SortColumn{$Count} = $_->{display};
                $Count++;
            }        

            my $Flag = 0;
			my (@TableSort, @Header);
            for (@{$PerlStructureScalar}){
                my %RowSort;
			    for my $Key (sort keys %SortColumn){
                    
                    $RowSort{$Key} = $_->{$SortColumn{$Key}};

                    if(!$Flag){
                        push @Header, $SortColumn{$Key};
                    }
                }

                my $SizeColumn = scalar keys %{$_};
                my $SizeSortColumn = scalar keys %SortColumn;

                if($SizeColumn > $SizeSortColumn){
                    $RowSort{$SizeColumn} = $_->{'RowTotal'};
                    if(!$Flag){
                        push @Header, 'RowTotal';
                    }
                }               

                $Flag = 1;
                push @TableSort, sort \%RowSort;
            }

            for my $Header (@Header){
				$LayoutObject->Block(
					Name => 'HeaderRow',
					Data => {
						Column => $Header,
					},
				);
			}

            for my $Row (@TableSort){

                my @Values;

                for (sort keys %{$Row}){
                    push @Values, $Row->{$_};
                }
							
				$LayoutObject->Block(
                    Name => 'Row',
                    Data => {},
                );
				
				foreach my $Values (@Values){
					$LayoutObject->Block(
						Name => 'ValuesRow',
						Data => {
							Values => $Values,
						},
					);
				}				
			}
						
			# generate HTML
			$ValueStrg->{Value} = $LayoutObject->Output(
				TemplateFile => "DynamicFieldTable/AgentDynamicFieldTable"				
			);			
		
		}
        elsif( $DynamicFieldConfig->{FieldType} eq 'CheckList' ){
 
            my $Value = $BackendObject->ValueGet(
                DynamicFieldConfig => $DynamicFieldConfig,      
                ObjectID           => $Ticket{TicketID},                                                                                                                                 
            );
			
			my $DecodeValue;

            if( $Value ){
                $DecodeValue = $JSONObject->Decode(  
                    Data => $Value,
                );
            }

            for my $TableHeader ( @{$DynamicFieldConfig->{Config}{PossibleColumns}} ){
                $LayoutObject->Block(
                    Name => 'TableHeader',
                    Data => {
                        TableHeader     => $TableHeader,
                    }
                );
            }

            if( $DecodeValue ){

                for my $TableData ( @{$DecodeValue} ){

                    $LayoutObject->Block(
                        Name => 'TableBody',
                        Data => {
                            TableLabel     => $TableData->{Label},
                        }
                    );

                    my $CounterColumns = 0;
                    for my $DFColumn ( @{$DynamicFieldConfig->{Config}{PossibleColumns}} ){
                        $CounterColumns ++;

                        my $Checked = '';

                        if( $TableData->{Coluns}[$CounterColumns - 1] eq '1' ){
                            $Checked = 'checked = checked';
                        }

                        $LayoutObject->Block(
                            Name => 'TableBodyData',
                            Data => {
                                TableLabel     => $TableData->{Label},
                                Checked        => $Checked,
                            }
                        );
                    
                    }
                }
                
            }else{

                for my $TableData (@{$DynamicFieldConfig->{Config}{PossibleLines}} ){

                    $LayoutObject->Block(
                        Name => 'TableBody',
                        Data => {
                            TableLabel     => $TableData,
                        }
                    );

                    for my $DFColumn ( @{$DynamicFieldConfig->{Config}{PossibleColumns}} ){

                        $LayoutObject->Block(
                            Name => 'TableBodyData',
                            Data => {
                                TableLabel     => $TableData,
                            }
                        );
                    
                    }
                }

            }

			# generate HTML
			$ValueStrg->{Value} = $LayoutObject->Output(
				TemplateFile => "DynamicFieldChecklist/AgentDynamicFieldChecklist"				
			);			
        }
        else{
            # get the readable value (key) for each dynamic field
            $ValueStrg = $DynamicFieldBackendObject->ReadableValueRender(
                DynamicFieldConfig => $DynamicFieldConfig,
                Value              => $Ticket{ 'DynamicField_' . $DynamicFieldConfig->{Name} },
            );
        }

        # END BLOCK SUP

        # replace ticket content with the value from ReadableValueRender (if any)
        if ( IsHashRefWithData($ValueStrg) ) {
            $Ticket{ 'DynamicField_' . $DynamicFieldConfig->{Name} } = $ValueStrg->{Value};
        }
    }

    # replace it
    $HashGlobalReplace->( $Tag, %Ticket, %DynamicFieldDisplayValues );

    # COMPAT
    $Param{Text} =~ s/$Start OTRS_TICKET_ID $End/$Ticket{TicketID}/gixms;
    $Param{Text} =~ s/$Start OTRS_TICKET_NUMBER $End/$Ticket{TicketNumber}/gixms;
    if ( $Ticket{TicketID} ) {
        $Param{Text} =~ s/$Start OTRS_QUEUE $End/$Ticket{Queue}/gixms;
    }
    if ( $Param{QueueID} ) {
        $Param{Text} =~ s/$Start OTRS_TICKET_QUEUE $End/$Queue{Name}/gixms;
    }

    # cleanup
    $Param{Text} =~ s/$Tag.+?$End/-/gi;

    # get customer and agent params and replace it with <OTRS_CUSTOMER_... or <OTRS_AGENT_...
    my %ArticleData = (
        'OTRS_CUSTOMER_' => $Param{Data}      || {},
        'OTRS_AGENT_'    => $Param{DataAgent} || {},
    );

    # use a list to get customer first
    for my $DataType (qw(OTRS_CUSTOMER_ OTRS_AGENT_)) {
        my %Data = %{ $ArticleData{$DataType} };

        # HTML quoting of content
        if ( $Param{RichText} ) {

            ATTRIBUTE:
            for my $Attribute ( sort keys %Data ) {
                next ATTRIBUTE if !$Data{$Attribute};

                $Data{$Attribute} = $Kernel::OM->Get('Kernel::System::HTMLUtils')->ToHTML(
                    String => $Data{$Attribute},
                );
            }
        }

        if (%Data) {

            # replace <OTRS_CUSTOMER_*> and <OTRS_AGENT_*> tags
            $Tag = $Start . $DataType;
            $HashGlobalReplace->( $Tag, %Data );

            # prepare body (insert old email) <OTRS_CUSTOMER_EMAIL[n]>, <OTRS_CUSTOMER_NOTE[n]>
            #   <OTRS_CUSTOMER_BODY[n]>, <OTRS_AGENT_EMAIL[n]>..., <OTRS_COMMENT>

            # Changed this to a 'while' to allow the same key/tag multiple times and different number of lines.
            while (
                $Param{Text} =~ /$Start(?:$DataType(EMAIL|NOTE|BODY)\[(.+?)\])$End/
                ||
                $Param{Text} =~ /$Start(?:OTRS_COMMENT(\[(.+?)\])?)$End/
                )
            {

                my $Line       = $2 || 2500;
                my $NewOldBody = '';
                my @Body       = split( /\n/, $Data{Body} );

                for my $Counter ( 0 .. $Line - 1 ) {

                    # 2002-06-14 patch of Pablo Ruiz Garcia
                    # http://lists.otrs.org/pipermail/dev/2002-June/000012.html
                    if ( $#Body >= $Counter ) {

                        # add no quote char, do it later by using DocumentCleanup()
                        if ( $Param{RichText} ) {
                            $NewOldBody .= $Body[$Counter];
                        }

                        # add "> " as quote char
                        else {
                            $NewOldBody .= "> $Body[$Counter]";
                        }

                        # add new line
                        if ( $Counter < ( $Line - 1 ) ) {
                            $NewOldBody .= "\n";
                        }
                    }
                    $Counter++;
                }

                chomp $NewOldBody;

                # HTML quoting of content
                if ( $Param{RichText} && $NewOldBody ) {

                    # remove trailing new lines
                    for ( 1 .. 10 ) {
                        $NewOldBody =~ s/(<br\/>)\s{0,20}$//gs;
                    }

                    # add quote
                    $NewOldBody = "<blockquote type=\"cite\">$NewOldBody</blockquote>";
                    $NewOldBody = $Kernel::OM->Get('Kernel::System::HTMLUtils')->DocumentCleanup(
                        String => $NewOldBody,
                    );
                }

                # replace tag
                $Param{Text}
                    =~ s/$Start(?:(?:$DataType(EMAIL|NOTE|BODY)\[(.+?)\]|(?:OTRS_COMMENT(\[(.+?)\])?)))$End/$NewOldBody/;
            }

            # replace <OTRS_CUSTOMER_SUBJECT[]>  and  <OTRS_AGENT_SUBJECT[]> tags
            $Tag = "$Start$DataType" . 'SUBJECT';
            if ( $Param{Text} =~ /$Tag\[(.+?)\]$End/g ) {

                my $SubjectChar = $1;
                my $Subject     = $Kernel::OM->Get('Kernel::System::Ticket')->TicketSubjectClean(
                    TicketNumber => $Ticket{TicketNumber},
                    Subject      => $Data{Subject},
                );

                $Subject =~ s/^(.{$SubjectChar}).*$/$1 [...]/;
                $Param{Text} =~ s/$Tag\[.+?\]$End/$Subject/g;
            }

            if ( $DataType eq 'OTRS_CUSTOMER_' ) {

                # Arnold Ligtvoet - otrs@ligtvoet.org
                # get <OTRS_EMAIL_DATE[]> from body and replace with received date
                use POSIX qw(strftime);
                $Tag = $Start . 'OTRS_EMAIL_DATE';

                if ( $Param{Text} =~ /$Tag\[(.+?)\]$End/g ) {

                    my $TimeZone       = $1;
                    my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');
                    my $EmailDate      = $DateTimeObject->Format( Format => '%A, %B %e, %Y at %T ' );
                    $EmailDate .= "($TimeZone)";
                    $Param{Text} =~ s/$Tag\[.+?\]$End/$EmailDate/g;
                }
            }
        }

        if ( $DataType eq 'OTRS_CUSTOMER_' ) {

            # get and prepare realname
            $Tag = $Start . 'OTRS_CUSTOMER_REALNAME';
            if ( $Param{Text} =~ /$Tag$End/i ) {

                my $From;

                if ( $Ticket{CustomerUserID} ) {

                    $From = $Kernel::OM->Get('Kernel::System::CustomerUser')->CustomerName(
                        UserLogin => $Ticket{CustomerUserID}
                    );
                }

                # try to get the real name directly from the data
                $From //= $Recipient{Realname};

                # get real name based on reply-to
                if ( $Data{ReplyTo} ) {
                    $From = $Data{ReplyTo};

                    # remove email addresses
                    $From =~ s/&lt;.*&gt;|<.*>|\(.*\)|\"|&quot;|;|,//g;

                    # remove leading/trailing spaces
                    $From =~ s/^\s+//g;
                    $From =~ s/\s+$//g;
                }

                # generate real name based on sender line
                if ( !$From ) {
                    $From = $Data{To} || '';

                    # remove email addresses
                    $From =~ s/&lt;.*&gt;|<.*>|\(.*\)|\"|&quot;|;|,//g;

                    # remove leading/trailing spaces
                    $From =~ s/^\s+//g;
                    $From =~ s/\s+$//g;
                }

                # replace <OTRS_CUSTOMER_REALNAME> with from
                $Param{Text} =~ s/$Tag$End/$From/g;
            }
        }
    }

    # get customer data and replace it with <OTRS_CUSTOMER_DATA_...
    $Tag  = $Start . 'OTRS_CUSTOMER_';
    $Tag2 = $Start . 'OTRS_CUSTOMER_DATA_';

    if ( $Ticket{CustomerUserID} || $Param{Data}->{CustomerUserID} ) {

        my $CustomerUserID = $Param{Data}->{CustomerUserID} || $Ticket{CustomerUserID};

        my %CustomerUser = $Kernel::OM->Get('Kernel::System::CustomerUser')->CustomerUserDataGet(
            User => $CustomerUserID,
        );

        # HTML quoting of content
        if ( $Param{RichText} ) {

            ATTRIBUTE:
            for my $Attribute ( sort keys %CustomerUser ) {
                next ATTRIBUTE if !$CustomerUser{$Attribute};
                $CustomerUser{$Attribute} = $Kernel::OM->Get('Kernel::System::HTMLUtils')->ToHTML(
                    String => $CustomerUser{$Attribute},
                );
            }
        }

        # replace it
        $HashGlobalReplace->( "$Tag|$Tag2", %CustomerUser );
    }

    # cleanup all not needed <OTRS_CUSTOMER_DATA_ tags
    $Param{Text} =~ s/(?:$Tag|$Tag2).+?$End/-/gi;

    # cleanup all not needed <OTRS_AGENT_ tags
    $Tag = $Start . 'OTRS_AGENT_';
    $Param{Text} =~ s/$Tag.+?$End/-/gi;

    return $Param{Text};
}

1;