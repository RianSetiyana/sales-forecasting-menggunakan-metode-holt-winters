WITH normalized_dates AS (
    SELECT
        REPLACE(order_id, 'CA', 'US') AS order_id,
        CAST(
            CASE
                WHEN order_date LIKE '% %'
                    THEN REGEXP_REPLACE(SPLIT_PART(order_date, ' ', 1), '(\d{4}).(\d{2}).(\d{2})', '\2-\3-\1', 'g')
                ELSE REGEXP_REPLACE(order_date, '(\d{1,2}).(\d{2}).(\d{4})', '\2-\1-\3', 'g')
            END AS DATE
        ) AS order_date,
        CAST(
            CASE
                WHEN ship_date LIKE '% %'
                    THEN REGEXP_REPLACE(SPLIT_PART(ship_date, ' ', 1), '(\d{4}).(\d{2}).(\d{2})', '\2-\3-\1', 'g')
                ELSE REGEXP_REPLACE(ship_date, '(\d{1,2}).(\d{2}).(\d{4})', '\2-\1-\3', 'g')
            END AS DATE
        ) AS ship_date,
        ship_mode,
        customer_id,
        customer_name,
        segment,
        country,
        city,
        state,
        postal_code,
        region,
        product_id,
        category,
        sub_category,
        product_name,
        sales,
        quantity,
        discount,
        profit
    FROM data.superstore
),

monthly_sales AS (
    SELECT
        order_date,
        EXTRACT(YEAR FROM order_date)  AS order_year,
        TRIM(TO_CHAR(order_date, 'Month')) AS order_month,
        EXTRACT(MONTH FROM order_date) AS month_number,
        sales,
		profit
    FROM normalized_dates
)

SELECT
	CAST(CONCAT_WS('-', order_year, month_number, 1) AS DATE) AS order_date,
    order_year,
    order_month,
	month_number,
    SUM(sales) AS sales,
	SUM(profit) AS profit,
	'Actual' AS data_type
FROM monthly_sales
GROUP BY
    order_year, order_month, month_number
ORDER BY
    order_year, month_number;