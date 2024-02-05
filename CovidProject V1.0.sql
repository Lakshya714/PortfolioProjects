select *
from SQLCovProject..CovidDeaths
order by 3, 4

select *
from SQLCovProject..CovidVaccinations
order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from SQLCovProject..CovidDeaths
order by 1,2

--looking at the total caes vs total deaths
--shows likelihood of death by covid

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpcent
from SQLCovProject..CovidDeaths
where location = 'India'
order by 1,2

--loking at total cases vs population
--shows what pcent of poopulation got covid

select location, date, total_cases, population, (total_cases/population)*100 as Covpcent
from SQLCovProject..CovidDeaths
where location = 'India'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as Covpcent
from SQLCovProject..CovidDeaths
group by location, population
order by Covpcent

--showing countries with highest deathcount per population

select location, max(cast(total_deaths as int )) as totalDeathCount
from SQLCovProject..CovidDeaths
where continent is not null
group by location
order by totalDeathCount desc

--LET'S COMPARE THE CONTINENTS

select location, max(cast(total_deaths as int )) as totalDeathCount
from SQLCovProject..CovidDeaths
where continent is null
group by location
order by totalDeathCount desc


-- GLOBAL NUMBERS 
select sum(new_cases) as totalcases, sum(cast (new_deaths as int )) as totaldeaths, sum(cast (new_deaths as int ))/sum(new_cases)*100 as DeathPerCent
from SQLCovProject..CovidDeaths
where continent is not null
order by 1,2


--Inter Table Relation

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVacPeople
from SQLCovProject..CovidDeaths dea
join SQLCovProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3 



--Using CTE

With PopvsVac(continent, location, Date, Population,new_vaccinations , RollingVacPeople)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVacPeople
from SQLCovProject..CovidDeaths dea
join SQLCovProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3 
	)
select*, (RollingVacPeople/Population)*100
from PopvsVac


--Using TempTable

DROP TABLE IF EXISTS #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime,
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from SQLCovProject..CovidDeaths dea
join SQLCovProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

	select*, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from SQLCovProject..CovidDeaths dea
join SQLCovProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated