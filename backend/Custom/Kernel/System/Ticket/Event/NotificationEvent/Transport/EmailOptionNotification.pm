# --
# Custom/Kernel/System/Ticket/Event/NotificationEvent/Transport/EmailOptionNotification.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::System::Ticket::Event::NotificationEvent::Transport::EmailOptionNotification;
## nofilter(TidyAll::Plugin::OTRS::Perl::LayoutObject)
## nofilter(TidyAll::Plugin::OTRS::Perl::ParamObject)

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

use parent qw(Kernel::System::Ticket::Event::NotificationEvent::Transport::Base);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::CustomerUser',
    'Kernel::System::Crypt::PGP',
    'Kernel::System::Crypt::SMIME',
    'Kernel::System::Email',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::Queue',
    'Kernel::System::SystemAddress',
    'Kernel::System::Ticket',
    'Kernel::System::Ticket::Article',
    'Kernel::System::Ticket::Article::Backend::Email',
    'Kernel::System::User',
    'Kernel::System::Web::Request',
);

=head1 NAME

Kernel::System::Ticket::Event::NotificationEvent::Transport::Email - email transport layer

=head1 DESCRIPTION

Notification event transport layer.

=head1 PUBLIC INTERFACE

=head2 new()

create a notification transport object. Do not use it directly, instead use:

    my $TransportObject = $Kernel::OM->Get('Kernel::System::Ticket::Event::NotificationEvent::Transport::Email');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub SendNotification {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(TicketID UserID Notification Recipient)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # cleanup event data
    $Self->{EventData} = undef;

    # get needed objects
    my $ConfigObject        = $Kernel::OM->Get('Kernel::Config');
    my $DynamicFieldObject  = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $HTMLUtilsObject     = $Kernel::OM->Get('Kernel::System::HTMLUtils');
    my $SystemAddressObject = $Kernel::OM->Get('Kernel::System::SystemAddress');
    my $LayoutObject        = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # get recipient data
    my %Recipient = %{ $Param{Recipient} };    

    # Verify a customer have an email
    if ( $Recipient{Type} eq 'Customer' && $Recipient{UserID} && !$Recipient{UserEmail} ) {

        my %CustomerUser = $Kernel::OM->Get('Kernel::System::CustomerUser')->CustomerUserDataGet(
            User => $Recipient{UserID},
        );

        if ( !$CustomerUser{UserEmail} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'info',
                Message  => "Send no customer notification because of missing "
                    . "customer email (CustomerUserID=$CustomerUser{CustomerUserID})!",
            );
            return;
        }

        # Set calculated email.
        $Recipient{UserEmail} = $CustomerUser{UserEmail};
    }

    return if !$Recipient{UserEmail};

    return if $Recipient{UserEmail} !~ /@/;

    my $IsLocalAddress = $Kernel::OM->Get('Kernel::System::SystemAddress')->SystemAddressIsLocalAddress(
        Address => $Recipient{UserEmail},
    );

    return if $IsLocalAddress;

    my %Notification = %{ $Param{Notification} };    

    # get configs 
    # my $EventFields      = $ConfigObject->Get('InBox::EmailOption::DynamicFieldEvent');
    # my $PublicField      = $ConfigObject->Get('InBox::EmailOption::DynamicFieldPublicKey');
    my $EmailOptionField = $ConfigObject->Get('InBox::EmailOption::DynamicFieldsEnabledValues');

    for my $Field ( keys  %{ $EmailOptionField } ) {

        my $OptionDynamicField = $DynamicFieldObject->DynamicFieldGet(
            Name => $Field,
        );

        $Notification{Body} = $Self->_CreateOptionKeyAttribute(
            TicketID => $Param{TicketID},
            Message  => $Notification{Body},
            SendTo   => $Recipient{UserEmail},
            Field    => $OptionDynamicField,
            Values   => $EmailOptionField->{$Field}
        );
    }

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    if ( $Param{Notification}->{ContentType} && $Param{Notification}->{ContentType} eq 'text/html' ) {

        # Get configured template with fallback to Default.
        my $EmailTemplate = $Param{Notification}->{Data}->{TransportEmailTemplateEmailOption}->[0] || 'Default';

        my $Home              = $Kernel::OM->Get('Kernel::Config')->Get('Home');
        my $TemplateDir       = "$Home/Kernel/Output/HTML/Templates/Standard/NotificationEvent/Email";
        my $CustomTemplateDir = "$Home/Custom/Kernel/Output/HTML/Templates/Standard/NotificationEvent/Email";

        if ( !-r "$TemplateDir/$EmailTemplate.tt" && !-r "$CustomTemplateDir/$EmailTemplate.tt" ) {
            $EmailTemplate = 'Default';
        }

        my $RecipientLanugageObject = $LayoutObject->{LanguageObject};

        if ( $Recipient{UserLanguage} ) {

            # Create new language object to include recipient language preference if applicable.
            $RecipientLanugageObject = Kernel::Language->new(
                UserLanguage => $Recipient{UserLanguage},
            );
        }

        local $LayoutObject->{LanguageObject} = $RecipientLanugageObject;

        # generate HTML
        $Notification{Body} = $LayoutObject->Output(
            TemplateFile => "NotificationEvent/Email/$EmailTemplate",
            Data         => {
                TicketID => $Param{TicketID},
                Body     => $Notification{Body},
                Subject  => $Notification{Subject},
            },
        );
    }    

    # send notification
    if ( $Recipient{Type} eq 'Agent' ) {

        my $FromEmail = $ConfigObject->Get('NotificationSenderEmail');

        # send notification
        my $From = $ConfigObject->Get('NotificationSenderName') . ' <'
            . $FromEmail . '>';

        # security part
        my $SecurityOptions = $Self->SecurityOptionsGet( %Param, FromEmail => $FromEmail );
        return if !$SecurityOptions;

        # get needed objects
        my $EmailObject = $Kernel::OM->Get('Kernel::System::Email');

        my $Sent = $EmailObject->Send(
            From          => $From,
            To            => $Recipient{UserEmail},
            Subject       => $Notification{Subject},
            MimeType      => $Notification{ContentType},
            Type          => $Notification{ContentType},
            Charset       => 'utf-8',
            Body          => $Notification{Body},
            Loop          => 1,
            Attachment    => $Param{Attachments},
            EmailSecurity => $SecurityOptions || {},
        );

        if ( !$Sent->{Success} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "'$Notification{Name}' notification could not be sent to agent '$Recipient{UserEmail} ",
            );

            return;
        }

        # log event
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'info',
            Message  => "Sent agent '$Notification{Name}' notification to '$Recipient{UserEmail}'.",
        );

        # set event data
        $Self->{EventData} = {
            Event => 'ArticleAgentNotification',
            Data  => {
                TicketID => $Param{TicketID},
            },
            UserID => $Param{UserID},
        };
    }
    else {

        my $QueueObject   = $Kernel::OM->Get('Kernel::System::Queue');
        my $ArticleObject = $Kernel::OM->Get('Kernel::System::Ticket::Article');

        # Get last article from customer.
        my @CustomerArticles = $ArticleObject->ArticleList(
            TicketID   => $Param{TicketID},
            SenderType => 'customer',
            OnlyLast   => 1,
        );

        my %CustomerArticle;

        ARTICLE:
        for my $Article (@CustomerArticles) {
            next ARTICLE if !$Article->{ArticleID};

            %CustomerArticle = $ArticleObject->BackendForArticle( %{$Article} )->ArticleGet(
                %{$Article},
                DynamicFields => 0,
            );
        }

        my %Article = %CustomerArticle;

        # If the ticket has no customer article, get the last agent article.
        if ( !%CustomerArticle ) {

            # Get last article from agent.
            my @AgentArticles = $ArticleObject->ArticleList(
                TicketID   => $Param{TicketID},
                SenderType => 'agent',
                OnlyLast   => 1,
            );

            my %AgentArticle;

            ARTICLE:
            for my $Article (@AgentArticles) {
                next ARTICLE if !$Article->{ArticleID};

                %AgentArticle = $ArticleObject->BackendForArticle( %{$Article} )->ArticleGet(
                    %{$Article},
                    DynamicFields => 0,
                );
            }

            %Article = %AgentArticle;
        }

        # Get raw ticket data.
        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $Param{TicketID},
            DynamicFields => 0,
        );

        my %Address = $QueueObject->GetSystemAddress( QueueID => $Ticket{QueueID} );

        # get queue
        my %Queue = $QueueObject->QueueGet(
            ID => $Ticket{QueueID},
        );

        # security part
        my $SecurityOptions = $Self->SecurityOptionsGet(
            %Param,
            FromEmail => $Address{Email},
            Queue     => \%Queue
        );
        return if !$SecurityOptions;

        my $IsVisibleForCustomer = 0;
        if ( defined $Notification{Data}->{IsVisibleForCustomerEmailOption} ) {
            $IsVisibleForCustomer = $Notification{Data}->{IsVisibleForCustomerEmailOption}->[0];
        }

        my $IsVisibleForAgent = 0;
        if ( defined $Notification{Data}->{IsVisibleForAgentEmailOption} ) {
            $IsVisibleForAgent = $Notification{Data}->{IsVisibleForAgentEmailOption}->[0];
           
        }        

        # BLOCK SUP - SenderType Hidden

        my $ArticleID = $ArticleObject->BackendForChannel( ChannelName => 'Email' )->ArticleSend(
            TicketID             => $Param{TicketID},
            # SenderType           => 'system',
            SenderType           => $IsVisibleForAgent ? 'hidden_agent' : 'system',
            IsVisibleForCustomer => $IsVisibleForCustomer,
            HistoryType          => 'SendCustomerNotification',
            HistoryComment       => "\%\%$Recipient{UserEmail}",
            From                 => "$Address{RealName} <$Address{Email}>",
            To                   => $Recipient{UserEmail},
            Subject              => $Notification{Subject},
            Body                 => $Notification{Body},
            MimeType             => $Notification{ContentType},
            Type                 => $Notification{ContentType},
            Charset              => 'utf-8',
            UserID               => $Param{UserID},
            Loop                 => 1,
            Attachment           => $Param{Attachments},
            EmailSecurity        => $SecurityOptions || {},
        );

        if ( !$ArticleID ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "'$Notification{Name}' notification could not be sent to customer '$Recipient{UserEmail} ",
            );

            return;
        }

        # log event
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'info',
            Message  => "Sent customer '$Notification{Name}' notification to '$Recipient{UserEmail}'.",
        );

        # set event data
        $Self->{EventData} = {
            Event => 'ArticleCustomerNotification',
            Data  => {
                TicketID  => $Param{TicketID},
                ArticleID => $ArticleID,
            },
            UserID => $Param{UserID},
        };
    }

    return 1;
}

sub _CreateOptionKeyAttribute {
    my ( $Self, %Param ) = @_;

    # get object
    my $EmailOptionObject = $Kernel::OM->Get('Kernel::System::EmailOption');

    # check needed stuff
    for my $Needed ( qw(Message Field Values TicketID) ) {
        return if !$Param{$Needed};
    }

    if ( $Param{Message} =~ m/OTRS_EMAILOPTION_$Param{Field}->{Name}/ ) {    

        for my $Value ( keys %{ $Param{Values} } ) {	

            my $PublicKey = $EmailOptionObject->RequestSend(
                TicketID   => $Param{TicketID},
                FieldID    => $Param{Field}->{ID},
                FieldValue => $Value,
                SendTo     => $Param{SendTo}
            );

            $Param{Message} =~ s/&lt;OTRS_EMAILOPTION_$Param{Field}->{Name}_$Value&gt;/$PublicKey/g;
        }
    }  

	return $Param{Message};
}

sub GetTransportRecipients {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(Notification)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed",
            );
        }
    }

    my @Recipients;

    # get recipients by RecipientEmail
    if ( $Param{Notification}->{Data}->{RecipientEmailOption} ) {
        if ( $Param{Notification}->{Data}->{RecipientEmailOption}->[0] ) {
            my $RecipientEmail = $Param{Notification}->{Data}->{RecipientEmailOption}->[0];

            # replace OTRSish attributes in recipient email
            $RecipientEmail = $Self->_ReplaceTicketAttributes(
                Ticket => $Param{Ticket},
                Field  => $RecipientEmail,
            );

            my @RecipientEmails;

            if ( !IsArrayRefWithData($RecipientEmail) ) {

                # Split multiple recipients on known delimiters: comma and semi-colon.
                #   Do this after the OTRS tags were replaced.
                @RecipientEmails = split /[;,\s]+/, $RecipientEmail;
            }
            else {
                @RecipientEmails = @{$RecipientEmail};
            }

            # Include only valid email recipients.
            for my $Recipient (@RecipientEmails) {
                if ( $Recipient && $Recipient =~ /@/ ) {
                    push @Recipients, {
                        Realname                        => '',
                        Type                            => 'Customer',
                        UserEmail                       => $Recipient,
                        IsVisibleForCustomerEmailOption => $Param{Notification}->{Data}->{IsVisibleForCustomerEmailOption},
                    };
                }
            }
        }
    }

    return @Recipients;
}

sub TransportSettingsDisplayGet {
    my ( $Self, %Param ) = @_;

    KEY:
    for my $Key ( qw( RecipientEmailOption ) ) {
        next KEY if !$Param{Data}->{$Key};
        next KEY if !defined $Param{Data}->{$Key}->[0];
        $Param{$Key} = $Param{Data}->{$Key}->[0];
    }

    my $Home              = $Kernel::OM->Get('Kernel::Config')->Get('Home');
    my $TemplateDir       = "$Home/Kernel/Output/HTML/Templates/Standard/NotificationEvent/Email";
    my $CustomTemplateDir = "$Home/Custom/Kernel/Output/HTML/Templates/Standard/NotificationEvent/Email";

    my @Files = $Kernel::OM->Get('Kernel::System::Main')->DirectoryRead(
        Directory => $TemplateDir,
        Filter    => '*.tt',
    );

    if ( -d $CustomTemplateDir ) {
        push @Files, $Kernel::OM->Get('Kernel::System::Main')->DirectoryRead(
            Directory => $CustomTemplateDir,
            Filter    => '*.tt',
        );
    }

    # for deduplication
    my %Templates;

    for my $File (@Files) {
        $File =~ s{^.*/([^/]+)\.tt}{$1}smxg;
        $Templates{$File} = $File;
    }

    # get layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    $Param{TransportEmailTemplateStrgEmailOption} = $LayoutObject->BuildSelection(
        Data        => \%Templates,
        Name        => 'TransportEmailTemplateEmailOption',
        Translation => 0,
        SelectedID  => $Param{Data}->{TransportEmailTemplateEmailOption} || 'Default',
        Class       => 'Modernize W50pc',
    );

    # my $ReplyCustomTemplateDir = "$Home/Custom/Kernel/Output/HTML/Templates/Standard/EmailOption";

    # my @CustomTemplates;

    # if ( -d $ReplyCustomTemplateDir ) {
    #     push @CustomTemplates, $Kernel::OM->Get('Kernel::System::Main')->DirectoryRead(
    #         Directory => $ReplyCustomTemplateDir,
    #         Filter    => '*.tt',
    #     );
    # }

    # my %ReplyTemplates;

    # for my $CustomTemplate (@CustomTemplates) {
    #     $CustomTemplate =~ s{^.*/([^/]+)\.tt}{$1}smxg;
    #     $ReplyTemplates{$CustomTemplate} = $CustomTemplate;
    # }

    # # get layout object
    # $Param{ReplyTemplateStrgEmailOption} = $LayoutObject->BuildSelection(
    #     Data        => \%ReplyTemplates,
    #     Name        => 'ReplyTemplateEmailOption',
    #     Translation => 0,
    #     SelectedID  => $Param{Data}->{ReplyTemplateEmailOption} || 'Default',
    #     Class       => 'Modernize W50pc',
    # );

    # security fields

    # get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my %SecuritySignEncryptOptions;

    if ( $ConfigObject->Get('PGP') ) {
        $SecuritySignEncryptOptions{'PGPSign'}      = Translatable('PGP sign only');
        $SecuritySignEncryptOptions{'PGPCrypt'}     = Translatable('PGP encrypt only');
        $SecuritySignEncryptOptions{'PGPSignCrypt'} = Translatable('PGP sign and encrypt');
    }

    if ( $ConfigObject->Get('SMIME') ) {
        $SecuritySignEncryptOptions{'SMIMESign'}      = Translatable('SMIME sign only');
        $SecuritySignEncryptOptions{'SMIMECrypt'}     = Translatable('SMIME encrypt only');
        $SecuritySignEncryptOptions{'SMIMESignCrypt'} = Translatable('SMIME sign and encrypt');
    }

    # set security settings enabled
    $Param{EmailSecuritySettingsEmailOption} = ( $Param{Data}->{EmailSecuritySettingsEmailOption} ? 'checked="checked"' : '' );
    $Param{SecurityDisabled}      = 0;

    if ( $Param{EmailSecuritySettingsEmailOption} eq '' ) {
        $Param{SecurityDisabled} = 1;
    }

    if ( !IsHashRefWithData( \%SecuritySignEncryptOptions ) ) {
        $Param{EmailSecuritySettingsEmailOption} = 'disabled="disabled"';
        $Param{EmailSecurityInfoEmailOption}     = Translatable('PGP and SMIME not enabled.');
    }

    # create security methods field
    $Param{EmailOptionEmailSigningCrypting} = $LayoutObject->BuildSelection(
        Data         => \%SecuritySignEncryptOptions,
        Name         => 'EmailSigningCryptingEmailOption',
        SelectedID   => $Param{Data}->{EmailSigningCryptingEmailOption},
        Class        => 'Security Modernize W50pc',
        Multiple     => 0,
        Translation  => 1,
        PossibleNone => 1,
        Disabled     => $Param{SecurityDisabled},
    );

    # create missing signing actions field
    $Param{EmailMissingSigningKeysEmailOption} = $LayoutObject->BuildSelection(
        Data => [
            {
                Key   => 'Skip',
                Value => Translatable('Skip notification delivery'),
            },
            {
                Key   => 'Send',
                Value => Translatable('Send unsigned notification'),
            },
        ],
        Name        => 'EmailMissingSigningKeysEmailOption',
        SelectedID  => $Param{Data}->{EmailMissingSigningKeysEmailOption},
        Class       => 'Security Modernize W50pc',
        Multiple    => 0,
        Translation => 1,
        Disabled    => $Param{SecurityDisabled},
    );

    # create missing crypting actions field
    $Param{EmailMissingCryptingKeysEmailOption} = $LayoutObject->BuildSelection(
        Data => [
            {
                Key   => 'Skip',
                Value => Translatable('Skip notification delivery'),
            },
            {
                Key   => 'Send',
                Value => Translatable('Send unencrypted notification'),
            },
        ],
        Name        => 'EmailMissingCryptingKeysEmailOption',
        SelectedID  => $Param{Data}->{EmailMissingCryptingKeysEmailOption},
        Class       => 'Security Modernize W50pc',
        Multiple    => 0,
        Translation => 1,
        Disabled    => $Param{SecurityDisabled},
    );

    # generate HTML
    my $Output = $LayoutObject->Output(
        TemplateFile => 'AdminNotificationEventTransportEmailOptionSettings',
        Data         => \%Param,
    );

    return $Output;
}

