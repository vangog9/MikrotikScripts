:local YandexLogin "YANDEX_MAILBOX_NAME@yandex.ru";
:local YandexPassword "YANDEX_MAILBOX_PASSWORD";

:local MailTo "YOUR_MAILBOX_NAME@gmail.com";
:local MailSubject "MikroTik Backup";

:local CurrentTime [/system clock get time];
:local CurrentDate [/system clock get date];

:local Hour [:tostr [:pick $CurrentTime 0 2]];
:local Min [:tostr [:pick $CurrentTime 3 5]];
:local Day [:tostr [:pick $CurrentDate 4 6]];
:local Month [:tostr [:pick $CurrentDate 0 3]];
:local Year [:tostr [:pick $CurrentDate 7 [:len $CurrentDate]]];

:do {
  :local FileName ([/system identity get name]."__$Day_$Month_$Year__$Hour_$Min.backup");
  /system backup save name=$FileName;
  :log info "Backup file ($FileName) created success";
  
  :do {
    :delay 2s;
    :global logMessages;
    :set logMessages ""
    :foreach i in=[/log find ] do={ 
      :set logMessages ($logMessages. [/log get $i time ]. " "); 
      :set logMessages ($logMessages. [/log get $i message ]); 
      :set logMessages ($logMessages. "\n")
    }
    /tool e-mail send server=213.180.204.38 port=587 start-tls=yes user=$YandexLogin \
      password=$YandexPassword to=$MailTo from=$YandexLogin \
      subject=($MailSubject." ($Day/$Month/$Year $Hour:$Min)") \
      body=( \
        "System information:". \
        "\n____________________\n \n". \
        "Board name: ".[/system resource get platform]." ".[/system resource get board-name]."\n". \
        "Version: ".[/system resource get version]."\n". \
        "CPU: ".[/system resource get cpu]." (load ".[/system resource get cpu-load]."%)\n". \
        "Free HDD space: ".[/system resource get free-hdd-space]." (total: ".[/system resource get total-hdd-space].")\n". \
        "Free memory: ".[/system resource get free-memory]." (total: ".[/system resource get total-memory].")\n". \
        "Uptime: ".[/system resource get uptime]. \
        "\n \n \n". \
        "Last log messages:". \
        "\n____________________\n \n". \
        $logMessages \
      ) file=$FileName;
    :log info "Mail with backup sending success";
    :do {
      :delay 3s;
      /file remove $FileName;
      :log info "Remove backup file success";
    } on-error={
      :log warning "Cannot remove backup file $FileName";
    };
  } on-error={
    :log warning "Email sending failed!";
  };
} on-error={
  :log error "Backup creation failed!";
};