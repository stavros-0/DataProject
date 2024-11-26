-- SELECT *
-- FROM DataProject.dbo.CovidDeaths
-- order by 3,4;


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM DataProject.dbo.CovidDeaths
order by 1,2;


-- Total Cases vs. Total Deaths
-- likelihood of contracting Covid
SELECT 
    location, 
    date, 
    total_cases,
    CAST((CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100) AS DeathPercentage
FROM DataProject.dbo.CovidDeaths
WHERE location like '%Poland%'
order by 1,2;

-- Total cases vs Population
-- percentage of population that has contracted covid
SELECT 
    location, 
    date, 
    total_cases, 
    population,
    CAST((CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 AS FLOAT) AS PercentageContracted
FROM DataProject.dbo.CovidDeaths
WHERE location like '%states%'
order by 1,2; 

SELECT 
    location, 
    date, 
    MAX(total_cases) AS MaxTotalCases, 
    population,
    CAST((CAST(MAX(total_cases) AS FLOAT) / CAST(population AS FLOAT)) * 100 AS FLOAT) AS PercentageContracted
FROM 
    DataProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentageContracted DESC;

SELECT location, MAX(cast(total_deaths as INT)) as totaldeathcount
from DataProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY totaldeathcount DESC

SELECT *
FROM DataProject.dbo.CovidDeaths
WHERE continent IS NOT NULL



SELECT continent, MAX(cast(total_deaths as INT)) as totaldeathcount
FROM DataProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY totaldeathcount DESC

SELECT date, SUM(new_cases) AS TOTAL_CASES, sum(new_deaths) AS TOTAL_DEATHS, CAST(CAST(sum(new_deaths) AS FLOAT)/ CAST(sum(new_cases)AS FLOAT)*100 AS FLOAT) as DeathPercentage
FROM DataProject.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM DataProject.dbo.CovidDeaths dea 
JOIN DataProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM DataProject.dbo.CovidDeaths dea 
JOIN DataProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac
ORDER BY 2,3


CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
Date DATETIME,
population NUMERIC,
new_vaccination NUMERIC,
RollingPeopleVaccinated NUMERIC
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM DataProject.dbo.CovidDeaths dea 
JOIN DataProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- create view to store data for visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM DataProject.dbo.CovidDeaths dea 
JOIN DataProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

 -- Queries for tableau
 SELECT SUM(new_cases) AS TOTAL_CASES, sum(new_deaths) AS TOTAL_DEATHS, 
    CAST(CAST(sum(new_deaths) AS FLOAT)/ CAST(sum(new_cases)AS FLOAT)*100 AS FLOAT) as DeathPercentage
FROM DataProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT location, sum(new_deaths) AS TOTAL_DEATHS
FROM DataProject.dbo.CovidDeaths
WHERE continent IS NULL
    AND location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TOTAL_DEATHS DESC

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
    MAX(CAST(total_cases AS FLOAT) / population) * 100 AS PercentPopulationInfected
FROM DataProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

SELECT location, population, date, max(total_cases) as HighestInfectionCount, 
    MAX(CAST(total_cases AS FLOAT) / population) * 100 as PercentPopulationInfected
FROM DataProject.dbo.CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC