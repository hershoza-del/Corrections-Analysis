import os
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

df = pd.read_csv("/Users/hershoza/Downloads/Citywide_Payroll_Data_Correction_2025.csv")

#brief analysis of csv before changing it

print(df.shape)
print(df.info())
print(df.describe())
print(df.isnull().sum())
print(df.duplicated().sum())

#changing the csv

numeric_cols = [
    "Base Salary", "Regular Hours", "Regular Gross Paid",
    "OT Hours", "Total OT Paid", "Total Other Pay"
]

for col in numeric_cols:
    df[col] = pd.to_numeric(
        df[col].str.replace(r"[$,]", "", regex=True).str.strip(),
        errors="coerce"
    )

analysis = df.groupby("Title Description")["Base Salary"].agg(['mean', 'min', 'max', 'count'])
print(analysis)

df["OT Hours"] = (
    pd.to_numeric(df["OT Hours"].astype(str).str.replace(",", ""), errors="coerce")
      .round()
      .astype("Int64")
)

text_cols = ["Work Location Borough", "Title Description", "Leave Status as of June 30"]
for col in text_cols:
    df[col] = df[col].str.title()

df["Agency Start Date"] = pd.to_datetime(df["Agency Start Date"], format="%m/%d/%Y", errors="coerce")
df = df.sort_values("Agency Start Date").reset_index(drop=True)
df["Agency Start Date"] = df["Agency Start Date"].dt.strftime("%m/%d/%Y")

df.index = ["Correction Employee #" + str(i) for i in range(1, len(df) + 1)]
df.index.name = "Employee"

df["Title Description"] = df["Title Description"].str.replace(r"\b(Ii|Iii|Iv)\b", lambda m: m.group().upper(), regex=True)

df = df.drop(columns=["Fiscal Year", "Payroll Number", "Agency Name",
                      "Last Name", "First Name", "Mid Init", "Regular Hours"])

df = df.rename(columns={"Agency Start": "Start Date", "Title Description": "Title",
                        "Leave Status as of June 30": "Leave Status"})

#exporting the changes to a new csv

df.to_csv("/Users/hershoza/Downloads/Corrections_Analysis.csv")