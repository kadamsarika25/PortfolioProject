select*
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--select*
--from PortfolioProject..CovidVaccination
--order by 3,4



--looking at total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

---looking at total cases vs population
---shows what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as Covidpercentage
from PortfolioProject..CovidDeaths
--where location like '%india%'
order by 1,2

--looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%india%'
group by location, population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population
select location, MAX(Total_deaths) as HighestDeathCount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by location
order by HighestDeathCount desc

--Showing countries with highest death count per population
select location, MAX(cast (Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by location
order by TotalDeathCount desc


BREAK THINGS BY CONTINENT

--Showing continents with highest death count per population

select continent, MAX(cast (Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc

select location, MAX(cast (Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is null
group by location
order by TotalDeathCount desc

--Global numbers
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

select date, SUM(new_cases)--, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

select*
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
  on dea.location = vac.location
  and dea.date = vac.date

-- Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- total population vs vaccinations with sum of new vaccinations 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac 
     On dea.location = vac.location
     and dea.date = vac.date
	 where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table  #PercentPopulationVaccinated
(
Continent nvarchar(256),
Location nvarchar(256),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac 
     On dea.location = vac.location
     and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data later for Visualisation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac 
     On dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
