# iris-watched-status

This class allows the user to create a class containing a <a href="https://docs.intersystems.com/irislatest/csp/documatic/%25CSP.Documatic.cls?LIBRARY=%25SYS&CLASSNAME=%25Library.Status">%Library.Status</a> object. Depending on how the properties of the class are set, the status can throw or log itself as an exception or write out its error text automatically whenever the status goes from $$$OK to an error status.

Instances should be created by calling the New method and providing flags as desired. Available flags are:<ul><li><b>T</b> - The status will be thrown when it is an error.</li><li><b>L</b> - The status will be logged as an exception when it becomes an error.</li><li><b>W</b> - The status will write its error text when it becomes an error.</li><li><b>R</b> - The status will reset to $$$OK after all other error handling.</li></ul>

Flags can be provided in any order and are not case sensitive.

The following code should create a watched status that writes its own error text, then resets to $$$OK. (This is useful when testing in a terminal.)

set status = ##class(DH.WatchedStatus).New("RW")<br />
set status.sc = (some method that returns a status object)

If the R flag was not given, further error handing by setting this same status will not trigger unless the sc is manually set back to $$$OK.
