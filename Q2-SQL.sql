# 1
# What are the top 5 brands by receipts scanned for most recent month?
# Here I cannot find the output, because the lastest purchase date is "2021-03-01", which is way too long since now
# But I think my Query can work well with the lateset data tables
SELECT b.name, COUNT(b.name) AS Total_num
FROM google_analytics_pageviews.receipts_items ri 
LEFT JOIN  google_analytics_pageviews.receipts r ON r._id = ri._id
LEFT JOIN  google_analytics_pageviews.brands b ON b.barcode = ri.rewardsReceiptItemList_barcode
WHERE r.dateScanned>now() - interval 1 month
GROUP BY b.name
ORDER BY COUNT(b.name) DESC
LIMIT 5;




# 2
# How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
# MySQL cannot support the window function, so I use UNION ALL to finish it
(SELECT date_format(r.purchaseDate, '%Y-%m') times, b.name, COUNT(b.name) total_num
-- ROW_NUMBER() over (partition by date_format(r.purchaseDate, '%Y-%m') order by COUNT(b.name) desc) as brand_rank
FROM google_analytics_pageviews.receipts_items ri 
LEFT JOIN  google_analytics_pageviews.receipts r ON r._id = ri._id
LEFT JOIN  google_analytics_pageviews.brands b ON b.barcode = ri.rewardsReceiptItemList_barcode
WHERE date_format(r.purchaseDate, '%Y-%m') = "2022-02"
GROUP BY date_format(r.purchaseDate, '%Y-%m'), b.name
ORDER BY date_format(r.purchaseDate, '%Y-%m'), COUNT(b.name) DESC
LIMIT 5)

UNION ALL

(SELECT date_format(r.purchaseDate, '%Y-%m') times, b.name, COUNT(b.name) total_num
-- , COUNT(b.name), ROW_NUMBER() over (partition by date_format(r.purchaseDate, '%Y-%m') order by COUNT(b.name) desc) as brand_rank
FROM google_analytics_pageviews.receipts_items ri 
LEFT JOIN  google_analytics_pageviews.receipts r ON r._id = ri._id
LEFT JOIN  google_analytics_pageviews.brands b ON b.barcode = ri.rewardsReceiptItemList_barcode
WHERE date_format(r.purchaseDate, '%Y-%m') = "2022-03"
GROUP BY date_format(r.purchaseDate, '%Y-%m'), b.name
ORDER BY date_format(r.purchaseDate, '%Y-%m'), COUNT(b.name) DESC
LIMIT 5);



# 3
# When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
SELECT rewardsReceiptStatus, ROUND(AVG(totalSpent),2) average_spend
FROM google_analytics_pageviews.receipts r
WHERE rewardsReceiptStatus = 'FINISHED' OR rewardsReceiptStatus = 'REJECTED'
GROUP BY rewardsReceiptStatus
ORDER BY AVG(totalSpent) DESC;

# 4
# When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
SELECT r.rewardsReceiptStatus, COUNT(r.rewardsReceiptStatus) total_num
FROM google_analytics_pageviews.receipts r 
LEFT JOIN  google_analytics_pageviews.receipts_items ri ON r._id = ri._id
WHERE rewardsReceiptStatus = 'FINISHED' OR rewardsReceiptStatus = 'REJECTED'
GROUP BY rewardsReceiptStatus
ORDER BY COUNT(r.rewardsReceiptStatus) DESC;

# 5 
# Which brand has the most spend among users who were created within the past 6 months?
# The lastest purchase date is way too long since now, so the query cannot find the output
SELECT b.name, SUM(totalSpent) total_spend
FROM google_analytics_pageviews.receipts_items ri 
LEFT JOIN  google_analytics_pageviews.receipts r ON r._id = ri._id
LEFT JOIN  google_analytics_pageviews.brands b ON b.barcode = ri.rewardsReceiptItemList_barcode
LEFT JOIN  google_analytics_pageviews.users u ON u._id = r.userId
WHERE u.createdDate >= DATE_SUB(NOW(), interval 6 month)
GROUP BY b.name
ORDER BY SUM(totalSpent) DESC
LIMIT 1
;


# 6 
# Which brand has the most transactions among users who were created within the past 6 months?
# The lastest transactions is way too long since now, so the query cannot find the output
SELECT b.name, COUNT(b.name) num_transactions
FROM google_analytics_pageviews.receipts_items ri 
LEFT JOIN  google_analytics_pageviews.receipts r ON r._id = ri._id
LEFT JOIN  google_analytics_pageviews.brands b ON b.barcode = ri.rewardsReceiptItemList_barcode
LEFT JOIN  google_analytics_pageviews.users u ON u._id = r.userId
WHERE u.createdDate >= DATE_SUB(NOW(), interval 6 month)
GROUP BY b.name
ORDER BY COUNT(b.name) DESC
LIMIT 1
;

