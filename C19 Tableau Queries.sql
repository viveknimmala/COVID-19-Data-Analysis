-- Global Total -

Select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2



-- Continents with Highest Deaths per Population -

Select location, SUM(cast(new_deaths as int)) as Total_Death_Count
From Portfolio_Project..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by Total_Death_Count desc



-- Countries with Highest Infection Rate -

Select Location, population, MAX(total_cases) as Highest_Infections, Round(MAX(total_cases/population)*100, 2) as Percentage_Population_Infected
from Portfolio_Project..CovidDeaths
where continent is not null
Group by location, population
order by 4 desc


-- Useful for Visualisation

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_Project..CovidDeaths
where continent is not null
Group by Location, Population, date
order by PercentPopulationInfected desc