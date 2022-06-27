SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
--AND Location like '%state%'
ORDER BY 3, 4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3, 4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

--Looking at Total Cases vs. Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
ORDER BY 1, 2

--Looking at Total Cases vs Population

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS percentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
ORDER BY 1, 2


--Look at  countries with highest infection rate compared to population
SELECT Location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 AS percentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
Group By Location, population
ORDER BY percentPopulationInfected desc


--Broken down by Continenet
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent  is not null
Group By continent
ORDER BY TotalDeathCount desc

--SELECT continent, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 AS percentPopulationInfected
--FROM PortfolioProject..CovidDeaths
----WHERE Location like '%states%'
--WHERE continent is not null
--Group By continent, population
--ORDER BY percentPopulationInfected desc



--countries  with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent  is not null
Group By Location
ORDER BY TotalDeathCount desc

--Global Numbers
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent  is not null
GROUP BY date
ORDER BY 1, 2

SELECT  SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent  is not null
ORDER BY 1, 2


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

--Looking at Total Population vs Deaths (as a percentage of the total population)

SELECT continent, location, max(CAST(total_deaths as int)) as TotalDeathCount, population, max((total_deaths/population))*100 AS percentPopulationDead
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not null
Group By continent, location, population
ORDER BY percentPopulationDead desc


--use CTE (Revisit with Temp table)

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationCount)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingVaccinationCount/Population) * 100
FROM PopvsVac


--TEMP TABLE Version
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationCount numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3


SELECT *, (RollingVaccinationCount/Population) * 100
FROM #PercentPopulationVaccinated

--Creating Views to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

Create View DeathPercentage as
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
--ORDER BY 1, 2

Create View PercentPopulationDead as
SELECT continent, location, max(CAST(total_deaths as int)) as TotalDeathCount, population, max((total_deaths/population))*100 AS percentPopulationDead
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not null
Group By continent, location, population
--ORDER BY percentPopulationDead desc

