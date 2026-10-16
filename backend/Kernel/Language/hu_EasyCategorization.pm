# --
# Kernel/Language/hu_EasyCategorization.pm - the Hungarian translation for EasyCategorization
# Copyright (C) 2019 Service Up http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@beonup.com.br
# * pdias@beonup.com.br
# * mbernardo@beonup.com.br
# * poliveira@serviceup.com.br
# * lcavalheiro@serviceup.com.br
# * dparavani@serviceup.com.br
# * gbolsoni@serviceup.com.br
# --

package Kernel::Language::hu_EasyCategorization;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation};

    return if ref $Lang ne 'HASH';

    # Kernel/Config/Files/EasyCategorization.xml
    $Lang->{'Module to show ticket categorization.'} = 'Egy modul a jegykategorizálás megjelenítéséhez.';
    $Lang->{'Easy to classify your tickets.'} = 'Egyszerűen kategorizálhatóvá teszi a jegyeit.';
    $Lang->{'Easy Categorization'} = 'Egyszerű kategorizálás';
    $Lang->{'Easy categorization for the service.'} = 'A szolgáltatás egyszerű kategorizálása.';
    $Lang->{'Easy categorization for the type.'} = 'A típus egyszerű kategorizálása.';
    $Lang->{'Easy categorization for the priority.'} = 'A prioritás egyszerű kategorizálása.';
    $Lang->{'Easy categorization for the state.'} = 'Könnyű kategorizálás az állam számára.';
    $Lang->{'Easy Categorization for Suspended Dynamic Fields or Contract.'} = 'Könnyű kategorizálás a felfüggesztett dinamikus mezőkhöz vagy szerződéshez.';
    $Lang->{'Frontend module registration for the agent interface.'} = 'Frontend modul regisztráció az ügynök felülethez.';
    $Lang->{'Easy Categorization for Suspended Dynamic Fields or Contract.'} = 'Könnyű kategorizálás a felfüggesztett dinamikus mezőkhöz vagy szerződéshez.';
    $Lang->{'Enter the status of the ticket in which the EasyCategorization fields are to be blocked'} = 'Adja meg annak a jegynek az állapotát, amelyben az EasyCategorization mezőket blokkolni kívánja';
    $Lang->{'Easy categorization for the owner.'} = 'Könnyű kategorizálás a tulajdonos számára.';
    $Lang->{'Easy categorization for the queue.'} = 'Könnyű sorba sorolás.';
    $Lang->{'Easy categorization for the responsible.'} = 'Egyszerű kategorizálás a felelősök számára.';
    $Lang->{'Add button to manually save changes.'} = 'Hozzáadás gomb a változtatások manuális mentéséhez.';
    $Lang->{'Create article with easy categorization information when there is update.'} = 'Frissítéskor hozzon létre cikket egyszerű kategorizációs információkkal.';
    $Lang->{'Define the title of the article that will be created if InBox::EasyCategorization::Config###ArticleCreate is enabled.'} = 'Határozza meg annak a cikknek a címét, amely akkor jön létre, ha az InBox::EasyCategorization::Config###ArticleCreate engedélyezve van.';
    $Lang->{'Update Easy Categorization'} = 'Frissítse az egyszerű kategorizálást';
    $Lang->{'Lock / Unlock'} = 'Zárolás / Feloldás';
    $Lang->{'Easy categorization for the lock / unlock.'} = 'Könnyű kategorizálás a záráshoz / feloldáshoz.';
    $Lang->{'Locked'} = 'Zárt';
    $Lang->{'Unlocked'} = 'Feloldva';

    return 1;
}

1;
