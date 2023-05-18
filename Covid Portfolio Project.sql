SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING

SELECT location, date, total_cases,new_cases,total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2


-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACTED COVID IN YOUR COUNTRY FOR PERIOD ANALYSED

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE LOCATION LIKE '%SOUTH AFRICA%'
ORDER BY 1,2


-- LOOKING AT THE TOTAL CASES VS POPULATION
-- SHOWS WHAT PERCENTAGE OF THE POPULATION WAS INFECTED WITH COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths$
WHERE LOCATION LIKE '%SOUTH AFRICA%'
ORDER BY 1,2


-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE CONPARED TO POPULATION

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc


-- SHOWING COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc


-- SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as Total_cases, SUM(CAST(new_deaths AS int)) as Total_deaths, SUM(CAST(new_deaths AS int))/
SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as Total_cases, SUM(CAST(new_deaths AS int)) as Total_deaths, SUM(CAST(new_deaths AS int))/
SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
FROM PortfolioProject..CovidDeaths$ DEA
JOIN PortfolioProject..CovidVaccinations$ VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date


-- USE CTE

WITH PopvsVac (Continent,Location, Date, Population, New_Vacccinations,RollingPeopleVaccinated)
as
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as int)) OVER (PARTITION BY DEA.location,
DEA.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ DEA
JOIN PortfolioProject..CovidVaccinations$ VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/Population)
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentagePopulation
CREATE TABLE  #PercentagePopulation
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations int,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentagePopulation
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as int)) OVER (PARTITION BY DEA.location ORDER BY DEA.location,
DEA.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ DEA
JOIN PortfolioProject..CovidVaccinations$ VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentagePopulation


-- CREATING VIEW TO  STORE DATE FOR LATE VISUALISATION
DROP VIEW IF EXISTS PercentPopulationVaccinated
CREATE VIEW [PercentPopulationVaccinated] AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as int)) OVER (PARTITION BY DEA.location,
DEA.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ DEA
JOIN PortfolioProject..CovidVaccinations$ VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated

DROP VIEW IF EXISTS GlobalDailyNumbers
CREATE VIEW GlobalDailyNumbers As
SELECT date, SUM(new_cases) as Total_cases, SUM(CAST(new_deaths AS int)) as Total_deaths, SUM(CAST(new_deaths AS int))/
SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date

SELECT *
FROM GlobalDailyNumbers
ORDER BY 1,2,3