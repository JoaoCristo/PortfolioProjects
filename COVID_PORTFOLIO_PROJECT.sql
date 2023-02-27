
Select *
From CovidDeaths
Where continent is not Null
order by 3,4


Select *
From CovidVaccinations
order by 3,4

		-- Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where location = 'Portugal'
order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract Covid in your country


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
From CovidDeaths
Where location = 'Portugal'
order by 1,2


-- Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select Location, date, total_cases,Population, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
Where location = 'Portugal'
order by 1,2


-- Looking at Countries with Highest Infection Rate Compared to Population

Select Location,Population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, population
order by PercentPopulationInfected desc

Set ARITHABORT OFF
SET ANSI_WARNINGS OFF

-- Let's Break things down by Continent

-- Showing continents with the highest death count per population

Select Location, Max(total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is Null
Group by Location
order by TotalDeathCount desc

-- Showing Countries with Highest death count per Population

Select Location, Max(total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is not Null
Group by Location
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date,SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as Deathpercentage
From CovidDeaths
where continent is not null
Group By date
order by 1,2

Select SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as Deathpercentage
From CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccinations
-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as Percentage_of_Population_Vaccinated
From PopvsVac

-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as Percentage_of_Population_Vaccinated
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
