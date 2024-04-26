--Test Queries
select *
From CovidDeaths
Order by 3, 4

select *
From CovidVaccinatons
Order by 3,4 

Select location , continent, sum (people_fully_vaccinated) as TotalVaccinations
From CovidVaccinatons
Where continent = 'Africa' and location = 'Kenya'
Group by location, continent
order by 'TotalVaccinations' desc

-- DataSet (CovidDeaths)

select location, date, total_cases, new_cases, total_deaths,population
from CovidDeaths
order by 1, 2

--Total Cases vs Total Deaths 
--Likelihood of dying if you contract covid
SELECT location, date, total_cases, total_deaths, 
       (CAST(total_deaths AS decimal) / total_cases)*100 AS deathpercentage
FROM CovidDeaths
Where location = 'Kenya'
ORDER BY 1, 2;

--Total cases vs Total Population
--Percentage of the population that contracted covid
Select location, date, population, total_cases,
       (cast (total_cases as decimal)/population)*100 as PercentPopulationInfected
From CovidDeaths
Where location = 'Kenya'
Order by PercentPopulationInfected desc

--Highest Infection rate compared to Population
Select location, population, Max (total_cases)as MaxCasesPerCountry,
       max (cast(total_cases as decimal)/population)*100 as PerecentPopulationInfected
from CovidDeaths
Where location = 'Kenya' 
and continent is not null
Group by location, population
Order By PerecentPopulationInfected desc

--Highest Death Count per Population
Select location, population, max(total_deaths) as MaxDeathsPerCountry, 
       Max(cast(total_deaths as decimal)/population)*100 as DeathPercentage
from CovidDeaths
--where location = 'Kenya'
Group by location, population
Order by MaxDeathsPerCountry desc

--BREAK DOWN BY CONTINENT
-- Continents by death-count
Select continent, max(cast(total_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is not null
group by continent
order by TotalDeaths desc

--GLOBAL NUMBERS
--By Date (Death)
Select date,sum(new_cases) as TotalCasesByDate, sum(new_deaths) as TotalDeathsByDate, 
      case 
	  when sum(new_cases) = 0 then 0
      else (cast(sum(new_deaths) as decimal)/sum(new_cases))*100 
	  end as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by date 

--JOINS
SELECT *
FROM CovidDeaths dea
inner join CovidVaccinatons vac
 on dea.location=vac.location
 and dea.date=vac.date

 -- Total vaccines by location and date
 SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
  sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
inner join CovidVaccinatons vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 order by 2,3

-- CTE
 With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as (
  SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
  sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
inner join CovidVaccinatons vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 2,3
 )
 select *, (cast(RollingPeopleVaccinated as decimal)/population)*100
 From PopVsVac


 --TEMP TABLE

 Drop Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated 
 (
 continent NVARCHAR(255),
 location nvarchar (255),
 date datetime,
 population bigint,
 new_vaccinations bigint,
 RollingPeopleVaccinated bigint
 )
 Insert Into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
  sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
inner join CovidVaccinatons vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 2,3
 select *, (cast(RollingPeopleVaccinated as decimal)/population)*100 as percentpeoplevaccinated
 From #PercentPopulationVaccinated
