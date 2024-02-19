--Looking at Total Population vs Vaccinations


-- CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
SELECT 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
(SELECT ISNULL(SUM(CONVERT(bigint, vac2.new_vaccinations)), 0)
FROM PortfolioProject..CovidVaccinations vac2 
 WHERE vac2.location = dea.location AND vac2.date <= dea.date) AS RollingPeopleVaccinated
FROM 
PortfolioProject..CovidDeaths dea
		JOIN 
PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE  
dea.continent IS NOT NULL
)


 Select *, (RollingPeopleVaccinated/Population)*100
 From PopvsVac

 -- TEM TABLE

 DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into  #PercentPopulationVaccinated
SELECT 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
(SELECT ISNULL(SUM(CONVERT(bigint, vac2.new_vaccinations)), 0)
FROM PortfolioProject..CovidVaccinations vac2 
 WHERE vac2.location = dea.location AND vac2.date <= dea.date) AS RollingPeopleVaccinated
FROM 
PortfolioProject..CovidDeaths dea
		JOIN 
PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
--WHERE  dea.continent IS NOT NULL


Select *, (RollingPeopleVaccinated/Population)*100
 From #PercentPopulationVaccinated


 --GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2


-- showing continents with the highest death count per population

select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc



-- creating view to store data for later visualization

create view PercentPopulationVaccinated as
SELECT 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
(SELECT ISNULL(SUM(CONVERT(bigint, vac2.new_vaccinations)), 0)
FROM PortfolioProject..CovidVaccinations vac2 
 WHERE vac2.location = dea.location AND vac2.date <= dea.date) AS RollingPeopleVaccinated
FROM 
PortfolioProject..CovidDeaths dea
		JOIN 
PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE  dea.continent IS NOT NULL
--order by 2,3



select *
from PercentPopulationVaccinated