select * 
from portfolioproject..CovidDeaths
order by 3,4

--select *
--from portfolioproject..CovidVaccinations
--order by 3,4

--select data taht we are going to be using

select Location,date, total_cases, new_cases, total_deaths, population
from portfolioproject..CovidDeaths
order by 1,2

--Looking  at total cases vs total deaths

select Location,date, total_cases,  total_deaths, (total_cases/total_deaths)*100 as Deathpercenatge
from portfolioproject..CovidDeaths
where location like '%states%'
order by 1,2


--Looking at total cases vs popualtion
select Location,date, total_cases,population, (total_cases/population)*100 as Deathpercenatge
from portfolioproject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at contries with highest infection rate compare to population

select Location, population,max(total_cases) as highestinfectioncount, max(total_cases/population)*100 as percentpopulationinfected
from portfolioproject..CovidDeaths
group by Location,population
order by percentpopulationinfected desc

--showing countries with highest deaths count per population

select Location,max(cast(total_deaths as int)) as totaldeaths
from portfolioproject..CovidDeaths
where continent is not null
group by Location
order by totaldeaths desc
 
-- LET'S BREAK THINGS DOWN BY CONTINENT

select continent,max(cast(total_deaths as int)) as totaldeaths
from portfolioproject..CovidDeaths
where continent is not   null
group by continent
order by totaldeaths desc

--showing contients with the highest deaths count population

select continent,max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..CovidDeaths
where continent is not   null
group by continent
order by totaldeathcount desc


--GLOBAL NUMBERS

select  sum(new_cases) as totalcases, sum(cast(new_deaths as int )) as totaldeaths, 
sum(cast(new_deaths as int))/ sum(new_cases)*100 as deathpercentage
from portfolioproject..CovidDeaths
--where location like '%states%'
where  continent  is not null
--group by date
order by 1,2



-- Looking at total population vs vaccination
select  dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.Location,dea.date) as RollingpeopleVaccinated
from portfolioproject..covidDeaths dea
join  portfolioproject..CovidVaccinations vac
     on dea.location=vac.location
     and dea.date = vac.date
     where dea.continent is not null
     order by 2,3

-- use CTE 

with PopvsVac (Continent, Location,Date,Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
select  dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.Location,dea.Date) as RollingPeopleVaccinated
from portfolioproject..covidDeaths dea
join  portfolioproject..CovidVaccinations vac
     on dea.location=vac.location
     and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as tatolPercent
from PopvsVac




--TEMP TABLES
drop table if exists  #percentpopualtionvaccinated

create table #percentpopualtionvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentpopualtionvaccinated
select  dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.Location,dea.Date) as RollingPeopleVaccinated
from portfolioproject..covidDeaths dea
join  portfolioproject..CovidVaccinations vac
     on dea.location=vac.location
     and dea.date = vac.date
where dea.continent is not null
select *, (RollingPeopleVaccinated/population)*100 as tatolPercent
from #percentpopualtionvaccinated


-- creating view to store data for later visualizations

create view percentpopualtionvaccinated as
select  dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.Location,dea.Date) as RollingPeopleVaccinated
from portfolioproject..covidDeaths dea
join  portfolioproject..CovidVaccinations vac
     on dea.location=vac.location
     and dea.date = vac.date
where dea.continent is not null 

select *
from percentpopualtionvaccinated
