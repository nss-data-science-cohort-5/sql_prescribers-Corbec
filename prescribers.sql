-- 1. a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
--    b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

-- a.

SELECT
	p1.npi,
	SUM(p2.total_claim_count) AS total_claims
FROM prescriber p1
JOIN prescription p2 ON p1.npi = p2.npi
GROUP BY 1
ORDER BY 2 DESC
;

-- b.

SELECT
	p1.npi,
	p1.nppes_provider_first_name || ' ' || p1.nppes_provider_last_org_name AS name,
	p1.specialty_description AS specialty,
	SUM(p2.total_claim_count) AS total_claims
FROM prescriber p1
JOIN prescription p2 ON p1.npi = p2.npi
GROUP BY 1,2,3
ORDER BY 4 DESC
;

/* 2. a. Which specialty had the most total number of claims (totaled over all drugs)?

    b. Which specialty had the most total number of claims for opioids?

    c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

    d. **Difficult Bonus:** 
	*Do not attempt until you have solved all other problems!* 
	For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?
*/

-- a.
SELECT
	p1.specialty_description AS specialty,
	SUM(p2.total_claim_count) AS total_claims
FROM prescriber p1
JOIN prescription p2 ON p1.npi = p2.npi
GROUP BY 1
ORDER BY 2 DESC
;

-- b.

SELECT
	p1.specialty_description AS specialty,
	SUM(p2.total_claim_count) AS total_claims
FROM prescriber p1
JOIN prescription p2 ON p1.npi = p2.npi
JOIN drug d ON p2.drug_name = d.drug_name
WHERE d.opioid_drug_flag = 'Y'
GROUP BY 1
ORDER BY 2 DESC
;

-- c.

SELECT
	p1.specialty_description AS specialty,
	COALESCE(SUM(p2.total_claim_count), 0) AS total_claims
FROM prescriber p1
LEFT JOIN prescription p2 ON p1.npi = p2.npi
GROUP BY 1
ORDER BY 2 
;

-- d.


-- 3. a. Which drug (generic_name) had the highest total drug cost?
--    b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.

-- a.
SELECT
	d.generic_name,
	SUM(p.total_drug_cost) AS total_cost
FROM prescription p
LEFT JOIN drug d ON p.drug_name = d.drug_name
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1
;

-- b.
SELECT
	d.generic_name,
	ROUND(SUM(p.total_drug_cost) / SUM(p.total_day_supply), 2) AS total_cost_per_day
FROM prescription p
LEFT JOIN drug d ON p.drug_name = d.drug_name
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1
;


-- 4. a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y',
--       says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
--    b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics.
--       Hint: Format the total costs as MONEY for easier comparision.

-- a.
SELECT
	drug_name,
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither'
	END AS drug_type
FROM drug
;

-- b.
SELECT
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	END AS drug_type,
	SUM(total_drug_cost)::money AS total_cost
FROM drug d
JOIN prescription p ON d.drug_name = p.drug_name
WHERE opioid_drug_flag = 'Y'
OR antibiotic_drug_flag = 'Y'
GROUP BY 1
ORDER BY 2 DESC
;


-- 5. a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
--    b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
--    c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

-- a. 
SELECT
	COUNT(DISTINCT(c.cbsa))
FROM fips_county f
JOIN cbsa c ON f.fipscounty = c.fipscounty
WHERE f.state = 'TN'
;

-- b.
SELECT
	c.cbsaname,
	SUM(p.population) AS population
FROM fips_county f
JOIN population p ON f.fipscounty = p.fipscounty
JOIN cbsa c ON f.fipscounty = c.fipscounty
-- WHERE f.state = 'TN'
GROUP BY 1
ORDER BY 2 DESC
;

-- c. 
SELECT
	county,
	p.population
FROM fips_county f
JOIN population p ON f.fipscounty = p.fipscounty
LEFT JOIN cbsa c ON f.fipscounty = c.fipscounty
WHERE f.state = 'TN'
AND c.cbsa IS NULL
ORDER BY 2 DESC
LIMIT 1
;


-- 6. a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
--    b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
--    c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

-- a.
SELECT
	drug_name,
	SUM(total_claim_count) AS total_claims
FROM prescription p
WHERE total_claim_count >= 3000
GROUP BY 1
ORDER BY 2 DESC
;


-- Bryan's code
select * from (select drug_name, sum(total_claim_count) total_claims
from prescription
group by drug_name) subquery
where subquery.total_claims >= 3000
order by subquery.total_claims desc

-- b.
SELECT
	d.drug_name,
	d.opioid_drug_flag,
	SUM(total_claim_count) AS total_claims
FROM prescription p
JOIN drug d ON p.drug_name = d.drug_name
WHERE total_claim_count >= 3000
GROUP BY 1,2
ORDER BY 3 DESC
;




-- c.
SELECT
	d.drug_name,
	d.opioid_drug_flag,
	p2.nppes_provider_first_name || ' ' || p2.nppes_provider_last_org_name AS prescriber_name,
	total_claim_count AS total_claims
FROM prescription p
JOIN drug d ON p.drug_name = d.drug_name
JOIN prescriber p2 ON p.npi = p2.npi
WHERE total_claim_count >= 3000
ORDER BY 4 DESC
;


-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid.
--        a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment')
--           in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y').
--           **Warning:** Double-check your query before running it. You will likely only need to use the prescriber and drug tables.
--        b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims.
--           You should report the npi, the drug name, and the number of claims (total_claim_count).
--        c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

-- a.












