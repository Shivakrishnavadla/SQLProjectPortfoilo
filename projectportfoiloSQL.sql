
select *
from Portfoiloprojet.dbo.CovidDeaths
where continent is not null
order by 3,4;

--select *
--from Portfoiloprojet.dbo.CovidVaccination
--order by 3,4;

-- Select the data that we are using

Select location,date, total_cases,new_cases,total_deaths,population
from Portfoiloprojet.dbo.CovidDeaths
order by 1,2;

--Looking at the Total cases vs Total Deaths

Select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from Portfoiloprojet.dbo.CovidDeaths
Where location='India'
order by 1,2;

Select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from Portfoiloprojet.dbo.CovidDeaths
Where location Like'%states%'
order by 1,2;

--Looking at Total cases Vs population
-- Shows what percentages of population got covid
Select Location,date,total_cases,Population, (total_cases/population)*100 as Deathpercentage
from Portfoiloprojet.dbo.CovidDeaths
Where location Like'%states%'
order by 1,2;

 -- Looking at countries with hightes infect rate compared with population

Select Location,population,max(total_cases) as Highestinfectionrate, max((total_cases/population))*100 as percentpopulation
from Portfoiloprojet.dbo.CovidDeaths
Group by population,location
--Where location Like'%states%'
order by percentpopulation desc;

-- countries showing the hightes death rate
Select Location,max(cast(total_deaths as int)) as totaldeathcount
from Portfoiloprojet.dbo.CovidDeaths
where continent is not null
Group by location

order by totaldeathcount desc;

-- Let us do it by continent-

Select Location,max(cast(total_deaths as int)) as totaldeathcount
from Portfoiloprojet.dbo.CovidDeaths
where continent is null
Group by location

order by totaldeathcount desc;


--- Breaking Global numbers

Select date,sum(new_cases), sum(cast(new_deaths as int)), (sum(cast(new_deaths as int))/sum(new_cases))*100 as Deathpercentage
from Portfoiloprojet.dbo.CovidDeaths
--Where location Like'%states%'
where continent is not null
group by date
order by 1,2;


Select sum(new_cases), sum(cast(new_deaths as int)), (sum(cast(new_deaths as int))/sum(new_cases))*100 as Deathpercentage
from Portfoiloprojet.dbo.CovidDeaths
--Where location Like'%states%'
where continent is not null
order by 1,2;


-------------------------------------------------
WITH popvsvac (continent, location, date, population, New_vaccinations, RollingPeopleVaccination)
AS
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) Over (partition by dea.location order by dea.location, dea.Date ) as Rollingpeoplevacnated
From Portfoiloprojet.dbo.CovidDeaths dea
join Portfoiloprojet.dbo.CovidVaccination vac
on dea.location=vac.location and dea.date= vac.date
where dea.continent IS NOT NULL

)

Select *,(RollingPeopleVaccination/population) as  from popvsvac;
---------------------------------------------------------------------------

---TEMP TABLE CREATION
Drop table if exists #percentagepopulationvaccinated
Create Table #percentagepopulationvaccinated
(
 continent nvarchar(225),
 Location nvarchar(225),
 Date datetime,
 population numeric,
 New_vaccination numeric,
 Rollingpeoplevacnated numeric
 )

 insert into #percentagepopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) Over (partition by dea.location order by dea.location, dea.Date ) as Rollingpeoplevacnated
From Portfoiloprojet.dbo.CovidDeaths dea
join Portfoiloprojet.dbo.CovidVaccination vac
on dea.location=vac.location and dea.date= vac.date
where dea.continent IS NOT NULL

Select continent, location,Date from #percentagepopulationvaccinated;

--- Creating view to store data for later visualization
Create View PercentPopulationVaccinatedview as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) Over (partition by dea.location order by dea.location, dea.Date ) as Rollingpeoplevacnated
From Portfoiloprojet.dbo.CovidDeaths dea
join Portfoiloprojet.dbo.CovidVaccination vac
on dea.location=vac.location and dea.date= vac.date
where dea.continent IS NOT NULL;


select * from PercentPopulationVaccinatedview