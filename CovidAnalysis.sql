SELECT *
FROM CovidDeathsPortfolioProj..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM CovidDeathsPortfolioProj..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases,total_deaths, population
FROM CovidDeathsPortfolioProj..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

--Total cases vs deaths 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeathsPortfolioProj..CovidDeaths
WHERE location='Pakistan' AND continent is not NULL
ORDER BY 1,2

--Total cases vs Population 
SELECT location, date, population, total_cases,  (total_cases/population)*100 AS CovidPercentage
FROM CovidDeathsPortfolioProj..CovidDeaths
WHERE location='Pakistan' AND continent is not NULL
ORDER BY 1,2

--Country with highest infection rate
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS CovidPercentage
FROM CovidDeathsPortfolioProj..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY CovidPercentage DESC

--country  with highest death count
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount  
FROM CovidDeathsPortfolioProj..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--continent  with highest death count
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount  
FROM CovidDeathsPortfolioProj..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS 
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeathsPortfolioProj..CovidDeaths
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2

--Total Population vs Vaccinations
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM CovidDeathsPortfolioProj..CovidDeaths dea
JOIN CovidDeathsPortfolioProj..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac
ORDER BY 2,3

--TEMP TABLE 
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM CovidDeathsPortfolioProj..CovidDeaths dea
JOIN CovidDeathsPortfolioProj..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM CovidDeathsPortfolioProj..CovidDeaths dea
JOIN CovidDeathsPortfolioProj..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT * 
FROM PercentPopulationVaccinated