enum AMHealthCheckImportance {
    Information = 0
    Warning     = 1
    Error       = 2
}

class AMConstructHealthCheckItem {
    $Object
    $Hint
    AMConstructHealthCheckItem($Object, $Hint) {
        $this.Object = $Object
        $this.Hint   = $Hint
        $this | Add-Member -MemberType NoteProperty -Name "Name" -Value $Object.Name
        $this | Add-Member -MemberType NoteProperty -Name "Path" -Value $Object.Path
        $this | Add-Member -MemberType NoteProperty -Name "ID" -Value $Object.ID
    }
}

class AMHealthCheckItem {
    $Name
    $Value
    AMHealthCheckItem($Name, $Value) {
        $this.Name  = $Name
        $this.Value = $Value
    }
}

class AMHealthCheckResult {
    $Category
    $Function
    $Results
    $ConnectionAlias
    AMHealthCheckResult($Category, $Function, $Results, $ConnectionAlias) {
        $this.Category = $Category
        $this.Function = $Function
        $this.Results = $Results
        $this.ConnectionAlias = $ConnectionAlias
    }
}