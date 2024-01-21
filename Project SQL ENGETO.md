# SQL PROJEKT
## ZADÁNÍ

Úvod do projektu

Na vašem analytickém oddělení nezávislé společnosti, která se zabývá životní úrovní občanů, jste se dohodli, že se pokusíte odpovědět na pár definovaných výzkumných otázek, které adresují dostupnost základních potravin široké veřejnosti. Kolegové již vydefinovali základní otázky, na které se pokusí odpovědět a poskytnout tuto informaci tiskovému oddělení. Toto oddělení bude výsledky prezentovat na následující konferenci zaměřené na tuto oblast.

Potřebují k tomu od vás připravit robustní datové podklady, ve kterých bude možné vidět porovnání dostupnosti potravin na základě průměrných příjmů za určité časové období.

Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.

Datové sady, které je možné použít pro získání vhodného datového podkladu

Primární tabulky:

1.	czechia_payroll – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
2.	czechia_payroll_calculation – Číselník kalkulací v tabulce mezd.
3.	czechia_payroll_industry_branch – Číselník odvětví v tabulce mezd.
4.	czechia_payroll_unit – Číselník jednotek hodnot v tabulce mezd.
5.	czechia_payroll_value_type – Číselník typů hodnot v tabulce mezd.
6.	czechia_price – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
7.	czechia_price_category – Číselník kategorií potravin, které se vyskytují v našem přehledu.

Číselníky sdílených informací o ČR:
1.	czechia_region – Číselník krajů České republiky dle normy CZ-NUTS 2.
2.	czechia_district – Číselník okresů České republiky dle normy LAU.

Dodatečné tabulky:
1.	countries - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.
2.	economies - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.

Výzkumné otázky
1.	Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
2.	Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
3.	Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
4.	Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
5.	Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

Výstup projektu

Pomozte kolegům s daným úkolem. Výstupem by měly být dvě tabulky v databázi, ze kterých se požadovaná data dají získat. Tabulky pojmenujte t_{jmeno}_{prijmeni}_project_SQL_primary_final (pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky) a t_{jmeno}_{prijmeni}_project_SQL_secondary_final (pro dodatečná data o dalších evropských státech).

Dále připravte sadu SQL, které z vámi připravených tabulek získají datový podklad k odpovězení na vytyčené výzkumné otázky. Pozor, otázky/hypotézy mohou vaše výstupy podporovat i vyvracet! Záleží na tom, co říkají data.


## ANALÝZA

Při tvorbě primární tabulky jsem zprvu řešil, jak napojit informace ze dvou, ne tak úplně souvisejících zdrojů dat. Bylo důležité si představit, co má být tím správným výstupem, aby tabulka dávala smysl a dalo se z ní dále vycházet. Rozhodl jsem se použít klauzuli UNION, abych dostal data o odvětvích mezd a druhů potravin pod sebe na řádky. To mi zajistilo zpřehlednění dat.

Poté jsem si potřeboval definovat 3 kategorie vstupních dat: mzda, potravina a HDP, abych byl schopen dále data porovnávat.

Poslední úskalí, které jsem řešil byl výběr dat pouze pro společné roky. Data o mzdách, cenách potravin a výši HDP měla jinou množinu hodnot sledovaných let. Proto bylo žádoucí použít klauzuli INTERSECT, která vrátila hodnotu jako průnik těchto množin.


## POSTUP

Tabulka 1

V prvním kroku jsem se snažil získat potřebná data separátně přes dílčí SELECT klauzuli. Celkem jsem potřeboval tyto  3 SELECT pro mzdy, potraviny a globální ekonomická data.

Tzn. nejprve jsem si sjednotil klauzulí JOIN tabulku cp.payroll s tabulkou cp.industry_branch, abych získal  přes společný klíč (5958 - týkající se pouze hrubé mzdy) výslednou tabulku s doplněním o příslušná odvětví, do jakého daná mzda spadá.  Pak jsem sjednotil klauzulí JOIN tabulku czechia_price s tabulkou czechia_price_category s cílem získat přes společný kód kategorie název této kategorie. V posledním SELECT jsem se snažil získat klauzulí WHERE pouze data týkající se České republiky a jež nemají hodnotu ve sloupci GDP prázdnou.

Současně jsem v SELECT cp.payroll a czechia_price použil sjednocovací klauzuli GROUP BY s cílem získat sjednocená data vždy v rámci celého jednoho roku a pro jednu konkrétní kategorii potravin/odvětví mzdy.

V druhém kroku jsem potřeboval použít klauzuli UNION, abych získal jednu výslednou tabulku se všemi potřebnými daty. Protože však lze tato klauzule použít pouze za předpokladu, že máme ve všech dílčích SELECT stejný počet sloupců, tak jsem vytvořil společné sloupce common_years, research_category, avg_value a research_subject.  

Ve třetím kroku jsem ještě potřeboval, aby výsledná data měla průnik ve společných zkoumaných letech a nevstupovaly mi do výsledné tabulky roky, které nejsou pro jednotlivé SELECT shodné. Musel jsem tedy pomocí vnořeného SELECT z doposud získané tabulky přidat klauzule WHERE a INTERSECT, které určily podmínku, aby byly vybrány roky, které jsou průnikem vzniklých SELECT ve sloupci common_year, jež se váže v každé tabulce k danému sloupci, kde se vyskytuje rok/datum v příslušném formátu.

Tabulka 2

Pro tuto tabulku bylo potřebné sloučení 2 tabulek a to: economies a countries, přes společný klíč, kterým je název země. Důvodem bylo, že jsme potřebovali tímto způsobem zjistit, které země spadají do Evropy, jakožto podmínky zadání. Druhá podmínka nám říká, že takto vzniklá tabulka má být za stejné období jako primární tabulka. Zvolil jsem tedy klauzuli WHERE, kde je specifikované, že mají být zkoumány pouze roky, které se vyskytují současně i v primární tabulce. 

Dotaz 1

Prvním krokem je vnořený SELECT s okenní fcí LAG a PARTITION BY. Tato kombinace nám zaručí přiřazení každému druhu research_category (konkrétní odvětví mzdy) v závislosti na common_years hodnotu předešlého roku avg_value_before_year. Nyní můžeme od průměrné hodnoty (průměr z průměrů) odečíst průměr předchozího roku, abychom dostali míru změny ratio ve výši mzdy každého odvětví. Pro usnadnění a hlavně přehlednost přiřadíme přes klauzuli CASE každému řádku, resp. odvětví konkrétního roku trend, zda-li roste, klesá, stagnuje nebo se jedná o nultý (počáteční) rok, kterým průzkum začíná. Přidáme ještě omezení, abychom získali data pouze týkající se mezd za použití klauzule WHERE. 

V druhém kroku takto nově vytvořený SELECT proložíme podmínkou WHERE, která nám zajistí zobrazení pouze odvětví, kde je trend klesající. Pro co nejkonkrétnější požadovaný výsledek seřadíme na základě sloupce research_category, abychom lépe viděli, v jakém odvětví mzdy klesají nejčastěji, resp. ve více letech za sledované období.

Dotaz 2

V první fázi jsem si vytvořil dvě separátní klauzule SELECT. První se týkala mezd a bylo potřeba zprůměrovat data mezd za všechna odvětví v každém sledovaném roce, abychom dostali právě jednu hodnotu mzdy pro daný rok. Pomocí klauzule GROUP BY jsem data seskupil dle předmětu zkoumání a společných let. Současně jsem klauzulí WHERE omezil výběr dat z primární tabulky tak, aby se zobrazila data týkající se pouze mezd a počátečního a koncového sledovaného období.

