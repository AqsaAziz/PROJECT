CREATE DATABASE project_hr;

USE project_hr;

SELECT * FROM hr;

##data cleaning and preprocessing##

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

DESCRIBE hr

SET sql_safe_updates = 0;

UPDATE hr
SET birthdate = CASE
        WHEN  birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
        WHEN  birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
        ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

UPDATE hr
SET hire_date = CASE
WHEN  hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
        WHEN  hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
        ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

## change the date format and datatype of termdate column ##

UPDATE hr
SET termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate !='';

## create an age column ##
 
 ALTER TABLE hr
 ADD COLUMN age INT;
 
 UPDATE hr
 SET age = timestampdiff(YEAR,birthdate,curdate())
 
 SELECT min(age), max(age) FROM hr
 
 ## 1. What is gender breakdown of employees in the company? ##
 
 SELECT * FROM hr
 
 SELECT gender, COUNT(*) AS count
 FROM hr
 WHERE termdate IS NULL
 GROUP BY gender;
 
 ## 2. What is race breakdown of employees in the company? ##
 
 SELECT race, COUNT(*) AS count
 FROM hr
 WHERE termdate IS NULL
 GROUP BY race;
 
 ## 3. What is the age distribution of employees in the company? ##
  
SELECT
    CASE
       WHEN age>=18 AND age<=24 THEN '18-24'
       WHEN age>=25 AND age<=34 THEN '25-34'
       WHEN age>=35 AND age<=44 THEN '35-44'
       WHEN age>=45 AND age<=54 THEN '45-54'
       WHEN age>=55 AND age<=64 THEN '55-64'
ELSE '65+'
END AS age_group,
COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY age_group
ORDER BY age_group;

## 4. How many employees work at HQ vs remote? ##

SELECT location, COUNT(*) as count
from hr
where termdate is null
group by location
 

## 5. What is the average length of employment whe have been terminated? ##
SELECT year(termdate)- year(hire_date) AS length_of_emp
FROM HR
WHERE termdate is not null AND termdate <= curdate()

##6. How does the gender distribution vary across dept, and jobtitles##

select * FROM hr 

SELECT department,jobtitle,gender,COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY department, jobtitle, gender
ORDER BY department, jobtitle, gender


SELECT department,jobtitle,gender,COUNT(*) AS count
FROM hr
WHERE termdate IS  NULL
GROUP BY department, gender
ORDER BY department, gender


SELECT department,COUNT(*) AS count
FROM hr
WHERE termdate is null
GROUP BY department
ORDER BY department
 
 ## 7. What is the distribution of jobtitles across the company ##
 
SELECT jobtitle, COUNT(*) AS count
FROM hr
WHERE termdate is null
GROUP BY jobtitle;

## 8. Which dept has the higher turn over or termination rate??

SELECT department,
      COUNT(*) AS total_count,
      COUNT( CASE
	           WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1
			   END) AS terminated_count,
	ROUND((COUNT(CASE
	           WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1
               END)/COUNT(*))*100,2) AS termination_rate
FROM hr
GROUP BY department
ORDER BY termination_rate DESC

## 9. What is distribution of employess across loation_state?

SELECT location_state, COUNT(*) AS count
FROM hr
where termdate is null
group by location_state 

SELECT location_city, COUNT(*) AS count
FROM hr
where termdate is null
group by location_city 

## 10. How has the company employee count changed over time based on hire and termination date??
      
SELECT * from hr     

SELECT year,
       hires,
       terminations, 
       hires-terminations AS net_change,
       (terminations/hires)*100 AS change_percent
FROM( 
     SELECT YEAR(hire_date) AS year,
     count(*) AS hires, 
     sum( case
		when termdate is not null and termdate <=curdate() then 1
         end) AS terminations
         from hr
          group by year(hire_date)) AS subquery
 group by year
 order by year;
 
 ## 11. what is tenure distribution between ech dept??
 
 SELECT department, round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure
 from hr
 where termdate is NOT NULL and termdate <= curdate()
 GROUP BY department
 
 ## 12. terminations and hire breakdown gender wisw
 
 SELECT gender,
		total_hires,
        total_terminations,
        ROUND((total_terminations/total_hires)*100,2) AS termination_rate
FROM(
     SELECT gender,
     COUNT(*) AS total_hires,
     COUNT(CASE
WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
END ) AS total_terminations 
     FROM hr
     GROUP BY gender) as subquery
GROUP BY gender

## dept wise terminatins

SELECT department,
		total_hires,
        total_terminations,
        ROUND((total_terminations/total_hires)*100,2) AS termination_rate
FROM(
     SELECT department,
     COUNT(*) AS total_hires,
     COUNT(CASE
WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
END ) AS total_terminations 
     FROM hr
     GROUP BY department) as subquery
GROUP BY department

##. race wise terminations
SELECT race,
		total_hires,
        total_terminations,
        ROUND((total_terminations/total_hires)*100,2) AS termination_rate
FROM(
     SELECT race,
     COUNT(*) AS total_hires,
     COUNT(CASE
WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
END ) AS total_terminations 
     FROM hr
     GROUP BY race) as subquery
GROUP BY race

##. Age wise terminations..

SELECT age,
		total_hires,
        total_terminations,
        ROUND((total_terminations/total_hires)*100,2) AS termination_rate
FROM(
     SELECT age,
     COUNT(*) AS total_hires,
     COUNT(CASE
WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
END ) AS total_terminations 
     FROM hr
     GROUP BY age) as subquery
GROUP BY age