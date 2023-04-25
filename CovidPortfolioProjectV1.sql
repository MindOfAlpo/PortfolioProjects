
-- SELECT Data that we are going to be using
-- looking at total cases vs Total deaths 
-- This shows the liklihood of dying if you contract covid in your country during specific time period. 
	--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS percentage
	--FROM PortfolioProject1..CovidDeaths
	--WHERE location = 'United States'
	--ORDER BY 1, 2

--Altering a data type of specific column
ALTER TABLE PortfolioProject1..CovidVaccinations
ALTER COLUMN new_vaccinations float

----------------------------------------------

--Looking at the total Cases vs Population 
--What percentage of populations gov Covid
	--SELECT location, date, Population, total_cases, (total_cases/population)* 100 AS DeathPercentage
	--FROM PortfolioProject1..CovidDeaths
	--WHERE location = 'United States'
	--ORDER BY 1, 2
-------------------------------------------

--Looking at the highest death/case ratio recorded for each location. 
	--SELECT location, MAX(total_deaths/total_cases)*100 AS Maximum
	--FROM PortfolioProject1..CovidDeaths
	--GROUP BY location 
	--ORDER BY Maximum Desc

-----------------------------------------

--Looking at countries with highest infection rate compared to population
	--SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
	--FROM PortfolioProject1..CovidDeaths
	--GROUP BY location, population 
	--ORDER BY PercentPopulationInfected Desc;

----------------------------------------
--Showing Countries with the highest death count per population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL -- Will allow us to choose values were only real countries are in. (we can add this to others)
GROUP BY location
ORDER BY TotalDeathCount Desc


-- Showing continent with the highest death count per population
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL -- 
GROUP BY continent
ORDER BY TotalDeathCount Desc --Highlight first to run specific query. 

-- GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0) *
100 AS death_percentage-- MAX(total_cases/population)* 100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
--WHERE location = 'United States' 
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY 1, 2

-- Looking at Total Population Vs Vaccination Rolling count of vaccinated people (Aarons Way)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER(ORDER BY dea.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.date = vac.date 
WHERE dea.continent is not null
AND vac.new_vaccinations IS NOT NULL
ORDER BY 2,3

--Looking at Total Population Vs Vaccination Rolling count of vaccinated people (Alex The Analysts Way)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) -- partition allows it split the sum 
--at every 
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location 
	AND dea.date = vac.date 
WHERE dea.continent is not null 
ORDER BY 2,3 

-- Creating CTE
WITH PopVsVAC (continenet, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) -- partition allows it split the sum 
--at every 
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location 
	AND dea.date = vac.date 
WHERE dea.continent is not null 
--ORDER BY 2,3 
)


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVAC

-- Creating Temp Table ------------------------------------------------------------------

DROP TABLE IF exists #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) -- partition allows it split the sum 
--at every 
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location 
	AND dea.date = vac.date 
WHERE dea.continent is not null 
--ORDER BY 2,3 

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated 

---------------------------------------

-- Creating View to Store data for later vizualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) -- partition allows it split the sum 
--at every 
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location 
	AND dea.date = vac.date 
WHERE dea.continent is not null 
--ORDER BY 2,3 

SELECT * 
FROM PercentPopulationVaccinated