sub TransportParamSettingsGet {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(GetParam)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed",
            );
        }
    }

    # get param object
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    PARAMETER:
    for my $Parameter (
        qw(Recipient TransportEmailTemplate IsVisibleForAgent IsVisibleForCustomer
        EmailSigningCrypting EmailMissingSigningKeys EmailMissingCryptingKeys
        EmailSecuritySettings)
        )
    {
        my @Data = $ParamObject->GetArray( Param => $Parameter . 'EmailOption' );
        next PARAMETER if !@Data;
        $Param{GetParam}->{Data}->{$Parameter. 'EmailOption'} = \@Data;
    }

    # Note: Example how to set errors and use them
    # on the normal AdminNotificationEvent screen
    # # set error
    # $Param{GetParam}->{$Parameter.'ServerError'} = 'ServerError';

    return 1;
}

sub IsUsable {
    my ( $Self, %Param ) = @_;

    # define if this transport is usable on
    # this specific moment
    return 1;
}

sub SecurityOptionsGet {
    my ( $Self, %Param ) = @_;

    # Verify security options are enabled.
    my $EnableSecuritySettings = $Param{Notification}->{Data}->{EmailSecuritySettingsEmailOption}->[0] || '';

    # Return empty hash ref to continue with email sending (without security options).
    return {} if !$EnableSecuritySettings;

    # Verify if the notification has to be signed or encrypted
    my $SignEncryptNotification = $Param{Notification}->{Data}->{EmailSigningCryptingEmailOption}->[0] || '';

    # Return empty hash ref to continue with email sending (without security options).
    return {} if !$SignEncryptNotification;

    my %Queue = %{ $Param{Queue} || {} };

    # Define who is going to be the sender (from the given parameters)
    my $NotificationSenderEmail = $Param{FromEmail};

    # Define security options container
    my %SecurityOptions = (
        Method => 'Detached',
    );

    my @SignKeys;
    my @EncryptKeys;
    my $KeyField;

    # Get private and public keys for the given backend (PGP or SMIME)
    if ( $SignEncryptNotification =~ /^PGP/i ) {

        my $PGPObject = $Kernel::OM->Get('Kernel::System::Crypt::PGP');

        if ( !$PGPObject ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "No PGP support!",
            );
            return;
        }

        @SignKeys = $PGPObject->PrivateKeySearch(
            Search => $NotificationSenderEmail,
        );

        # Take just valid keys.
        @SignKeys = grep { $_->{Status} eq 'good' } @SignKeys;

        @EncryptKeys = $PGPObject->PublicKeySearch(
            Search => $Param{Recipient}->{UserEmail},
        );

        # Take just valid keys.
        @EncryptKeys = grep { $_->{Status} eq 'good' } @EncryptKeys;

        # Get PGP method (Detached or In-line).
        if ( !$Kernel::OM->Get('Kernel::Output::HTML::Layout')->{BrowserRichText} ) {
            $SecurityOptions{Method} = $Kernel::OM->Get('Kernel::Config')->Get('PGP::Method') || 'Detached';
        }

        $SecurityOptions{Backend} = 'PGP';
        $KeyField = 'Key';
    }
    elsif ( $SignEncryptNotification =~ /^SMIME/i ) {

        my $SMIMEObject = $Kernel::OM->Get('Kernel::System::Crypt::SMIME');

        if ( !$SMIMEObject ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "No SMIME support!",
            );
            return;
        }

        # Take just valid keys.
        @SignKeys = $SMIMEObject->PrivateSearch(
            Search => $NotificationSenderEmail,
            Valid  => 1,
        );

        # Take just valid keys.
        @EncryptKeys = $SMIMEObject->CertificateSearch(
            Search => $Param{Recipient}->{UserEmail},
            Valid  => 1,
        );

        $SecurityOptions{Backend} = 'SMIME';
        $KeyField = 'Filename';
    }

    # Initialize sign key container
    my %SignKey;

    # Initialize crypt key container
    my %EncryptKey;

    # Get default signing key from the queue (if applies).
    if ( $Queue{DefaultSignKey} ) {

        my $DefaultSignKey;

        # Convert legacy stored default sign keys.
        if ( $Queue{DefaultSignKey} =~ m{ (?: Inline|Detached ) }msx ) {
            my ( $Type, $SubType, $Key ) = split /::/, $Queue{DefaultSignKey};
            $DefaultSignKey = $Key;
        }
        else {
            my ( $Type, $Key ) = split /::/, $Queue{DefaultSignKey};
            $DefaultSignKey = $Key;
        }

        if ( grep { $_->{$KeyField} eq $DefaultSignKey } @SignKeys ) {
            $SignKey{$KeyField} = $DefaultSignKey;
        }
    }

    # Otherwise take the first signing key available.
    if ( !%SignKey ) {
        SIGNKEY:
        for my $SignKey (@SignKeys) {
            %SignKey = %{$SignKey};
            last SIGNKEY;
        }
    }

    # Also take the first encryption key available.
    CRYPTKEY:
    for my $EncryptKey (@EncryptKeys) {
        %EncryptKey = %{$EncryptKey};
        last CRYPTKEY;
    }

    my $OnMissingSigningKeys = $Param{Notification}->{Data}->{EmailOptionEmailMissingSigningKeys}->[0] || '';

    # Add options to sign the notification
    if ( $SignEncryptNotification =~ /Sign/i ) {

        # Take an action if there are missing signing keys.
        if ( !IsHashRefWithData( \%SignKey ) ) {

            my $Message
                = "Could not sign notification '$Param{Notification}->{Name}' due to missing $SecurityOptions{Backend} sign key for '$NotificationSenderEmail'";

            if ( $OnMissingSigningKeys eq 'Skip' ) {

                # Log skipping notification (return nothing to stop email sending).
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'notice',
                    Message  => $Message . ', skipping notification distribution!',
                );

                return;
            }

            # Log sending unsigned notification.
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'notice',
                Message  => $Message . ', sending unsigned!',
            );
        }

        # Add signature option if a sign key is available
        else {
            $SecurityOptions{SignKey} = $SignKey{$KeyField};
        }
    }

    my $OnMissingEncryptionKeys = $Param{Notification}->{Data}->{EmailMissingCryptingKeysEmailOption}->[0] || '';

    # Add options to encrypt the notification
    if ( $SignEncryptNotification =~ /Crypt/i ) {

        # Take an action if there are missing encryption keys.
        if ( !IsHashRefWithData( \%EncryptKey ) ) {

            my $Message
                = "Could not encrypt notification '$Param{Notification}->{Name}' due to missing $SecurityOptions{Backend} encryption key for '$Param{Recipient}->{UserEmail}'";

            if ( $OnMissingEncryptionKeys eq 'Skip' ) {

                # Log skipping notification (return nothing to stop email sending).
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'notice',
                    Message  => $Message . ', skipping notification distribution!',
                );

                return;
            }

            # Log sending unencrypted notification.
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'notice',
                Message  => $Message . ', sending unencrypted!',
            );
        }

        # Add encrypt option if a encrypt key is available
        else {
            $SecurityOptions{EncryptKeys} = [ $EncryptKey{$KeyField}, ];
        }
    }

    return \%SecurityOptions;

}

1;