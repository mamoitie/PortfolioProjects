
/*  2020-01-01 to 2021-04-30 DATA*/


CREATE DATABASE portfolio_project;
use portfolio_project;


CREATE TABLE coviddeaths(
iso_code VARCHAR(255),
continent VARCHAR(255),
location VARCHAR(255),
date DATE,
poplulation VARCHAR(255),
total_case VARCHAR(255),
new_case VARCHAR(255),
new_case_smoothed VARCHAR(255),
total_deaths VARCHAR(255),
new_deaths VARCHAR(255),
new_deaths_smoothed VARCHAR(255),
total_cases_per_million VARCHAR(255),
new_case_per_million VARCHAR(255),
new_case_smoothed_per_million VARCHAR(255),
total_deaths_per_million VARCHAR(255),
new_deaths_per_million VARCHAR(255),
new_deaths_smoothed_per_million VARCHAR(255),
reproduction_rate VARCHAR(255),
icu_patients VARCHAR(255),
ice_patients_per_million VARCHAR(255),
hosp_patients VARCHAR(255),
hosp_patients_per_million VARCHAR(255),
weekly_icu_admissions VARCHAR(255),
weekly_icu_admissions_per_million VARCHAR(255),
weekly_hosp_admissions VARCHAR(255),
weekly_hosp_admissions_per_million VARCHAR(255)
);



LOAD DATA infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CovidDeaths.csv'
INTO TABLE coviddeaths
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

show tables;
SELECT * from coviddeaths;
select COUNT(*) FROM coviddeaths;


CREATE TABLE covidvaccinations(
iso_code VARCHAR(255),
continent VARCHAR(255),
location VARCHAR(255),
date DATE,
new_tests VARCHAR(255),
total_tests VARCHAR(255),
total_tests_per_thousand VARCHAR(255),
new_tests_per_thousand VARCHAR(255),
new_tests_smoothed VARCHAR(255),
new_tests_smoothed_per_thousand VARCHAR(255),
positive_rate VARCHAR(255),
tests_per_case VARCHAR(255),
tests_units VARCHAR(255),
total_vaccinations VARCHAR(255),
people_vaccinated VARCHAR(255),
people_fully_vaccinated VARCHAR(255),
new_vaccinations VARCHAR(255),
new_vaccinations_smoothed VARCHAR(255),
total_vaccinations_per_hundred VARCHAR(255),
people_vaccinated_per_hundred VARCHAR(255),
people_fully_vaccinated_per_hundred VARCHAR(255),
new_vaccinations_smoothed_per_million VARCHAR(255),
stringency_index VARCHAR(255),
population_density VARCHAR(255),
median_age VARCHAR(255),
aged_65_older VARCHAR(255),
aged_70_older VARCHAR(255),
gdp_per_capita VARCHAR(255),
extreme_poverty VARCHAR(255),
cardiovasc_death_rate VARCHAR(255),
diabetes_prevalence VARCHAR(255),
female_smokers VARCHAR(255),
male_smokers VARCHAR(255),
handwashing_facilities VARCHAR(255),
hospital_beds_per_thousand VARCHAR(255),
life_expectancy VARCHAR(255),
human_development_index VARCHAR(255)
);


select * from covidvaccinations;
DESC covidvaccinations;

LOAD DATA infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Covid_19Vac.csv'
INTO TABLE covidvaccinations
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from covidvaccinations
order by 3,4;
 
select * from coviddeaths
WHERE continent is not null
order by 3,4;


DELETE FROM coviddeaths WHERE location in ( 'world', 'Africa','Oceania','Ueropean Union','Asia');
DELETE FROM coviddeaths WHERE location in ( 'Europe','Ueropean Union','International');
DELETE FROM coviddeaths WHERE location = 'European Union';
DELETE FROM coviddeaths WHERE location = 'South America';

DELETE FROM covidvaccinations WHERE location in ( 'North America','South America','world', 'Africa','Oceania','Ueropean Union','International','Asia');
DELETE FROM covidvaccinations WHERE location = 'European Union';


-- Looking at Total Cases vs Total Deaths

-- Shows the percentage of dying if you have contract covid in your country
SELECT 
    location, date, total_case, total_deaths, cast(total_deaths/total_case*100 as decimal(16,6)) as deathpercentage
FROM
    coviddeaths
    #WHERE location like '%states%'
ORDER BY 1, 2;



-- 	Shows what percentage of population got Covid

SELECT 
    location,
    date,
    population,
    total_case,
    CAST(total_case / population * 100 AS DECIMAL (16 , 6 )) AS percentagepopulationInfected
