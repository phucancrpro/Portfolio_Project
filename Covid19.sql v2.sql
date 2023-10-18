select*
from CovidDeaths$

-- select data gonna using

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1,2

--Looking at total cases vs total deaths
--Show what percentage of population got covid

select location, date,population, total_cases, (total_cases/population)*100 as case_rate
from CovidDeaths$
where location like '%State%'
order by 1,2

--Looking at Countries with highest infestion rate compared to population

select location, population, max(total_cases), max(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths$
group by location, population
order by PercentPopulationInfected desc

--showing countries with highest death rate

select location, population, max(total_cases) as total_cases, max(total_deaths) as total_deaths, max(total_deaths/total_cases)*100 as PercentPopulationDead
from CovidDeaths$
group by location, population
order by PercentPopulationDead desc

--showing countries with highest death count per population

select location, population, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
group by location, population
order by TotalDeathCount desc

--Showing continents with highest death count per population

select continent, sum(population) as Population, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers

select date, sum(new_cases) as Newcases_total, sum(cast(new_deaths as int)) as Newdeaths_total,
sum(cast(new_deaths as int))/sum(new_cases) as Death_percentage
from CovidDeaths$
where continent is not null
group by date
 order by 1

 select sum(new_cases) as Newcases_total, sum(cast(new_deaths as int)) as Newdeaths_total,
sum(cast(new_deaths as int))/sum(new_cases) as Death_percentage
from CovidDeaths$
where continent is not null
--group by date
 order by 1

 --Vaccin

select * from CovidVaccinations$
 
 select* from Portfolio_Project..CovidDeaths$ d
 JOIN Portfolio_Project..CovidVaccinations$ v
 ON d.location = v.location
 and d.date = v.date
 order by 1,2,3

--looking at total population vs vaccinations

 select d.continent, d.location, d.date, d.population, v.new_vaccinations
 from Portfolio_Project..CovidDeaths$ d
   JOIN Portfolio_Project..CovidVaccinations$ v
   ON d.location = v.location
   and d.date = v.date
where d.continent is not null
 order by 1,2,3

  --group by sum

 select d.location, sum(cast(v.new_vaccinations as int)) as LocationVaccinated
 from Portfolio_Project..CovidDeaths$ d
   JOIN Portfolio_Project..CovidVaccinations$ v
   ON d.location = v.location
   and d.date = v.date
where d.continent is not null
group by d.location
 order by 1,2
 
 --Without CTE
 select d.continent, d.location, d.date, d.population, 
  sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as rollingPeopleVaccinated,
 (sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date)/population)*100
 from Portfolio_Project..CovidDeaths$ d
   JOIN Portfolio_Project..CovidVaccinations$ v
   ON d.location = v.location
   and d.date = v.date
where d.continent is not null
 order by 2,3

 --WIth CTE

 With PopVsVac (Continent, Location, Date, Population, rollingPeopleVaccinated) as
 (
 select d.continent, d.location, d.date, d.population, 
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as rollingPeopleVaccinated
 from Portfolio_Project..CovidDeaths$ d
   JOIN Portfolio_Project..CovidVaccinations$ v
   ON d.location = v.location
   and d.date = v.date
where d.continent is not null
)
Select *, (rollingPeopleVaccinated/Population)*100 as Vaccination_Rate from PopVsVac




--temp table
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as rollingPeopleVaccinated
 from Portfolio_Project..CovidDeaths$ d
   JOIN Portfolio_Project..CovidVaccinations$ v
   ON d.location = v.location
   and d.date = v.date
where d.continent is not null
Select *, (rollingPeopleVaccinated/Population)*100 as Vaccination_Rate from #PercentPopulationVaccinated

--Create view for visualizations
drop view if exists PercentPopulationVaccinated
create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
 from Portfolio_Project..CovidDeaths$ d
   JOIN Portfolio_Project..CovidVaccinations$ v
   ON d.location = v.location
   and d.date = v.date
where d.continent is not null

Select * from PercentPopulationVaccinated