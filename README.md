The objective of this project was to create heat maps depicting 
labour force participation rates for different categories of 
gender and age in India. Data source: Employment and Unemployment, 
July 2011- June 2012 NSS 68th Round by the Ministry of Statistics 
and Programme Implementation (MoSPI).

The STATA code achieves the following:
1. Creates a unique panel identifier and merges the relevant variables.
2. Defines a sampling pattern and multiplier
3. Redefines the employment variables to suit the requirements of the project
4. Generates variables by categories (gender, rural/urban, age)
5. Collapses variables for summary statistics, for each graph
6. Exports the data with district labels, to input onto DataWrapper.  
