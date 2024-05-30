# Splice Case Study

This is a take-home case study project that uses SQLMesh seeds, models, and tests to determine the total number of active customers, churned customers, and returning customers by [report] month and cohort [first seen subscription] month.

## Running this project
To get up and running with this project:

1. Install SQLMesh using [these instructions.](https://sqlmesh.readthedocs.io/en/stable/quick_start/)

2. Clone this repository.

3. Change into the case-study directory from the command line:

```
$ cd case-study
```
4. Run the models:

```
$ sqlmesh plan <ENV>
```
5. Query the data:

```
$ sqlmesh fetchdf "SELECT * FROM splice_case_study.full_model LIMIT 10;"
```

<br>

## General thoughts and grievances

### Naming Conventions and Data Types 

#### Source Data Complaints

1. Column name "month" is vague. The field should be renamed to "report_month" or similar. "month" being a SQL keyword can create confusing syntax in certain SQL statements.
    * e.g: `DATE_DIFF('month', cohort_month, month)`

2. Column "user_id" has varying lengths - from 15-19 numbers long. Seeing as these IDs are (most likely) not to be used in calculations, they could be stored as a VARCHAR instead. And perhaps padding with zeroes to ensure all strings have the same length.
    * Pros of changing user_id to type VARCHAR:
        1. Future Development - We may decide to implement a mixed alpha-numeric identifier for each user_id in the future. e.g: 24110982725182USA
        2. Preventative measure for any calculations being done on the ID.
    * Cons of changing user_id to type VARCHAR:
        1. Storage - INTs are generally cheaper to store than lengthy VARCHARs.
        2. Efficiency - Queries, Constraints, and Keys tend to work more quickly with numeric values.
    * Ultimately, compatibility of the ID with other systems or applications that interact with the database is the deciding factor.

3. Column name "cohort_month" is vague. Names such as "cohort_start_month", "subcription_start_month", etc. would be more clear to users of the table what 
    this field represents.

4. Column "customer_flag" is of type INT instead of type BOOLEAN. While this approach works fine in this case, the flag could accidentally be set to an incosistent and nonsensical value.
   *  e.g: `customer_flag = 29`

### Destination Table Complaints
1. Column name "relative_month_number" is vague. Names such as "customer_tenure", "customer_lifetime", etc. would be more clear to users of the table what this field represents.
     * If customer tenure is not the desired metric from this field, a name like "months_since_activation" may suffice.

## Data Quality

1. There are users registered with cohort_month dates in the future from the current reporting month.
    * e.g:
    
| month | user_id | cohort_month | customer_flag |
| :--: | :--: | :--: | :--: |
| 2023-06-01 | 2411109671690172286 | 2023-08-01 | 0 |

<br>

2. There are users registered as inactive in their cohort_month.
 * e.g: 

| month | user_id | cohort_month | customer_flag |
| :--: | :--: | :--: | :--: |
| 2023-06-01 |  809197614891168787 | 2023-06-01   |             0

2. There is an inconsistent tracking of inactive customers in the table. Sometimes an inactive customer will be removed from the table the following month from a customer_flag = 0 record. Other times a customer will be in the table for two inactive months in a row.
    * e.g: This user appears in the table in 2023-12 and 2024-01 despite being inactive two months in a row.
<br>

| month | user_id | cohort_month | customer_flag |
| :--: | :--: | :--: | :--: |
| 2023-07-01 | 680584580777716216 | 2023-07-01 | 1 |
| 2023-08-01 | 680584580777716216 | 2023-07-01 | 1 |
| 2023-09-01 | 680584580777716216 | 2023-07-01 | 0 |
| 2023-11-01 | 680584580777716216 | 2023-07-01 | 1 |
| 2023-12-01 | 680584580777716216 | 2023-07-01 | 0 |
| 2024-01-01 | 680584580777716216 | 2023-07-01 | 0 |
<br>

 * e.g: This user does not have a record for 2023-12 because it is the following month from the first showing of inactivity.
 <br>

| month | user_id | cohort_month | customer_flag |
| :--: | :--: | :--: | :--: |
| 2023-09-01 | 868733413088241 | 2023-09-01   |             1 |
| 2023-10-01 | 868733413088241 | 2023-09-01   |             1 |
| 2023-11-01 | 868733413088241 | 2023-09-01   |             0 |
| 2024-01-01 | 868733413088241 | 2023-09-01   |             1 |
| 2024-02-01 | 868733413088241 | 2023-09-01   |             1 |

```
    /\_____/\
   /  o   o  \
  ( ==  ^  == )
   )         (
  (           )
 ( (  )   (  ) )
(__(__)___(__)__) THANKS FOR READING
```