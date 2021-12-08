--covers the case of someone inserting the resord between this code selecting 
--and inserting

BEGIN TRAN

IF EXISTS(SELECT ClientRequestTask_PK FROM [dbo].[U_ClientRequestTask] WITH (UPDLOCK, HOLDLOCK) WHERE [TaskId_LK] = @TaskId_LK)
	BEGIN
				
		UPDATE [dbo].[U_ClientRequestTask]
		SET [TaskName] = COALESCE(@TaskName,[TaskName]), 				
		WHERE TaskId_LK = @TaskId_LK	
		
	END
ELSE
	BEGIN
	
		INSERT INTO [U_ClientRequestTask]
				   ([ClientRequest_FK])
		 VALUES  (@ClientRequestPK)
				   
	END

COMMIT TRAN