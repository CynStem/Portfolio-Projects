Select *
From CovidDeaths
Where continent is not Null
Order by 3, 4

--Select *
--From CovidVaccinations
--Order by 3, 4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not Null
Order by 1, 2

--Looking at Total Cases vs Total Deaths
-- shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where continent is not Null
Where location like '%states%'
Order by 1, 2


-- Looking at total cases vs population
Select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
From CovidDeaths
--Where location like '%states%'
Order by 1, 2

-- looking at coiuntries with highest infection rate compared to poluation
Select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentofPopInfected
From CovidDeaths
--Where location like '%states%'
Group by location, population
Order by PercentofPopInfected desc


--Showing Countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not Null
--Where location like '%states%'
Group by location
Order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is NOT Null
--Where location like '%states%'
Group by continent
Order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as TotalCases, SUM(new_Deaths) as TotalDeaths, SUM(New_Deaths)/Sum(new_Cases)*100 as DeathPercentage
From CovidDeaths
--Where continent is not Null
Where continent is not null
--Group by date
Order by 1, 2

-- Looking at the Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingPplVac
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac





--- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select *
from PercentPopulationVaccinated
