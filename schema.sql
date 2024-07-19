-- Represents the ratings agencies that rate bonds
CREATE TABLE "Rating_Agency"(
    "id" INTEGER,
    "Name" TEXT NOT NULL,
    PRIMARY KEY("id")
);


-- Represents the bonds rated by rating agencies
CREATE TABLE "Bonds"(
    "id" INTEGER,
    "Rating_Agency_id" INTEGER,
    "Rating" TEXT NOT NULL CHECK(("Rating" IN ('AAA','AA','A','BBB') AND "Investment_Grade"==1) OR ("Rating" IN ('BB','B','CCC','CC','C','D') AND "Investment_Grade"==0)),
    "Investment_Grade" INTEGER NOT NULL CHECK("Investment_Grade" IN (0,1)),
    "Date" DATETIME DEFAULT CURRENT_TIMESTAMP,
    "Purchased?" INTEGER NOT NULL CHECK("Purchased?" IN (0,1)) DEFAULT 0,
    PRIMARY KEY("id"),
    FOREIGN KEY("Rating_Agency_id") REFERENCES "Rating_Agency"("id")
);


-- Represents the companies that issued the bonds
CREATE TABLE "Companies"(
    "id" INTEGER,
    "Name" TEXT NOT NULL,
    "Ticker" TEXT NOT NULL CHECK (LENGTH("Ticker")<=5),
    "Sector" TEXT NOT NULL,
    PRIMARY KEY("id")
);


-- Represents which company issued which bond
CREATE TABLE "Issue" (
    "Company_id" INTEGER,
    "Bond_id" INTEGER,
    FOREIGN KEY("Company_id") REFERENCES "Companies"("id"),
    FOREIGN KEY("Bond_id") REFERENCES "Bonds"("id")
);


-- Represents the financials of each company in the list
CREATE TABLE "Financials" (
    "Company_id" INTEGER UNIQUE,
    "Date" DATETIME DEFAULT CURRENT_TIMESTAMP,
    "Current_Ratio" NUMERIC NOT NULL CHECK("Current_Ratio">=0),
    "Operating_Cash_Flow_PerShare" NUMERIC NOT NULL,
    "Operating_Profit_Margin" NUMERIC NOT NULL CHECK("Operating_Profit_Margin"<=1),
    "Debt_Equity_Ratio" NUMERIC NOT NULL,
    "Enterprise_Value_Multiple" NUMERIC NOT NULL,
    FOREIGN KEY("Company_id") REFERENCES "Companies"("id")
);


-- View that contains information about investment grade bonds
CREATE VIEW "Investment_Grade_Bonds"
AS
SELECT "id"
	,"Rating"
	,"Name"
	,"Date"
FROM "Bonds"
JOIN "Rating_Agency" ON "Rating_Agency"."id" = "Bonds"."Rating_Agency_id"
WHERE "Investment_Grade" == 1;


-- View that contains information about junk bonds
CREATE VIEW "Junk_Bonds"
AS
SELECT "id"
	,"Rating"
	,"Name"
	,"Date"
FROM "Bonds"
JOIN "Rating_Agency" ON "Rating_Agency"."id" = "Bonds"."Rating_Agency_id"
WHERE "Investment_Grade" == 0;


-- View that contains information about purchased bonds
CREATE VIEW "Personal_Portfolio" AS
SELECT "Bonds"."id" AS "Bond_id","Rating","Investment_Grade","Name" AS "Company_Name" FROM "Bonds"
JOIN "Issue" ON "Bonds"."id"="Issue"."Bond_id"
JOIN "Companies" ON "Issue"."Company_id"="Companies"."id"
WHERE "Bonds"."Purchased?"=1;


-- Trigger that updates the underlying table instead of deleting from the view
CREATE TRIGGER "Sell"
INSTEAD OF DELETE ON "Personal_Portfolio"
FOR EACH ROW
BEGIN
UPDATE "Bonds" SET "Purchased?"=0 WHERE "id" = OLD."Bond_id";
END;


-- Trigger that updates the underlying table instead of inserting to the view
CREATE TRIGGER "Buy"
INSTEAD OF INSERT ON "Personal_Portfolio"
FOR EACH ROW
BEGIN
  UPDATE "Bonds" SET "Purchased?"=1 WHERE "id" = NEW."Bond_id";
END;

-- Indices to speed up typical queries
CREATE INDEX "Rating_index" ON "Bonds"("Rating");
CREATE INDEX "Company_name_index" ON "Companies"("Name");
CREATE INDEX "Company_ticker_index" ON "Companies"("Ticker");
CREATE INDEX "Current_ratio_index" ON "Financials"("Current_Ratio");
CREATE INDEX "Profit_margin_index" ON "Financials"("Operating_Profit_Margin");
CREATE INDEX "DE_ratio_index" ON "Financials"("Debt_Equity_Ratio");




