use tg_tourism;
Select * from domestic_visitors;
/* Q1.list down the top Ten district that have the highest number of domestic visitors from over all(2016-2019)*/
SELECT district, SUM(visitors) AS total_visitors
FROM domestic_visitors
GROUP BY district
ORDER BY total_visitors DESC limit 10;

/* Q2.List Down the top three district based on compound annual growth rate
 (CAGR) of visitors betwwn (2016-2019)*/
 WITH cagr_data AS (
  SELECT
    district,
    (MAX(visitors) / MIN(visitors)) ^ (1.0 / 4) - 1 AS cagr
  FROM
    domestic_visitors
  WHERE
    year >= 2016 AND year <= 2019
  GROUP BY
    district
)
SELECT
  district,
  cagr
FROM
  cagr_data
ORDER BY
  cagr DESC
LIMIT 3;
/*-----------------------*/
WITH cagr_data AS (
  SELECT
    district,
    (MAX(visitors) / MIN(visitors)) ^ (1.0 / 4) - 1 AS cagr
  FROM
    domestic_visitors
  WHERE
    year >= 2016 AND year <= 2019
  GROUP BY
    district
)
SELECT
  district,
  cagr * 100 AS cagr_percentage
FROM
  cagr_data
ORDER BY
  cagr_percentage DESC
LIMIT 3;





WITH yearly_data AS (
  SELECT district, 
         EXTRACT(YEAR FROM date) AS year, 
         SUM(visitors) AS total_visitors
  FROM domestic_visitors
  WHERE EXTRACT(YEAR FROM date) >= 2016 AND EXTRACT(YEAR FROM date) <= 2019
  GROUP BY district, year
)
SELECT district, 
       ((MAX(total_visitors) / MIN(total_visitors)) ^ (1.0 / 4)) - 1 AS cagr
FROM yearly_data
GROUP BY district
ORDER BY cagr DESC
LIMIT 3;

 /*Q3.Q2.List Down the bottom three district based on compound annual growth rate
 (CAGR) of visitors betwwn (2016-2019)*/
 WITH cagr_data AS (
  SELECT
    district,
    (MAX(visitors) / MIN(visitors)) ^ (1.0 / 4) - 1 AS cagr
  FROM
    domestic_visitors
  WHERE
    year >= 2016 AND year <= 2019
  GROUP BY
    district
)
SELECT
  district,
  cagr
FROM
  (
    SELECT
      district,
      cagr
    FROM
      cagr_data
    WHERE
      cagr IS NOT NULL
    ORDER BY
      cagr ASC
    LIMIT 3
  ) AS bottom_three
ORDER BY
  cagr ASC;


  WITH cagr_data AS (
  SELECT
    district,
    (MAX(visitors) / MIN(visitors)) ^ (1.0 / 4) - 1 AS cagr
  FROM
    foreign_visitors
  WHERE
    year >= 2016 AND year <= 2019
  GROUP BY
    district
)
SELECT
  district,
  cagr
FROM
  (
    SELECT
      district,
      cagr
    FROM
      cagr_data
    WHERE
      cagr IS NOT NULL
    ORDER BY
      cagr ASC
    LIMIT 3
  ) AS bottom_three
ORDER BY
  cagr ASC;

 /*Q4  What are the peak and low season months for Hydrabad based on the 
 data from 2016-2019 for hydrabad district?*/
 SELECT month,SUM(visitors) as dm_visitors from domestic_visitors where district ='Hyderabad'
 group by month
 order by dm_visitors desc limit 3;
 
 SELECT month,SUM(visitors) as dm_visitors from domestic_visitors where district ='Hyderabad'
 group by month
 order by dm_visitors asc limit 3;
 /*-------Foreign_visitors-----------*/
 
 SELECT month,SUM(visitors) as dm_visitors from foreign_visitors where district ='Hyderabad'
 group by month
 order by dm_visitors desc limit 3;
 
 SELECT month,SUM(visitors) as dm_visitors from foreign_visitors where district ='Hyderabad'
 group by month
 order by dm_visitors asc limit 3;
 
 /* Q5 Top 3 and bottom 3 districts with high domestic to foreign tourist ratio*/
 WITH dm_visitors AS
 (SELECT district, sum(visitors) as total_visitors from domestic_visitors 
 group by district
 order by total_visitors desc),
 fm_visitors As
 (SELECT district, sum(visitors) as total_visitors from foreign_visitors 
 group by district
 order by total_visitors desc),
 district_ratios AS (
  SELECT dm_visitors.district,
         dm_visitors.total_visitors AS dm_total_visitors,
         fm_visitors.total_visitors AS fm_total_visitors,
         dm_visitors.total_visitors / fm_visitors.total_visitors AS visitor_ratio
  FROM dm_visitors
  JOIN fm_visitors ON dm_visitors.district = fm_visitors.district
)
SELECT district, visitor_ratio
FROM district_ratios
ORDER BY visitor_ratio DESC
LIMIT 3;


