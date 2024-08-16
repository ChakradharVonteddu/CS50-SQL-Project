SELECT "id","Rating","Date"
FROM "Bonds"
WHERE  "Company_id" IN (
	SELECT "id"
	FROM "Companies"
	WHERE "Sector" = 'Consumer Durables'
);
 -- Finding bond id,rating and date of issuance for companies in the consumer durables sector

SELECT "Sector"
	,"Current_Ratio"
	,"Debt_Equity_Ratio"
	,"Operating_Profit_Margin"
FROM "Companies"
JOIN "Financials" ON "Financials"."Company_id" = "Companies"."id"
WHERE "Name" = 'Whirlpool Corporation';
  -- Finding the financial information and sector of a company called Whirlpool Corporation

SELECT "Rating"
	,"Current_Ratio"
	,"Operating_Cash_Flow_PerShare"
	,"Enterprise_Value_Multiple"
FROM "Bonds"
JOIN "Financials" ON "Bonds"."Company_id" = "Financials"."Company_id"
WHERE "Rating" IN (
		'AAA','AA'
		);
  -- Finding the financial information of companies who issued AAA and AA rated bonds

DELETE FROM "Personal_Portfolio" WHERE "Rating"='BBB' AND "Company_Name"='Whirlpool Corporation';
  -- Updating portfolio to capture sale of Whirlpool Corporation's BBB bonds

INSERT INTO "Personal_Portfolio" ("Bond_id")
SELECT "id"
FROM "Bonds"
WHERE "Company_id" = (
      SELECT "id"
      FROM "Companies"
      WHERE "Name" = 'Sysco Corporation'
);
 -- Updating portfolio to capture the purchase of all Sysco Corporation bonds


