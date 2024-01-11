SELECT *
From PortfolioProject..CovidDeaths
order by 3,4



--SELECT *
--From PortfolioProject..CovidVaccinations
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is NOT NULL
order by 1,2

-- Looking at Total cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is NOT NULL
order by 1,2

-- Looking at total cases vs populations

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is NOT NULL
order by 1,2

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is NOT NULL
Group BY location, population
order by PercentPopulationInfected desc

-- Showing counteries with highest death count per population

SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is NOT NULL
Group BY location
order by TotalDeathCount desc

--By continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is NULL
Group BY continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(New_deaths)/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is NOT NULL
GROUP BY date
order by 1,2

--Looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by 
dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
where dea.continent is not null
 AND dea.date = vac.date
order by 2,3

--Use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by 
dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
where dea.continent is not null
 AND dea.date = vac.date
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--  TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by 
dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 --where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Create veiw to store data for for later visulatizations 

Create View PercentPopulationVaaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by 
dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated