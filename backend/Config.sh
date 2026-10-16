bin/znuny.Console.pl Admin::Config::Update --setting-name DashboardBackend###0255-MyLastChangedTickets --valid 0
bin/znuny.Console.pl Admin::Config::Update --setting-name DashboardBackend###0260-TicketCalendar --valid 0
bin/znuny.Console.pl Admin::Config::Update --setting-name DashboardBackend###0280-DashboardEventsTicketCalendar --valid 0
bin/znuny.Console.pl Admin::Config::Update --setting-name DashboardBackend###0300-LastMentions --valid 0
bin/znuny.Console.pl Admin::Config::Update --setting-name DashboardBackend###0390-UserOutOfOffice --valid 0
bin/znuny.Console.pl Admin::Config::Update --setting-name DashboardBackend###0398-FAQ-LastChange --valid 0
bin/znuny.Console.pl Admin::Config::Update --setting-name DashboardBackend###0399-FAQ-LastCreate --valid 0
bin/znuny.Console.pl Admin::Config::Update --setting-name DashboardBackend###0442-RSS --valid 0
bin/znuny.Console.pl Admin::Config::Update --setting-name DashboardBackend###0500-AppointmentCalendar --valid 0
bin/znuny.Console.pl Admin::Config::Update --setting-name Loader::Customer::CommonJS###001-InBoxCore --valid 0
bin/znuny.Console.pl Admin::Config::Update --setting-name Frontend::ToolBarModule###110-Ticket::AgentTicketQueue --reset
bin/znuny.Console.pl Admin::Config::Update --setting-name Frontend::ToolBarModule###120-Ticket::AgentTicketStatus --reset
bin/znuny.Console.pl Admin::Config::Update --setting-name Frontend::ToolBarModule###140-Ticket::AgentTicketPhone --reset
bin/znuny.Console.pl Admin::Config::Update --setting-name Frontend::ToolBarModule###150-Ticket::AgentTicketEmail --reset
bin/znuny.Console.pl Admin::Config::Update --setting-name Frontend::ToolBarModule###210-Ticket::TicketSearchProfile --reset
bin/znuny.Console.pl Admin::Config::Update --setting-name Frontend::ToolBarModule###220-Ticket::TicketSearchFulltext --reset
bin/znuny.Console.pl Admin::Config::Update --setting-name Frontend::ToolBarModule###230-CICSearchCustomerID --reset
bin/znuny.Console.pl Admin::Config::Update --setting-name Frontend::ToolBarModule###240-CICSearchCustomerUser --reset
bin/znuny.Console.pl Admin::Config::Update --setting-name Loader::Module::AdminPackageManager###001-Framework --reset
 
bin/znuny.Console.pl Maint::Config::Rebuild
bin/znuny.Console.pl Maint::Cache::Delete