Druhá klauzule SELECT mi pomohla s výběrem dat týkajících se pouze konkrétních potravin mléko a chléb. Protože jsem měl data v primární tabulce nepřehledně pod sebou, tak jsem díky klauzuli MAX(CASE) zvolená data o mléku a chlebu překlopil do sloupců namísto původních řádku. Cílem bylo mít pouze dva řádky, pro každý rok jeden, aby se dala data z tabulky wage_data snáze napojit.

V druhé fázi jsem použil CTE fci WITH, díky které jsem získal zjednodušené tabulky wage_data  a food_data a ty pak napojil do sebe přes JOIN klauzuli pomocí klíče common_years, kterými byly sledované roky 2006 a 2018.

V posledním kroku bylo potřeba zjistit počet chleba a mléka, který si nakoupíme z průměrné mzdy v daném roce. Zde už jsem pouze přidal 2 sloupce pro počet litrů mléka a kilo chleba za mzdu v daném roce jako podíl průměrné mzdy a ceny mléka.

Dotaz 3

Prvním krokem je vnořený SELECT s okenní fcí LAG a PARTITION BY. Tato kombinace nám zaručí přiřazení každému druhu research_category (konkrétní druh potraviny) v závislosti na common_years hodnotu předešlého roku avg_value_before_year. Nyní můžeme od průměrné hodnoty (průměr z průměrů) odečíst průměr předchozího roku, abychom dostali míru změny ratio ve výši cen každé potraviny. Dotaz ještě omezíme fcí WHERE pouze pro potraviny.

Abychom však z dat byli schopni vyčíst informace týkající se míry zdražování jednotlivých druhů potravin s ohledem na počet let, tak budeme muset data ještě více seskupit a provést další vnořený SELECT, kterým vypočítáme průměrnou hodnotu avg_ratio, z průměrných přírůstků cen potravin v percentuálním vyjádření. Jinými slovy musíme zprůměrovat míru změny každého druhu potraviny pro sledované období let 2006-2018 a seskupit s pomocí GROUP BY podle příslušných druhů potravin.

V posledním kroku klauzulí WHERE určíme, že požadujeme pouze nejnižší nárůst tak, že hodnota průměrné změny je větší než nula, následně seřadíme pomocí  ORDER BY dle průměrné hodnoty změny a nakonec přes klauzuli LIMIT dostaneme právě 1 požadovanou výslednou hodnotu.

Dotaz 4

Prvním krokem je vnořený SELECT s okenní fcí LAG a PARTITION BY. Tato kombinace nám zaručí přiřazení každému druhu research_category (konkrétní potravina a odvětví mzdy) v závislosti na common_years hodnotu předešlého roku avg_value_before_year. Nyní můžeme od průměrné hodnoty (průměr z průměrů) odečíst průměr předchozího roku, abychom dostali míru změny ratio ve výši cen každé potraviny, odvětví mezd a HDP.

Pomocí druhého vnořeného SELECT dojde ke sjednocení na úrovni research_subject (kategorii mzda/potravina/HDP) v závislosti na příslušném roce common_years. Data sjednotíme pomocí GROUP BY s ohledem na zkoumanou věc (mzda/potravina/HDP) a společný rok. Výsledkem tedy je tabulka, kde každý rok obsahuje pouze jednu hodnotu změny výše průměrné mzdy, potraviny a HDP, resp. průměr z průměrů těchto hodnot avg_ratio. 

Aby se nám na otázku číslo 4 lépe odpovídalo, tak bychom si mohli data ještě lépe seřadit za pomocí 3. vnořeného SELECT. A to tak, že si vytvoříme namísto shluku dat o změně ve mzdách, cenách potravin a výší HDP v jednom sloupci tři doplňující sloupce pomocí fce MAX(CASE). Každý sloupec bude následně obsahovat pouze příslušné hodnoty vážící se ke mzdám avg_wage, cenám potravin avg_food a HDP avg_HDP. Navíc za přispění GROUP BY bude každý řádek seskupen v rámci daného roku. 

