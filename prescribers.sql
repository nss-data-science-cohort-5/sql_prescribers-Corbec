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
	p1.specialty_description AS specialty
	SUM(p2.total_claim_count) AS total_claims
FROM prescriber p1
LEFT JOIN prescription p2 ON p1.npi = p2.npi
-- WHERE p2.total_claim_count IS NULL
GROUP BY 1
ORDER BY 2
;