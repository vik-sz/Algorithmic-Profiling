# PREPARATTION #########################################################################################################
# Libraries ------------------------------------------------------------------------------------------------------------
library(tidyverse)
library(psych) # for function describe
library(writexl)
library(DataExplorer)
library(janitor)

# Load data ------------------------------------------------------------------------------------------------------------
data <- readRDS("data/dataJuSAW.rds")

# Exploring the data ===================================================================================================
str(data)
names(data)
summary(data)
describe(data)

# Variable exploration =================================================================================================

# General ==============================================================================================================
# Abhängige Variable kurzfristiges Kriterium ---------------------------------------------------------------------------
# innerhalb von 7 Monaten nach "Meilenstein" insgesamt 90 Tage in ungeförderter Beschäftigung stehend (1), sonst (0)
table(data$r_besch)
data$EMPLOYMENTDAYS <- factor(data$r_besch, levels = c(0, 1), labels = c("<90 Days", ">=90 Days"), ordered = FALSE)
table(data$EMPLOYMENTDAYS, useNA = "always") # cannot use NAs
data <- subset(data, !is.na(EMPLOYMENTDAYS))
# Job at second interview
table(data$job_t1)
table(data$r_besch, data$job_t1) # Kombination aus beidem für eine neue Variable?

# Other ------------------------------------------------------------------------
#data$case
table(data$ams_t1) # Derzeitiger Status: beim AMS gemeldet?
table(data$month_of_interview) # Monat erstes Interview?
table(data$month_of_interview_t1) # Monat zweites Interview ca. ein Jahr später

# Agegroup -------------------------------------------------------------------------------------------------------------
# the characteristic AGE GROUP is redefined: less than 20 years (0), 20 to 24 years (20).
table(data$ageg, useNA = "always")
data$AGEGROUP <- factor(data$ageg)
table(data$AGEGROUP)

# GESCHLECHT_WEIBLICH: Geschlecht weiblich, mit 0= männlich, 1=weiblich ------------------------------------------------
table(data$r_geschlecht, useNA = "always")
table(data$female, data$r_geschlecht) # lieber female verwenden, hat weniger missings
data$GENDER <- factor(data$female, levels = c("0", "1"), labels = c("male", "female"), ordered = FALSE)

# Children ---------------------------------------------------------------------
# Betreuungspflichten (nur für Frauen)
table(data$r_betreuungspflichten)
table(data$r_betreuungspflichten, data$kinder) 
table(data$r_betreuungspflichten, data$female)
table(data$kinder, data$female)
table(data$kinder, useNA = "always")

data$CHILDCARE_both <-factor(data$kinder, levels = c("ja", "nein"), labels =  c("ja", "nein"), ordered = FALSE)
data$CHILDCARE <- ifelse(data$GENDER == "female" & data$CHILDCARE_both =="ja", "yes", "no")
data$CHILDCARE <- factor(data$CHILDCARE, ordered = FALSE)
data$CHILDCARE_men <- ifelse(data$GENDER == "male" & data$CHILDCARE_both =="ja", "ja", "nein")
data$CHILDCARE_men <- factor(data$CHILDCARE_men, ordered = FALSE)
data$CHILDCARE_both <- relevel(data$CHILDCARE_both, ref = "nein")
data$CHILDCARE <- relevel(data$CHILDCARE, ref = "nein")
data$CHILDCARE_men <- relevel(data$CHILDCARE_men, ref = "nein")
table(data$CHILDCARE_both)
table(data$CHILDCARE)
table(data$CHILDCARE, data$GENDER)
table(data$CHILDCARE_men, data$GENDER)
table(data$CHILDCARE_both, data$GENDER)

