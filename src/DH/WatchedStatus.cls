/// This class can be used to make a status code do some basic handling on its own when it becomes an error status.
/// For example:<br /><br />
/// set status = ##class(DH.WatchedStatus).New("RW")<br />
/// set status.sc = (some method that returns a status here)<br /><br />
/// If the method returns an error status, it will immediately be written, and the status will change back to $$$OK.<br />
/// Note that if ..sc is not set back to an $$$OK status, either automatically or manually, error handling will not trigger again on the next error.
Class DH.WatchedStatus Extends %RegisteredObject
{

/// This is the status code to be watched.
Property sc As %Status [ InitialExpression = 1, SqlComputeCode = {set {*} = ##class(User.WatchedStatus).Reset({sc},{resetSelf})}, SqlComputed, SqlComputeOnChange = isErr ];

/// Used to track if the status code is an error. This is necessary for some shenanigans with SQLComputeCode between this flag and the status code.
Property isErr As %Boolean [ InitialExpression = 0, SqlComputeCode = {set {*} = ##class(User.WatchedStatus).ErrCheck({sc},{writeSelf},{logSelf},{throwSelf})}, SqlComputed, SqlComputeOnChange = sc ];

/// If true, this will will throw ..sc as soon as it becomes an error.
Property throwSelf As %Boolean [ InitialExpression = 0 ];

/// If true, this will log ..sc as an Exception as soon as it becomes an error.
Property logSelf As %Boolean [ InitialExpression = 0 ];

/// If true, this will write the error text of ..sc as soon as it becomes an error.
Property writeSelf As %Boolean [ InitialExpression = 0 ];

/// If true, after other error handling, ..sc will be reset to $$$OK.
/// Note that if this is false, you will need to reset the status yourself for the automatic handling to trigger again.
Property resetSelf As %Boolean [ InitialExpression = 0 ];

/// Handles status according to flags set, then sets isErr.
ClassMethod ErrCheck(sc, writeSelf, logSelf, throwSelf) As %Boolean [ Internal ]
{
	if $$$ISERR(sc){
		if writeSelf{
			write $SYSTEM.Status.GetErrorText(sc)
		}
		if logSelf = 1{
			do ##class(%Exception.StatusException).CreateFromStatus(sc).Log()
		}
		if throwSelf = 1{
			$$$ThrowStatus(sc)
		}
		quit 1
	}
	else{
		quit 0
	}
}

/// If resetSelf is true, resets the status code after error handling occurs.
ClassMethod Reset(sc, resetSelf) As %Status [ Internal ]
{
	return:resetSelf $$$OK
	return sc
}

/// flags is a string which determines status behavior when an error occurs
/// T = throw the status
/// L = log the status as an exception
/// W = write the status error text
/// R = reset status after error handling; if set, isErr goes back to 0 and sc goes back to 1
ClassMethod New(flags As %String) As User.WatchedStatus
{
	set status = ##class(User.WatchedStatus).%New()
	set flags = $ZCVT(flags,"U")
	set:(flags [ "T") status.throwSelf = 1
	set:(flags [ "L") status.logSelf = 1
	set:(flags [ "W") status.writeSelf = 1
	set:(flags [ "R") status.resetSelf = 1
	return status
}

}