/*Q6 LISt The top And Bottom 5 district based on  'population to tourist footfall ratio in 2019*/

with domestic as 
(SELECT district,sum(visitors) as total_dm_visitors from domestic_visitors where year = 2019
group by district
order by total_dm_visitors DESC),
fm_visitors as 
(SELECT district,sum(visitors) as total_fm_visitors from foreign_visitors where year = 2019
group by district
order by total_fm_visitors DESC),
dm_pl as
(Select dm.district,dm.total_dm_visitors,pl.Population_2019_year
from domestic dm join population pl on
pl.District = dm.district)
(Select district,(total_dm_visitors/Population_2019_year) as footfall_ratio
FROM dm_pl order by footfall_ratio desc limit 5) union
(Select district,(total_dm_visitors/Population_2019_year) as footfall_ratio
FROM dm_pl order by footfall_ratio asc limit 5);

/*Q7  what will be the projected number of domestic and foreign tourists in hyderabad  in 2025
 based on the growth rate from previoues years*/



WITH growth_rate_dm AS (
    SELECT district, year, SUM(visitors) AS total_visitors
    FROM domestic_visitors
    WHERE district = 'Hyderabad'
    GROUP BY district, year
),
growth_rate_fv AS (
    SELECT district, year, SUM(visitors) AS total_visitors
    FROM foreign_visitors
    WHERE district = 'Hyderabad'
    GROUP BY district, year
),
grt_dm AS (
    SELECT district, ((MAX(total_visitors) - MIN(total_visitors)) / MIN(total_visitors)) * 100 AS growth_rate_dm
    FROM growth_rate_dm
    GROUP BY district
),
grt_fv AS (
    SELECT district, ((MAX(total_visitors) - MIN(total_visitors)) / MIN(total_visitors)) * 100 AS growth_rate
    FROM growth_rate_fv
    GROUP BY district
),
predicted_dm_visitors AS (
    SELECT
        grt_dm.district AS district_dm,
        ((SELECT total_visitors FROM growth_rate_dm WHERE year = 2019) * POWER(1 + grt_dm.growth_rate_dm / 100, 2025 - 2019)) AS visitors_dm_hyd_2025
    FROM grt_dm
),
predicted_fv_visitors AS (
    SELECT
        grt_fv.district AS district_fv,
        ((SELECT total_visitors FROM growth_rate_fv WHERE year = 2019) * POWER(1 + grt_fv.growth_rate / 100, 2025 - 2019)) AS visitors_fv_hyd_2025
    FROM grt_fv
)
SELECT
    predicted_dm_visitors.district_dm,
    predicted_dm_visitors.visitors_dm_hyd_2025,
    predicted_fv_visitors.district_fv,
    predicted_fv_visitors.visitors_fv_hyd_2025
FROM predicted_dm_visitors
JOIN predicted_fv_visitors ON predicted_dm_visitors.district_dm = predicted_fv_visitors.district_fv;


/*Q8 Estimate the projected revenue for hydrabad in 2025 based on 
average revenue spent per tourists**/
WITH growth_rate_dm AS (
    SELECT district, year, SUM(visitors) AS total_visitors
    FROM domestic_visitors
    WHERE district = 'Hyderabad'
    GROUP BY district, year
),
growth_rate_fv AS (
    SELECT district, year, SUM(visitors) AS total_visitors
    FROM foreign_visitors
    WHERE district = 'Hyderabad'
    GROUP BY district, year
),
grt_dm AS (
    SELECT district, ((MAX(total_visitors) - MIN(total_visitors)) / MIN(total_visitors)) * 100 AS growth_rate_dm
    FROM growth_rate_dm
    GROUP BY district
),
grt_fv AS (
    SELECT district, ((MAX(total_visitors) - MIN(total_visitors)) / MIN(total_visitors)) * 100 AS growth_rate
    FROM growth_rate_fv
    GROUP BY district
),
predicted_dm_visitors AS (
    SELECT
        grt_dm.district AS district_dm,
        ((SELECT total_visitors FROM growth_rate_dm WHERE year = 2019) * POWER(1 + grt_dm.growth_rate_dm / 100, 2025 - 2019)) AS visitors_dm_hyd_2025
    FROM grt_dm
),
predicted_fv_visitors AS (
    SELECT
        grt_fv.district AS district_fv,
        ((SELECT total_visitors FROM growth_rate_fv WHERE year = 2019) * POWER(1 + grt_fv.growth_rate / 100, 2025 - 2019)) AS visitors_fv_hyd_2025
    FROM grt_fv
),
total_revenue AS (
    SELECT
        (SELECT visitors_dm_hyd_2025 FROM predicted_dm_visitors) * 1200 AS domestic_revenue,
        (SELECT visitors_fv_hyd_2025 FROM predicted_fv_visitors) * 5600 AS foreign_revenue
)
SELECT
    domestic_revenue AS domestic_revenue_2025,
    foreign_revenue AS foreign_revenue_2025
FROM total_revenue;