# Health ---------------------------------------------------------------------------------------------------------------
# Beeinträchtigt
table(data$shealth, useNA = "always") # Wie schätzen Sie Ihren allgemeinen Gesundheitszustand ein?
table(data$lhealth, useNA = "always") # wahrscheinlich beste Wahl - # Werden Sie bei Ihren täglichen Aktivitäten in irgendeiner Weise von einer längeren Krankheit oder einer Behinderung beeinträchtigt?
table(data$longill, useNA = "always") # Kam es im letzten Jahr vor, dass Sie länger als 6 Wochen ununterbrochen krank waren?
data$IMPAIRMENT_order <-factor(data$lhealth, levels = c("ja stark", "ja ein wenig", "nein", "keine Angabe"), 
                               labels =  c("yes, very", "yes, a little", "no", "not specified"), ordered =  TRUE)
fct_rev(data$IMPAIRMENT_order)
data$IMPAIRMENT <-ifelse(data$IMPAIRMENT_order == "yes, very", "yes", "no")
data$IMPAIRMENT <- ifelse(data$IMPAIRMENT_order == "not specified", NA, data$IMPAIRMENT)
data$IMPAIRMENT <- factor(data$IMPAIRMENT, ordered = FALSE)
data$IMPAIRMENT <- relevel(data$IMPAIRMENT, ref = "no")

data$IMPAIRMENT_strong <-ifelse(data$IMPAIRMENT_order == "yes, very" | data$IMPAIRMENT_order == "yes, a little", "yes", "no")
data$IMPAIRMENT_strong <- ifelse(data$IMPAIRMENT_order == "not specified", NA, data$IMPAIRMENT_strong)
data$IMPAIRMENT_strong <- factor(data$IMPAIRMENT_strong, ordered = FALSE)
data$IMPAIRMENT_strong <- relevel(data$IMPAIRMENT_strong, ref = "no")

is.ordered(data$IMPAIRMENT_order)
is.ordered(data$IMPAIRMENT)


table(data$IMPAIRMENT_order, useNA = "always")
table(data$IMPAIRMENT_order, data$lhealth, useNA = "always")
table(data$IMPAIRMENT, data$IMPAIRMENT_order, useNA = "always")
table(data$IMPAIRMENT_strong, useNA = "always")

# Migration background -------------------------------------------------------------------------------------------------
table(data$birthAT, useNA = "always")
table(data$birthAT_v, useNA = "always") # Vater: Geburtsland Österreich
table(data$birthAT_m, useNA = "always") # Mutter: Geburtsland Österreich
table(data$migklasse, useNA = "always")
table(data$schuleat, useNA = "always") 

table(data$mighint12g_new, useNA = "always") # 0=kein Migrationshintergrund - wenn keine Info zu Vater/Mutter, dann nur Mig wenn Hinweis durch 1 Elternteil
ggplot(data, aes(x = mighint12g_new, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill") 

table(data$deutsch5, useNA = "always") # leider nur t1
ggplot(data, aes(x = deutsch5, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill") #

table(data$deutschpex, useNA = "always") 
ggplot(data, aes(x = as.factor(deutschpex), group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")

# Staatengruppe
table(data$r_staatengruppe, useNA = "always")  
data$STATEGROUP <- factor(data$r_staatengruppe, levels = c("AUT", "DRITT", "EU"), 
                          labels =  c("AUT", "DRITT", "EU"), ordered = FALSE)
table(data$STATEGROUP, useNA = "always")

data$stategroup01 = as.factor(ifelse(data$STATEGROUP == "AUT", "AUT", "nAUT"))


# Variable Isalm und other
data$relig_islam <- as.factor(ifelse(data$relig == "Islam", "Islam", "other"))
ggplot(data, aes(x = relig_islam, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = relig_islam, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")

# RGS Typ --------------------------------------------------------------------------------------------------------------
table(data$r_rgstyp, useNA = "always") 
data$RGS <-factor(data$r_rgstyp, levels = c("1", "2", "3", "4"), labels =  c("1", "2", "3", "4"), ordered = TRUE)
table(data$RGS, useNA = "always")

# RGS Typ 1 auslassen, da es nur einmal/zweimal vorkommt/ oder zu 2 hinzutun?
data[data$RGS==1 & !is.na(data$RGS),"RGS"] <- 2

# Hard Skills ==========================================================================================================
# Education ------------------------------------------------------------------------------------------------------------
table(data$ausb_t1, useNA = "always")
table(data$eduhöchst4, useNA = "always")
table(data$eduhöchst4,data$eduhöchst4_t1, useNA = "always")

table(data$notede, useNA = "always") # Schulnote letztes Zeugnis: Deutsch
table(data$notema, useNA = "always") # Schulnote letztes Zeugnis: Mathematik

table(data$elternschulint, useNA = "always")
table(data$yrsedu, useNA = "always")

table(data$edumore, useNA = "always")
ggplot(data, aes(x = as.factor(edumore), group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = as.factor(edumore), group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")

table(data$abbruch01, useNA = "always")
ggplot(data, aes(x = as.factor(abbruch01), group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = as.factor(abbruch01), group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")

# AUSBILDUNG: Ausbildung
table(data$r_ausbildung, useNA = "always") 
data$EDUCATION <- factor(data$r_ausbildung, levels = c("L", "M", "P"), labels =  c("L", "M", "P"), ordered = FALSE)
data$EDUCATION <- relevel(data$EDUCATION, ref = "P")
table(data$EDUCATION, useNA = "always")

# Ability --------------------------------------------------------------------------------------------------------------
table(data$SDT, useNA = "always")  # Symbol Zahlen Test  
# Geht eigentlich nur bis 10, wo kommt die 11 her?
data[data$SDT == 11, "SDT"] <- 10
ggplot(data, aes(x = EMPLOYMENTDAYS, y = SDT)) +
  geom_boxplot() #+
  #geom_jitter()
table(cut(data$SDT, 4))
data$SDT_grouped <- as.numeric(cut(data$SDT, 4))

table(data$tiere_no, useNA = "always") # Tiere nennen, Anzahl - händisch kodiert / gezählt
ggplot(data, aes(x = EMPLOYMENTDAYS, y = tiere_no)) +
  geom_boxplot()
table(cut(data$tiere_no, 4))
data$tiere_no_grouped <- as.numeric(cut(data$tiere_no, 4))


table(data$recall, useNA = "always") # Lernen einer Wörterliste
ggplot(data, aes(x = EMPLOYMENTDAYS, y = recall)) +
  geom_boxplot()
table(cut(data$recall, 4))
data$recall_grouped <- as.numeric(cut(data$recall, 4))

table(data$drecall, useNA = "always") # Lernen einer Wörterliste 
ggplot(data, aes(x = EMPLOYMENTDAYS, y = drecall)) +
  geom_boxplot()
table(cut(data$drecall, 4))
data$drecall_grouped <- as.numeric(cut(data$drecall, 4))

table(data$rechnencorr1, useNA = "always") # Rechenaufgabe I: Kosten
data$rechnencorr1 <- as.factor(data$rechnencorr1)
data$rechnencorr2 <- as.factor(data$rechnencorr2)
ggplot(data, aes(x = rechnencorr1, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = rechnencorr1, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")
table(data$rechnencorr2, useNA = "always") # Rechenaufgabe II: Preis
ggplot(data, aes(x = rechnencorr2, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = rechnencorr2, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")

table(data$kast1corra, useNA = "always") # 1. Kästchentest
data$kast1corra <- as.factor(data$kast1corra)
data$kast2corra <- as.factor(data$kast2corra)
ggplot(data, aes(x = as.factor(kast1corra), group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = as.factor(kast1corra), group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")
table(data$kast2corra, useNA = "always") # 2. Kästchentest - KA als falsche Antwort kodiert
ggplot(data, aes(x = as.factor(kast2corra), group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = as.factor(kast2corra), group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")


# Ability Variable Zusammenfassung? Für alle aufgaben gleiche Punktzahl - 8 Aufgaben gesamt
data$ability <- data$SDT_grouped +data$tiere_no_grouped + data$drecall_grouped + data$drecall_grouped + 
  4*as.numeric(data$rechnencorr1) + 4*as.numeric(data$rechnencorr2) + 
  4*as.numeric(data$kast1corra) + 4*as.numeric(data$kast2corra)
table(data$ability, useNA = "always")
ggplot(data, aes(x = EMPLOYMENTDAYS, y = ability)) +
  geom_boxplot()

# Job ------------------------------------------------------------------------------------------------------------------
# Berufsgruppe Produktion oder Service
table(data$r_berufsgruppe_ams1, useNA = "always")
table(data$r_berufsgruppe, useNA = "always")
table(data$r_berufsgruppe_ams1, data$r_berufsgruppe, useNA = "always")
data$OCCUPATIONGROUP_all <- factor(data$r_berufsgruppe_ams1, ordered = FALSE)
data$OCCUPATIONGROUP <- factor(data$r_berufsgruppe, ordered = FALSE)

# Beschäftigungsverlauf
# BESCHÄFTIGUNGSVERLAUF: Beschäftigungsverlauf vor AL
table(data$r_beschverl_voral, useNA = "always")
data$EMPLOYMENTHIST <- factor(data$r_beschverl_voral, levels = c(1, 2), labels = c(">75%", "<75%"), ordered = FALSE)
table(data$EMPLOYMENTHIST, useNA = "always")


table(data$r_monate_erw_j1voral, useNA = "always")
table(data$r_monate_erw_j2voral, useNA = "always")
table(data$r_monate_erw_j3voral, useNA = "always")
table(data$r_monate_erw_j4voral, useNA = "always")

# Unemployment experience
table(data$ALexp, useNA = "always") # Vielleicht das statt EMPLOYMENT?
table(data$exp, useNA = "always") #  Erwerbstätigkeit Lifetime Gesamtdauer - Summe aus Jahren und Monaten Erfahrung - in Jahren

# Geschäftsfalldauer
# 0 = kein Geschäftsfall mit Dauer >= 180 Tage; 1 = 1 oder mehrere Geschäftsfälle mit Dauer >= 180 Tage -> halbes Jahr
table(data$r_geschfalldau_voral, useNA = "always")
table(data$r_geschfalldau3m_voral, useNA = "always")
data$BUSINESSCASEDUR <- factor(data$r_geschfalldau_voral, levels = c(0, 1), 
                               labels = c("kein GF>=180", "GF>=180"), ordered = FALSE)


table(data$r_geschaeftsfall_j1voral, useNA = "always")
table(data$r_geschaeftsfall_j2voral, useNA = "always")
table(data$r_geschaeftsfall_j3voral, useNA = "always")
table(data$r_geschaeftsfall_j4voral, useNA = "always")

# Geschäftsfallfrequenz
table(data$r_geschfallfreq_voral, useNA = "always")
data$BUSINESSCASEFREQ <- factor(data$r_geschfallfreq_voral)
data$BUSINESSCASEFREQ_order <- factor(data$r_geschfallfreq_voral, levels = c(0, 1, 2, 3),  ordered = TRUE)
table(data$BUSINESSCASEFREQ_order)

# Maßnahmenteilnahme
table(data$r_maßnahmenteilnahme, useNA = "always")
data$SUPPORTMEASURE <- factor(data$r_maßnahmenteilnahme, levels = c(0, 1, 2, 3), 
                              labels = c("kM", "min 1 unterst.", "min 1 qual", "min 1 Bförd"), ordered = FALSE)
data$SUPPORTMEASURE_order <- factor(data$SUPPORTMEASURE, ordered = TRUE)
table(data$SUPPORTMEASURE_order)
is.ordered(data$SUPPORTMEASURE_order)


# Letzter Job Charakteristika ------------------------------------------------------------------------------------------
# What job was the last job and what contract?
table(data$statuslastjob, useNA = "always")
table(data$angest_level_l, useNA = "always") 
table(data$beruf_letzt_isco1_t0, useNA = "always")
table(data$beruf_letzt_isco1_t1, useNA = "always") 
table(data$beruf_isco1_t1, useNA = "always") 

# How many were employed before/ for at least 3 months?
table(data$job3, useNA = "always") # 3 Monate Job gehabt?
table(data$dauer_längster, useNA = "always")

table(data$match, useNA = "always") # Qualitätsmerkmal job
table(data$match_l_t1, useNA = "always")
table(data$match_t1, useNA = "always")

table(data$jobsat, useNA = "always")
table(data$jobsat_l_t1, useNA = "always")
table(data$jobsat_t1, useNA = "always")

table(data$vertrag, useNA = "always")
table(data$vertrag_l_t1, useNA = "always")
table(data$vertrag_t1, useNA = "always")

table(data$firmsize, useNA = "always")

# Why did it end?
table(data$endlastjob, useNA = "always")
table(data$endlastjob_t1, useNA = "always")
table(data$endreason, useNA = "always") # Zusammenfassung
data$endreason01 <- ifelse(data$endreason == "Mein Arbeitgeber hat mich gekündigt", 1, 0)
table(data$endreason01, useNA = "always") # Zusammenfassung


# Next job -------------------------------------------------------------------------------------------------------------
table(data$zusage, useNA = "always") 
table(data$zusage_t1, useNA = "always")
table(data$zusage, data$EMPLOYMENTDAYS, useNA = "always")
table(data$zusage_t1, data$EMPLOYMENTDAYS, useNA = "always")

# Job search
table(data$bewerbung_no, useNA = "always")      
table(data$vorstell_no, useNA = "always")
table(data$suche_specific, useNA = "always")   

table(data$suchintens, useNA = "always") # leider nur t1
ggplot(data, aes(x = EMPLOYMENTDAYS, y = suchintens)) +
  geom_boxplot() 

# Soft Skilss ==========================================================================================================
# Jobattributpräferenz -------------------------------------------------------------------------------------------------
# Motivation
table(data$effortmot, useNA = "always")

table(data$jap_jobsec, useNA = "always")
table(data$jap_income, useNA = "always")
table(data$jap_career, useNA = "always")
table(data$jap_anerkennung, useNA = "always")
table(data$jap_freizeit, useNA = "always")
table(data$jap_independent, useNA = "always")
table(data$jap_creative, useNA = "always")
table(data$jap_selfdevel, useNA = "always")
table(data$jap_learnopp, useNA = "always")
table(data$jap_interest, useNA = "always")
table(data$jap_social, useNA = "always")
table(data$jap_help, useNA = "always")

data$intrins <- (data$jap_selfdevel +data$jap_learnopp +data$jap_independent
                 + data$jap_creative +data$jap_interest)/5
data$extrins <- (data$jap_jobsec+ data$jap_income 
                 + data$jap_career + data$jap_anerkennung)/4 #values 1-4
data$intrins_min_extrins <- data$intrins - data$extrins
table(data$intrins, useNA = "always")
table(data$extrins, useNA = "always")
table(data$intrins_min_extrins, useNA = "always")
ggplot(data, aes(x = EMPLOYMENTDAYS, y = intrins)) +
  geom_boxplot()
ggplot(data, aes(x = EMPLOYMENTDAYS, y = extrins)) +
  geom_boxplot()
ggplot(data, aes(x = EMPLOYMENTDAYS, y = intrins_min_extrins)) +
  geom_boxplot()

data$intrins_t1 <- (data$jap_selfdevel_t1 +data$jap_learnopp_t1 +data$jap_independent_t1
                 + data$jap_creative_t1 +data$jap_interest_t1)/5
data$extrins_t1 <- (data$jap_jobsec_t1 + data$jap_income_t1 
                 + data$jap_career_t1 + data$jap_anerkennung_t1)/4 #values 1-4


# Work Attitudes
table(data$lottery, useNA = "always")
ggplot(data, aes(x = lottery, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = lottery, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")
table(data$leisurevalue, useNA = "always")
ggplot(data, aes(x = EMPLOYMENTDAYS, y = leisurevalue)) +
  geom_boxplot()
table(data$familyvalue, useNA = "always")
ggplot(data, aes(x = EMPLOYMENTDAYS, y = familyvalue)) +
  geom_boxplot()
table(data$lifesat, useNA = "always")
ggplot(data, aes(x = EMPLOYMENTDAYS, y = lifesat)) +
  geom_boxplot()
table(data$prefcat, useNA = "always")
ggplot(data, aes(x = prefcat, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = prefcat, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")

table(data$fertint, useNA = "always") # Haben Sie vor, in den nächsten drei Jahren ein (weiteres) Kind zu bekommen?
ggplot(data, aes(x = fertint, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = fertint, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")
table(data$fertint_t1, useNA = "always")

# Sinn von Arbeit: Geld verdienen, dazugehören, interessante Tätigkeiten ausführen
table(data$a_instrumental, useNA = "always") # Einstellungen zu Arbeit: Arbeit ist nur ein Mittel, um Geld zu verdienen.
ggplot(data, aes(x = a_instrumental, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = a_instrumental, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")

table(data$a_belong, useNA = "always") # Einstellungen zu Arbeit: Arbeit ist wichtig, weil sie einem das Gefühl gibt, dazuzugehören.
ggplot(data, aes(x = a_belong, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = a_belong, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")

table(data$a_interest, useNA = "always") # Einstellungen zu Arbeit: Arbeit ist wichtig, weil sie einem erlaubt, interessante Tätigkeiten auszuüben.
ggplot(data, aes(x = a_interest, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = a_interest, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")

# Reservationslohn (Nettoverdienst)
table(data$reserve, useNA = "always") 
ggplot(data, aes(x = EMPLOYMENTDAYS, y = reserve)) +
  geom_boxplot()
table(data$reserveDK, useNA = "always") # Don't know

# Personality ----------------------------------------------------------------------------------------------------------
# Selbstwert
table(data$sw_träumer, useNA = "always") 
ggplot(data, aes(x = sw_träumer, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = sw_träumer, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")
table(data$sw_wertlos, useNA = "always")
table(data$sw_selbstzweifel, useNA = "always")
table(data$sw_zukunftsangst, useNA = "always")
table(data$sw_mitmirzufrieden, useNA = "always")
table(data$sw_selbstwert, useNA = "always") # selbstwert=(wertlos+zukunftsangst+selbstzweifel)/3, Alpha=0.78
ggplot(data, aes(x = EMPLOYMENTDAYS, y = sw_selbstwert)) +
  geom_boxplot()

table(data$risk, useNA = "always") # Risikobereitschaft
ggplot(data, aes(x = EMPLOYMENTDAYS, y = risk)) +
  geom_boxplot()
table(data$trust, useNA = "always")
ggplot(data, aes(x = EMPLOYMENTDAYS, y = trust)) +
  geom_boxplot()

# Big Five Personality
table(data$p_introvertiert, useNA = "always") # Was ist 1 und was ist 5?
table(data$p_trust, useNA = "always")
table(data$p_faul, useNA = "always")
table(data$p_laidback, useNA = "always")
table(data$p_goaloriented, useNA = "always")
table(data$p_noculture, useNA = "always") 
table(data$p_extravert, useNA = "always")
table(data$p_sorgen, useNA = "always")
table(data$p_kritisieren, useNA = "always")
table(data$p_gründlich, useNA = "always")
table(data$p_insecure, useNA = "always")
table(data$p_fantasie, useNA = "always")
table(data$p_tüchtig, useNA = "always")

table(data$gewissenh, useNA = "always") # p_tüchtig + p_gründlich + p_goaloriented)/3
ggplot(data, aes(x = EMPLOYMENTDAYS, y = gewissenh)) +
  geom_boxplot()

# locus of control
table(data$locus_self, useNA = "always")
table(data$locus_luck, useNA = "always")
table(data$locus_work, useNA = "always")
table(data$locus_selbstzweifel, useNA = "always")
table(data$locus_nocontrol, useNA = "always")

# Depression
table(data$dep_gelassen, useNA = "always")
table(data$dep_einsam, useNA = "always")
table(data$dep_ärgerlich, useNA = "always")
table(data$dep_niedergeschlagen, useNA = "always")
table(data$dep_glücklich, useNA = "always")
table(data$dep_nervös, useNA = "always")
table(data$dep_ängstlich, useNA = "always")
table(data$dep_traurig, useNA = "always")
table(data$dep_energie, useNA = "always")
table(data$depress, useNA = "always") # Summenindex ((6-dep_gelassen)+dep_einsam+dep_ärgerlich+dep_niedergeschlagen+(6-dep_glücklich)+dep_nervös+dep_ängstlich+dep_traurig+(6-dep_energie)) divided by 9 - 1 to 5
ggplot(data, aes(x = EMPLOYMENTDAYS, y = depress)) +
  geom_boxplot()
table(data$depress_WHO, useNA = "always") # Sumenindex wie depress, auf einer anderen Skala 0-36
table(data$depress10_WHO, useNA = "always") # 0 to 10
table(data$depressrisk_WHO, useNA = "always") # Indikator für Risiko wenn depress_WHO >18
data$depressrisk_WHO <- as.factor(data$depressrisk_WHO)
data$depressrisk_WHO_t1 <- as.factor(data$depressrisk_WHO_t1)
ggplot(data, aes(x = depressrisk_WHO, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = depressrisk_WHO, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")

data$depress_d # Differenz Summenindex Welle2-Welle 1, N=584 nur vollständige Angaben

# Behavior -------------------------------------------------------------------------------------------------------------
table(data$alkohol, useNA = "always")
ggplot(data, aes(x = alkohol, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = alkohol, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")
table(data$alccut) # Haben Sie schon einmal das Gefühl gehabt, dass Sie Ihren Alkoholkonsum verringern sollten?
ggplot(data, aes(x = alccut, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = alccut, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")

table(data$rauchen, useNA = "always")
ggplot(data, aes(x = rauchen, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = rauchen, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")

table(data$schlaf, useNA = "always") # Was bedeuten Auswahlmöglichkeiten?
table(data$sport, useNA = "always")
ggplot(data, aes(x = sport, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = sport, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")

table(data$ernährung, useNA = "always")
table(data$fz_fernsehen_video, useNA = "always")
ggplot(data, aes(x = fz_fernsehen_video, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = fz_fernsehen_video, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")

table(data$fz_computerspiele, useNA = "always")
ggplot(data, aes(x = fz_computerspiele, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = fz_computerspiele, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")

table(data$fz_internetsurfen, useNA = "always")
ggplot(data, aes(x = fz_internetsurfen, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = fz_internetsurfen, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")

table(data$fz_musikhören, useNA = "always")
table(data$fz_lesen, useNA = "always")
ggplot(data, aes(x = fz_lesen, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = fz_lesen, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")

# Time structure -------------------------------------------------------------------------------------------------------
# nochmal nachschauen was das jahoda zeug ist und was ist das p - p heißt vergangen
# Alles t1 mit sher vielen missings
table(data$jahoda_timestruc_aufst, useNA = "always")
table(data$jahoda_timestruc_termine, useNA = "always")
table(data$jahoda_timestruc_tag, useNA = "always")
table(data$jahoda_timestruc_bett, useNA = "always")
table(data$jahoda_timestruc, useNA = "always")

# Social
table(data$jahoda_social_treff, useNA = "always")
table(data$jahoda_social_einsam, useNA = "always")
table(data$jahoda_social_kolleg, useNA = "always")
table(data$jahoda_social, useNA = "always")
table(data$jahoda_purpose_lang, useNA = "always")

table(data$jahoda_purpose_zeit, useNA = "always")

table(data$jahoda_stigma_unan, useNA = "always")
table(data$jahoda_stigma_sorg, useNA = "always")

table(data$jahoda_depress_down_p, useNA = "always")
table(data$jahoda_depress_interest_p, useNA = "always")
table(data$jahoda_depress_p, useNA = "always")

# Finanzen
table(data$jahoda_finanz1_p, useNA = "always")
table(data$jahoda_finanz2_p, useNA = "always")
table(data$jahoda_finanz_p, useNA = "always")

# Social ---------------------------------------------------------------------------------------------------------------
table(data$socialmeet, useNA = "always")
table(data$socialcomp, useNA = "always") # Wenn Sie sich mit Gleichaltrigen vergleichen, wie oft nehmen Sie an geselligen Ereignissen oder Treffen teil?
ggplot(data, aes(x = socialcomp, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = socialcomp, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")

table(data$freunde, useNA = "always")

# t1 Variablen
table(data$soc_konflikt, useNA = "always") 
table(data$soc_versteh, useNA = "always")


# Finances
table(data$finanzgut, useNA = "always")
ggplot(data, aes(x = finanzgut, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = finanzgut, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")

table(data$finanzschlecht, useNA = "always")
table(data$efinanzgut, useNA = "always")
table(data$efinanzschlecht, useNA = "always")
table(data$e_unterstütz, useNA = "always")
ggplot(data, aes(x = EMPLOYMENTDAYS, y = e_unterstütz)) +
  geom_boxplot()


# Discrimination -> t1 sehr viele NAs
table(data$diskrim, useNA = "always")
table(data$diskrim_nat, useNA = "always")
table(data$diskrim_rel, useNA = "always")
table(data$diskrim_lan, useNA = "always")
table(data$diskrim_col, useNA = "always")
table(data$diskrim_age, useNA = "always")
table(data$diskrim_sex, useNA = "always")
table(data$diskrim_phy, useNA = "always")
table(data$diskrim_other, useNA = "always")
table(data$ges_status, useNA = "always") # Gesellschaftlicher Status - Position in Hierarchie

# Relationships --------------------------------------------------------------------------------------------------------
# Relationship
table(data$beziehung, useNA = "always")

# Siblings
table(data$geschwist, useNA = "always")

# Parents
table(data$edudad, useNA = "always")
ggplot(data, aes(x = edudad, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = edudad, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")
table(data$dadwork, useNA = "always")
ggplot(data, aes(x = dadwork, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = dadwork, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")


table(data$dadberuf, useNA = "always")

table(data$edumum, useNA = "always")
ggplot(data, aes(x = edumum, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = edumum, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")
table(data$mumwork, useNA = "always")
ggplot(data, aes(x = mumwork, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = position_dodge(width = 0.5))
ggplot(data, aes(x = mumwork, group = EMPLOYMENTDAYS, fill = EMPLOYMENTDAYS)) +
  geom_bar(position = "fill")

table(data$mumberuf, useNA = "always")

table(data$varbeitgerne, useNA = "always")
table(data$varbeitwichtig, useNA = "always")
table(data$marbeitgerne, useNA = "always")
table(data$marbeitwichtig, useNA = "always")
table(data$arbeitswerte_elt, useNA = "always")
data$arbeitswerte_elt0 <- ifelse(is.na(data$arbeitswerte_elt), 0, data$arbeitswerte_elt)
table(data$arbeitswerte_elt0, useNA = "always")
ggplot(data, aes(x = EMPLOYMENTDAYS, y = arbeitswerte_elt)) +
  geom_boxplot()


table(data$mobilityv, useNA = "always")
table(data$mobilitym, useNA = "always")
table(data$mobility_both, useNA = "always")
table(data$mobility_both2, useNA = "always")

# Who's living in the same household
# Gibts auch alles mit t1
table(data$hhvater, useNA = "always")
table(data$hhstiefvater, useNA = "always")
table(data$hhmutter, useNA = "always")
table(data$hhstiefmutter, useNA = "always")
table(data$hhpartner, useNA = "always")
table(data$hhkinder, useNA = "always")
table(data$hhkinder, data$female, data$r_betreuungspflichten, useNA = "always")
table(data$hhkinderpartner, useNA = "always")
table(data$hhgeschwister, useNA = "always")
table(data$hhgroßeltern, useNA = "always")
table(data$hhwg, useNA = "always")
table(data$hhalleine, useNA = "always")
table(data$hhsonst, useNA = "always")
table(data$hhsize, useNA = "always")



# Save dataset =========================================================================================================
data_clean <- janitor::clean_names(data)

saveRDS(data, "data/JuSAW_prepared.rds")
saveRDS(data_clean, "data/JuSAW_prepared_clean.rds")