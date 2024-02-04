SELECT *
FROM PortofolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3, 4

--SELECT *
--FROM PortofolioProject..CovidVaccinations
--ORDER BY 3, 4

-- Select the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at total cases vs total death
-- Show likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at total cases vs population
-- Showa what percentage of population got covid

SELECT location, date, population, total_cases,  (total_cases / population)*100 as PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases / population))*100 as 
PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing the countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortofolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortofolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortofolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortofolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers

SELECT  SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 
as DeathPercentage
FROM PortofolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2




-- Looking at toal population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3



-- Use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP Table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating a view to store data for alter visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated