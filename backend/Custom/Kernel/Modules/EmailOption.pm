# --
# Kernel/Modules/EmailOption.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * gesquetini@beonup.com.br
# * lsnevelin@serviceup.com.br
# * jsantos@serviceup.com.br
# * msantos@serviceup.com.br
# --

package Kernel::Modules::EmailOption;

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
      
    my $Subaction = $ParamObject->GetParam(
        Param => 'Subaction',
    );

    my $TicketNumber = $ParamObject->GetParam(
        Param => 'P1',
    );

    ## Subject = Subject of article
    ## Artigo  = Text article
    ## P1      = TicketNumber
    ## P2      = TicketOption
    ## P3      = FieldID
    ## P4      = ArticleID
    
    if(defined $Subaction && $Subaction eq "Success"){

        _Sucess($Self,%Param);
    }
    else {

        _Overview($Self,%Param);
    }
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
	return if !IsHashRefWithData($Param{CustomerUser});
	
	for my $CustumerAttribute( keys %{ $Param{CustomerUser} } ){
		$Param{Message} =~ s/<OTRS_CUSTOMER_$CustumerAttribute>/$Param{CustomerUser}->{$CustumerAttribute}/;
		$Param{Message} =~ s/<<OTRS_$CustumerAttribute>/$Param{CustomerUser}->{$CustumerAttribute}/;
	}	
	
	return $Param{Message};
}

sub _Overview {
    my ( $Self, %Param ) = @_;

    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $UserObject         = $Kernel::OM->Get('Kernel::System::User');

    my $BaseLink = $ConfigObject->Get('FQDN');

    my $Output;
    my $DynamicFieldOptionName;

    my @ParamNames = $ParamObject->GetParamNames();

    my $ArticleText = $ParamObject->GetParam(
        Param => 'Article',
    );

    my $SubjectText = $ParamObject->GetParam(
        Param => 'Subject',
    );

    my $Body = $ParamObject->GetParam(
        Param => 'Customer',
    );

    my $TicketNumber = $ParamObject->GetParam(
        Param => 'P1',
    );

    my $DynamicFieldOption = $ParamObject->GetParam(
        Param => 'P2',
    );  

    my $DynamicFieldID = $ParamObject->GetParam(
        Param => 'P3',
    );

    my $ArticleIDObject = $ParamObject->GetParam(
        Param => 'P4',
    );

    my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
        ID => $DynamicFieldID,
    );

    my @TicketID = $TicketObject->TicketSearch(
        TicketNumber => $TicketNumber,
        Result       => 'ARRAY',
        UserID       => 1,
    );

    my $Configs = $ConfigObject->Get('InBox::EmailOption::Configs');

    my $PossibleDynamicFields = $ConfigObject->Get('InBox::EmailOption::DynamicFieldsEnabledValues');
    my $ValidDF = 0;

    my $PossibleValuesConfigArticle;
    
    for my $DFItem (keys %{$PossibleDynamicFields}){

        my $DynamicFieldConfigCOMP = $DynamicFieldObject->DynamicFieldGet(
            Name => $DFItem,
        );

        if(($DynamicFieldConfig->{ID} == $DynamicFieldConfigCOMP->{ID} ) && $DynamicFieldConfigCOMP->{FieldType} eq "Dropdown"){
            $ValidDF = 1;

            $PossibleValuesConfigArticle = $PossibleDynamicFields->{$DFItem};
            last;
        }
    }

    if($ValidDF == 0 || $TicketNumber eq "" || $DynamicFieldOption eq "" || $DynamicFieldID eq ""){

        $Param{Description} = $LayoutObject->{LanguageObject}->Translate("An error has occurred, please contact support");
        $Param{TextArea}    = "Hidden";
        $Param{Link}        = "http://".$BaseLink."/znuny/index.pl?Action=AgentTicketZoom;TicketID=".$TicketID[0];

        $LayoutObject->Block(
            Name => 'Error',
            Data => {
                Description => $Param{Description},
                TextArea    => $Param{TextArea},
                Link        => $Param{Link},
                Title       => $Configs->{Title},
                Color       => $Configs->{Color},
            },
        );

        $Output = $LayoutObject->CustomerHeader(
            DisableIFrameOriginRestricted => 1,
            Title 			              => $LayoutObject->{LanguageObject}->Translate('Email Option'),
        );	

        $Output .= $LayoutObject->Output(
            TemplateFile => 'EmailOption',
            Data => {
                %Param,
            },
        );

        $Output .= $LayoutObject->CustomerFooter(
            Type => 'Small',
        );

        return $Output;
    }
       
    my $DFCheck;

    if (defined $ArticleIDObject) {

        $DFCheck = _CheckDynamicFieldArticle($ArticleIDObject, $DynamicFieldID);
    }
    else {
        $DFCheck = _CheckDynamicField($TicketNumber, $DynamicFieldID);
        $ArticleIDObject = "";
    }

    my %TicketData = $TicketObject->TicketGet(
        TicketID => $TicketID[0],
        UserID   => 1,
    );

    my $DynamicFieldName = $DynamicFieldConfig->{Label};
 
    my $PossibleValues = $BackendObject->PossibleValuesGet(
        DynamicFieldConfig => $DynamicFieldConfig,  
    );

    for my $Options (keys %{$PossibleValues}){

        if(!defined $DFCheck){
            if ( $Options eq $DynamicFieldOption ){
                $DynamicFieldOptionName = $PossibleValues->{$Options};
            }
        }
        else{
            if ( $Options eq $DFCheck ){
                $DynamicFieldOptionName = $PossibleValues->{$Options};
            }
        }
    }

    my $ParamArticle = "";

    if (defined $ArticleText) {
        $ParamArticle .= "ArticleText=".$ArticleText.";";
    }
    if (defined $SubjectText) {
        $ParamArticle .= "Subject=".$SubjectText.";";
    }

    $Param{Link} = "public.pl?Action=EmailOption;Subaction=Success;".$ParamArticle."P1=".$TicketNumber.";P2=".$DynamicFieldOption.";P3=".$DynamicFieldID.";P4=".$ArticleIDObject.";";

    if ($ArticleIDObject eq "") {
        $ArticleIDObject = undef;
    }
 
    if(defined $DFCheck ){

        my $Name = $UserObject->UserName(
            User => $TicketData{Responsible},
        );

        $Param{TicketNumberText} = $LayoutObject->{LanguageObject}->Translate("TicketNumber : "). $TicketNumber;
        $Param{Description}      = $LayoutObject->{LanguageObject}->Translate("You have already answer");
        $Param{Link}             = "http://".$BaseLink."/znuny/index.pl?Action=AgentTicketZoom;TicketID=".$TicketID[0];
        
        # $Param{TicketCustomerText} = $LayoutObject->{LanguageObject}->Translate("Customer : "). $TicketData{CustomerID};
        # $Param{TicketTitleText}    = $LayoutObject->{LanguageObject}->Translate("Title : "). $TicketData{Title};
        # $Param{TicketAgentText}    = $LayoutObject->{LanguageObject}->Translate("Agent : "). $Name;
        # $Param{Details}            = $LayoutObject->{LanguageObject}->Translate("For more details, access the ticket clicking ")." <a id='Redirect' href='".$Param{Link}."' target='_blank'>".$LayoutObject->{LanguageObject}->Translate("here")."</a>";
        
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
                Color              => $Configs->{Color},
            },
        );

        $Output = $LayoutObject->CustomerHeader(
            DisableIFrameOriginRestricted => 1,
            Title 			              => $LayoutObject->{LanguageObject}->Translate('Email Option'),
        );	

        $Output .= $LayoutObject->Output(
            TemplateFile => 'EmailOption',
            Data => {
                %Param,
            },
        );

        $Output .= $LayoutObject->CustomerFooter(
            Type => 'Small',
        );

        return $Output;
    }

    $PossibleValues = $BackendObject->PossibleValuesGet(
        DynamicFieldConfig => $DynamicFieldConfig,  
    );

    my $Success = 0;

    my $VisibleArticleForCustomer = $ConfigObject->Get('InBox::EmailOption::VisibleArticleForCustomer');
    my $DynamicFieldsTexts        = $ConfigObject->Get('InBox::EmailOption::DynamicFieldsTexts');

    my $IsVisibleForCustomer = $VisibleArticleForCustomer->{$DynamicFieldConfig->{Name}} || 0;

    OPTION:
    for my $Options (keys %{$PossibleValues}){

        if ( $Options eq $DynamicFieldOption){

            $DynamicFieldOptionName = $PossibleValues->{$Options};

            next OPTION if (!defined $PossibleValuesConfigArticle->{$Options});

            if( $PossibleValuesConfigArticle->{$Options} == 0){

                my $ObjectID;

                if (defined $ArticleIDObject) {
                    $ObjectID = $ArticleIDObject;
                }
                else {
                    $ObjectID = $TicketID[0];
                }

                $Success = $BackendObject->ValueSet(
                    DynamicFieldConfig => $DynamicFieldConfig,     
                    ObjectID           => $ObjectID,                
                    Value              => $DynamicFieldOption,                   
                    UserID             => 1,
                );

                if($Success == 1){

                    my $DefaultArticleSubject = $ConfigObject->Get('InBox::EmailOption::DefaultSubjectOfAnsweredArticle');
                    my $DefaultArticleBody    = $ConfigObject->Get('InBox::EmailOption::DefaultTextOfAnsweredArticle');

                    $Param{Description} = $DynamicFieldsTexts->{$DynamicFieldConfig->{Name}}->{$DynamicFieldOption} || $LayoutObject->{LanguageObject}->Translate("The dynamic field ") . $DynamicFieldName . $LayoutObject->{LanguageObject}->Translate(" has been successfully updated, with the value: ") . $DynamicFieldOptionName;
                    $Param{TextArea}    = "Hidden";
                
                    if(!defined $ArticleText){

                        if (!$DefaultArticleBody) {
                            $ArticleText = $LayoutObject->{LanguageObject}->Translate("Updated dynamic field via email");
                        }
                        else {
                            $ArticleText = $DefaultArticleBody;
                        }
                    }

                    if(!defined $SubjectText){

                        if (!$DefaultArticleSubject) {
                            $SubjectText = $LayoutObject->{LanguageObject}->Translate("Updated dynamic field via email");
                        }
                        else {
                            $SubjectText = $DefaultArticleSubject;
                        }
                    }

                    my %DataTicket = $TicketObject->TicketGet(
                        TicketID      => $TicketID[0],
                        UserID        => 1,
                        DynamicFields => 0,
                    );

                    #get body of the article
                    $ArticleText = $Self->_ReplaceTicketAttributes(
                        Ticket  => \%DataTicket,
                        Message => $ArticleText
                    );

                    #get title of the article
                    $SubjectText = $Self->_ReplaceTicketAttributes(
                        Ticket  => \%DataTicket,
                        Message => $SubjectText
                    );

                    if ($DataTicket{CustomerUserID}) {

                        my %User = $CustomerUserObject->CustomerUserDataGet(
                            User => $DataTicket{CustomerUserID},
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

                    $Kernel::OM->Get('Kernel::System::Ticket::Article::Backend::Internal')->ArticleCreate(
                        TicketID             => $TicketID[0],
                        SenderType           => 'system',
                        IsVisibleForCustomer => $IsVisibleForCustomer,
                        From                 => "Admin",
                        Subject              => $SubjectText,
                        Body                 => $ArticleText,
                        ContentType          => 'text/plain; charset=ISO-8859-15',
                        HistoryType          => 'Misc',
                        HistoryComment       => $LayoutObject->{LanguageObject}->Translate('DynamicField update'),
                        UserID               => 1, 
                    );
                }

                else{
                    $Param{Description} = $LayoutObject->{LanguageObject}->Translate("An error has occurred");
                    $Param{TextArea}    = "Hidden";
                }
            }
            else{
                $Param{Description} = $DynamicFieldsTexts->{$DynamicFieldConfig->{Name}}->{$DynamicFieldOption} || $LayoutObject->{LanguageObject}->Translate("Enter the information to complete the vote");
                $Param{TextArea}    = "Enable";
            }
        } 
    }

    if($Success == 0 && $Param{TextArea} ne "Enable"){
        return _ErrorScreen($TicketID[0]);         
    }
    
    $LayoutObject->Block(
        Name => 'Overview',
        Data => {
            Description => $Param{Description},
            TextArea    => $Param{TextArea},
            Link        => $Param{Link},
            Title       => $Configs->{Title},
            Color       => $Configs->{Color},
        },
    );

    $Output = $LayoutObject->CustomerHeader(
        DisableIFrameOriginRestricted => 1,
        Title 			              => $LayoutObject->{LanguageObject}->Translate('Email Option'),
    );	

    $Output .= $LayoutObject->Output(
        TemplateFile => 'EmailOption',
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

    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');

    my $Configs = $ConfigObject->Get('InBox::EmailOption::Configs');

    my $DynamicFieldOptionName;

    my $ArticleText = $ParamObject->GetParam(
        Param => 'Article',
    );

    my $ArticleTextDefined = $ParamObject->GetParam(
        Param => 'ArticleText',
    );
    
    my $SubjectText = $ParamObject->GetParam(
        Param => 'Subject',
    );

    my $TicketNumber = $ParamObject->GetParam(
        Param => 'P1',
    ); 

    my $DynamicFieldOption = $ParamObject->GetParam(
        Param => 'P2',
    );  

    my $DynamicFieldID = $ParamObject->GetParam(
        Param => 'P3',
    );

    my $ArticleIDObject = $ParamObject->GetParam(
        Param => 'P4',
    ) || undef;

    my $DFCheck;

    if (defined $ArticleIDObject) {

        $DFCheck = _CheckDynamicFieldArticle($ArticleIDObject, $DynamicFieldID);
    }
    else {

        $DFCheck = _CheckDynamicField($TicketNumber, $DynamicFieldID);
    }

    my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
        ID => $DynamicFieldID,
    );

    my $BaseLink = $ConfigObject->Get('FQDN');
    
    my @TicketID = $TicketObject->TicketSearch(
        TicketNumber => $TicketNumber,
        Result       => 'ARRAY',
        UserID       => 1,
    );

    my %TicketData = $TicketObject->TicketGet(
        TicketID      => $TicketID[0],
        UserID        => 1,
        DynamicFields => 1,
    );

    my $PossibleDynamicFields = $ConfigObject->Get('InBox::EmailOption::DynamicFieldsEnabledValues');

    my $PossibleValuesConfigArticle;
    my $ValidDF = 0;
 
    for my $DFItem (keys %{$PossibleDynamicFields}){

        my $DynamicFieldConfigCOMP = $DynamicFieldObject->DynamicFieldGet(
            Name => $DFItem,
        );

        if(($DynamicFieldConfig->{ID} == $DynamicFieldConfigCOMP->{ID} ) && $DynamicFieldConfigCOMP->{FieldType} eq "Dropdown"){
            $ValidDF = 1;

            $PossibleValuesConfigArticle = $PossibleDynamicFields->{$DFItem};
            last;
        }
    }

    my $Output;
    
    if($ValidDF == 0){

        $Param{Description} = $LayoutObject->{LanguageObject}->Translate("An error has occurred, please contact support");
        $Param{TextArea}    = "Hidden";
        $Param{Link}        = "http://".$BaseLink."/znuny/index.pl?Action=AgentTicketZoom;TicketID=".$TicketID[0];

        $LayoutObject->Block(
            Name => 'Error',
            Data => {
                Description => $Param{Description},
                TextArea    => $Param{TextArea},
                Link        => $Param{Link},
                Title       => $Configs->{Title},
                Color       => $Configs->{Color},
            },
        );

        $Output = $LayoutObject->CustomerHeader(
            DisableIFrameOriginRestricted => 1,
            Title 			              => $LayoutObject->{LanguageObject}->Translate('Email Option'),
        );	

        $Output .= $LayoutObject->Output(
            TemplateFile => 'EmailOption',
            Data => {
                %Param,
            },
        );

        $Output .= $LayoutObject->CustomerFooter(
            Type => 'Small',
        );

        return $Output;
    }

    if( defined $DFCheck){

        return _Overview($Self,%Param);
    }

    my $DynamicFieldName = $DynamicFieldConfig->{Label};

    my $PossibleValues = $BackendObject->PossibleValuesGet(
        DynamicFieldConfig => $DynamicFieldConfig,  
    );

    my $Success = 0;

    my $VisibleArticleForCustomer = $ConfigObject->Get('InBox::EmailOption::VisibleArticleForCustomer');
    my $DynamicFieldsTexts        = $ConfigObject->Get('InBox::EmailOption::DynamicFieldsTexts');

    my $IsVisibleForCustomer = $VisibleArticleForCustomer->{$DynamicFieldConfig->{Name}} || 0;

    OPTION:
    for my $Options (keys %{$PossibleValues}){

        if ( $Options eq $DynamicFieldOption  ){

            $DynamicFieldOptionName = $PossibleValues->{$Options};
            
            next OPTION if (!defined $PossibleValuesConfigArticle->{$Options});

            if( $PossibleValuesConfigArticle->{$Options} == 0){

                my $ObjectID;

                if (defined $ArticleIDObject) {
                    $ObjectID = $ArticleIDObject;
                }
                else {
                    $ObjectID = $TicketID[0];
                }

                $Success = $BackendObject->ValueSet(
                    DynamicFieldConfig => $DynamicFieldConfig,     
                    ObjectID           => $ObjectID,                
                    Value              => $DynamicFieldOption,                   
                    UserID             => 1,
                );

                if($Success == 1){

                    my $DefaultArticleSubject = $ConfigObject->Get('InBox::EmailOption::DefaultSubjectOfAnsweredArticle');
                    my $DefaultArticleBody    = $ConfigObject->Get('InBox::EmailOption::DefaultTextOfAnsweredArticle');

                    $Param{TextDescription} = $LayoutObject->{LanguageObject}->Translate("You answered : ").$DynamicFieldOptionName;
                    $Param{TextArea}        = "Enable";
                    
                    if(!defined $ArticleText){

                        if (!$DefaultArticleBody) {
                            $ArticleText = $LayoutObject->{LanguageObject}->Translate("Updated dynamic field via email");
                        }
                        else {
                            $ArticleText = $DefaultArticleBody;
                        }
                    }

                    if(!defined $SubjectText){

                        if (!$DefaultArticleSubject) {
                            $SubjectText = $LayoutObject->{LanguageObject}->Translate("Updated dynamic field via email");
                        }
                        else {
                            $SubjectText = $DefaultArticleSubject;
                        }
                    }

                    if (defined $ArticleTextDefined) {
                        $ArticleText = $ArticleTextDefined . " - " . $ArticleText;
                    }

                    my %DataTicket = $TicketObject->TicketGet(
                        TicketID      => $TicketID[0],
                        UserID        => 1,
                        DynamicFields => 1,
                    );

                    # get body of the article
                    $ArticleText = $Self->_ReplaceTicketAttributes(
                        Ticket  => \%DataTicket,
                        Message => $ArticleText
                    );

                    # get title of the article
                    $SubjectText = $Self->_ReplaceTicketAttributes(
                        Ticket  => \%DataTicket,
                        Message => $SubjectText
                    );

                    if ($DataTicket{CustomerUserID}) {

                        my %User = $CustomerUserObject->CustomerUserDataGet(
                            User => $DataTicket{CustomerUserID},
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

                    my $ArticleID = $Kernel::OM->Get('Kernel::System::Ticket::Article::Backend::Internal')->ArticleCreate(
                        TicketID             => $TicketID[0],
                        SenderType           => 'system',
                        From                 => "Admin",
                        Subject              => $SubjectText,
                        Body                 => $ArticleText,
                        ContentType          => 'text/plain; charset=ISO-8859-15',
                        HistoryType          => 'Misc',
                        HistoryComment       => $LayoutObject->{LanguageObject}->Translate('DynamicField update'),
                        UserID               => 1,
                        IsVisibleForCustomer => $IsVisibleForCustomer,
                    );

                    $Param{Link}= "http://".$BaseLink."/znuny/index.pl?Action=AgentTicketZoom;TicketID=".$TicketID[0].";ArticleID=".$ArticleID;
                }
                else {
                    $Param{TextDescription} = $LayoutObject->{LanguageObject}->Translate("An error has occurred, please contact support");
                    $Param{TextArea}        = "Hidden";
                    $Param{Link}            = "http://".$BaseLink."/znuny/index.pl?Action=AgentTicketZoom;TicketID=".$TicketID[0];
                }
            }
            else {

                if(!defined $ArticleText) {
                    # $ArticleText = $LayoutObject->{LanguageObject}->Translate("Updated dynamic field via email");
                    # Obligatory Article
                    $Param{TextDescription} = $LayoutObject->{LanguageObject}->Translate("An error has occurred, please contact support");
                    $Param{TextArea}        = "Enable";
                    $Param{Link}            = "http://".$BaseLink."/znuny/public.pl?Action=EmailOption;P1=".$TicketNumber.";P2=".$DynamicFieldOption.";P3=".$DynamicFieldID;
            
                }
                else {

                    my $ObjectID;

                    if (defined $ArticleIDObject) {
                        $ObjectID = $ArticleIDObject;
                    }
                    else {
                        $ObjectID = $TicketID[0];
                    }

                    $Success = $BackendObject->ValueSet(
                        DynamicFieldConfig => $DynamicFieldConfig,     
                        ObjectID           => $ObjectID,                
                        Value              => $DynamicFieldOption,                   
                        UserID             => 1,
                    );

                    my $DefaultArticleSubject = $ConfigObject->Get('InBox::EmailOption::DefaultSubjectOfAnsweredArticle');
                    my $DefaultArticleBody    = $ConfigObject->Get('InBox::EmailOption::DefaultTextOfAnsweredArticle');

                    if(!defined $ArticleText){

                        if (!$DefaultArticleBody) {
                            $ArticleText = $LayoutObject->{LanguageObject}->Translate("Updated dynamic field via email");
                        }
                        else {
                            $ArticleText = $DefaultArticleBody;
                        }
                    }
                    
                    if(!defined $SubjectText){

                        if (!$DefaultArticleSubject) {
                            $SubjectText = $LayoutObject->{LanguageObject}->Translate("Updated dynamic field via email");
                        }
                        else {
                            $SubjectText = $DefaultArticleSubject;
                        }
                    }

                    if (defined $ArticleTextDefined) {
                        $ArticleText = $ArticleTextDefined . " - " . $ArticleText;
                    }

                    my %DataTicket = $TicketObject->TicketGet(
                        TicketID      => $TicketID[0],
                        UserID        => 1,
                        DynamicFields => 1,
                    );

                    #get body of the article
                    $ArticleText = $Self->_ReplaceTicketAttributes(
                        Ticket  => \%DataTicket,
                        Message => $ArticleText
                    );

                    #get title of the article
                    $SubjectText = $Self->_ReplaceTicketAttributes(
                        Ticket  => \%DataTicket,
                        Message => $SubjectText
                    );

                    if ($DataTicket{CustomerUserID}) {

                        my %User = $CustomerUserObject->CustomerUserDataGet(
                            User => $DataTicket{CustomerUserID},
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

                    my $ArticleID = $Kernel::OM->Get('Kernel::System::Ticket::Article::Backend::Internal')->ArticleCreate(
                        TicketID             => $TicketID[0],
                        SenderType           => 'system',
                        From                 => "Admin",
                        Subject              => $SubjectText,
                        Body                 => $ArticleText,
                        ContentType          => 'text/plain; charset=ISO-8859-15',
                        HistoryType          => 'Misc',
                        HistoryComment       => $LayoutObject->{LanguageObject}->Translate('DynamicField update'),
                        IsVisibleForCustomer => $IsVisibleForCustomer,
                        UserID               => 1,
                    );

                    $Param{TextDescription} = $DynamicFieldsTexts->{$DynamicFieldConfig->{Name}}->{$DynamicFieldOption};
                    $Param{Link}            = "http://".$BaseLink."/znuny/index.pl?Action=AgentTicketZoom;TicketID=".$TicketID[0].";ArticleID=".$ArticleID;
                }
            }
        } 
    }

    if($Success == 0 && $Param{TextArea} ne "Enable"){
        return _ErrorScreen($TicketID[0]);         
    }

    $LayoutObject->Block(
        Name => 'Success',
        Data => {
            TextDescription => $Param{TextDescription},
            TextArea        => $Param{TextArea},
            Link            => $Param{Link},
            Title           => $Configs->{Title},
            Color           => $Configs->{Color},
        },
    );
    
    $Output = $LayoutObject->CustomerHeader(
        DisableIFrameOriginRestricted => 1,
        Title 			              => $LayoutObject->{LanguageObject}->Translate('Email Option'),
    );	

    $Output .= $LayoutObject->Output(
        TemplateFile => 'EmailOption',
        Data => {
            %Param,
        },
    );

    $Output .= $LayoutObject->CustomerFooter(
        Type => 'Small',
    );

    return $Output;
}

sub _CheckDynamicField {

    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');

    my @TicketID = $TicketObject->TicketSearch(
        Result       => 'ARRAY',
        TicketNumber => $_[0],
        UserID       => 1,
    );

    my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
        ID => $_[1],
    );

    my $Value = $BackendObject->ValueGet(
        DynamicFieldConfig => $DynamicFieldConfig,      
        ObjectID           => $TicketID[0],                
    );

    if (defined $Value){
        return $Value;
    }
    else{
        return undef;
    }
}

sub _CheckDynamicFieldArticle {

    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
        ID => $_[1],
    );

    my $Value = $BackendObject->ValueGet(
        DynamicFieldConfig => $DynamicFieldConfig,      
        ObjectID           => $_[0],                
    );

    if (defined $Value){
        return $Value;
    }
    else{
        return undef;
    }
}

sub _ErrorScreen {
    my ($TicketID) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $Configs = $ConfigObject->Get('InBox::EmailOption::Configs');

    my $BaseLink = $ConfigObject->Get('FQDN');

    my %Param;
    my $Output;

    $Param{Description} = $LayoutObject->{LanguageObject}->Translate("An error has occurred, please contact support");
    $Param{TextArea}    = "Hidden";
    $Param{Link}        = "http://".$BaseLink."/znuny/index.pl?Action=AgentTicketZoom;TicketID=".$TicketID;

    $LayoutObject->Block(
        Name => 'Error',
        Data => {
            Description => $Param{Description},
            TextArea    => $Param{TextArea},
            Link        => $Param{Link},
            Title       => $Configs->{Title},
            Color       => $Configs->{Color},
        },
    );

    $Output = $LayoutObject->CustomerHeader(
        DisableIFrameOriginRestricted => 1,
        Title 			              => $LayoutObject->{LanguageObject}->Translate('Email Option'),
    );	

    $Output .= $LayoutObject->Output(
        TemplateFile => 'EmailOption',
        Data => {
            %Param,
        },
    );

    $Output .= $LayoutObject->CustomerFooter(
        Type => 'Small',
    );

    return $Output;
}

1;