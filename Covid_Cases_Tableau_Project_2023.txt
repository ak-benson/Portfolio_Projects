/*
Queries used for Tableau Project
*/


/* 1.0 */

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From coviddeaths23
where location = 'World'
order by 1,2

/* 2.0 */
/* We take these out as they are not inluded in the above queries and want to stay consistent. 
 * European Union is part of Europe*/

Select location, SUM(new_deaths) as TotalDeathCount
From coviddeaths23
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

/* 3.0 */

Select location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeaths23
Group by Location, population
order by PercentPopulationInfected desc

/* 4.0 */

Select location, population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeaths23
Group by location, population, date
order by PercentPopulationInfected desc

/* 5.0 */

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
From coviddeaths23 dea
Join covidvaccinations23 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3

/* 6.0 */
/* Using CTE to perform Calculation on Partition By in previous query */

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths23 dea
join covidvaccinations23 vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
/*order by 2,3*/
)
select *, (RollingPeopleVaccinated/population)*100 as percentvaccinated
from PopvsVac


