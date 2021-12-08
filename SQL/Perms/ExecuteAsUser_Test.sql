SELECT suser_name(), original_login() --DOMAIN\YourAccount, DOMAIN\YourAccount
--here's the actual impersonation. this can just as easily be a normal <abbr title="Structured Query Language">SQL</abbr> account
EXECUTE AS USER = 'test'
--display the current user we're accessing as. note that SUSER_NAME() is the account specified above
SELECT suser_name(), original_login() --DOMAIN\AnotherAccount, DOMAIN\YourAccount
/*
run test cases here to verify correct settings
*/

--tests:
select * from dbo.D_Portfolio
select * from feeds.V_ExtractFor_IrDelta
select * from star.D_V_CurrencyPair



--this steps us back out to the normal context
revert
--verify that we've reverted back to ourselves
SELECT suser_name(), original_login()