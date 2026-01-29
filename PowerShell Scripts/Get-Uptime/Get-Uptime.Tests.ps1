Describe 'Get-ComputerUptime' {
    BeforeAll {
        # Prevent the script's main block from running when dot-sourcing during tests
        $env:SKIP_MAIN = '1'

        # Dot-source the script under test (use PSScriptRoot when tests are executed)
        $scriptToTest = Join-Path $PSScriptRoot 'Get-Uptime.ps1'
        . $scriptToTest
    }

    Context 'When CIM returns valid data' {
        It 'returns a success object with uptime' {
            $fakeOs = New-Object PSObject -Property @{ LastBootUpTime = '20240101000000.000000+000' }
            $fakeOs | Add-Member -MemberType ScriptMethod -Name ConvertToDateTime -Value { param($x) [datetime]::Parse('2024-01-01') } -PassThru

            Mock -CommandName Get-CimInstance -MockWith { $fakeOs }

            $result = Get-ComputerUptime -ComputerName 'srv1'

            $result | Should -Not -BeNullOrEmpty
            $result.ComputerName | Should -Be 'srv1'
            $result.Status | Should -Be 'Success'
        }
    }

    Context 'When CIM throws an error' {
        It 'returns a failed status' {
            Mock -CommandName Get-CimInstance -MockWith { throw 'Simulated error' }

            $result = Get-ComputerUptime -ComputerName 'srv2'

            $result | Should -Not -BeNullOrEmpty
            $result.Status | Should -Match 'Failed:'
        }
    }
}
