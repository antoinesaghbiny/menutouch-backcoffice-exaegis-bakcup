@echo off
setlocal EnableExtensions EnableDelayedExpansion

set USER=root
set PASSWORD=""   
set DBNAME=menutouchresto01
set WHERE_CLAUSE=id_client in ^(3,10,14752,21558,21556^)
:: PASSWORD avec l'option -p%PASSWORD%

set TABLES_REFERENCES=page_type categorie_type information_type menu_type menu_sous_categorie_type questionnaire_type monnaie pays licence timezones parametre langue fichier message
set TABLES_CLIENT_WITH_TRADUCTION=client_message label page categorie sous_categorie produit menu menu_sous_categorie information option_commande option_commande_choix prix questionnaire
set TABLES_CLIENT=client config_backoffice client_device client_fichier client_langue client_parametre  imprimante horaire tables zone sf_guard_user log_webmenu log_webmenu_archive


:: récupérer la date du jour (format AAAAMMJJ)
for /f "tokens=2-4 delims=/ " %%a in ("%date%") do (
    set "DAY=%%a"
    set "MONTH=%%b"
    set "YEAR=%%c"
)
set "TODAY=!YEAR!!MONTH!!DAY!"
:: nom du fichier de sortie
set "OUTFILE=dump_filtered_!TODAY!.sql"
echo Fichier de sortie: !OUTFILE!


::create and use database
echo CREATE SCHEMA `menutouchresto01` DEFAULT CHARACTER SET utf8; > !OUTFILE!
echo USE `menutouchresto01`; >> !OUTFILE!


::structure des tables
mysqldump -u %USER% --password= --no-data --single-transaction --quick %DBNAME% --ignore-table=%DBNAME%.facture_abonnement_pour_compta --ignore-table=%DBNAME%.client_payant >> !OUTFILE!


::données de references
for %%T in (%TABLES_REFERENCES%) do (
    echo Dumping %%T ...
    mysqldump -u %USER% --password= %DBNAME% %%T --no-create-info >> !OUTFILE!
)


::données client
for %%T in (%TABLES_CLIENT%) do (
    echo Dumping %%T ...
    mysqldump -u %USER% --password= %DBNAME% %%T --where="%WHERE_CLAUSE%" --no-create-info >> !OUTFILE!
)


::données client AVEC traduction
for %%T in (%TABLES_CLIENT_WITH_TRADUCTION%) do (
    echo Dumping %%T ...
    mysqldump -u %USER% --password= %DBNAME% %%T --where="%WHERE_CLAUSE%" --no-create-info >> !OUTFILE!
    mysqldump -u %USER% --password= %DBNAME% %%T_traduction --where="%WHERE_CLAUSE%" --no-create-info >> !OUTFILE!
)