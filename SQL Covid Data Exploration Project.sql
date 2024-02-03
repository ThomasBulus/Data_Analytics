use PortfolioProjects;
select *
From PortfolioProjects..CovidDeaths
where continent is not null
order by 3,4

--select *
--From PortfolioProjects..CovidVaccinations
--Order by 3,4


-- selecting the data to be used

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..CovidDeaths
where continent is not null
order by 1,2

-- looking at total cases vs total deaths
-- the likelihood of dying if you contracted covid in your country



-- looking at total cases vs total population
-- shows what percentage of population got covid

select Location, date, population, total_cases, (total_cases)/(population)*100 as PercentPopulationInfect
from PortfolioProjects..CovidDeaths
--where location like '%Africa%'
where continent is not null
order by 1,2

-- looking at country with highest infection rate per population

select Location, population, MAX(total_cases) as HighestInfectCount, MAX((total_cases)/(population))*100 as PercentPopulationInfect
from PortfolioProjects..CovidDeaths
--where location like '%Africa%'
where continent is not null
GROUP BY Location, population
order by PercentPopulationInfect DESC

-- showing countries with highest death count per population


select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProjects..CovidDeaths
-- where location like '%states%'
where continent is null
GROUP BY Location
order by TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continent with highest death count

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProjects..CovidDeaths
-- where location like '%states%'
where continent is not null
GROUP BY continent
order by TotalDeathCount DESC



-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where continent is not null
-- where location like '%Africa%'
--GROUP BY date
order by 1,2


-- looking at total population vs total vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(INT, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,
 dea.Date) as RollingPeopleVaccinated
 , (RollingPeopleVaccinated/Population)*100
from PortfolioProjects..CovidVaccinations vac
Join PortfolioProjects..CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null
order by 2, 3



-- Use CTE

with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,
 dea.Date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/Population)*100
from PortfolioProjects..CovidVaccinations vac
Join PortfolioProjects..CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null
--order by 2, 3
)

select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE

Drop Table if exists #PercentPeopleVaccinated
CREATE Table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,
 dea.Date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/Population)*100
from PortfolioProjects..CovidVaccinations vac
Join PortfolioProjects..CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
--where dea.continent is not null
--order by 2, 3		

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPeopleVaccinated


-- CREATING VIEWS FOR LATER VISUALIZATION

Create View PercentPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,
 dea.Date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/Population)*100
from PortfolioProjects..CovidVaccinations vac
Join PortfolioProjects..CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null
--order by 2, 3	

select * 
from PercentPeopleVaccinated