V posledním kroku určíme podmínku, která nám zobrazí výsledky, ve kterých letech je rozdíl mezi průměrnou mírou potravin a mzdy větší než 10%. Nesmíme zapomenout kromě podmínky na rozdíl hodnot mezi potravinou a mzdou zohlednit i možnost, že v jednom roce může potravina růst a mzda klesat, případně naopak.

Dotaz 5

Pomocí vnořeného SELECT přes fci CASE se snažíme řádky jednotlivých let vážící se k HDP, mzdám a potravinám přeměnit ve sloupce, abychom data zredukovali a zpřehlednili. Nedílnou součástí takovéhoto řešení je sjednocení mzdových odvětví a druhů potravin do jediné položky, tedy průměrné mzdy daného roku a průměrné ceny potravin daného roku. 

V druhém kroku je našim cílem sjednotit předměty zkoumání na jediný řádek vážící se k danému roku přes klauzuli SUM. 

Abychom byli schopni přehledně porovnat aktuální rok s rokem předešlým a mohli zodpovědět otázku, tak použijeme klauzuli LOG. Ta zajistí výběr dat z předchozího roku a pomocí rozdílu aktuálního a předchozího roku vrátí změnu dat v % pro mzdu, cenu potravin a HDP. V neposlední řadě sjednotíme na základě společných let pro unikátní hodnotu ve sloupci common_years.



## VÝSLEDKY

Otázka 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

Pokles mezd v odvětvích se v průběhu let děje běžně alespoň v jednom ze sledovaných období. Pokles ve dvou letech v průběhu období je patrný u Kulturní, zábavní a rekreační činnosti, Profesní, vědecké a technické činnosti, Ubytování, stravování a pohostinství, Veřejná správa a obrana; povinné sociální zabezpečení a Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu. Vůbec nejhorší situace je ale v odvětví Těžby a dobývání, kde mzdy klesaly dokonce ve 4 sledovaných letech a to 2009,2013,2014 a 2016.

Otázka 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

Z dat jsme zjistili, že ze mzdy v roce 2006 ve výši 20.754 Kč a ze 32.536 Kč v roce 2018 je možné zakoupit 1.437 litrů mléka a 1.287 kilo chleba, resp. 1.642 a 1.342. 

Otázka 3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

Pokud se budeme bavit výhradně o kategorii potravin, jejíž meziroční nárůst je nejnižší a nebudeme uvažovat potraviny u nichž dokonce průměrná míra ceny v letech klesá, tak kategorií s nejnižším průměrným meziročním nárůstem (v úhrnu průměrů průměrných změn v dílčích letech) jsou banány žluté.

Otázka 4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

Pokud chceme získat pro každý rok jednu průměrnou hodnotu výše mzdy, ceny potraviny a HDP, pak musíme nejprve toto množství dat sloučit a následně provést průměr z průměrů těchto hodnot.

Odpovědí na takto sloučená data je, že ani v jednom zkoumaném roce nepřekročil maximální průměrný přírůstek hodnoty potraviny výši 10% a to ani ve vztahu ke mzdě (tedy rozdílu průměrných přírůstků potravin ke mzdě).

Otázka 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

Výše HDP nemá přímý vliv na změnu ve mzdách v aktuálním roce, ani v roce předešlém. Mzdy dlouhodobě rostou nezávisle na vývoji ekonomiky. Dokonce v některých slabších letech rostou rychleji než vývoj HDP.

U potravin je situace hodně podobná, ceny potravin rostou každým rokem dlouhodobě. Paradoxně v některých letech slabšího HDP dokonce naprosto disproporčně. Např. i když HDP v roce 2012 oproti předešlému roku pokleslo, tak cena potravin vzrostla o více než 6%. 

Z makroekonomického hlediska jde tento trend ruku v ruce s politikou centrálních bank a ideového zabarvení současného západního světa. Ceny ani mzdy nerostou s vývojem ekonomiky, ale výrazně rychleji než samotná ekonomika.
