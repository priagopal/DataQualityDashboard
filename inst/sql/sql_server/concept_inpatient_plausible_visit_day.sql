/*********
CONCEPT LEVEL check:
INPATIENT_VISIT - number of records where inpatient visit is less than 1 day
Parameters used in this template:
cdmDatabaseSchema = @cdmDatabaseSchema
cdmTableName = @cdmTableName
cdmFieldName = @cdmFieldName
conceptId = @conceptId
**********/


SELECT num_violated_rows, CASE WHEN denominator.num_rows = 0 THEN 0 ELSE 1.0*num_violated_rows/denominator.num_rows END AS pct_violated_rows,
       denominator.num_rows as num_denominator_rows
FROM
    (
        SELECT COUNT_BIG(*) AS num_violated_rows
        FROM
            (
                SELECT m.*
                FROM @cdmDatabaseSchema.@cdmTableName m
                {@cohort}?{
                JOIN @cohortDatabaseSchema.COHORT c
                ON m.PERSON_ID =c.SUBJECT_ID
                AND c.COHORT_DEFINITION_ID = @cohortDefinitionId
                }

                WHERE m.@cdmFieldName = @conceptId
                  AND ((m.VISIT_END_DATE-m.VISIT_START_DATE)+1) <=1
            ) violated_rows
    ) violated_row_count,
    (
        SELECT COUNT_BIG(*) AS num_rows
        FROM @cdmDatabaseSchema.@cdmTableName m
        {@cohort}?{
            JOIN @cohortDatabaseSchema.COHORT c
        ON m.PERSON_ID = c.SUBJECT_ID
            AND c.COHORT_DEFINITION_ID = @cohortDefinitionId
        }
        WHERE m.@cdmFieldName = @conceptId
        AND VISIT_END_DATE is NOT NULL
        AND VISIT_START_DATE is NOT NULL
    ) denominator
;
