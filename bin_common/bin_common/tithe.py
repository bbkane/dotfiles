#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import datetime

today = datetime.date.today().strftime("%a %b %d - %Y-%m-%d")
print(f"Today is {today}. Remember to use last month's values :)")

pay1_in: str = input("Gross Pay 1: ")
pay1 = float(pay1_in.replace("$", "").replace(",", ""))

pay2_in: str = input("Gross Pay 2: ")
pay2 = float(pay2_in.replace("$", "").replace(",", ""))

espp1_in: str = input("Gross ESPP 1 (should be < 0): ")
espp1 = float(espp1_in.replace("$", "").replace(",", ""))

espp2_in: str = input("Gross ESPP 2 (should be < 0): ")
espp2 = float(espp2_in.replace("$", "").replace(",", ""))

tithes = ((pay1 + pay2) + (espp1 + espp2)) * 0.1
print("Tithes:", tithes)
