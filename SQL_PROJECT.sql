--SELECT*
--FROM portfolio_sql..Covid_death$

--SELECT*
--FROM portfolio_sql..Covid_vaccination$
--ORDER BY 1,2
--SELECT THE DATA THAT WE ARE GOING TO USE
SELECT location, date, new_cases, total_cases ,
total_deaths,total_tests
FROM portfolio_sql.. Covid_death
ORDER BY 1,2

--LOOKING FOR TOTAL CASES VS TOTAL DEATH AND ITS PERCENTAGE

SELECT location, date,  total_cases ,total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM portfolio_sql.. Covid_death
where location=  'United states'
ORDER BY 1,2

--LOOKING FOR THE TOTAL CASES VS POPULATION AND ITS PERCENTAGES
SELECT location, date,population,  total_cases ,total_deaths, (total_cases/population)*100 as infected_peoplePercentage
FROM portfolio_sql.. Covid_death
ORDER BY 1,2

--LOOKING FOR THE COUNTRIES WITH HIGHEST INFECTION RATE

SELECT location,  population , MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 as
infected_peoplePercentage
FROM portfolio_sql.. Covid_death
Group By location, population
order by infected_peoplePercentage desc

--LOOKING FOR THE HIGHEST DEATH COUNT AS PER POPULATION 

SELECT location,  population , MAX(cast(total_deaths as int)) as highestdeathcount, MAX((total_deaths/population))*100 as
death_Percentage
FROM portfolio_sql.. Covid_death
Where continent is not null
Group By location, population
order by highestdeathcount desc

--NOW LET'S LOOK ON THE BASIS OF CONTINENTS

SELECT continent, MAX(cast(total_deaths as int)) as highestdeathcount

FROM portfolio_sql.. Covid_death
Where continent is not null
Group By continent

--HOW MANY NEW CASES AND DEATH COME DAILY GLOBALLY


SELECT  date, sum(new_cases) as totalcases, sum(cast(total_deaths as int)) as totaldeath
FROM portfolio_sql.. Covid_death
where continent is not null
GROUP BY date
ORDER BY 1,2

--join both tables on location and date

SELECT*
FROM portfolio_sql..covid_death death
 JOIN portfolio_sql..Covid_vaccination vac
 ON death.location = vac.location
  and death.date = vac.date

  --looking for total population vs total vaccination

SELECT death.continent, death.location,death.date,death.population , vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by death.location  ORDER BY death.location, death.date)
as peoplevaccinated
FROM portfolio_sql..covid_death death
JOIN portfolio_sql..Covid_vaccination vac
     ON death.location = vac.location
      and death.date = vac.date
WHERE death.continent is not null
ORDER BY 2,3
 
 --WITH CTE

WITH deathvsvac (continent, location,date,population, newvaccination, peoplevaccinated)
as 
(
SELECT death.continent, death.location,death.date,death.population , vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by death.location  ORDER BY death.location, death.date)
as peoplevaccinated
FROM portfolio_sql..covid_death death
JOIN portfolio_sql..Covid_vaccination vac
     ON death.location = vac.location
      and death.date = vac.date
WHERE death.continent is not null 
)
SELECT*, (peoplevaccinated/population)*100
from deathvsvac


--TEMP TABLE

CREATE TABLE #percentagepopulationvacinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccination numeric,
peoplevaccinated numeric
)
INSERT INTO #percentagepopulationvacinated

SELECT death.continent, death.location,death.date,death.population , vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by death.location  ORDER BY death.location, death.date)
as peoplevaccinated
FROM portfolio_sql..covid_death death
JOIN portfolio_sql..Covid_vaccination vac
     ON death.location = vac.location
      and death.date = vac.date
WHERE death.continent is not null 

SELECT*, (peoplevaccinated/population)*100
from #percentagepopulationvacinated

--VIEW

CREATE VIEW vwglobalnumbers
AS
SELECT death.continent, death.location,death.date,death.population , vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by death.location  ORDER BY death.location, death.date)
as peoplevaccinated
FROM portfolio_sql..covid_death death
JOIN portfolio_sql..Covid_vaccination vac
     ON death.location = vac.location
      and death.date = vac.date
WHERE death.continent is not null

select* 
FROM vwglobalnumbers