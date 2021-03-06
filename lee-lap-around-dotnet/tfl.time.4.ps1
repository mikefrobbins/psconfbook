Get-ChildItem -Path C:\foo\ -File | 
    Where-Object LastAccessTime -lt $($Today.AddMonths(-3))


This example gets all the files in the `C:\Foo` folder, then filters all but files that were last accessed over three months ago.


### Time Zones

Most folks are familiar with time zones. 
American readers will know about Eastern Standard Time or Pacific Standard Time.
In Great Britain, we use Greenwich Mean time.

Some time zones also have a daylight savings time, which advances clocks by an hour each spring, and retards them by an hour in the autumn.
The idea of daylight savings is to take more advantage of the daylight and it is meant to be somewhat energy efficient.
The arguments for and against day light savings are kind of irrelevant and are left for the those of a pedantic nature.

## TimeZone Rules

Each timezone can have TimeZone Rules.
These that tell whether a particular time zone uses day light savings (falling back an hour in the autumn and spring forward an hour in the spring) and when those changes happen.

### TimeZone classes

In .Net, there are two classes that you can use to represent time zones.
The `System.TimeZone` class provides basic information about a timezone.
A richer class, `System.TimeZoneInfo`, provides significant enhancements.
You may find it useful on occasion to use both of these classes.

For Information on how .NET works with Dates, Times and time zones, see: https://docs.microsoft.com/en-us/dotnet/standard/datetime/

For more information on the `System.Timezone` class, see https://docs.microsoft.com//dotnet/api/system.timezone.

For more information on the `System.TimeZoneInfo` class, see https://docs.microsoft.com/en-gb/dotnet/api/system.timezoneinfo?view=netframework-4.7.2


This example gets all the files in the `C:\Foo` folder, then filters all but files that were last accessed over three months ago.


### Time Zones

Most folks are familiar with time zones. 
American readers will know about Eastern Standard Time or Pacific Standard Time.
In Great Britain, we use Greenwich Mean time.

Some time zones also have a daylight savings time, which advances clocks by an hour each spring, and retards them by an hour in the autumn.
The idea of daylight savings is to take more advantage of the daylight and it is meant to be somewhat energy efficient.
The arguments for and against day light savings are kind of irrelevant and are left for the those of a pedantic nature.

## TimeZone Rules

Each timezone can have TimeZone Rules.
These that tell whether a particular time zone uses day light savings (falling back an hour in the autumn and spring forward an hour in the spring) and when those changes happen.

### TimeZone classes

In .Net, there are two classes that you can use to represent time zones.
The `System.TimeZone` class provides basic information about a timezone.
A richer class, `System.TimeZoneInfo`, provides significant enhancements.
You may find it useful on occasion to use both of these classes.

For Information on how .NET works with Dates, Times and time zones, see: https://docs.microsoft.com/en-us/dotnet/standard/datetime/

For more information on the `System.Timezone` class, see https://docs.microsoft.com//dotnet/api/system.timezone.

For more information on the `System.TimeZoneInfo` class, see https://docs.microsoft.com/en-gb/dotnet/api/system.timezoneinfo?view=netframework-4.7.2


This example gets all the files in the `C:\Foo` folder, then filters all but files that were last accessed over three months ago.


### Time Zones

Most folks are familiar with time zones. 
American readers will know about Eastern Standard Time or Pacific Standard Time.
In Great Britain, we use Greenwich Mean time.

Some time zones also have a daylight savings time, which advances clocks by an hour each spring, and retards them by an hour in the autumn.
The idea of daylight savings is to take more advantage of the daylight and it is meant to be somewhat energy efficient.
The arguments for and against day light savings are kind of irrelevant and are left for the those of a pedantic nature.

## TimeZone Rules

Each timezone can have TimeZone Rules.
These that tell whether a particular time zone uses day light savings (falling back an hour in the autumn and spring forward an hour in the spring) and when those changes happen.

### TimeZone classes

In .Net, there are two classes that you can use to represent time zones.
The `System.TimeZone` class provides basic information about a timezone.
A richer class, `System.TimeZoneInfo`, provides significant enhancements.
You may find it useful on occasion to use both of these classes.

For Information on how .NET works with Dates, Times and time zones, see: https://docs.microsoft.com/en-us/dotnet/standard/datetime/

