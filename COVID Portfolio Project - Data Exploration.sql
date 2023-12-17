
select *
from PortfolioProject1..COVID_Deaths
Where continent is not null
order by 3,4

select *
from PortfolioProject1..COVID_Vaccinations
Where continent is not null
order by 3,4


select location, date, total_cases, new_cases, total_deaths,population
from PortfolioProject1..COVID_Deaths
Where continent is not null
order by 1,2


-- TOTAL CASES VS TOTAL DEATHS

SELECT Location,date,total_cases,total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float))*100 as death_rate
FROM PortfolioProject1..COVID_Deaths
Where location like '%india%'
and continent is not null
ORDER BY 1,2 


-- TOTAL CASES VS POPULATIONS (shows what percentage of population got covid)

SELECT Location,date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject1..COVID_Deaths
--Where location like '%india%'
ORDER BY 1,2 

-- COUNTRY WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT Location, population, MAX(total_cases)AS HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject1..COVID_Deaths
--Where location like '%india%'
group by Location, population
ORDER BY PercentPopulationInfected desc


-- COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT Location, MAX(cast(total_deaths as int))AS TotalDeathCount
FROM PortfolioProject1..COVID_Deaths
--Where location like '%india%'
Where continent is not null
group by Location
ORDER BY TotalDeathCount desc


-- BY CONTITNENT

--	CONTINENT with HIGHEST DEATHCOUNT PER POPULATION

SELECT continent, MAX(cast(total_deaths as int))AS TotalDeathCount
FROM PortfolioProject1..COVID_Deaths
--Where location like '%india%'
Where continent is not null
group by continent
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT  sum(new_cases)as total_cases, sum(cast(new_deaths as int))as total_deaths, sum(cast(new_deaths as decimal(18, 2)))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..COVID_Deaths
-- Where location like '%india%'
where continent is not null
--Group by date
ORDER BY 1,2 



-- Total Population vs Vaccinations
-- Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..COVID_Deaths dea
Join PortfolioProject1..COVID_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- USE CTE

WITH PopvsVac (continen, location, date, population, New_Vaccinations, rollingpeoplevaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..COVID_Deaths dea
Join PortfolioProject1..COVID_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3
)
select *, (rollingpeoplevaccination/population)*100
from PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PERCENTAGEPOPULATIONVACCINATION
CREATE TABLE #PERCENTAGEPOPULATIONVACCINATION
(
CONTINENT nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PERCENTAGEPOPULATIONVACCINATION
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..COVID_Deaths dea
Join PortfolioProject1..COVID_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null 
-- order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PERCENTAGEPOPULATIONVACCINATION




 -- View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..COVID_Deaths dea
Join PortfolioProject1..COVID_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3


SELECT *
FROM PercentPopulationVaccinated
