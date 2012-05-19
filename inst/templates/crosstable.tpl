<!--head
Title:          Crosstable
Author:         Gergely Daróczi
Email:          gergely@snowl.net
Description:    Returning the Chi-squared test of two given variables with count, percentages and Pearson's residuals table.
Packages:       descr
Data required:  TRUE
Strict:         TRUE
Example:        rapport('crosstable', data=ius2008, row='gender', col='dwell')
		rapport('crosstable', data=ius2008, row='email', col='dwell')

row             | *factor | Row variable        | A categorical variable.
col             | *factor | Column variable     | A categorical variable.
annotation	| TRUE	  | Annotation		| Should textual annotations be added to the report?
head-->

# Variable description

Two variables specified:

 * "<%=rp.name(row)%>"<%ifelse(rp.label(row)==rp.name(row), '', sprintf(' ("%s")', rp.label(row)))%> with <%rp.valid(as.numeric(row))%> and
 * "<%=rp.name(col)%>"<%ifelse(rp.label(col)==rp.name(col), '', sprintf(' ("%s")', rp.label(col)))%> with <%rp.valid(as.numeric(col))%> valid values.

# Counts

<%
caption('Counted values')
table     <- table(row, col, deparse.level = 0)
(fulltable <- addmargins(table))
%>

<%
if (annotation) {
   table.max <- which(table == max(table), arr.ind = TRUE)
   sprintf('Most of the cases (%s) can be found in "%s" categories. Row-wise "%s" holds the highest number of cases (%s) while column-wise "%s" has the utmost cases (%s).', table[table.max], paste(rownames(table)[table.max[,1]], colnames(table)[table.max[,2]], sep = '-'), names(which.max(rowSums(table))), max(rowSums(table)), names(which.max(colSums(table))), max(colSums(table)))
}
%>

# Percentages

<%
caption('Total percentages')
rp.round(addmargins(prop.table(table)*100), short = TRUE)
%>

<%
caption('Row percentages')
rp.round(prop.table(addmargins(table, 1), 1)*100, short = TRUE)
%>

<%
caption('Column percentages')
rp.round(prop.table(addmargins(table,2 ), 2)*100, short = TRUE)
%>

# Chi-squared test

<%
t <- suppressWarnings(chisq.test(table))
lambda <- lambda.test(table)
cramer <- sqrt(as.numeric(t$statistic)/(sum(table)*min(dim(table))))
t
%>

<%
ifelse(t$p.value < 0.05, sprintf('It seems that a real association can be pointed out between *%s* and *%s* by the *%s* (χ=%s at the degree of freedom being %s) at the significance level of %s.\nBased on Goodman and Kruskal\'s lambda it seems that *%s* (λ=%s) has an effect on *%s* (λ=%s) if we assume both variables to be nominal.\nThe association between the two variables seems to be %s based on Cramer\'s V (%s).', rp.name(row), rp.name(col), t$method, rp.round(as.numeric(t$statistic)), rp.round(as.numeric(t$parameter)), rp.round(t$p.value), c(rp.name(col),rp.name(row))[which.max(lambda)], rp.round(max(as.numeric(lambda))), c(rp.name(col),rp.name(row))[which.min(lambda)], rp.round(min(as.numeric(lambda))), ifelse(cramer < 0.5, "weak", "strong"), rp.round(cramer)), sprintf('It seems that no real association can be pointed out between *%s* and *%s* by the *%s* (χ=%s at the degree of freedom being %s) at the significance level of %s.\nFor this end no other statistical tests were performed.', rp.name(row), rp.name(col), t$method, rp.round(as.numeric(t$statistic)), rp.round(as.numeric(t$parameter)), rp.round(t$p.value)))
%>

<%
caption('Pearson\'s residuals')
(table.res <- suppressWarnings(CrossTable(table))$chisq$stdres)
%>

<%
if (annotation) {
   table.res.high     <- which(table.res >  2, arr.ind = TRUE)
   table.res.low      <- which(table.res < -2, arr.ind = TRUE)
   table.res.highlow  <- which(table.res < -2 | table.res > 2, arr.ind = TRUE)
   if (nrow(table.res.highlow) > 0)
      sprintf('Based on Pearson\'s resuals the following cells seems interesting (with values higher then `2` or lower then `-2`):\n%s', paste(sapply(1:nrow(table.res.highlow), function(i) sprintf('\n * "%s - %s"', rownames(table)[table.res.highlow[i, 1]], colnames(table)[table.res.highlow[i, 2]])), collapse = ''))
   else
      sprintf('No interesting (higher then `2` or lower then `-2`) values found based on Pearson\'s residuals.')

}
%>

# Charts

<%
caption('Mosaic chart')
mosaicplot(table, shade=T, main=NULL)
%>