FROM
    coviddeaths
ORDER BY 1 , 2;


-- Looking at Countries with Highest Infection Rates Compared to its Population


WITH max_cases AS (
    SELECT 
        location, 
        population, 
        MAX(CAST(total_case AS UNSIGNED)) AS highestInfectedCount
    FROM coviddeaths
    GROUP BY location, population
),
detailed_data AS (
    SELECT 
        cd.location, 
        cd.population, 
        cd.date, 
        cd.total_case,
        CAST(cd.total_case AS UNSIGNED) AS total_case_int,
        CAST(cd.total_case/cd.population*100 AS DECIMAL(16,6)) AS percentagepopulationInfected,
        ROW_NUMBER() OVER (PARTITION BY cd.location ORDER BY CAST(cd.total_case AS UNSIGNED) DESC) AS row_num
    FROM coviddeaths cd
    JOIN max_cases mc ON cd.location = mc.location AND cd.total_case = mc.highestInfectedCount
)
SELECT 
    location, 
    population, 
    date, 
    total_case, 
    percentagepopulationInfected
FROM detailed_data
WHERE row_num = 1
#ORDER BY total_case_int DESC; 
ORDER BY percentagepopulationInfected DESC; 




/* HIGHEST INFECTED COUNT IN A DAY PER LOCATION */


WITH max_cases AS (
    SELECT 
        location, 
        population, 
        MAX(CAST(new_case AS UNSIGNED)) AS highestInfectedCount
    FROM coviddeaths
    GROUP BY location, population
),
detailed_data AS (
    SELECT 
        cd.location, 
        cd.population, 
        cd.date, 
        cd.new_case,
        CAST(cd.new_case AS UNSIGNED) AS new_case_int, -- Add this line
        CAST(cd.new_case/cd.population*100 AS DECIMAL(16,6)) AS percentagepopulationInfected,
        ROW_NUMBER() OVER (PARTITION BY cd.location ORDER BY CAST(cd.new_case AS UNSIGNED) DESC) AS row_num
    FROM coviddeaths cd
    JOIN max_cases mc ON cd.location = mc.location AND cd.new_case = mc.highestInfectedCount
)
SELECT 
    location, 
    population, 
    date, 
    new_case AS highestInfectedCount, 
    percentagepopulationInfected
FROM detailed_data
WHERE row_num = 1
ORDER BY new_case_int DESC; -- Modify this line



-- Showing Countries with Highest Death Count 

SELECT 
    location,
    population,
    MAX(CAST(total_deaths AS UNSIGNED)) AS total_death_Count,
    MAX(CAST(total_deaths / population * 100 AS DECIMAL (16 , 6 ))) AS deathpercentage
FROM
    coviddeaths
GROUP BY location , population
ORDER BY total_death_Count DESC;
/*
SELECT 
   location, population, MAX(cast(total_deaths as UNSIGNED)) AS total_death_Count, MAX(cast(total_deaths as UNSIGNED))/population*100 as deathpercentage
FROM
    coviddeaths
	#WHERE location like '%man%' AND
     #continent = 'Asia'
GROUP BY location, population
ORDER BY total_death_Count DESC;
*/




-- Getting all negative values and covert it to positive

SELECT new_case,location FROM coviddeaths 
WHERE new_case < 0;


UPDATE coviddeaths 
SET new_case = ABS(new_case)
WHERE new_case < 0 ;
 
 
SELECT new_deaths,location FROM coviddeaths 
WHERE new_deaths < 0;

UPDATE coviddeaths 
SET new_deaths = ABS(new_deaths)
WHERE new_deaths < 0 ;



-- GLOBAL NUMBERS
/* DEATH PERCENTAGE OF TOTAL CASE*/


SELECT 
    continent,
    location,
    SUM(CAST(new_case AS UNSIGNED)) AS totalcases,
    SUM(CAST(new_deaths AS UNSIGNED)) AS totaldeaths,
    SUM(CAST(new_deaths AS UNSIGNED)) / SUM(CAST(New_case AS UNSIGNED)) * 100 AS 'deathpercentage/totalcase'
FROM
    coviddeaths
GROUP BY continent , location
ORDER BY totalcases DESC;



--  Overall Daily Death percentage

SELECT 
    date,
    SUM(CAST(new_case AS UNSIGNED)) AS totalcases,
    SUM(CAST(new_deaths AS UNSIGNED)) AS totaldeaths,
    SUM(CAST(new_deaths AS UNSIGNED)) / SUM(CAST(New_case AS UNSIGNED)) * 100 AS deathpercentage
FROM
    coviddeaths
WHERE
    new_case != 0
GROUP BY date
ORDER BY 1;



-- Death percentage of the total cases as of '2021-04-30'
SELECT 
    SUM(population) AS overall_population,
    SUM(CAST(new_case AS UNSIGNED)) AS overall_cases,
    SUM(CAST(new_deaths AS UNSIGNED)) AS overall_deaths,
    SUM(CAST(new_deaths AS UNSIGNED)) / SUM(CAST(New_case AS UNSIGNED)) * 100 AS overall_deathpercentage
FROM
    coviddeaths;



-- it seems that WHO official record starts in '2020-01-22' globally
SELECT 
    MIN(date) AS date,
    location,
     new_case,
    total_case,
    total_deaths
FROM
    coviddeaths
WHERE total_case is not null
GROUP BY new_case ,total_case ,total_deaths , location
ORDER BY date
LIMIT 20;


-- Total Death Counts per Continent

SELECT 
    continent,
    SUM(CAST(new_deaths AS UNSIGNED)) AS total_death_counts
FROM
    coviddeaths
GROUP BY continent
ORDER BY total_death_counts DESC;

-- Total Death Counts per country
SELECT 
    location,
    SUM(CAST(new_deaths AS UNSIGNED)) total_death_counts
FROM
    coviddeaths
GROUP BY location;



-- Total Population vs Vaccination


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccount
-- , (rolling_vaccount/ population)*100 
from portfolio_project.coviddeaths dea
Join portfolio_project.covidvaccinations vac
On dea.location = vac.location
and dea.date = vac.date
ORDER BY 2,3;



 
-- Using Common Table Expression (CTE) to display population vs vaccinated daily 

WITH popVSvac 
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccount
-- , (rolling_vaccount/ population)*100 
from portfolio_project.coviddeaths dea
Join portfolio_project.covidvaccinations vac
On dea.location = vac.location
and dea.date = vac.date
-- ORDER BY 2,3
) 
SELECT *, (rolling_vaccount/population)*100 as '%PeopleVaccinated'
from popVSvac;


-- POPULATION VS TOTAL VACCINATED

WITH popVSvac 
AS
(SELECT dea.location,  dea.population,
sum(CAST(vac.new_vaccinations as UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location) as total_vac
-- , (rolling_vaccount/ population)*100 
from portfolio_project.coviddeaths dea
Join portfolio_project.covidvaccinations vac
On dea.location = vac.location
and dea.date = vac.date
-- ORDER BY 2,3
) 
SELECT location, population,max(total_vac) as vaccinated, (max(total_vac/population))*100 as percentage
from popVSvac 
GROUP BY location,population;




SELECT 
    location,
    SUM(CAST(new_vaccinations AS UNSIGNED)) AS total_vaccination
FROM
    covidvaccinations
GROUP BY location;
 
 
SELECT 
    location,
    SUM(CAST(new_vaccinations AS UNSIGNED)) AS total_vaccination
FROM
    covidvaccinations
WHERE
    new_vaccinations IS NOT NULL
        AND new_vaccinations != 0
GROUP BY location;


SELECT 
    continent,
    SUM(CAST(new_vaccinations AS UNSIGNED)) AS total_vaccination
FROM
    covidvaccinations
GROUP BY continent;



-- TEMP TABLE

DROP TABLE if EXISTS Percent_Population_vaccinatedated;
CREATE TABLE Percent_Population_Vaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
Date DATE,
Population VARCHAR(255),
New_vaccinations VARCHAR(255),
Rolling_vaccination_count VARCHAR(255)
);

INSERT INTO Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_vaccination_count
from portfolio_project.coviddeaths dea
Join portfolio_project.covidvaccinations vac
On dea.location = vac.location
and dea.date = vac.date;
-- ORDER BY 2,3

SELECT *, Rolling_vaccination_count/population *100 as '%ofPeopleVaccinated'
from Percent_Population_Vaccinated;


-- Creating VIEW for visualazition


CREATE VIEW Population_Vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_vaccination_count
from portfolio_project.coviddeaths dea
Join portfolio_project.covidvaccinations vac
On dea.location = vac.location
and dea.date = vac.date;
-- ORDER BY 2,3

SELECT * from population_vaccinated;

SELECT 
    location,
    population,
    MAX(rolling_vaccination_count) AS total_vaccinated
FROM
    population_vaccinated
GROUP BY location , population;





