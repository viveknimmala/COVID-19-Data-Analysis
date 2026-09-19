-- Selecting Data from Covid Deaths

Select Location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..CovidDeaths
Order by 1,2


-- Total Deaths vs Total Cases

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deaths_per_cases_reported
from Portfolio_Project..CovidDeaths
order by 1,2


-- Total Cases vs Population

Select Location, date, total_cases, population, (total_cases/population)*100 as Percentage_of_cases_reported
from Portfolio_Project..CovidDeaths
order by 1,2


-- Countries with Highest Infection Rate -

Select Location, population, MAX(total_cases) as Highest_Infections, Round(MAX(total_cases/population)*100, 2) as Percentage_Population_Infected
from Portfolio_Project..CovidDeaths
where continent is not null
Group by location, population
order by 4 desc


-- Countries with highest Deaths

Select Location, MAX(Cast(total_deaths as int)) as Total_Death_Count
from Portfolio_Project..CovidDeaths
where continent is not null
Group by location
order by 2 desc


-- Continents with Highest Deaths per Population -

Select location, SUM(cast(new_deaths as int)) as Total_Death_Count
From Portfolio_Project..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by Total_Death_Count desc


-- Global Numbers day-wise breakdown 

Select date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from Portfolio_Project..CovidDeaths
where continent is not null
group by date
order by 1,2


-- Global Total -

Select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2


-- Total Vaccinations

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
from Portfolio_Project..CovidDeaths cd
join Portfolio_Project..CovidVaccinations cv
     on cd.location = cv.location
	 and cd.date = cv.date
where cd.continent is not null
order by 2,3


-- Running Total for Total vaccinations

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as Running_Total_Vaccinations
from Portfolio_Project..CovidDeaths cd
join Portfolio_Project..CovidVaccinations cv
     on cd.location = cv.location
	 and cd.date = cv.date
where cd.continent is not null
order by 2,3


-- Using temporary table for calculating Running Total vs Population

Drop table if exists #PercentVaccinated

Create table #PercentVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations nvarchar(255),
Running_Total_Vaccinations numeric
)

Insert into #PercentVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as Running_Total_Vaccinations
from Portfolio_Project..CovidDeaths cd
join Portfolio_Project..CovidVaccinations cv
     on cd.location = cv.location
	 and cd.date = cv.date
where cd.continent is not null

select *, (Running_Total_Vaccinations/population)*100 as Percent_Vaccinated
from #PercentVaccinated
order by location, date


-- Creating views to store data

Create View PercentVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as Running_Total_Vaccinations
from Portfolio_Project..CovidDeaths cd
join Portfolio_Project..CovidVaccinations cv
     on cd.location = cv.location
	 and cd.date = cv.date
where cd.continent is not null

select *, (Running_Total_Vaccinations/population)*100 as Percent_Vaccinated
from #PercentVaccinated
order by location, date


-- Using CTE for calculating highest percent of people vaccinated

With RTvsP (continent, location, population, new_vaccinations, Running_Total_Vaccinations)
as (
Select cd.continent, cd.location, cd.population, cv.new_vaccinations, sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as Running_Total_Vaccinations
from Portfolio_Project..CovidDeaths cd
join Portfolio_Project..CovidVaccinations cv
     on cd.location = cv.location
	 and cd.date = cv.date
where cd.continent is not null
)
select location, population, Max(Running_Total_Vaccinations/population)*100 as Percent_Vaccinated
from RTvsP
group by location, population
order by 3 desc


-- Useful for Visualisation

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_Project..CovidDeaths
where continent is not null
Group by Location, Population, date
order by PercentPopulationInfected desc