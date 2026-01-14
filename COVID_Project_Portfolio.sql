SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- SELECT data that we are going to use 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases and Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'India' and continent IS NOT NULL
ORDER BY 1,2

-- Looking Total Cases vs Population
-- Shows %of population with Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS Affected_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'India' and continent IS NOT NULL
ORDER BY 1,2


-- Looking at countries with highest infection rate 

SELECT location, population, MAX(total_cases) AS HighestInfectionCountry , MAX(total_cases/population)*100 AS Cases_Percentage
FROM PortfolioProject..CovidDeaths
--WHERE location like 'India' and continent IS NOT NULL
GROUP BY location, population
ORDER BY Cases_Percentage DESC;


-- Showing countries witht the highest death count per population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like 'India' and continent IS NOT NULL
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- LETS BREAK THINGS DOWN BY CONTINENT, here we took nulls because in previous queris we considered the not null values 
-- because the didnt include the values where the continents values was null which we can use here instead

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like 'India' and continent IS NOT NULL
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--SHOWING CONTINENTS WITH HIGHEST DEATH COUNTS
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like 'India' and continent IS NOT NULL
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--NOW LET'S SEE HOW TO VISUALIZE IT AT THE BACK OF THE HEAD AS WELL USING DRILL DOWN IN TABLEAU/POWER BI

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/ SUM(new_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--OVERALL DEATHS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/ SUM(new_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

--Looking At Total Population Vs Vaccination

SELECT *
FROM PortfolioProject..CovidDeaths AS dea
JOIN  PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
    AND dea.date = vac.date;

--We use Partition to have the sum only by countries and seperate as new country name comes up

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM PortfolioProject..CovidDeaths AS dea
JOIN  PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


--CTE(Number of columns in cte should be same)

WITH PopVsVac (continent, location, date, population,New_vaccinations, RollingPeopleVaccinated) 
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM PortfolioProject..CovidDeaths AS dea
JOIN  PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Locatiion nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM PortfolioProject..CovidDeaths AS dea
JOIN  PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
    AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualiztion

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM PortfolioProject..CovidDeaths AS dea
JOIN  PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated