
select * from [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4

--select * from [Portfolio Project]..CovidVaccinations order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths order by 1,2

--looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your contry
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths 
where location like '%state%'
and continent is not null
order by 1,2


--looking at Total Cases vs Population
--shows what percentage of population got Covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths 
--where location like '%state%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths 
--where location like '%state%'
group by location, population
order by PercentPopulationInfected desc


--showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths 
--where location like '%state%'
where continent is not null
group by location
order by TotalDeathCount desc



--showing continents with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths 
--where location like '%state%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths 
--where location like '%state%'
where continent is not null
--group by date
order by 1,2

--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVacciated/population)*100
from [Portfolio Project]..CovidVaccinations vac
join [Portfolio Project]..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVacciated/population)*100
from [Portfolio Project]..CovidVaccinations vac
join [Portfolio Project]..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- Temp Table

drop table if exists #PercentPopulationVaccincated
create table #PercentPopulationVaccincated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccincated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVacciated/population)*100
from [Portfolio Project]..CovidVaccinations vac
join [Portfolio Project]..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccincated



--creating view to store data for later visualizations

create view PercentPopulationVaccincated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVacciated/population)*100
from [Portfolio Project]..CovidVaccinations vac
join [Portfolio Project]..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccincated
