SELECT *
FROM CovidDeaths$
WHERE continent is NOT NULL
Order BY 3,4

--SELECT *
--FROM CovidVaccinations$
--Order BY 3,4

-- Selecting Data
SELECT location, date, Total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
Order BY 1,2

-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if contracted in the US

SELECT location, date, Total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths$
WHERE location like '%states%'
Order BY 1,2

-- Looking at total Cases Vs Population 
-- Shows percentage of population infected with Covid in the US

SELECT location, date, Total_cases, population, (total_cases/population)*100 AS InfectionPercent
FROM CovidDeaths$
WHERE location like '%states%'
Order BY 1,2

-- Looking at Countries with highest infection rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopInfected
FROM CovidDeaths$
GROUP BY location, population
ORDER BY PercentPopInfected DESC

-- Looking at countries with the Highest Death Count

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent is NOT NULL
Group BY location
ORDER BY TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT


-- Showing continents with highest death count

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

-- Global Daily cases, deaths, and death percentage

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as DeathPercent
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

-- Global totals

SELECT  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as DeathPercent
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Total Population Vs Vaccinations
-- Creating a rolling tally of vaccinations by country

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(dea.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ AS dea
JOIN CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE to perform calculations on the previous Partion By query

WITH PopvsVac (Continent, Location, Date, Population, New_Vccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(dea.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ AS dea
JOIN CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)
SELECT * , (RollingPeopleVaccinated/Population)*100 AS PercentVac
FROM PopvsVac


-- Using Temp Table to perform calculations on the previous Partion BY query

DROP TABLE IF EXISTS #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(dea.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ AS dea
JOIN CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentVac
FROM #PercentPopVaccinated


-- Crating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(dea.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ AS dea
JOIN CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL


