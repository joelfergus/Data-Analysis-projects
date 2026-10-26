select *
from PortfolioProject..CovidDeaths

order by 1,2;


--total cases vs total deaths
-- chances of dying from covid in the nigeria
create view CasesvsCasualties 
as
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where continent is not null
and continent is not null
--order by 1,2

--total cases vs population
--population that got covid
Create view CasesvsPopulation as
select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where continent is not null
--order by DeathPercentage desc


--country with the highest infection rate compared to the population
create view InfectedPercentagePerCountry as
select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectedPercentage 
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
--order by InfectedPercentage desc


--countries with the highest death count per population
create view DeathPercentage as
select location, max(total_deaths) as TotalDeathCount, max((total_deaths/population))*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where continent is not null
group by location
--order by TotalDeathCount desc



--breaking down by continent
 

--showing the continent with the highest death count
create view ContinentalDeathCount as
select continent, max(total_deaths) as TotalDeathCount 
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers
select sum(new_cases) as totalCases, sum(new_deaths) as totalDeaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
--group by date
order by 1,2



--total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_Vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--using cte
with PopvsVac(continent, location, date, population,New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_Vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)* 100
from PopvsVac




--temp table
drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
continent  nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_Vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)* 100
from #PercentagePopulationVaccinated


--creating view to store data for visualizations
create view PercentPopulatedVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_Vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

select * from PercentPopulatedVaccinated