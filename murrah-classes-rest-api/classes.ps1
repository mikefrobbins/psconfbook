Class Car {
    #region Properties
    [String]$Manufacturer
    [String]$Model
    [Int]$ModelYear
    [DateTime]$DateAdded
    [Int]$ID
    #endregion
    #region Methods
    #region Get Methods
    Static [car] Get(
        [int]$id
    ) {
        # Step 1: build URI string and body
        $BaseURI = 'http://localhost:3000/cars'
        $URIString = "$baseURI/$ID"
        # Step 2: submit request and capture output
        write-verbose $URIString
        $Return = Invoke-RestMethod -Uri $URIString -Method Get
        # Step 3: instantiate new object and return it
        $output = [car]::New($return.manufacturer,
            $return.model,
            $return.modelyear,
            $return.DateAdded,
            $return.id)
        return $output
    }
    Static [Car[]] Get(
        [String]$Manufacturer,
        [String]$Model,
        [Int]$ModelYear
    ) {
        # Step 1: build URI string and body
        $BaseURI = 'http://localhost:3000/cars'
        $URIString = "$BaseURI`?"
        If ($Manufacturer) {$URIString += "manufacturer=$Manufacturer&"}
        If ($Model) {$URIString += "model=$Model&"}
        If ($ModelYear) {$URIString += "modelyear=$ModelYear&"}
        $URIString = $URIString.TrimEnd('&')
        # Step 2: submit request and capture output
        write-verbose $URIString
        $Return = Invoke-RestMethod -Uri $URIString -Method Get
        # Step 3: instantiate new object and return it
        $output = @()
        Foreach ($item in $Return) {
            $output += [car]::New($item.manufacturer,
                $item.model,
                $item.modelyear,
                $item.dateadded,
                $item.id)
        }
        return $output
    }
    #endregion
    #region Create method
    Static [Car]Create(
        [String]$Manufacturer,
        [String]$Model,
        [Int]$ModelYear
    ) {
        # Step 1: build URI string and body
        $BaseURI = 'http://localhost:3000/cars'
        $newCarBody = @{
            manufacturer = $Manufacturer
            model        = $Model
            modelyear    = $ModelYear
            dateadded    = $(get-date -uformat "%m/%d/%Y")
        }
        # Step 2: submit request and capture output
        write-verbose $BaseURI
        $Return = Invoke-RestMethod -Uri $BaseURI -Method POST -body $newCarBody
        # Step 3: instantiate new object and return it
        $output = [car]::New($return.manufacturer,
            $return.model,
            $return.modelyear,
            $return.dateadded,
            $return.id)
        return $output
    }
    #endregion
    #region Delete method
    [Void]Delete() {
        $BaseURI = 'http://localhost:3000/cars'
        $URIString = "$BaseURI/$($this.ID)"
        Invoke-RestMethod -Uri $URIString -Method Delete
    }
    #endregion
    #region Set Method
    #no set method for the car class as there isn't realistically anything we'd change to an existing car record
    #endregion
    #region ToString method
    [String] ToString() {
        $outputString = "$($this.ModelYear) $($this.Manufacturer) $($this.Model)"
        return $outputString
    }
    #endregion
    #endregion
    #region Constructors
    Car (
        [String]$Manufacturer,
        [String]$Model,
        [Int]$ModelYear,
        [DateTime]$DateAdded,
        [Int]$ID
    ) {
        $this.Manufacturer = $Manufacturer
        $this.Model = $Model
        $this.ModelYear = $ModelYear
        $this.DateAdded = $DateAdded
        $this.ID = $ID
    }
    #endregion
}

