--Select the data we are going to use
SELECT continent,location,date,total_cases,new_cases,total_deaths,population
FROM coviddeaths
WHERE continent ISNULL
ORDER BY location,date;

-- looking at Total cases Vs Total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS percent_deaths
FROM coviddeaths
ORDER BY location,date;

--looking at total cases and population
SELECT location, date,population, total_cases, (total_cases/population)*100 AS percent_of_population
FROM coviddeaths
--WHERE location = 'India'
ORDER BY location,date;

--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS max_cases, MAX((total_cases/population))*100 AS percent_of_population
FROM coviddeaths
GROUP BY location, population
--WHERE location = 'India'
ORDER BY percent_of_population DESC;

--Highest death count per population
SELECT location, MAX(total_deaths) AS max_deaths
FROM coviddeaths
WHERE continent NOTNULL AND total_deaths NOTNULL -- some continents as misplaced in location
GROUP BY location, population
--WHERE location = 'India'
ORDER BY max_deaths DESC;

--Breaking down by continents(We have some problem in the data continents are added in the location columns)
SELECT location AS continent1, MAX(total_deaths) AS max_deaths
FROM coviddeaths
WHERE continent ISNULL
GROUP BY continent1
ORDER BY max_deaths DESC;

--continue
SELECT continent, MAX(total_deaths) AS max_deaths
FROM coviddeaths
WHERE continent NOTNULL
GROUP BY continent
ORDER BY max_deaths DESC;

--Global numbers
SELECT date, SUM(new_cases) AS newcases, SUM(new_deaths) AS newdeaths,(SUM(new_deaths)/SUM(new_cases))*100 AS percent_deaths
FROM coviddeaths
WHERE continent NOTNULL
GROUP BY date
ORDER BY date;

--Joining table
---looking at population Vs Vaccintions	
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths dea
INNER JOIN covidvacinations vac
 ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent NOTNULL
ORDER BY 2,3;

--cumulative vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS Rolling_count
FROM coviddeaths dea
INNER JOIN covidvacinations vac
 ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent NOTNULL
ORDER BY 2,3;

---using temp table with as for calculation
WITH PopvsVac(continent,location, date, population, new_vaccinations, Rolling_count)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS Rolling_count
FROM coviddeaths dea
INNER JOIN covidvacinations vac
 ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent NOTNULL
)

SELECT *,(Rolling_count/population)*100 AS population_percent
FROM PopvsVac

--Creating view for visualization
CREATE VIEW populationvaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS Rolling_count
FROM coviddeaths dea
INNER JOIN covidvacinations vac
 ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent NOTNULL
ORDER BY 2,3;
