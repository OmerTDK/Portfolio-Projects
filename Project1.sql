--SELECT *
--FROM Portfolio_Project_1..[Covid Vaccinations]
--Order by 3,4
SELECT *
FROM Portfolio_Project_1..[Covid Deaths]
ORDER BY 3,4

-- Selecting Data that we'll be using
SELECT Location, Date, total_cases, new_cases, total_deaths, population
From Portfolio_Project_1..[Covid Deaths]
Order by 1,2


-- Percentage Mortality
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Mortality_Rate
From Portfolio_Project_1..[Covid Deaths]
WHERE location like '%pakistan%'
Order by 1,2


-- Infection Rate 
SELECT Location, Date, total_cases, population, (total_cases/population)*100 AS InfectionRate
From Portfolio_Project_1..[Covid Deaths]
WHERE location like '%pakistan%'
Order by 1,2

-- Countries w/ Highest Infection Rate
SELECT Location,Population, MAX(total_cases) as HighestInfectionCounts , MAX((total_cases/population))*100 AS HighestInfectionRate
From Portfolio_Project_1..[Covid Deaths]
Group by location, population
Order by HighestInfectionRate desc

-- Highest Covid Mortality By Country
SELECT Location,Population, MAX(cast(total_deaths as int)) as TotalDeaths 
From Portfolio_Project_1..[Covid Deaths]
where continent is not NULL
Group by location, population
Order by TotalDeaths desc

-- (OMER) Highest Covid Mortality By Continent 
SELECT location, MAX(cast(total_deaths as int)) as TotalDeaths 
From Portfolio_Project_1..[Covid Deaths]
where continent IS NULL
and location not in ('World', 'High income', 'Upper middle income', 'Lower middle income', 'Low income', 'International')
Group by location
Order by TotalDeaths desc

-- (ALEX) Continent Covid Mortality
Select continent, MAX(cast (Total_deaths as int)) as TotalDeathCount
From Portfolio_Project_1..[Covid Deaths]
Where continent is not null
Group by continent
order by TotalDeathCount desc 

-- (OMER)Continents w/ Highest Infection Rate
SELECT Location, MAX(total_cases) as HighestInfectionCounts , MAX((total_cases/population))*100 AS HighestInfectionRate
From Portfolio_Project_1..[Covid Deaths]
where continent IS NULL and location not in ('European Union','World', 'High income', 'Upper middle income', 'Lower middle income', 'Low income', 'International')
Group by location
Order by HighestInfectionRate desc

-- (ALEX) Continets w/ Highest Infection Rate
SELECT continent, MAX(total_cases) as HighestInfectionCounts , MAX((total_cases/population))*100 AS HighestInfectionRate
From Portfolio_Project_1..[Covid Deaths]
where continent IS not null
Group by continent
Order by HighestInfectionRate desc

-- Global Numbers
SELECT SUM(new_cases) as Totalcases,SUM(cast(new_deaths as int)) as totaldeaths,
	SUM(cast(new_deaths as int))/sum(New_cases)*100 as DeathPercentage  
From Portfolio_Project_1..[Covid Deaths]
where continent is not null
--group by date
Order by 1,2



-- Total Population Vs. Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project_1..[Covid Vaccinations] vac
join Portfolio_Project_1..[Covid Deaths] dea
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project_1..[Covid Vaccinations] vac
join Portfolio_Project_1..[Covid Deaths] dea
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)

Select *
From PopVsVac



-- Using Temp Table to perform Calculation on Partition By in previous query
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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project_1..[Covid Deaths] dea
Join Portfolio_Project_1..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project_1..[Covid Deaths] dea
Join Portfolio_Project_1..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

SELECT *
From PercentPopulationVaccinated
