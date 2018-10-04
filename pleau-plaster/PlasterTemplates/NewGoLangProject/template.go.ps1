<%
if ($PLASTER_PARAM_MainPackage -eq 'Main')
{
@"
package main

import (
"@
}
else
{
@"
package $PLASTER_PARAM_ProjectName

import (
"@
}


foreach ($import in $PLASTER_PARAM_Imports)
{
@"
	"$($import)"`r
"@
}

@"
)

func main() {
"@

if ($PLASTER_PARAM_Imports -contains 'fmt')
{
@"
    fmt.Println("Hello, Demo!")
"@
}

if ($PLASTER_PARAM_Imports -contains 'os')
{
@"
	h, err := os.Hostname()
	if err != nil {
		panic(err)
	}
	fmt.Println(h)
"@
}

if ($PLASTER_PARAM_Imports -contains 'time')
{
@"
	t := time.Now()
	fmt.Println(t)
"@
}

@"
}
"@
%>