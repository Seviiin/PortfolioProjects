
select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


-- select the data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- looking at Total cases vs Total death
-- shows likelihood of dying if you contact covid in your country

select location , date, total_cases, total_deaths , (total_deaths/total_cases)*100 DeathPercentage 
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


--Looking for total cases vs total population
--shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
order by PercentagePopulationInfected desc



--Looking at countries with highest infection rate comared to population
select location, population , max(total_cases) as HighestInfectionCount, max(total_cases/ population)*100  PercentPopulationInfected
from CovidDeaths
group by location, population
order by PercentPopulationInfected desc


--Showing countries with the highest death count per population
select location, max (cast(total_deaths as int)) MaxTotalDeath
from PortfolioProject..CovidDeaths
where continent is not null
group by  location
order by MaxTotalDeath desc

--Lets break it down by continet
select location, max (cast(total_deaths as int)) TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by  location
order by TotalDeathCount desc


----look at the difference between this and before
select continent, max (cast(total_deaths as int)) MaxTotalDeath
from PortfolioProject..CovidDeaths
group by  continent
order by MaxTotalDeath desc

--showing the continent with the highest death count

select continent, max (cast(total_deaths as int)) MaxTotalDeath
from PortfolioProject..CovidDeaths
where continent is not null
group by  continent
order by MaxTotalDeath desc



--Global Numbers
--shows each date what is the number of new cases, new deaths and the percentage of deaths globaly

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by date

--just a number

select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null


----------------------------------------------
---------------GO TO Covid VACCINATION Table
----------------------------------------------

-- Total population vs Total Vaccination

select Dea.continent ,Dea.location, Dea.date, Dea.population Total_Population, Vac.new_vaccinations , 
	sum(convert(int,Vac.new_vaccinations) ) OVER (partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
		--, (RollingPeopleVaccinated/population)*100 --This part get error because we can not use a column that just now we have created.
	--The solution is using Temp Table or CTE
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null


-- in the example above we want to get the max amount of RollingPeopleVaccinated, but the problem is we can not use like this>> (RollingPeopleVaccinated/population)/100
-- because we can use a column that just created. So what to do?
-- We need to use ///Temp Table/// or ///CTE///
--So what is CTE?
-- be careful: number of items infront of with must be equal with the numbers of items in the select 


--CTE 
/*CTE format:: with x ()
				as
				(
				...
				...
				)
*/

with PopvsVac (continent, location, date, total_population, new_vaccinations, RollingPeopleVaccinated)
as
(
select Dea.continent ,Dea.location, Dea.date, Dea.population Total_Population, Vac.new_vaccinations , 
	sum(convert(int,Vac.new_vaccinations) ) OVER (partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
)

select * , (RollingPeopleVaccinated/total_population)*100 as PercentageVaccinated
from PopvsVac


--Using Temp Table
Drop table if exists  #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select Dea.continent ,Dea.location, Dea.date, Dea.population Total_Population, Vac.new_vaccinations , 
	sum(convert(int,Vac.new_vaccinations) ) OVER (partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null


select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from #PercentPopulationVaccinated

 
 --- calculating the total percentage of vaccination by each location
select location, max(RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from #PercentPopulationVaccinated
where continent is not null
group by location
order by location



-----for using this queries in the Tableau we need to create Views 
--Create View to store data for later visualizations

-- Creating View
Create View ViewofPercentPopulationVaccinated as
select Dea.continent ,Dea.location, Dea.date, Dea.population Total_Population, Vac.new_vaccinations , 
	sum(convert(int,Vac.new_vaccinations) ) OVER (partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null


select * from ViewofPercentPopulationVaccinated