For more information on the `System.Timezone` class, see https://docs.microsoft.com//dotnet/api/system.timezone.

For more information on the `System.TimeZoneInfo` class, see https://docs.microsoft.com/en-gb/dotnet/api/system.timezoneinfo?view=netframework-4.7.2


This example gets all the files in the `C:\Foo` folder, then filters all but files that were last accessed over three months ago.


### Time Zones

Most folks are familiar with time zones. 
American readers will know about Eastern Standard Time or Pacific Standard Time.
In Great Britain, we use Greenwich Mean time.

Some time zones also have a daylight savings time, which advances clocks by an hour each spring, and retards them by an hour in the autumn.
The idea of daylight savings is to take more advantage of the daylight and it is meant to be somewhat energy efficient.
The arguments for and against day light savings are kind of irrelevant and are left for the those of a pedantic nature.

## TimeZone Rules

Each timezone can have TimeZone Rules.
These that tell whether a particular time zone uses day light savings (falling back an hour in the autumn and spring forward an hour in the spring) and when those changes happen.

### TimeZone classes

In .Net, there are two classes that you can use to represent time zones.
The `System.TimeZone` class provides basic information about a timezone.
A richer class, `System.TimeZoneInfo`, provides significant enhancements.
You may find it useful on occasion to use both of these classes.

For Information on how .NET works with Dates, Times and time zones, see: https://docs.microsoft.com/en-us/dotnet/standard/datetime/

For more information on the `System.Timezone` class, see https://docs.microsoft.com//dotnet/api/system.timezone.

For more information on the `System.TimeZoneInfo` class, see https://docs.microsoft.com/en-gb/dotnet/api/system.timezoneinfo?view=netframework-4.7.2
# Finds files not accessed for more than 3 months
Get-ChildItem -Path C:\foo\ -File | 
    Where-Object LastAccessTime -lt $($Today.AddMonths(-3))
# Finds files not accessed for more than 3 months
Get-ChildItem -Path C:\foo\ -File |
    Where-Object LastAccessTime -lt $($Today.AddMonths(-3))
# Finds files not accessed for more than 3 months
# Get today's date
$Today = Get-Date

# Get-ChildItem -Path C:\Foo\ -File |
    Where-Object LastAccessTime -lt $($Today.AddMonths(-3))

# The output from this varies with what is in the folder C:\Foo.
# Get all the time zones on this system
$Zones = [System.TimeZoneInfo]::GetSystemTimeZones()
Write-Output ("There are $($Zones.Count) time zones on this host")

# View First One
Write-Output "First time zone on this host:"
$Zones | Select-Object -First 1

# Get the current timezone
Write-Output 'Current Time Zone:'
[System.TimeZone]::CurrentTimeZone

# Get TimeZone information for GMT
Write-Output 'Timezone details for GMT:'
$Zones | Where-Object StandardName -Match 'GMT'

# For each zone, display name if the zone does NOT support DST
Write-Output 'TimeZones not supporting DST:'
foreach($Zone in $Zones) {
   if (-Not $Zone.SupportsDaylightSavingTime) {$Zone.DisplayName}
}

# Output from this fragment
#
#  There are 137 time zones on this host
#
#  First time zone on this host:
#  Id                         : Dateline Standard Time
#  DisplayName                : (UTC-12:00) International Date Line West
#  StandardName               : Dateline Standard Time
#  DaylightName               : Dateline Summer Time
#  BaseUtcOffset              : -12:00:00
#  SupportsDaylightSavingTime : False
#
#  Current Time Zone:
#  StandardName : GMT Standard Time
#  DaylightName : GMT Summer Time
#
#  Timezone details for GMT:
#  Id                         : GMT Standard Time
#  DisplayName                : (UTC+00:00) Dublin, Edinburgh, Lisbon, London
#  StandardName               : GMT Standard Time
#  DaylightName               : GMT Summer Time
#  BaseUtcOffset              : 00:00:00
#  SupportsDaylightSavingTime : True
#
#  TimeZones not supporting DST:
#  (UTC-12:00) International Date Line West
#  (UTC-11:00) Co-ordinated Universal Time-11
#  (UTC-10:00) Hawaii
#                            remainder snipped to save space!

