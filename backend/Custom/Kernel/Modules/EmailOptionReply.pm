# --
# Kernel/Modules/EmailOptionReply.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * gesquetini@beonup.com.br
# * lsnevelin@serviceup.com.br
# * jsantos@serviceup.com.br
# * msantos@serviceup.com.br
# * dsilva@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::Modules::EmailOptionReply;

use strict;
use warnings;

use Encode;
use utf8;

our $ObjectManagerDisabled = 1;

use Kernel::Language qw(Translatable);
use Kernel::System::VariableCheck qw(:all);

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
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my %GetParam;    

    for my $Param ( qw( Subaction PublicKey) ) {
        $GetParam{$Param} = $ParamObject->GetParam( Param => $Param ) || '';
    }

    if ( defined $GetParam{Subaction} && $GetParam{Subaction} eq 'Success' ) {

        $Self->_Sucess( %GetParam );
    }
    else {

        $Self->_Overview( %GetParam );
    }
}

sub _Overview {
    my ( $Self, %Param ) = @_;

    # get objects
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $UserObject         = $Kernel::OM->Get('Kernel::System::User');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $EmailOptionObject  = $Kernel::OM->Get('Kernel::System::EmailOption');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    
    # get request email option
    my $EmailOptionData = $EmailOptionObject->RequestGet(
        PublicKey => $Param{PublicKey}
    );

    my $DynamicFieldOption = $EmailOptionData->{FieldValue};
    my $DynamicFieldID     = $EmailOptionData->{FieldID};    
    my $ArticleIDObject    = $EmailOptionData->{AritcleID};

    # get field email option sender
    my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
        ID => $DynamicFieldID,
    );

    # get configs
    my $BaseLink                  = $ConfigObject->Get('FQDN');
    my $Configs                   = $ConfigObject->Get('InBox::EmailOption::Configs');
    
    my $ArticleParameters         = $ConfigObject->Get('InBox::EmailOption::ArticleParameters');
    my $TextToAlreadyAnswered     = $ConfigObject->Get('InBox::EmailOption::TextToAlreadyAnswered');
    my $DynamicFieldsTexts        = $ConfigObject->Get('InBox::EmailOption::DynamicFieldsTexts');
    my $VisibleArticleForCustomer = $ConfigObject->Get('InBox::EmailOption::VisibleArticleForCustomer');
    my $PossibleDynamicFields     = $ConfigObject->Get('InBox::EmailOption::DynamicFieldsEnabledValues');
    my $DefaultArticleSubject     = $ConfigObject->Get('InBox::EmailOption::DefaultSubjectOfAnsweredArticle');
    my $DefaultArticleBody        = $ConfigObject->Get('InBox::EmailOption::DefaultTextOfAnsweredArticle');
    my $AnswerAuthor              = $ConfigObject->Get('InBox::EmailOption::AnswerAuthor');
    my $ReplyTemplate             = $ConfigObject->Get('InBox::EmailOption::ReplyTemplate');

    # get subject and article text, if defined in config
    my $ArticleText = $ArticleParameters->{$DynamicFieldConfig->{Name}}->{Body};
    my $SubjectText = $ArticleParameters->{$DynamicFieldConfig->{Name}}->{Subject};

    # get ticket number
    my $TicketNumber = $TicketObject->TicketNumberLookup(
        TicketID => $EmailOptionData->{TicketID}
    );
   
    # get ticket
    my %TicketData = $TicketObject->TicketGet(
        TicketID => $EmailOptionData->{TicketID},
        DynamicFields => 1,
        UserID   => 1
    );

    # get customer user data
    my %User = $CustomerUserObject->CustomerUserDataGet(
        User => $TicketData{CustomerUserID},
    );
   
    my $ValidDF = 0;
    my $PossibleValuesConfigArticle;
        
    # check if the field is of the dropdown type and is defined in the config
    if ( $DynamicFieldConfig->{FieldType} eq 'Dropdown' && $PossibleDynamicFields->{$DynamicFieldConfig->{Name}} ) {
        $ValidDF = 1;
        $PossibleValuesConfigArticle = $PossibleDynamicFields->{$DynamicFieldConfig->{Name}};
    }

    my $Output;   

    # if field is not valid or not configured, display an error message
    if ( $ValidDF == 0 || $TicketNumber eq '' || $DynamicFieldOption eq '' || $DynamicFieldID eq '' ) {

        $Param{Description} = $LayoutObject->{LanguageObject}->Translate('An error has occurred, please contact support.');
        $Param{TextArea}    = 'Hidden';
        $Param{Link}        = "http://".$BaseLink."/znuny/index.pl?Action=AgentTicketZoom;TicketID=" . $EmailOptionData->{TicketID};

        $LayoutObject->Block(
            Name => 'Error',
            Data => {
                Description => $Param{Description},
                TextArea    => $Param{TextArea},
                Link        => $Param{Link},
                Placeholder => $Param{Error} eq 'TextRequerid' ? 'This field is requerid ...' : 'Write here...',
                Title       => $Configs->{Title},
                HeaderColor => $Configs->{HeaderColor},
                BtnColor    => $Configs->{BtnColor},
            },
        );

        $Output = $LayoutObject->CustomerHeader(
            DisableIFrameOriginRestricted => 1,
            Title 			              => $LayoutObject->{LanguageObject}->Translate('Email Option'),
            Type                          => 'Small',
        );	

        $Output .= $LayoutObject->Output(
            TemplateFile => 'EmailOption/' . $ReplyTemplate,
            Data => {
                %Param,
            },
        );

        $Output .= $LayoutObject->CustomerFooter(
            Type => 'Small',
        );

        return $Output;
    }
       
    # check if email option field has already been answered
    my $DFCheck = $EmailOptionData->{ValidID};

    # return if field has already been answered
    if ( !$DFCheck ) {

        my $Name = $UserObject->UserName(
            User => $TicketData{Responsible},
        );

        $Param{TicketNumberText} = $LayoutObject->{LanguageObject}->Translate("TicketNumber : "). $TicketNumber;

        my $Description = $TextToAlreadyAnswered->{$DynamicFieldConfig->{Name}} || '';

        # get body of the article
        $Description = $Self->_ReplaceTicketAttributes(
            Ticket  => \%TicketData,
            Message => $Description
        );

        $Param{Description} = $Description || $LayoutObject->{LanguageObject}->Translate("You have already answer!");

        $Param{Link}             = "http://".$BaseLink."/znuny/index.pl?Action=AgentTicketZoom;TicketID=" . $EmailOptionData->{TicketID};
       
        $LayoutObject->Block(
            Name => 'Warning',
            Data => {
                TicketCustomerText => $Param{TicketCustomerText},
                TicketNumberText   => $Param{TicketNumberText},
                TicketTitleText    => $Param{TicketTitleText},
                TicketAgentText    => $Param{TicketAgentText},
                Description        => $Param{Description},
                Details            => $Param{Details},
                Link               => $Param{Link},
                Title              => $Configs->{Title},
                Placeholder        => $Param{Error} eq 'TextRequerid' ? 'This field is requerid ...' : 'Write here...',
                HeaderColor        => $Configs->{HeaderColor},
                BtnColor           => $Configs->{BtnColor},
            },
        );

        $Output = $LayoutObject->CustomerHeader(
            DisableIFrameOriginRestricted => 1,
            Title 			              => $LayoutObject->{LanguageObject}->Translate('Email Option'),
            Type                          => 'Small',
        );	

        $Output .= $LayoutObject->Output(
            TemplateFile => 'EmailOption/' . $ReplyTemplate,
            Data => {
                %Param,
            },
        );

        $Output .= $LayoutObject->CustomerFooter(
            Type => 'Small',
        );

        return $Output;
    }

    my $DynamicFieldOptionName; 
    my $DynamicFieldName     = $DynamicFieldConfig->{Label};   
    my $IsVisibleForCustomer = $VisibleArticleForCustomer->{$DynamicFieldConfig->{Name}} || 0;
    my $Success              = 0;
    
    # get possible values
    my $PossibleValues = $BackendObject->PossibleValuesGet(
        DynamicFieldConfig => $DynamicFieldConfig,  
    );   

    my $ParamArticle = "";
    $Param{TextArea} = '';

    if ( defined $ArticleText ) {
        $ParamArticle .= "ArticleText=".$ArticleText.";";
    }
    if ( defined $SubjectText ) {
        $ParamArticle .= "Subject=".$SubjectText.";";
    }

    $Param{Link} = "public.pl?Action=EmailOptionReply;Subaction=Success;" . $ParamArticle . "PublicKey=$Param{PublicKey};";   

    my $AnswerDynamicField;
    if ( IsHashRefWithData($AnswerAuthor) ) {

        # get field where it will be saved who replied to the email
        $AnswerDynamicField = $DynamicFieldObject->DynamicFieldGet(
            Name => $AnswerAuthor->{ $DynamicFieldConfig->{Name} },
        );
    }

    # loop to save the value in the field that was selected
    OPTION:
    for my $Option ( keys %{$PossibleValues} ) {

        if ( $Option eq $DynamicFieldOption ) {
            
            $DynamicFieldOptionName = $PossibleValues->{$Option};           

            next OPTION if ( !defined $PossibleValuesConfigArticle->{$Option} );

            # if the value does not require a text field to create an article
            if ( $PossibleValuesConfigArticle->{$Option} == 0 ) {

                my $ObjectID;

                if ( $ArticleIDObject ) {
                    $ObjectID = $ArticleIDObject;
                }
                else {
                    $ObjectID = $EmailOptionData->{TicketID};
                }

                # set value for dynamic email option field
                $Success = $BackendObject->ValueSet(
                    DynamicFieldConfig => $DynamicFieldConfig,     
                    ObjectID           => $ObjectID,                
                    Value              => $DynamicFieldOption,                   
                    UserID             => 1,
                );

                # update email option shipping record
                my $Updated = $EmailOptionObject->RequestUpdate(
                    TicketID   => $EmailOptionData->{TicketID},
                    ArticleID  => $ArticleIDObject,
                    FieldID    => $DynamicFieldID,
                    AnsweredBy => $EmailOptionData->{SendTo}
                );

                if ( IsHashRefWithData($AnswerAuthor) ) {
                    # save email from respondent in dynamic field
                    $BackendObject->ValueSet(
                        DynamicFieldConfig => $AnswerDynamicField,
                        ObjectID           => $ObjectID,
                        Value              => $EmailOptionData->{SendTo},
                        UserID             => 1,
                    );
                }

                $Param{TextArea} = 'Hidden';

                my $CreateReplyArticle = $ConfigObject->Get('InBox::EmailOption::CreateReplyArticle');
                my $SenderValueToArticle = $ConfigObject->Get('InBox::EmailOption::SenderValueToArticle');
                my $SaveEmailToSenderToArticle = $ConfigObject->Get('InBox::EmailOption::SaveEmailToSenderToArticle');

                if ( $SaveEmailToSenderToArticle ) {
                    $SenderValueToArticle = $EmailOptionData->{SendTo};
                }

                if ( $Success == 1 ) {

                    $Param{Description} = $DynamicFieldsTexts->{$DynamicFieldConfig->{Name}}->{$DynamicFieldOption} ||
                        $LayoutObject->{LanguageObject}->Translate("The dynamic field ") . $DynamicFieldName 
                        . $LayoutObject->{LanguageObject}->Translate(" has been successfully updated, with the value: ") . $DynamicFieldOptionName;                   

                    if ( $CreateReplyArticle ) {

                        if ( !defined $ArticleText ) {

                            if ( !$DefaultArticleBody ) {
                                $ArticleText = $LayoutObject->{LanguageObject}->Translate("Updated dynamic field via email");
                            }
                            else {
                                $ArticleText = $DefaultArticleBody;
                            }
                        }

                        if ( !defined $SubjectText ) {

                            if ( !$DefaultArticleSubject ) {
                                $SubjectText = $LayoutObject->{LanguageObject}->Translate("Updated dynamic field via email");
                            }
                            else {
                                $SubjectText = $DefaultArticleSubject;
                            }
                        }

                        #get body of the article
                        $ArticleText = $Self->_ReplaceTicketAttributes(
                            Ticket  => \%TicketData,
                            Message => $ArticleText
                        );

                        #get title of the article
                        $SubjectText = $Self->_ReplaceTicketAttributes(
                            Ticket  => \%TicketData,
                            Message => $SubjectText
                        );

                        if ( $TicketData{CustomerUserID} ) {

                            # get customer title of the article
                            $SubjectText = $Self->_ReplaceCustomerUserAttributes(
                                CustomerUser => \%User,
                                Message      => $SubjectText
                            );

                            # get customer body of the article
                            $ArticleText = $Self->_ReplaceCustomerUserAttributes(
                                CustomerUser => \%User,
                                Message      => $ArticleText
                            );
                        }

                        $Kernel::OM->Get('Kernel::System::Ticket::Article::Backend::Internal')->ArticleCreate(
                            TicketID             => $EmailOptionData->{TicketID},
                            SenderType           => 'system',
                            IsVisibleForCustomer => $IsVisibleForCustomer,
                            From                 => $SenderValueToArticle,
                            Subject              => $SubjectText,
                            Body                 => $ArticleText,
                            ContentType          => 'text/plain; charset=ISO-8859-15',
                            HistoryType          => 'Misc',
                            HistoryComment       => $LayoutObject->{LanguageObject}->Translate('DynamicField update'),
                            UserID               => 1, 
                        );
                    }
                }
                else {

                    $Param{Description} = $LayoutObject->{LanguageObject}->Translate("An error has occurred.");                    
                }
            }
            else {
                $Param{Description} = $DynamicFieldsTexts->{$DynamicFieldConfig->{Name}}->{$DynamicFieldOption} || $LayoutObject->{LanguageObject}->Translate("Enter the information to complete the vote.");
                $Param{TextArea}    = 'Enable';
            }
        } 
    }

    if ( $Success == 0 && $Param{TextArea} ne 'Enable' ) {
        return _ErrorScreen($EmailOptionData->{TicketID});         
    }

    my @Fields = $Self->_GenerateHTMLForDynamicField(
        Name   => $DynamicFieldConfig->{Name},
        Origin => $DynamicFieldOption,
    );

    $LayoutObject->Block(
        Name => 'Overview',
        Data => {
            Description   => $Param{Description},
            TextArea      => $Param{TextArea},
            TextAreaError => $Param{Error} eq 'TextRequerid' ? 'TextAreaError' : '',
            Placeholder   => $Param{Error} eq 'TextRequerid' ? 'This field is requerid ...' : 'Write here...',
            Link          => $Param{Link},
            Title         => $Configs->{Title},
            HeaderColor   => $Configs->{HeaderColor},
            BtnColor      => $Configs->{BtnColor},
        },
    );


    foreach my $Field (@Fields) {
        $LayoutObject->Block(
            Name => 'DynamicField',
            Data => $Field
        )
    }

    $Output = $LayoutObject->CustomerHeader(
        DisableIFrameOriginRestricted => 1,
        Title 			              => $LayoutObject->{LanguageObject}->Translate('Email Option'),
        Type                          => 'Small',
    );

    if ( $Success == 0 ) {

        # get config attachment
        my $OptionAttachment = $ConfigObject->Get('InBox::EmailOption::Attachment');

        # add attachment input type
        if ( $OptionAttachment ) {

            $LayoutObject->Block(
                Name => 'ViewAttachment',
            );
        };
    }

    $Output .= $LayoutObject->Output(
        TemplateFile => 'EmailOption/' . $ReplyTemplate,
        Data => {
            %Param,
        },
    );

    $Output .= $LayoutObject->CustomerFooter(
        Type => 'Small',
    );

    return $Output;
}

sub _Sucess {
    my ( $Self, %Param ) = @_;

    # get objects
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $EmailOptionObject  = $Kernel::OM->Get('Kernel::System::EmailOption');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # get request email option
    my $EmailOptionData = $EmailOptionObject->RequestGet(
        PublicKey => $Param{PublicKey}
    );

    my $DynamicFieldOption = $EmailOptionData->{FieldValue};
    my $DynamicFieldID     = $EmailOptionData->{FieldID};    
    my $ArticleIDObject    = $EmailOptionData->{AritcleID};

    # get field email option sender
    my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
        ID => $DynamicFieldID,
    );

    # get configs
    my $BaseLink                  = $ConfigObject->Get('FQDN');
    my $Configs                   = $ConfigObject->Get('InBox::EmailOption::Configs');
    my $ArticleParameters         = $ConfigObject->Get('InBox::EmailOption::ArticleParameters');
    my $DynamicFieldsTexts        = $ConfigObject->Get('InBox::EmailOption::DynamicFieldsTexts');
    my $VisibleArticleForCustomer = $ConfigObject->Get('InBox::EmailOption::VisibleArticleForCustomer');
    my $PossibleDynamicFields     = $ConfigObject->Get('InBox::EmailOption::DynamicFieldsEnabledValues');
    my $DefaultArticleSubject     = $ConfigObject->Get('InBox::EmailOption::DefaultSubjectOfAnsweredArticle');
    my $DefaultArticleBody        = $ConfigObject->Get('InBox::EmailOption::DefaultTextOfAnsweredArticle');
    my $AnswerAuthor              = $ConfigObject->Get('InBox::EmailOption::AnswerAuthor');
    my $ReplyTemplate             = $ConfigObject->Get('InBox::EmailOption::ReplyTemplate');
    my $EmailOptionJustification  = $ConfigObject->Get('InBox::EmailOption::DynamicFieldsJustification');
    my $SenderValueToArticle      = $ConfigObject->Get('InBox::EmailOption::SenderValueToArticle');
    my $SaveEmailToSenderToArticle = $ConfigObject->Get('InBox::EmailOption::SaveEmailToSenderToArticle');

    my $ObjectID;

    if ( $ArticleIDObject ) {
        $ObjectID = $ArticleIDObject;
    }
    else {
        $ObjectID = $EmailOptionData->{TicketID};
    }

    # get article text
    my $ArticleText = $ParamObject->GetParam( Param => 'Article' ) || $ArticleParameters->{$DynamicFieldConfig->{Name}}->{Body};

    # get subject and article text, if defined in config
    my $SubjectText        = $ArticleParameters->{$DynamicFieldConfig->{Name}}->{Subject};
    my $ArticleTextDefined = $ArticleParameters->{$DynamicFieldConfig->{Name}}->{ArticleText};
    
    # get ticket number
    my $TicketNumber = $TicketObject->TicketNumberLookup(
        TicketID => $EmailOptionData->{TicketID}
    );

    # get ticket
    my %TicketData = $TicketObject->TicketGet(
        TicketID => $EmailOptionData->{TicketID},
        UserID   => 1
    );

    # get customer user data
    my %User = $CustomerUserObject->CustomerUserDataGet(
        User => $TicketData{CustomerUserID},
    );  
   
    # check if email option field has already been answered
    my $DFCheck = $EmailOptionData->{ValidID};  

    # return if field has already been answered
    if ( !$DFCheck ) {
        return _Overview($Self,%Param);
    }

    my $PossibleValuesConfigArticle;
    my $ValidDF = 0;

    # check if the field is of the dropdown type and is defined in the config
    if ( $DynamicFieldConfig->{FieldType} eq 'Dropdown' && $PossibleDynamicFields->{$DynamicFieldConfig->{Name}} ) {
        $ValidDF = 1;
        $PossibleValuesConfigArticle = $PossibleDynamicFields->{$DynamicFieldConfig->{Name}};
    }   

    my $Output;
      
    if ( $PossibleDynamicFields->{$DynamicFieldConfig->{Name}}->{$DynamicFieldOption} && ( !(defined $ArticleText) || $ArticleText eq '' ) ) {

        $Param{Error} = 'TextRequerid';

        return _Overview($Self,%Param);
    }
    
    # if field is not valid or not configured, display an error message
    if ( $ValidDF == 0 ) {

        $Param{Description} = $LayoutObject->{LanguageObject}->Translate("An error has occurred, please contact support.");
        $Param{TextArea}    = "Hidden";
        $Param{Link}        = "http://".$BaseLink."/znuny/index.pl?Action=AgentTicketZoom;TicketID=" . $EmailOptionData->{TicketID};

        $LayoutObject->Block(
            Name => 'Error',
            Data => {
                Description => $Param{Description},
                TextArea    => $Param{TextArea},
                Link        => $Param{Link},
                Title       => $Configs->{Title},
                Placeholder => $Param{Error} eq 'TextRequerid' ? 'This field is requerid ...' : 'Write here...',
                BtnColor    => $Configs->{BtnColor},
                HeaderColor => $Configs->{HeaderColor},
            },
        );

        $Output = $LayoutObject->CustomerHeader(
            DisableIFrameOriginRestricted => 1,
            Title 			              => $LayoutObject->{LanguageObject}->Translate('Email Option'),
            Type                          => 'Small',
        );	

        $Output .= $LayoutObject->Output(
            TemplateFile => 'EmailOption/' . $ReplyTemplate,
            Data => {
                %Param,
            },
        );

        $Output .= $LayoutObject->CustomerFooter(
            Type => 'Small',
        );

        return $Output;
    }    
   
    my $DynamicFieldOptionName;
    my $DynamicFieldName     = $DynamicFieldConfig->{Label};
    my $IsVisibleForCustomer = $VisibleArticleForCustomer->{$DynamicFieldConfig->{Name}} || 0;
    my $Success              = 0;   

    # get possible values
    my $PossibleValues = $BackendObject->PossibleValuesGet(
        DynamicFieldConfig => $DynamicFieldConfig,  
    );

    my $AnswerDynamicField;
    if ( IsHashRefWithData($AnswerAuthor) ) {

        # get field where it will be saved who replied to the email
        $AnswerDynamicField = $DynamicFieldObject->DynamicFieldGet(
            Name => $AnswerAuthor->{ $DynamicFieldConfig->{Name} },
        );
    }

    # loop to save the value in the field that was selected
    OPTION:
    for my $Option ( keys %{$PossibleValues} ) {

        if ( $Option eq $DynamicFieldOption  ) {

            $DynamicFieldOptionName = $PossibleValues->{$Option};
            
            next OPTION if ( !defined $PossibleValuesConfigArticle->{$Option} );

            # if the value does not require a text field to create an article
            if ( $PossibleValuesConfigArticle->{$Option} == 0 ) {

                my $ObjectID;

                if ( $ArticleIDObject ) {
                    $ObjectID = $ArticleIDObject;
                }
                else {
                    $ObjectID = $EmailOptionData->{TicketID};
                }

                #set value for dynamic email option field
                $Success = $BackendObject->ValueSet(
                    DynamicFieldConfig => $DynamicFieldConfig,     
                    ObjectID           => $ObjectID,                
                    Value              => $DynamicFieldOption,                   
                    UserID             => 1,
                );     


                #update email option shipping record
                my $Updated = $EmailOptionObject->RequestUpdate(
                    TicketID   => $EmailOptionData->{TicketID},
                    ArticleID  => $ArticleIDObject,
                    FieldID    => $DynamicFieldID,
                    AnsweredBy => $EmailOptionData->{SendTo}
                );

                if ( IsHashRefWithData($AnswerAuthor) ) {
                    # save email from respondent in dynamic field
                    $BackendObject->ValueSet(
                        DynamicFieldConfig => $AnswerDynamicField,
                        ObjectID           => $ObjectID,
                        Value              => $EmailOptionData->{SendTo},
                        UserID             => 1,
                    );
                }

                if ( $Success == 1 ) {                   

                    $Param{TextDescription} = $LayoutObject->{LanguageObject}->Translate("You answered : ") . $DynamicFieldOptionName;
                    $Param{TextArea}        = "Enable";
                    
                    if ( !defined $ArticleText ) {

                        if (!$DefaultArticleBody) {
                            $ArticleText = $LayoutObject->{LanguageObject}->Translate("Updated dynamic field via email");
                        }
                        else {
                            $ArticleText = $DefaultArticleBody;
                        }
                    }

                    if ( !defined $SubjectText ) {

                        if ( !$DefaultArticleSubject ) {
                            $SubjectText = $LayoutObject->{LanguageObject}->Translate("Updated dynamic field via email");
                        }
                        else {
                            $SubjectText = $DefaultArticleSubject;
                        }
                    }

                    if ( defined $ArticleTextDefined ) {
                        $ArticleText = $ArticleTextDefined . " - " . $ArticleText;
                    }

                    # get body of the article
                    $ArticleText = $Self->_ReplaceTicketAttributes(
                        Ticket  => \%TicketData,
                        Message => $ArticleText
                    );

                    # get title of the article
                    $SubjectText = $Self->_ReplaceTicketAttributes(
                        Ticket  => \%TicketData,
                        Message => $SubjectText
                    );

                    if ($TicketData{CustomerUserID}) {

                        my %User = $CustomerUserObject->CustomerUserDataGet(
                            User => $TicketData{CustomerUserID},
                        );

                        # get customer title of the article
                        $SubjectText = $Self->_ReplaceCustomerUserAttributes(
                            CustomerUser => \%User,
                            Message      => $SubjectText
                        );

                        # get customer body of the article
                        $ArticleText = $Self->_ReplaceCustomerUserAttributes(
                            CustomerUser => \%User,
                            Message      => $ArticleText
                        );
                    }

                    if ( $SaveEmailToSenderToArticle ) {
                        $SenderValueToArticle = $EmailOptionData->{SendTo};
                    }

                    my $ArticleID = $Kernel::OM->Get('Kernel::System::Ticket::Article::Backend::Internal')->ArticleCreate(
                        TicketID             => $EmailOptionData->{TicketID},
                        SenderType           => 'system',
                        From                 => $SenderValueToArticle,
                        Subject              => $SubjectText,
                        Body                 => $ArticleText,
                        ContentType          => 'text/plain; charset=ISO-8859-15',
                        HistoryType          => 'Misc',
                        HistoryComment       => $LayoutObject->{LanguageObject}->Translate('DynamicField update'),
                        UserID               => 1,
                        IsVisibleForCustomer => $IsVisibleForCustomer,
                    );

                    $Param{Link}= "http://".$BaseLink."/znuny/index.pl?Action=AgentTicketZoom;TicketID=".$EmailOptionData->{TicketID}.";ArticleID=".$ArticleID;
                }
                else {

                    $Param{TextDescription} = $LayoutObject->{LanguageObject}->Translate("An error has occurred, please contact support.");
                    $Param{TextArea}        = "Hidden";
                    $Param{Link}            = "http://".$BaseLink."/znuny/index.pl?Action=AgentTicketZoom;TicketID=".$EmailOptionData->{TicketID};
                }
            }
            else {

                if ( !$ArticleText ) {
                   
                    $Param{TextDescription} = $LayoutObject->{LanguageObject}->Translate("An error has occurred, please contact support.");
                    $Param{TextArea}        = "Enable";
                    $Param{Link}            = "http://".$BaseLink."/znuny/public.pl?Action=EmailOptionReply;PublicKey=$Param{PublicKey}";            
                }
                else {

                    my $ObjectID;

                    if (defined $ArticleIDObject) {
                        $ObjectID = $ArticleIDObject;
                    }
                    else {
                        $ObjectID = $EmailOptionData->{TicketID};
                    }

                    $Success = $BackendObject->ValueSet(
                        DynamicFieldConfig => $DynamicFieldConfig,     
                        ObjectID           => $ObjectID,                
                        Value              => $DynamicFieldOption,                   
                        UserID             => 1,
                    );

                    my $Updated = $EmailOptionObject->RequestUpdate(
                        TicketID   => $EmailOptionData->{TicketID},
                        ArticleID  => $ArticleIDObject,
                        FieldID    => $DynamicFieldID,
                        AnsweredBy => $EmailOptionData->{SendTo}
                    );

                    if ( IsHashRefWithData($AnswerAuthor) ) {
                        # save email from respondent in dynamic field
                        $BackendObject->ValueSet(
                            DynamicFieldConfig => $AnswerDynamicField,
                            ObjectID           => $ObjectID,
                            Value              => $EmailOptionData->{SendTo},
                            UserID             => 1,
                        );
                    }

                    if ( !$ArticleText ) {

                        if (!$DefaultArticleBody) {
                            $ArticleText = $LayoutObject->{LanguageObject}->Translate("Updated dynamic field via email");
                        }
                        else {
                            $ArticleText = $DefaultArticleBody;
                        }
                    }
                    
                    if ( !$SubjectText ) {

                        if ( !$DefaultArticleSubject ) {
                            $SubjectText = $LayoutObject->{LanguageObject}->Translate("Updated dynamic field via email");
                        }
                        else {
                            $SubjectText = $DefaultArticleSubject;
                        }
                    }

                    if ( $ArticleTextDefined ) {
                        $ArticleText = $ArticleTextDefined . " - " . $ArticleText;
                    }

                    #get body of the article
                    $ArticleText = $Self->_ReplaceTicketAttributes(
                        Ticket  => \%TicketData,
                        Message => $ArticleText
                    );

                    #get title of the article
                    $SubjectText = $Self->_ReplaceTicketAttributes(
                        Ticket  => \%TicketData,
                        Message => $SubjectText
                    );

                    # get config attachment
                    my $OptionAttachment = $ConfigObject->Get('InBox::EmailOption::Attachment');

                    my @Attachments;

                    if ( $OptionAttachment ) {

                        #get all Attachment                  
                        my %File = $ParamObject->GetMultipleUpload(
                            Param => 'EmailOptionAttachment',
            		    	Source => 'file',
                        );

                        #validate if is a hash type and push in a array
                        for my $Attachment ( values %File ) {

                            if ( ref $Attachment eq "HASH") {

                                push @Attachments, $Attachment;
                            }
                        }
                    }

                    if ( $TicketData{CustomerUserID} ) {
                        # get customer title of the article
                        $SubjectText = $Self->_ReplaceCustomerUserAttributes(
                            CustomerUser => \%User,
                            Message      => $SubjectText
                        );
                        # get customer body of the article
                        $ArticleText = $Self->_ReplaceCustomerUserAttributes(
                            CustomerUser => \%User,
                            Message      => $ArticleText
                        );
                    }

                    my $DynamicFieldEmailOption = $DynamicFieldObject->DynamicFieldGet(
                        ID => $EmailOptionData->{FieldID},
                    );

                    if ( $EmailOptionJustification->{$DynamicFieldEmailOption->{Name}} ) {
                        
                        my $DFConfig = $DynamicFieldObject->DynamicFieldGet(
                            Name => $EmailOptionJustification->{$DynamicFieldEmailOption->{Name}},
                        );
                        
                        $BackendObject->ValueSet(
                            DynamicFieldConfig => $DFConfig,
                            ObjectID           => $ObjectID,
                            Value              => $ArticleText,
                            UserID             => 1,
                        );
                    }

                    if ( $SaveEmailToSenderToArticle ) {
                        $SenderValueToArticle = $EmailOptionData->{SendTo};
                    }
                    
                    my $ArticleID = $Kernel::OM->Get('Kernel::System::Ticket::Article::Backend::Internal')->ArticleCreate(
                        TicketID             => $EmailOptionData->{TicketID},
                        SenderType           => 'system',
                        From                 => $SenderValueToArticle,
                        Subject              => $SubjectText,
                        Body                 => $ArticleText,
                        ContentType          => 'text/plain; charset=ISO-8859-15',
                        HistoryType          => 'Misc',
                        HistoryComment       => $LayoutObject->{LanguageObject}->Translate('DynamicField update'),
                        IsVisibleForCustomer => $IsVisibleForCustomer,
                        UserID               => 1,
                        Attachment           => \@Attachments,
                    );

                    $Param{TextDescription} = $DynamicFieldsTexts->{$DynamicFieldConfig->{Name}}->{"$DynamicFieldOption-Response"} || $LayoutObject->{LanguageObject}->Translate("Dynamic field updated successfully.");
                    $Param{Link}            = "http://".$BaseLink."/znuny/index.pl?Action=AgentTicketZoom;TicketID=".$EmailOptionData->{TicketID}.";ArticleID=".$ArticleID;
                }
            }
        } 
    }

    if ( $Success == 0 && $Param{TextArea} ne  'Enable' ) {
        return _ErrorScreen($EmailOptionData->{TicketID});         
    }

    my $FieldNames = $ConfigObject->Get('InBox::EmailOption::DynamicFieldsToShow')->{$DynamicFieldConfig->{Name}};

    my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');

    DYNAMICFIELD:
    for my $Field (keys %{$FieldNames}) {
        my $NewField = 'DynamicField_' . $Field;

        my $FieldConfig = $DynamicFieldObject->DynamicFieldGet(
            Name => $Field
        );

        my $DynamicFieldValue;

        if ( $FieldConfig->{FieldType} eq 'Multiselect' ) {
    
            my @DynamicFieldArray = ();
            @DynamicFieldArray = $ParamObject->GetArray( Param => $NewField );

            foreach my $Item ( @DynamicFieldArray ){
                push @{$DynamicFieldValue}, $Item;
            }
        }
        elsif ( $FieldConfig->{FieldType} eq 'Date' ) {
            my $DynamicFieldChecked = $ParamObject->GetParam( Param => $NewField . 'Used' );

            if ( $DynamicFieldChecked ) {
                my $DateDay   = $ParamObject->GetParam( Param => $NewField . 'Day' );
                my $DateMonth = $ParamObject->GetParam( Param => $NewField . 'Month' );
                my $DateYear  = $ParamObject->GetParam( Param => $NewField . 'Year' );

                if ( $DateMonth < 10 ) {
                    $DateMonth = "0".$DateMonth;
                }
                if ( $DateDay < 10 ) {
                    $DateDay = "0".$DateDay;
                }

                my $FullDate = "$DateYear-$DateMonth-$DateDay 00:00:00";

                $DynamicFieldValue = $FullDate;
            }
        }
        elsif ( $FieldConfig->{FieldType} eq 'DateTime' ) {
            my $DynamicFieldChecked = $ParamObject->GetParam( Param => $NewField . 'Used' );

            if ( $DynamicFieldChecked ){
                my $DateDay    = $ParamObject->GetParam( Param => $NewField . 'Day' );
                my $DateMonth  = $ParamObject->GetParam( Param => $NewField . 'Month' );
                my $DateYear   = $ParamObject->GetParam( Param => $NewField . 'Year' );
                my $DateHour   = $ParamObject->GetParam( Param => $NewField . 'Hour' );
                my $DateMinute = $ParamObject->GetParam( Param => $NewField . 'Minute' );
                
                if(!$DateHour){
                    $DateHour = "0";
                }
                if(!$DateMinute){
                    $DateMinute = "0";
                }
                if($DateMonth < 10){
                    $DateMonth = "0".$DateMonth;
                }
                if($DateDay < 10){
                    $DateDay = "0".$DateDay;
                }
                if($DateHour < 10){
                    $DateHour = "0".$DateHour;
                }

                if($DateMinute < 10){
                    $DateMinute = "0".$DateMinute;
                }

                my $FullDate = "$DateYear-$DateMonth-$DateDay $DateHour:$DateMinute:00";

                $DynamicFieldValue = $FullDate;
            }
        }
        elsif ( $FieldConfig->{FieldType} eq 'FileSystem' ) {

            my $DynamicFieldFileSystemValueObject = $Kernel::OM->Get('Kernel::System::DynamicField::Driver::FileSystem');

            my %UploadStuff = $ParamObject->GetMultipleUpload(
                Param => $NewField,
                Source => 'file',
            );

            my $FileCounter = $UploadStuff{Multiple};

            for my $FileID ( 1 .. $FileCounter ) {

                my $Sucess = $Kernel::OM->Get('Kernel::System::DynamicFieldFileSystemValue')->ValueSet(
                    FieldID  	=> 	$FieldConfig->{ID},
                    ObjectID 	=> 	$ObjectID,
                    FileContent => 	$UploadStuff{"DynamicField_"."$FieldConfig->{Name}"."_$FileID"},
                    UserID 		=> 	1,
                );

                if ( $Sucess ) {
                    
                    my $OK = $DynamicFieldValueObject->ValueSet(
						FieldID  => $FieldConfig->{ID},
						ObjectID => $ObjectID,
						Value    => [{ ValueText => 1 }],
						UserID   => 1,
					);                       
                }

                if ( !$Sucess ) {
                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'error',
                        Message  => "Upload of FileID $FileID is invalid!",
                    );
                }
            }
        }
        else { 

            my $DynamicFieldScalar = $ParamObject->GetParam( Param => $NewField );
			$DynamicFieldValue = $DynamicFieldScalar;          
        }

        next DYNAMICFIELD if (!defined $DynamicFieldValue);

		my $Success = $BackendObject->ValueSet(
			DynamicFieldConfig => $FieldConfig,     
			ObjectID           => $ObjectID,
			Value              => $DynamicFieldValue,
			UserID             => 1
		);
    }

    $LayoutObject->Block(
        Name => 'Success',
        Data => {
            TextDescription => $Param{TextDescription},
            TextArea        => $Param{TextArea},
            Link            => $Param{Link},
            Placeholder     => $Param{Error} eq 'TextRequerid' ? 'This field is requerid ...' : 'Write here...',
            Title           => $Configs->{Title},
            BtnColor        => $Configs->{BtnColor},
            HeaderColor     => $Configs->{HeaderColor},
        },
    );
    
    $Output = $LayoutObject->CustomerHeader(
        DisableIFrameOriginRestricted => 1,
        Title 			              => $LayoutObject->{LanguageObject}->Translate('Email Option'),
        Type                          => 'Small',
    );	

    $Output .= $LayoutObject->Output(
        TemplateFile => 'EmailOption/' . $ReplyTemplate,
        Data => {
            %Param,
        },
    );

    $Output .= $LayoutObject->CustomerFooter(
        Type => 'Small',
    );

    return $Output;
}

sub _ErrorScreen {
    my ( $TicketID ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $Configs       = $ConfigObject->Get('InBox::EmailOption::Configs');
    my $ReplyTemplate = $ConfigObject->Get('InBox::EmailOption::ReplyTemplate');
    my $BaseLink      = $ConfigObject->Get('FQDN');

    my %Param;
    my $Output;

    $Param{Description} = $LayoutObject->{LanguageObject}->Translate("An error has occurred, please contact support.");
    $Param{TextArea}    = "Hidden";
    $Param{Link}        = "http://".$BaseLink."/znuny/index.pl?Action=AgentTicketZoom;TicketID=".$TicketID;

    $LayoutObject->Block(
        Name => 'Error',
        Data => {
            Description => $Param{Description},
            TextArea    => $Param{TextArea},
            Link        => $Param{Link},
            Placeholder => $Param{Error} eq 'TextRequerid' ? 'This field is requerid ...' : 'Write here...',
            Title       => $Configs->{Title},
            BtnColor    => $Configs->{BtnColor},
            HeaderColor => $Configs->{HeaderColor},
        },
    );

    $Output = $LayoutObject->CustomerHeader(
        DisableIFrameOriginRestricted => 1,
        Title 			              => $LayoutObject->{LanguageObject}->Translate('Email Option'),
        Type                          => 'Small',
    );	

    $Output .= $LayoutObject->Output(
        TemplateFile => 'EmailOption/' . $ReplyTemplate,
        Data => {
            %Param,
        },
    );

    $Output .= $LayoutObject->CustomerFooter(
        Type => 'Small',
    );

    return $Output;
}

sub _ReplaceTicketAttributes {
    my ( $Self, %Param ) = @_;

    return if !$Param{Message};

    # get needed objects
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # replace ticket attributes such as <OTRS_Ticket_DynamicField_Name1> or
    # <OTRS_TICKET_DynamicField_Name1>
    # <OTRS_Ticket_*> is deprecated and should be removed in further versions of Znuny
    my $Count = 0;
    REPLACEMENT:
    while (
        $Param{Message}
        && $Param{Message} =~ m{<OTRS_TICKET_([A-Za-z0-9_]+)>}msxi
        && $Count++ < 1000
        )
    {
        my $TicketAttribute = $1;

        if ( $TicketAttribute =~ m{DynamicField_(\S+?)_Value} ) {
            my $DynamicFieldName = $1;

            my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
                Name => $DynamicFieldName,
            );

            next REPLACEMENT if !$DynamicFieldConfig;

            # get the display value for each dynamic field
            my $DisplayValue = $DynamicFieldBackendObject->ValueLookup(
                DynamicFieldConfig => $DynamicFieldConfig,
                Key                => $Param{Ticket}->{"DynamicField_$DynamicFieldName"},
            );

            my $DisplayValueStrg = $DynamicFieldBackendObject->ReadableValueRender(
                DynamicFieldConfig => $DynamicFieldConfig,
                Value              => $DisplayValue,
            );

            $Param{Message} =~ s{<OTRS_TICKET_$TicketAttribute>}{$DisplayValueStrg->{Value} // ''}ige;

            next REPLACEMENT;
        }

        # if ticket value is scalar substitute all instances (as strings)
        # this will allow replacements for "<OTRS_TICKET_Title> <OTRS_TICKET_Queue"
        if ( !ref $Param{Ticket}->{$TicketAttribute} ) {
            $Param{Message} =~ s{<OTRS_TICKET_$TicketAttribute>}{$Param{Ticket}->{$TicketAttribute} // ''}ige;
        }
        else {
            # if the value is an array (e.g. a multiselect dynamic field) set the value directly
            # this unfortunately will not let a combination of values to be replaced
            $Param{Message} = $Param{Ticket}->{$TicketAttribute};
        }
    }

    return $Param{Message};
}

sub _ReplaceCustomerUserAttributes {
    my ( $Self, %Param ) = @_;

    return if !$Param{Message};
	return $Param{Message} if !IsHashRefWithData($Param{CustomerUser});
	
	for my $CustumerAttribute( keys %{ $Param{CustomerUser} } ){
		$Param{Message} =~ s/<OTRS_CUSTOMER_$CustumerAttribute>/$Param{CustomerUser}->{$CustumerAttribute}/;
		$Param{Message} =~ s/<OTRS_$CustumerAttribute>/$Param{CustomerUser}->{$CustumerAttribute}/;
	}	
	
	return $Param{Message};
}

sub _GenerateHTMLForDynamicField {
    my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');

    my ( $Self, %Param ) = @_;

    my $FieldNames = $ConfigObject->Get('InBox::EmailOption::DynamicFieldsToShow');
    my @Fields = ();

    foreach my $Field (sort keys %{$FieldNames->{$Param{Name}}}) {
        my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
            Name => $Field
        );

        next if !defined($DynamicField->{ID});

        my @Allowed = map { $_ =~ s/^\s+|\s+$//g; $_ } split(/,|\||\//g, $FieldNames->{$Param{Name}}->{$Field});

        my $DynamicFieldHTML = $BackendObject->EditFieldRender(
            Value                => '',
            DynamicFieldConfig   => $DynamicField,
            ParamObject          => $ParamObject,
            LayoutObject         => $LayoutObject, 
            # Mandatory            => $Param{Origin} ~~ @Allowed,
            Mandatory            => grep { $_ eq $Param{Origin} } @Allowed,
        );

        push(@Fields, $DynamicFieldHTML);
    }

    return @Fields;
}

1;