Class customer {
    #region properties
    [String]$name
    [Int]$ID
    [car[]]$Cars
    [datetime]$LastVisit
    #endregion
    #region methods
    #region Get methods
    Static [customer] Get(
        [int]$id
    ) {
        # Step 1: build URI string and body
        $BaseURI = 'http://localhost:3000/customers'
        $URIString = "$baseURI/$ID"
        # Step 2: submit request and capture output
        write-verbose $URIString
        $Return = Invoke-RestMethod -Uri $URIString -Method Get
        # Step 3: instantiate new object and return it
        $Carlist = @(
            Foreach ($CarID in $return.cars) {
                [Car]::Get($CarID)
            }
        )
        $output = [customer]::New($return.name,
            $return.id,
            $Carlist,
            $return.lastvisit)
        return $output
    }
    #endregion
    #region Create method
    Static [Customer]Create (
        [String]$Name,
        [Car[]]$Cars
    ) {
        # Step 1: build URI string and body
        $BaseURI = 'http://localhost:3000/customers'
        $carIDs = $cars.ID
        $newCustomerBody = @{
            name      = $name
            cars      = $carIDs
            lastvisit = $(get-date -uformat "%m/%d/%Y")
        }
        # Step 2: submit request and capture output
        write-verbose $BaseURI
        $Return = Invoke-RestMethod -Uri $BaseURI -Method POST -body $newCustomerBody
        # Step 3: instantiate new object and return it
        $output = [customer]::New($return.Name,
            $return.ID,
            $Cars,
            $return.lastvisit)
        return $output
    }
    #endregion
    #region Set method
    [Void] Set (
        [Car[]]$Cars,
        [DateTime]$LastVisit
    ) {
        # Step 1: build URI string and body
        $BaseURI = 'http://localhost:3000/customers'
        $URIString = "$baseURI/$($this.ID)"
        $customerBody = @{
            name      = $this.name
            cars      = $Cars.ID
            lastvisit = $LastVisit.ToString()
        }
        # Step 2: submit request and capture output
        write-verbose $URIString
        $Return = Invoke-RestMethod -Uri $URIString -Method PUT -body $($CustomerBody | ConvertTo-JSON) -ContentType application/JSON
        # Step 3: update object with new values
        $UpdatedCarList = @(
            Foreach ($CarID in $Return.cars) {
                [Car]::Get($CarID)
            }
        )
        $this.Cars = $UpdatedCarList
        $this.LastVisit = $LastVisit
    }
    #endregion
    #region ToString method
    [String]ToString() {
        return $this.name
    }
    #endregion
    #region Delete method
    [Void]Delete() {
        $BaseURI = 'http://localhost:3000/customers'
        $URIString = "$BaseURI/$($this.ID)"
        Invoke-RestMethod -Uri $URIString -Method Delete
    }
    #endregion
    #endregion
    #region Constructors
    Customer (
        [String]$name,
        [Int]$ID,
        [car[]]$Cars,
        [datetime]$LastVisit
    ) {
        $this.name = $name
        $this.id = $id
        $this.cars = $cars
        $this.lastvisit = $lastvisit
    }
    #endregion
}

enum TicketStatus {
    Open = 1
    Working = 2
    Closed = 3
}

Class ServiceTicket {
    #region Properties
    [Int]$ID
    [car]$Car
    [customer]$Customer
    [datetime]$DateEntered
    [datetime]$DateClosed
    [String]$Issue
    [TicketStatus]$Status
    #endregion
    #region Methods
    #region Get Methods
    Static [ServiceTicket] Get(
        [int]$id
    ) {
        # Step 1: build URI string and body
        $BaseURI = 'http://localhost:3000/servicetickets'
        $URIString = "$baseURI/$ID"
        # Step 2: submit request and capture output
        write-verbose $URIString
        $Return = Invoke-RestMethod -Uri $URIString -Method Get
        # Step 3: instantiate new object and return it
        $returnedCar = [car]::Get($return.car)
        $returnedCustomer = [customer]::Get($return.customer)
        $output = [serviceTicket]::New($return.ID,
            $returnedCar,
            $returnedCustomer,
            $return.dateentered,
            $return.dateclosed,
            $return.issue,
            $return.status)
        return $output
    }
    Static [ServiceTicket[]] Get(
        [car]$Car,
        [customer]$Customer,
        [datetime]$DateEntered,
        [datetime]$DateClosed,
        [string]$Issue,
        [TicketStatus]$Status
    ) {
        # Step 1: build URI string and body
        $BaseURI = 'http://localhost:3000/servicetickets'
        $URIString = "$BaseURI`?"
        If ($Car) {$URIString += "car=$($car.id)&"}
        If ($Customer) {$URIString += "customer=$($customer.id)&"}
        If ($dateentered) {$URIString += "dateentered=$(get-date $DateEntered -uformat "%m/%d/%Y")&"}
        If ($dateclosed) {$URIString += "dateclosed=$(get-date $DateClosed -uformat "%m/%d/%Y")&"}
        If ($Issue) {$URIString += "issue_like=$issue&"}
        If ($status) {$URIString += "status=$status&"}
        $URIString = $URIString.TrimEnd('&')
        # Step 2: submit request and capture output
        write-verbose $URIString
        $Return = Invoke-RestMethod -Uri $URIString -Method Get
        # Step 3: instantiate new object and return it
        $output = @()
        Foreach ($item in $Return) {
            $returnedCar = [car]::Get($item.car)
            $returnedCustomer = [customer]::Get($item.customer)
            $output += [serviceTicket]::New($item.ID,
                $returnedCar,
                $returnedCustomer,
                $item.dateentered,
                $item.dateclosed,
                $item.issue,
                $item.status)
        }
        return $output
    }
    #endregion
    #region Create method
    Static [ServiceTicket]Create(
        [car]$Car,
        [customer]$Customer,
        [string]$Issue
    ) {
        # Step 1: build URI string and body
        $BaseURI = 'http://localhost:3000/servicetickets'
        $newServiceTicketBody = @{
            car         = $car.id
            customer    = $customer.id
            issue       = $issue
            dateentered = $(get-date -uformat "%m/%d/%Y")
            status      = 'open'
        }
        # Step 2: submit request and capture output
        write-verbose $BaseURI
        $Return = Invoke-RestMethod -Uri $BaseURI -Method POST -body $newServiceTicketBody
        # Step 3: instantiate new object and return it
        $carObject = [car]::Get($return.car)
        $customerObject = [customer]::Get($return.customer)
        $output = [serviceticket]::New($return.ID,
            $carObject,
            $customerObject,
            $return.dateentered,
            $return.issue,
            $return.status)
        return $output
    }
    #endregion
    #region Delete method
    [Void]Delete() {
        $BaseURI = 'http://localhost:3000/servicetickets'
        $URIString = "$BaseURI/$($this.ID)"
        Invoke-RestMethod -Uri $URIString -Method Delete
    }
    #endregion
    #region CloseTicket Method
    [void]CloseTicket(
        [TicketStatus]$Status
    ) {
        # Step 1: build URI string and body
        $BaseURI = 'http://localhost:3000/servicetickets'
        $URIString = "$baseURI/$($this.ID)"
        If ($this.Status -ne [ticketstatus]'Closed') {
            $ticketBody = @{
                customer    = $this.Customer
                car         = $this.Car
                issue       = $this.Issue
                status      = 'closed'
                dateentered = $this.DateEntered
                dateclosed  = $(get-date -uformat "%m/%d/%Y")
            }
            # Step 2: submit request and capture output
            write-verbose $URIString
            $return = Invoke-RestMethod -Uri $URIString -Method PUT -Body $($ticketBody | ConvertTo-Json) -ContentType application/JSON
            # Step 3: update object with new values
            $this.status = $return.status
            $this.DateClosed = $return.dateclosed
        }
    }
    #endregion
    #region ToString method
    [String] ToString() {
        $outputString = "$this.issue"
        return $outputString
    }
    #endregion
    #endregion
    #region Constructors
    ServiceTicket (
        [Int]$ID,
        [car]$Car,
        [customer]$Customer,
        [datetime]$DateEntered,
        [datetime]$DateClosed,
        [String]$Issue,
        [TicketStatus]$Status
    ) {
        $this.ID = $ID
        $this.Car = $Car
        $this.Customer = $Customer
        $this.DateEntered = $DateEntered
        $this.DateClosed = $DateClosed
        $this.Issue = $Issue
        $this.Status = $Status
    }
    ServiceTicket (
        [Int]$ID,
        [car]$Car,
        [customer]$Customer,
        [datetime]$DateEntered,
        [String]$Issue,
        [TicketStatus]$Status
    ) {
        $this.ID = $ID
        $this.Car = $Car
        $this.Customer = $Customer
        $this.DateEntered = $DateEntered
        $this.Issue = $Issue
        $this.Status = $Status
    }
    #endregion
}
